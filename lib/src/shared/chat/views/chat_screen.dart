import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/doctor/doctor_main_view.dart';
import '../../../features/patient/views/patient_main_view.dart';
import '../../../router/nav.dart';
import '../../providers/check_internet_connectivity_provider.dart';
import '../chat_services.dart';
import '../models/models_for_patient_and_doctors_for_chatting.dart';
import '../providers/chatting_auth_providers.dart';
import '../widgets/chat_screen_appbar.dart';
import '../widgets/chat_screen_body.dart';

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
  final ChatService _chatService = ChatService();
  AppUser? _currentUser;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleTyping);
    _currentUser = ref.read(currentUserProvider).value;
  }

  void _handleTyping() async {
    final user = ref.read(currentUserProvider).value;
    final isInternet = await ref.read(checkInternetConnectionProvider.future);
    final isTyping = _messageController.text.isNotEmpty;

    await _chatService.handleTyping(
      user: user,
      otherUserId: widget.otherUserId,
      isTyping: isTyping,
      typingTimer: _typingTimer,
      isInternet: isInternet,
    );
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (!widget.isPatient) {
            ref.read(doctorBottomNavIndexProvider.notifier).state = 3;
          } else {
            ref.read(bottomNavIndexProvider.notifier).state = 3;
          }
          if (widget.fromDoctorDetails) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            print('Popped until root, bottomNavIndex set to 3');
          } else {
            print('Normal pop to ChatView, bottomNavIndex remains 3');
            AppNavigation.pop();
          }
        }
      },
      child: Scaffold(
        appBar: ChatScreenAppBar(
          otherUserId: widget.otherUserId,
          otherUserName: widget.otherUserName,
          fromDoctorDetails: widget.fromDoctorDetails,
          isPatient: widget.isPatient,
        ),
        body: ChatScreenBody(
          otherUserId: widget.otherUserId,
          user: user,
          otherUserName:widget.otherUserName,
          messageController: _messageController,
          scrollController: _scrollController,
          chatService: _chatService,
          isPatient: widget.isPatient,
        ),
      ),
    );
  }
}