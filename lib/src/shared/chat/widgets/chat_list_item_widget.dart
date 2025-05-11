import 'package:cached_network_image/cached_network_image.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../const/app_fonts.dart';
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
    final unseenCount = ref.watch(unseenMessagesProvider(chatId));
    
    return ListTile(
      leading: profile.when(
        data: (data) => CircleAvatar(
          radius: 20,
          child: CachedNetworkImage(
            imageUrl: data['profileImageUrl']?.isNotEmpty == true
                ? data['profileImageUrl']
                : '',
            placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.gradientGreen,),
            errorWidget: (context, url, error) => Text(
              otherUserName.isNotEmpty ? otherUserName[0] : '?',
              style: const TextStyle(fontSize: 20),
            ),
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundImage: imageProvider,
            ),
          ),
        ),
        loading: () => const CircleAvatar(child: CircularProgressIndicator(color: AppColors.gradientGreen,)),
        error: (error, _) => CircleAvatar(
          child: Text(
            otherUserName.isNotEmpty ? otherUserName[0] : '?',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(otherUserName.isNotEmpty ? otherUserName : 'Unknown User',style: const TextStyle(
        fontFamily: AppFonts.rubik,
         fontSize: 18,
        fontWeight: FontWeight.w400,
      ),),
      subtitle: Text(
        lastMessage.isNotEmpty
            ? (isCurrentUserSender ? 'You: $lastMessage' : lastMessage)
            : 'No messages',
        style: TextStyle(
          fontSize: FontSizes(context).size18,
          fontFamily: AppFonts.rubik,
          fontWeight: FontWeight.w400,
          color: unseenCount.when(
            data: (count) => count > 0 ? AppColors.gradientGreen : Colors.grey,
            loading: () => Colors.grey,
            error: (error, _) => Colors.grey,
          ),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formatTimestamp(timestamp)),
          unseenCount.when(
            data: (count) => count > 0
                ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.gradientGreen,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}