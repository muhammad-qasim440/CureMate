import 'dart:async';

import 'package:curemate/src/router/nav.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/flutter_cache_manager.dart';
import '../../../features/patient/views/patient_main_view.dart';
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
    if (_currentUser != null) {
      _initChat(_currentUser!);
    }
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
      await _database.child('Chats/${user.uid}/${widget.otherUserId}').update({
        'chatId': chatId,
        otherUserRole: widget.otherUserName,
        'lastMessage': '',
        'timestamp': ServerValue.timestamp,
        'typing': false,
      });
      // Initialize for other user
      await _database.child('Chats/${widget.otherUserId}/${user.uid}').update({
        'chatId': chatId,
        currentUserRole: user.fullName,
        'lastMessage': '',
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
      // Send message
      await _database.child('Messages/$chatId/$messageId').set(message);
      // Update current user's chat
      await _database
          .child('Chats/$currentUserId/${widget.otherUserId}')
          .update({
            'chatId': chatId, // Ensure chatId is included
            'lastMessage': _messageController.text.trim(),
            'timestamp': ServerValue.timestamp,
          });
      // Update other user's chat
      await _database
          .child('Chats/${widget.otherUserId}/$currentUserId')
          .update({
            'chatId': chatId, // Ensure chatId is included
            'lastMessage': _messageController.text.trim(),
            'timestamp': ServerValue.timestamp,
          });

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
      // Cancel any existing timer
      _typingTimer?.cancel();

      // Update typing status
      _database
          .child('Chats/${user.uid}/${widget.otherUserId}/typing')
          .set(isTyping);
      print('Set typing=$isTyping for Chats/${user.uid}/${widget.otherUserId}');

      if (isTyping) {
        // Start a timer to set typing to false if no typing for 2 seconds
        _typingTimer = Timer(const Duration(seconds: 2), () {
          _database
              .child('Chats/${user.uid}/${widget.otherUserId}/typing')
              .set(false);
          print(
            'Typing stopped, set typing=false for Chats/${user.uid}/${widget.otherUserId}',
          );
        });
      }

      // Reset typing to false when user disconnects
      _database
          .child('Chats/${user.uid}/${widget.otherUserId}/typing')
          .onDisconnect()
          .set(false);
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }

  void _markAsSeen(String messageId, String chatId) {
    _database.child('Messages/$chatId/$messageId').update({'seen': true});
  }
  Future<bool> _onPopScope() async {
    print('onPopScope called: fromDoctorDetails=${widget.fromDoctorDetails}');
    // Set bottomNavIndexProvider to 3 (Chats tab)
    ref.read(bottomNavIndexProvider.notifier).state = 3;

    if (widget.fromDoctorDetails) {
      // Pop until the root (BottomNavScreen)
      Navigator.of(context).popUntil((route) => route.isFirst);
      print('Popped until root, bottomNavIndex set to 3');
      return false; // Prevent default pop
    } else {
      // Normal pop to return to ChatView
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              AppNavigation.pop();
              ref.read(bottomNavIndexProvider.notifier).state = 3;
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
                              style: const TextStyle(fontSize: 20),
                            ),
                        imageBuilder:
                            (context, imageProvider) => CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
                            ),
                      ),
                    ),
                loading:
                    () => const CircleAvatar(child: CircularProgressIndicator()),
                error:
                    (error, _) => CircleAvatar(
                      child: Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0]
                            : '?',
                        style: const TextStyle(fontSize: 20),
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
                    style: const TextStyle(fontSize: 16),
                  ),
                  status.when(
                    data: (data) {
                      final ping = data['ping'] as int?;
                      final now = DateTime.now().millisecondsSinceEpoch;
                      final isOnline = ping != null && (now - ping < 15000);
                      return Text(
                        isOnline
                            ? 'Online'
                            : ping != null
                            ? formatLastSeen(ping)
                            : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.grey,
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
              children: [
                Expanded(
                  child: messages.when(
                    data:
                        (msgs) => ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: msgs.length,
                          itemBuilder: (context, index) {
                            final msg = msgs[index];
                            final isMe = msg['senderId'] == user.uid;
                            if (!msg['seen'] && !isMe)
                              _markAsSeen(msg['messageId'], chatId);
                            return FadeInUp(
                              duration: const Duration(milliseconds: 300),
                              child: MessageBubble(
                                text: msg['text'] ?? '',
                                isMe: isMe,
                                timestamp: msg['timestamp'] ?? 0,
                                seen: msg['seen'] ?? false,
                              ),
                            );
                          },
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                  ),
                ),
                isTyping.when(
                  data:
                      (typing) =>
                          typing
                              ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FadeIn(
                                  child: Text(
                                    '${widget.otherUserName} is typing...',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (error, _) => const SizedBox.shrink(),
                ),
                otherUserSettings.when(
                  data:
                      (settings) => currentUserSettings.when(
                        data: (currentSettings) {
                          final canChat =
                              settings['allowChat'] == true &&
                              currentSettings['allowChat'] == true;
                          return canChat
                              ? ChatInput(
                                controller: _messageController,
                                onSend: () => _sendMessage(user.uid),
                              )
                              : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Chatting is disabled by one of the users.',
                                  style: TextStyle(color: Colors.red),
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
          ],
        ),
      ),
    );
  }
}
