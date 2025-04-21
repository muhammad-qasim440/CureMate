import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

        // Fetch otherUserName
        String otherUserName = chat['doctorName'] ?? chat['patientName'] ?? '';
        if (otherUserName.isEmpty) {
          print('Warning: No doctorName or patientName for otherUserId: $otherUserId');
          try {
            // Check if current user is a patient or doctor
            final isPatient = user.userType == 'Patient';
            final targetNode = isPatient ? 'Doctors' : 'Patients';
            final snapshot = await database.child('$targetNode/$otherUserId').get();
            if (snapshot.exists) {
              otherUserName = (snapshot.value as Map)['fullName'] ?? 'Unknown';
            } else {
              otherUserName = 'Unknown';
              print('No data found in $targetNode for otherUserId: $otherUserId');
            }
          } catch (e) {
            print('Error fetching name for otherUserId: $otherUserId, error: $e');
            otherUserName = 'Unknown';
          }
        }

        chats.add({
          'otherUserId': otherUserId,
          'otherUserName': otherUserName.trim(), // Remove trailing spaces
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

String _generateChatId(String userId1, String userId2) {
  final ids = [userId1, userId2]..sort();
  return '${ids[0]}_${ids[1]}';
}

// Chat messages provider: Messages for a specific chat
final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) {
  final database = FirebaseDatabase.instance.ref('Messages/$chatId');
  return database.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return [];
    return data.entries.map((e) {
      return {
        'messageId': e.key as String,
        ...Map<String, dynamic>.from(e.value as Map<dynamic, dynamic>),
      };
    }).toList()
      ..sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
  });
});

// Typing indicator provider
final typingIndicatorProvider = StreamProvider.family<bool, String>((ref, chatId) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(false);
  final otherUserId = chatId.split('_').first == user.uid
      ? chatId.split('_').last
      : chatId.split('_').first;
  final database = FirebaseDatabase.instance
      .ref('Chats/$otherUserId/${user.uid}/typing');
  return database.onValue.map((event) {
    final value = event.snapshot.value;
    return value is bool ? value : false;
  });
});

// Chat settings provider
final chatSettingsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final database = FirebaseDatabase.instance.ref('Users/$userId/settings');
  return database.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    return data != null ? Map<String, dynamic>.from(data) : {'allowChat': true};
  });
});

// Last seen and online status provider
final userStatusProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final database = FirebaseDatabase.instance.ref('Users/$userId/status');
  print('userStatusProvider: Listening to Users/$userId/status');
  return database.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
    print('userStatusProvider: Data for $userId: $data');
    return {
      'isOnline': data['isOnline'] ?? false,
      'lastSeen': data['lastSeen'] ?? 0,
    };
  });
});

// Other user profile provider (for profileImageUrl and fullName)
final otherUserProfileProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final database = FirebaseDatabase.instance.ref();
  return database.child('Doctors/$userId').onValue.asyncMap((doctorEvent) async {
    final doctorData = doctorEvent.snapshot.value as Map<dynamic, dynamic>?;
    if (doctorData != null) {
      return {
        'profileImageUrl': doctorData['profileImageUrl'] ?? '',
        'fullName': doctorData['fullName'] ?? '',
        'userType': 'Doctor',
      };
    }
    final patientData = await database.child('Patients/$userId').once();
    final patientMap = patientData.snapshot.value as Map<dynamic, dynamic>?;
    return {
      'profileImageUrl': patientMap?['profileImageUrl'] ?? '',
      'fullName': patientMap?['fullName'] ?? '',
      'userType': 'Patient',
    };
  });
});