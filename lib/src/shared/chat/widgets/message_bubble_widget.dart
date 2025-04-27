import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final int timestamp;
  final bool seen;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.seen,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ConstrainedBox(
          constraints:  BoxConstraints(
            maxWidth: ScreenUtil.scaleWidth(context, 300),
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isMe ? AppColors.gradientGreen : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  textAlign: TextAlign.start,
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontFamily: AppFonts.rubik,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(timestamp),
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? AppColors.black : AppColors.gradientGreen,
                        fontFamily: AppFonts.rubik,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 2),
                      Icon(
                        seen ? Icons.done_all : Icons.done,
                        size: 16,
                        color: seen ? AppColors.gradientBlue : AppColors.gradientWhite,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}