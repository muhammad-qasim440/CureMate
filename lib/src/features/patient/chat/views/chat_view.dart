import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/providers/chatting_auth_providers.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../shared/chat/views/chat_screen.dart';
import '../../../../shared/chat/widgets/chat_list_item_widget.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../shared/doctors_searching/widgets/search_bar_widget.dart';
import '../providers/patients_chat_with_doctors_providers.dart';
import '../widgets/patient_chat_view_header.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key});

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
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
                        print(
                          'ChatListItem $index: otherUserId=${chat['otherUserId']}, otherUserName=$otherUserName',
                        );
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
                    const Center(child: CircularProgressIndicator()),
                    error: (error, _) =>
                        Center(child: Text('Error: $error')),
                  ),
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
                      provider: searchQueryForPatientChatWithDoctorProvider,
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