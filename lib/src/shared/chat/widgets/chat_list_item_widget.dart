import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../providers/chatting_auth_providers.dart';
import '../providers/chatting_providers.dart';

class ChatListItem extends ConsumerWidget {
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final int timestamp;
  final String chatId;
  final String? senderId;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.timestamp,
    required this.chatId,
    required this.senderId,
    required this.onTap,
  });

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return '';
    final now = DateTime.now();
    final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);

    if (messageDay == today) {
      return DateFormat('hh:mm a').format(messageDate);
    } else if (messageDay == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(messageDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(otherUserProfileProvider(otherUserId));
    final currentUser = ref.watch(currentUserProvider).value;
    final isCurrentUserSender = senderId != null && currentUser != null && senderId == currentUser.uid;

    return ListTile(
      leading: profile.when(
        data: (data) => CircleAvatar(
          radius: 20,
          child: CachedNetworkImage(
            imageUrl: data['profileImageUrl']?.isNotEmpty == true
                ? data['profileImageUrl']
                : '',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Text(
              otherUserName.isNotEmpty ? otherUserName[0] : '?',
              style: const TextStyle(fontSize: 20),
            ),
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundImage: imageProvider,
            ),
          ),
        ),
        loading: () => const CircleAvatar(child: CircularProgressIndicator()),
        error: (error, _) => CircleAvatar(
          child: Text(
            otherUserName.isNotEmpty ? otherUserName[0] : '?',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(otherUserName.isNotEmpty ? otherUserName : 'Unknown User'),
      subtitle: Text(
        lastMessage.isNotEmpty
            ? (isCurrentUserSender ? 'You: $lastMessage' : lastMessage)
            : 'No messages',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(_formatTimestamp(timestamp)),
      onTap: onTap,
    );
  }
}