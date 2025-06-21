// Widget for the body content
import 'package:animate_do/animate_do.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../providers/check_internet_connectivity_provider.dart';
import '../../widgets/lower_background_effects_widgets.dart';
import '../chat_services.dart';
import '../models/models_for_patient_and_doctors_for_chatting.dart';
import '../providers/chatting_providers.dart';
import 'chat_input_widget.dart';
import 'message_bubble_widget.dart';

class ChatScreenBody extends ConsumerWidget {
  final String otherUserId;
  final AppUser user;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final ChatService chatService;
  final String otherUserName;
  final bool isPatient;
  const ChatScreenBody({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.user,
    required this.messageController,
    required this.scrollController,
    required this.chatService,
    required this.isPatient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatId = chatService.generateChatId(user.uid, otherUserId);
    final messages = ref.watch(chatMessagesProvider(chatId));
    final isTyping = ref.watch(typingIndicatorProvider(chatId));
    final otherUserSettings = ref.watch(chatSettingsProvider(otherUserId));
    final currentUserSettings = ref.watch(chatSettingsProvider(user.uid));
    final isInternet = ref.watch(checkInternetConnectionProvider).value ?? false;

    return Stack(
      children: [
        const LowerBackgroundEffectsWidgets(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: messages.when(
                data: (msgs) => ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    final isMe = msg['senderId'] == user.uid;
                    return VisibilityDetector(
                      key: Key(msg['messageId']),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction > 0.5 && !isMe && !msg['seen']) {
                          chatService.markAsSeen(
                            messageId: msg['messageId'],
                            chatId: chatId,
                            isInternet: isInternet,
                          );
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
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gradientGreen,)),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
            messages.when(
              data: (msgs) => chatService.isLastMessageFromCurrentUser(
                messages: msgs,
                currentUserId: user.uid,
              )
                  ? 20.height
                  : 40.height,
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
            ),
            otherUserSettings.when(
              data: (settings) => currentUserSettings.when(
                data: (currentSettings) {
                  final chatDisabledMessage = chatService.getChatDisabledMessage(
                    currentSettings: currentSettings,
                    otherSettings: settings,
                    user: user,
                    isPatient:isPatient,
                  );
                  return chatDisabledMessage.isEmpty
                      ? Container(
                    margin: EdgeInsets.zero,
                    child: ChatInput(
                      controller: messageController,
                      onSend: () => chatService.sendMessage(
                        isPatient:isPatient,
                        currentUserId: user.uid,
                        otherUserId: otherUserId,
                        otherUserName:otherUserName,
                        messageController: messageController,
                        scrollController: scrollController,
                        context: context,
                        ref: ref,
                        currentUser: user,
                      ),
                    ),
                  )
                      : Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      chatDisabledMessage,
                      style: TextStyle(color: AppColors.black,
                      fontFamily: AppFonts.rubik,fontSize: FontSizes(context).size14,
                      fontWeight: FontWeight.w500),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
              ),
              loading: () =>const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
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
    );
  }
}