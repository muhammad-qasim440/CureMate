import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/providers/chatting_auth_providers.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../shared/chat/views/chat_screen.dart';
import '../../../../shared/chat/widgets/chat_list_item_widget.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../shared/chat/providers/chat_list_search_query_provider.dart';
import '../../../../theme/app_colors.dart';
import '../widgets/patient_chat_view_header.dart';

class PatientChatView extends ConsumerStatefulWidget {
  const PatientChatView({super.key});

  @override
  ConsumerState<PatientChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<PatientChatView> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final filteredChats = ref.watch(filteredChatListProvider);

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              140.height,
              Expanded(
                child: user.when(
                  data: (appUser) => appUser == null
                      ? const Center(
                    child: Text('Please log in to view chats.'),
                  )
                      : ref.watch(chatListProvider).when(
                    data: (_) => filteredChats.isEmpty
                        ? const Center(
                      child: Text(
                        'No chats found. Start a conversation!',
                      ),
                    )
                        : ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final otherUserName =
                            chat['otherUserName']?.trim() ??
                                'Unknown';

                        return ChatListItem(
                          otherUserId: chat['otherUserId'] ?? '',
                          otherUserName: otherUserName,
                          lastMessage: chat['lastMessage'] ?? '',
                          senderId: chat['senderId'] ?? '',
                          timestamp: chat['timestamp'] ?? 0,
                          chatId: chat['chatId'] ?? '',
                          onTap: () {
                            if (chat['otherUserId'] != null &&
                                otherUserName != 'Unknown') {
                              AppNavigation.push(
                                ChatScreen(
                                  otherUserId:
                                  chat['otherUserId'],
                                  otherUserName: otherUserName,
                                  isPatient:
                                  appUser.userType == 'Patient',
                                  fromDoctorDetails: false,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Invalid chat data.',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    loading: () =>
                     const Center(child: CircularProgressIndicator(color:AppColors.gradientGreen)),
                    error: (error, _) =>
                        Center(child: Text('Error: $error')),
                  ),
                  loading: () =>
                  const Center(child: CircularProgressIndicator(color:AppColors.gradientGreen)),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const PatientsChatViewHeaderWidget(),
                Transform.translate(
                  offset: const Offset(0, -35),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 25,
                    ),
                    child: SearchBarWidget(
                      provider: chatListSearchQueryProviderProvider,
                      applyFocusNode: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}