import 'package:intl/intl.dart';

String formatLastSeen(int timestamp) {
  final lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final difference = now.difference(lastSeen);

  if (difference.inSeconds < 60) {
    return 'Last seen now';
  } else if (difference.inMinutes < 60) {
    return 'Last seen ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else if (difference.inHours < 24 &&
      now.day == lastSeen.day &&
      now.month == lastSeen.month &&
      now.year == lastSeen.year) {
    return 'Last seen ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inDays == 1 ||
      (now.day - lastSeen.day == 1 &&
          now.month == lastSeen.month &&
          now.year == lastSeen.year)) {
    return 'Last seen yesterday';
  } else if (difference.inDays < 7) {
    return 'Last seen ${DateFormat('EEEE').format(lastSeen)}'; // Day name
  } else if (now.year == lastSeen.year) {
    return 'Last seen ${DateFormat('MMM d').format(lastSeen)}';
  } else {
    return 'Last seen ${DateFormat('MMM d, yyyy').format(lastSeen)}';
  }
}
