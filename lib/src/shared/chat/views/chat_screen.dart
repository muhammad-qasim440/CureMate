import 'dart:async';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/doctor/doctor_main_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../const/app_fonts.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/flutter_cache_manager.dart';
import '../../../features/patient/views/patient_main_view.dart';
import '../../../utils/screen_utils.dart';
import '../../widgets/lower_background_effects_widgets.dart';
import '../models/models_for_patient_and_doctors_for_chatting.dart';
import '../providers/chatting_auth_providers.dart';
import '../providers/chatting_providers.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/message_bubble_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final bool isPatient;
  final bool fromDoctorDetails;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.isPatient,
    this.fromDoctorDetails = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  AppUser? _currentUser;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleTyping);
    _currentUser = ref.read(currentUserProvider).value;
  }

  Future<void> _initChat(AppUser user) async {
    final chatId = _generateChatId(user.uid, widget.otherUserId);
    final otherUserRole = widget.isPatient ? 'doctorName' : 'patientName';
    final currentUserRole = widget.isPatient ? 'patientName' : 'doctorName';

    if (widget.otherUserName.isEmpty) {
      print(
        'Error: otherUserName is empty for otherUserId: ${widget.otherUserId}',
      );
      return;
    }

    try {
      // Initialize for current user
      await _database.child('Chats/${user.uid}/${widget.otherUserId}').set({
        'chatId': chatId,
        otherUserRole: widget.otherUserName,
        'lastMessage': _messageController.text.trim(),
        'timestamp': ServerValue.timestamp,
        'typing': false,
      });
      // Initialize for other user
      await _database.child('Chats/${widget.otherUserId}/${user.uid}').set({
        'chatId': chatId,
        currentUserRole: user.fullName,
        'lastMessage': _messageController.text.trim(),
        'timestamp': ServerValue.timestamp,
        'typing': false,
      });
      print('Chat initialized for chatId: $chatId');
    } catch (e) {
      print('Failed to initialize chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize chat: $e')),
        );
      }
    }
  }

  void _sendMessage(String currentUserId) async {
    if (_messageController.text.trim().isEmpty || widget.otherUserId.isEmpty)
      return;
    final chatId = _generateChatId(currentUserId, widget.otherUserId);
    final messageId = _database.child('Messages/$chatId').push().key;
    if (messageId == null) return;

    final message = {
      'senderId': currentUserId,
      'text': _messageController.text.trim(),
      'timestamp': ServerValue.timestamp,
      'seen': false,
    };

    try {
      // Check if chat exists for the current user
      final chatSnapshot =
          await _database
              .child('Chats/$currentUserId/${widget.otherUserId}')
              .get();
      if (!chatSnapshot.exists) {
        // Initialize chat if it doesn't exist
        await _initChat(_currentUser!);
      } else {
        // Update existing chat
        await _database
            .child('Chats/$currentUserId/${widget.otherUserId}')
            .update({
              'lastMessage': _messageController.text.trim(),
              'timestamp': ServerValue.timestamp,
            });
        await _database
            .child('Chats/${widget.otherUserId}/$currentUserId')
            .update({
              'lastMessage': _messageController.text.trim(),
              'timestamp': ServerValue.timestamp,
            });
      }

      // Send message
      await _database.child('Messages/$chatId/$messageId').set(message);

      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Failed to send message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  String _generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void _handleTyping() {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final isTyping = _messageController.text.isNotEmpty;

    try {
      _typingTimer?.cancel();
      _database
          .child('Chats/${user.uid}/${widget.otherUserId}/typing')
          .set(isTyping)
          .catchError((e) {
            print('Error updating typing status: $e');
          });

      if (isTyping) {
        _typingTimer = Timer(const Duration(seconds: 2), () {
          _database
              .child('Chats/${user.uid}/${widget.otherUserId}/typing')
              .set(false)
              .catchError((e) {
                print('Error stopping typing status: $e');
              });
        });
      }
      _database
          .child('Chats/${user.uid}/${widget.otherUserId}/typing')
          .onDisconnect()
          .set(false);
    } catch (e) {
      print('Error handling typing: $e');
    }
  }

  void _markAsSeen(String messageId, String chatId) {
    _database
        .child('Messages/$chatId/$messageId')
        .update({'seen': true})
        .catchError((e) {
          print('Error marking message as seen: $e');
        });
  }

  Future<bool> _onPopScope() async {
    print('onPopScope called: fromDoctorDetails=${widget.fromDoctorDetails}');
    if (!widget.isPatient) {
      ref.read(doctorBottomNavIndexProvider.notifier).state = 3;
    } else {
      ref.read(bottomNavIndexProvider.notifier).state = 3;
    }
    if (widget.fromDoctorDetails) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      print('Popped until root, bottomNavIndex set to 3');
      return false;
    } else {
      print('Normal pop to ChatView, bottomNavIndex remains 3');
      return true;
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleTyping);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  String _getChatDisabledMessage(
    Map<String, dynamic> currentSettings,
    Map<String, dynamic> otherSettings,
    AppUser user,
  ) {
    final currentAllowChat = currentSettings['allowChat'] == true;
    final otherAllowChat = otherSettings['allowChat'] == true;
    if (currentAllowChat && otherAllowChat) {
      return ''; // Chat is enabled
    }
    final otherUserRole = widget.isPatient ? 'doctor' : 'patient';
    if (!currentAllowChat && !otherAllowChat) {
      return 'Chat disabled by both sides.';
    } else if (!currentAllowChat) {
      return 'Chat is disabled by you.';
    } else {
      return 'Chat disabled by $otherUserRole.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to chat.')),
      );
    }
    final chatId = _generateChatId(user.uid, widget.otherUserId);
    final messages = ref.watch(chatMessagesProvider(chatId));
    final isTyping = ref.watch(typingIndicatorProvider(chatId));
    final otherUserSettings = ref.watch(
      chatSettingsProvider(widget.otherUserId),
    );
    final currentUserSettings = ref.watch(chatSettingsProvider(user.uid));
    final otherUserProfile = ref.watch(
      otherUserProfileProvider(widget.otherUserId),
    );
    final status = ref.watch(userStatusProvider(widget.otherUserId));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _onPopScope();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.gradientGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.fromDoctorDetails && widget.isPatient) {
                ref.read(bottomNavIndexProvider.notifier).state = 3;
                Navigator.of(context).popUntil((route) => route.isFirst);
                print('Popped until root, bottomNavIndex set to 3');
              } else {
                AppNavigation.pop();
              }
            },
          ),
          title: Row(
            children: [
              otherUserProfile.when(
                data:
                    (profile) => CircleAvatar(
                      radius: 20,
                      child: CachedNetworkImage(
                        imageUrl:
                            profile['profileImageUrl']?.isNotEmpty == true
                                ? profile['profileImageUrl']
                                : '',
                        cacheManager: CustomCacheManager.instance,
                        placeholder:
                            (context, url) => const CircularProgressIndicator(),
                        errorWidget:
                            (context, url, error) => Text(
                              widget.otherUserName.isNotEmpty
                                  ? widget.otherUserName[0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: AppFonts.rubik,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        imageBuilder:
                            (context, imageProvider) => CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
                            ),
                      ),
                    ),
                loading:
                    () =>
                        const CircleAvatar(child: CircularProgressIndicator()),
                error:
                    (error, _) => CircleAvatar(
                      child: Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0]
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,

                        ),
                      ),
                    ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName.isNotEmpty
                        ? widget.otherUserName
                        : 'Unknown User',
                    style: const TextStyle(fontSize: 16,       fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w600,),
                  ),
                  status.when(
                    data: (data) {
                      final ping = data['ping'] as int?;
                      final now = DateTime.now().millisecondsSinceEpoch;
                      final isOnline =
                          ping != null && (now - ping < 15000); // 15s threshold
                      return Text(
                        isOnline
                            ? 'Online'
                            : ping != null
                            ? formatLastSeen(ping)
                            : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gradientWhite,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                    loading: () => const Text('...'),
                    error: (error, _) => const Text('Offline'),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            const LowerBackgroundEffectsWidgets(),
            Column(
              mainAxisSize: MainAxisSize.min, // Minimize vertical space
              children: [
                Expanded(
                  child: messages.when(
                    data: (msgs) => ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: msgs.length,
                      itemBuilder: (context, index) {
                        final msg = msgs[index];
                        final isMe = msg['senderId'] == user.uid;
                        return VisibilityDetector(
                          key: Key(msg['messageId']),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0.5 && !isMe && !msg['seen']) {
                              _markAsSeen(msg['messageId'], chatId);
                            }
                          },
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            child: MessageBubble(
                              text: msg['text'] ?? '',
                              isMe: isMe,
                              timestamp: msg['timestamp'] ?? 0,
                              seen: msg['seen'] ?? false,
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                  ),
                ),
                20.height,
                otherUserSettings.when(
                  data: (settings) => currentUserSettings.when(
                    data: (currentSettings) {
                      final chatDisabledMessage =
                      _getChatDisabledMessage(currentSettings, settings, user);
                      return chatDisabledMessage.isEmpty
                          ? Container(
                        margin: EdgeInsets.zero, // No margin to eliminate gap
                        child: ChatInput(
                          controller: _messageController,
                          onSend: () => _sendMessage(user.uid),
                        ),
                      )
                          : Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0), // Minimal margin
                        child: Text(
                          chatDisabledMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text('Error: $error'),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('Error: $error'),
                ),
              ],
            ),
            Positioned(
              bottom: ScreenUtil.scaleHeight(context, 40),
              left: ScreenUtil.scaleWidth(context, -15),
              child: isTyping.when(
                data: (typing) => typing
                    ? Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeIn(
                        child: SizedBox(
                          height: ScreenUtil.scaleHeight(context, 100),
                          child: Lottie.asset(
                            'assets/animations/typing.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
