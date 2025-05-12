import 'dart:async';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_last_seen_time.dart';
import '../../../features/authentication/signin/providers/auth_provider.dart';
import 'chatting_auth_providers.dart';

final chatListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final authService = ref.read(authProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    yield [];
    return;
  }

  final database = FirebaseDatabase.instance.ref();
  final subscription = database.child('Chats/${user.uid}').onValue.listen((event) async {
    final chats = <Map<String, dynamic>>[];
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      final chatData = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in chatData.entries) {
        final otherUserId = entry.key;
        final chat = entry.value as Map<dynamic, dynamic>;
        final chatId = chat['chatId'] as String;

        String? senderId;
        String lastMessage = '';
        int timestamp = 0;

        try {
          final messagesSnapshot = await database
              .child('Messages/$chatId')
              .orderByChild('timestamp')
              .limitToLast(1)
              .once();
          if (messagesSnapshot.snapshot.exists) {
            final messageData = (messagesSnapshot.snapshot.value as Map<dynamic, dynamic>).values.first as Map<dynamic, dynamic>;
            senderId = messageData['senderId'] as String?;
            lastMessage = messageData['text'] as String? ?? '';
            timestamp = messageData['timestamp'] as int? ?? 0;
            logDebug('chatListProvider: Fetched lastMessage="$lastMessage", timestamp=$timestamp, senderId=$senderId');
          } else {
            lastMessage = chat['lastMessage']?.toString() ?? '';
            timestamp = chat['timestamp'] as int? ?? 0;
            logDebug('chatListProvider: Fallback lastMessage="$lastMessage", timestamp=$timestamp');
          }
        } catch (e) {
          logDebug('chatListProvider: Error fetching messages for chatId=$chatId, error: $e');
          lastMessage = chat['lastMessage']?.toString() ?? '';
          timestamp = chat['timestamp'] as int? ?? 0;
        }

        String otherUserName;
        final isPatient = user.userType == 'Patient';
        if (isPatient) {
          otherUserName = chat['doctorName']?.trim() ?? '';
        } else {
          otherUserName = chat['patientName']?.trim() ?? '';
        }

        if (otherUserName.isEmpty || otherUserName == otherUserId) {
          logDebug('chatListProvider: Fetching name for otherUserId: $otherUserId');
          try {
            final targetNode = isPatient ? 'Doctors' : 'Patients';
            final snapshot = await database.child('$targetNode/$otherUserId').get();
            if (snapshot.exists) {
              otherUserName = (snapshot.value as Map)['fullName']?.trim() ?? 'Unknown';
            } else {
              otherUserName = 'Unknown';
              logDebug('chatListProvider: No data found in $targetNode for otherUserId: $otherUserId');
            }
          } catch (e) {
            logDebug('chatListProvider: Error fetching name for otherUserId: $otherUserId, error: $e');
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

    ref.state = AsyncValue.data(chats);
    ref.state.whenData((value) => value);
  });
  authService.addRealtimeDbListener(subscription);

  yield ref.state.value ?? [];
});
final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) async* {
  final authService = ref.read(authProvider);
  ref.watch(currentUserProvider);
  final subscription = FirebaseDatabase.instance.ref().child('Messages/$chatId').onValue.listen((event) {
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
    ref.state = AsyncValue.data(messages);
    ref.state.whenData((value) => value);
  });
  authService.addRealtimeDbListener(subscription);
  yield ref.state.value ?? [];
});
final typingIndicatorProvider = StreamProvider.family<bool, String>((ref, chatId) async* {
  final authService = ref.read(authProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    yield false;
    return;
  }

  final parts = chatId.split('_');
  final otherUserId = parts.first == user.uid ? parts.last : parts.first;

  final subscription = FirebaseDatabase.instance
      .ref()
      .child('Chats/$otherUserId/${user.uid}/typing')
      .onValue
      .listen((event) {
    final isTyping = event.snapshot.value as bool? ?? false;
    ref.state = AsyncValue.data(isTyping);
    ref.state.whenData((value) => value);
  });
  authService.addRealtimeDbListener(subscription);
  yield ref.state.value ?? false;
});
final chatSettingsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, uid) async* {
  final authService = ref.read(authProvider);
  ref.watch(currentUserProvider);
  final subscription = FirebaseDatabase.instance
      .ref()
      .child('Users/$uid/settings')
      .onValue
      .listen((event) {
    final settings = Map<String, dynamic>.from(event.snapshot.value as Map? ?? {'allowChat': true});
    ref.state = AsyncValue.data(settings);
    ref.state.whenData((value) => value);
  });
  authService.addRealtimeDbListener(subscription);
  yield ref.state.value ?? {'allowChat': true};
});
final otherUserProfileProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, uid) async* {
  final authService = ref.read(authProvider);
  ref.watch(currentUserProvider);
  final subscription = FirebaseDatabase.instance.ref().child('Users/$uid').onValue.listen((event) {
    final profile = Map<String, dynamic>.from(event.snapshot.value as Map? ?? {});
    ref.state = AsyncValue.data(profile);
    ref.state.whenData((value) => value);
  });
  authService.addRealtimeDbListener(subscription);
  yield ref.state.value ?? {};
});
// final formattedLastSeenProvider = StreamProvider.family<String, String>((ref, userId) async* {
//   final userRef = FirebaseDatabase.instance.ref().child('Users/$userId/status');
//   Timer? timer;
//
//   final subscription = Stream.periodic(const Duration(seconds: 1)).listen((_) async {
//     final snapshot = await userRef.get();
//     final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
//     final ping = data['ping'] as int?;
//     if (ping == null) {
//       ref.state = AsyncValue.data('Offline');
//     } else {
//       final now = DateTime.now().millisecondsSinceEpoch;
//       final isOnline = now - ping < 15000;
//       ref.state = AsyncValue.data(isOnline ? 'Online' : formatLastSeen(ping));
//     }
//     ref.state.whenData((value) => value);
//   });
//
//   timer = Timer.periodic(const Duration(seconds: 1), (_) async {
//     final snapshot = await userRef.get();
//     final data = Map<String, dynamic>.from(snapshot.value as Map? ?? {});
//     final ping = data['ping'] as int?;
//     if (ping == null) {
//       ref.state = AsyncValue.data('Offline');
//     } else {
//       final now = DateTime.now().millisecondsSinceEpoch;
//       final isOnline = now - ping < 15000;
//       ref.state = AsyncValue.data(isOnline ? 'Online' : formatLastSeen(ping));
//     }
//   });
//
//   ref.onDispose(() {
//     timer?.cancel();
//     subscription.cancel();
//   });
//   yield ref.state.value ?? 'Offline';
// });
final formattedStatusProvider = StreamProvider.family<String, String>((ref, userId) {
  final controller = StreamController<String>();
  final dbRef = FirebaseDatabase.instance.ref().child('Users/$userId/status');

  StreamSubscription? firebaseSub;
  Timer? periodicTimer;
  int? lastSeenTimestamp;
  bool isOnline = false;

  void updateStatus() {
    if (isOnline) {
      controller.add('Online');
    } else if (lastSeenTimestamp != null) {
      controller.add(formatLastSeen(lastSeenTimestamp!));
    } else {
      controller.add('Offline');
    }
  }

  // Listen to Firebase real-time status
  firebaseSub = dbRef.onValue.listen((event) {
    final data = event.snapshot.value as Map?;
    isOnline = data?['isOnline'] ?? false;
    lastSeenTimestamp = data?['lastSeen'];
    updateStatus();

    // If user is offline, start timer to update every minute
    periodicTimer?.cancel();
    if (!isOnline && lastSeenTimestamp != null) {
      periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        updateStatus();
      });
    }
  });

  ref.onDispose(() {
    firebaseSub?.cancel();
    periodicTimer?.cancel();
    controller.close();
  });

  return controller.stream;
});

final unseenMessagesProvider = StreamProvider.family<int, String>((ref, chatId) async* {
  final authService = ref.read(authProvider);
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    logDebug('unseenMessagesProvider: User is null');
    yield 0;
    return;
  }
  final messagesRef = FirebaseDatabase.instance.ref().child('Messages/$chatId');
  final subscription = messagesRef.onValue.listen((event) {
    int unseenCount = 0;
    if (event.snapshot.exists) {
      final messages = Map<String, dynamic>.from(event.snapshot.value as Map);
      messages.forEach((key, value) {
        final message = Map<String, dynamic>.from(value);
        if (message['senderId'] != user.uid && !(message['seen'] ?? false)) {
          unseenCount++;
        }
      });
    }
    logDebug('unseenMessagesProvider: Unseen count for $chatId = $unseenCount');
    ref.state = AsyncValue.data(unseenCount);
    ref.state.whenData((value) => value);
  });
  authService.addRealtimeDbListener(subscription);
  yield ref.state.value ?? 0;
});