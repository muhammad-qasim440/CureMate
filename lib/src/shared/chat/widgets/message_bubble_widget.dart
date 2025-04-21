// Reusable Message Bubble Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                text,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(timestamp)),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        seen ? Icons.done_all : Icons.done,
                        size: 14,
                        color: seen ? Colors.blue : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}