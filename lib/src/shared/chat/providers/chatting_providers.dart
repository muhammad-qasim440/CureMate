import 'package:curemate/core/utils/debug_print.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_last_seen_time.dart';
import 'chatting_auth_providers.dart';


final chatListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final database = FirebaseDatabase.instance.ref();
  return database.child('Chats/${user.uid}').onValue.asyncMap((event) async {
    final chats = <Map<String, dynamic>>[];
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      final chatData = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in chatData.entries) {
        final otherUserId = entry.key;
        final chat = entry.value as Map<dynamic, dynamic>;
        final chatId = chat['chatId'] as String;

        // Fetch last message
        final messagesSnapshot = await database
            .child('Messages/$chatId')
            .orderByChild('timestamp')
            .limitToLast(1)
            .once();
        String? senderId;
        String lastMessage = chat['lastMessage'] ?? '';
        int timestamp = chat['timestamp'] ?? 0;

        if (messagesSnapshot.snapshot.exists) {
          final messages = messagesSnapshot.snapshot.value as Map<dynamic, dynamic>;
          final lastMessageData = messages.values.first;
          senderId = lastMessageData['senderId'] as String?;
          lastMessage = lastMessageData['text'] as String? ?? '';
          timestamp = lastMessageData['timestamp'] as int? ?? 0;
        }

        // Determine otherUserName based on user type
        String otherUserName;
        final isPatient = user.userType == 'Patient';
        if (isPatient) {
          otherUserName = chat['doctorName']?.trim() ?? '';
        } else {
          otherUserName = chat['patientName']?.trim() ?? '';
        }

        // Fetch from database if name is empty or invalid
        if (otherUserName.isEmpty || otherUserName == otherUserId) {
          logDebug('Fetching name for otherUserId: $otherUserId');
          try {
            final targetNode = isPatient ? 'Doctors' : 'Patients';
            final snapshot = await database.child('$targetNode/$otherUserId').get();
            if (snapshot.exists) {
              otherUserName = (snapshot.value as Map)['fullName']?.trim() ?? 'Unknown';
            } else {
              otherUserName = 'Unknown';
              logDebug('No data found in $targetNode for otherUserId: $otherUserId');
            }
          } catch (e) {
            logDebug('Error fetching name for otherUserId: $otherUserId, error: $e');
            otherUserName = 'Unknown';
          }
        }

        chats.add({
          'otherUserId': otherUserId,
          'otherUserName': otherUserName.trim(),
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'chatId': chatId,
          'senderId': senderId,
        });
      }

      chats.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    }

    return chats;
  });
});


final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) {
  return FirebaseDatabase.instance.ref().child('Messages/$chatId').onValue.map((event) {
    final messages = <Map<String, dynamic>>[];
    if (event.snapshot.value != null) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        messages.add({
          'messageId': key,
          ...Map<String, dynamic>.from(value),
        });
      });
      messages.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    }
    return messages;
  });
});

final typingIndicatorProvider = StreamProvider.family<bool, String>((ref, chatId) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(false);

  final parts = chatId.split('_');
  final otherUserId = parts.first == user.uid ? parts.last : parts.first;

  return FirebaseDatabase.instance
      .ref()
      .child('Chats/$otherUserId/${user.uid}/typing')
      .onValue
      .map((event) => event.snapshot.value as bool? ?? false);
});


final chatSettingsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, uid) {
  return FirebaseDatabase.instance
      .ref()
      .child('Users/$uid/settings')
      .onValue
      .map((event) => Map<String, dynamic>.from(event.snapshot.value as Map? ?? {'allowChat': true}));
});

final otherUserProfileProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, uid) {
  return FirebaseDatabase.instance.ref().child('Users/$uid').onValue.map((event) =>
     Map<String, dynamic>.from(event.snapshot.value as Map? ?? {}));
});

final formattedLastSeenProvider = StreamProvider.family<String, String>((ref, userId) {
  final userRef = FirebaseDatabase.instance.ref().child('Users/$userId/status');
  return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
    final snapshot = await userRef.get();
    final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});

    final ping = data['ping'] as int?;
    if (ping == null) return 'Offline';

    final now = DateTime.now().millisecondsSinceEpoch;
    final isOnline = now - ping < 15000;

    return isOnline ? 'Online' : formatLastSeen(ping);
  });
});
