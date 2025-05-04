import 'dart:async';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../const/app_strings.dart';
import '../../../core/utils/debug_print.dart';
import '../providers/check_internet_connectivity_provider.dart';
import 'models/models_for_patient_and_doctors_for_chatting.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initChat({
    required AppUser user,
    required String otherUserId,
    required String otherUserName,
    required bool isPatient,
    required BuildContext context,
    required WidgetRef ref,
    required TextEditingController messageController,
  }) async {
    final chatId = generateChatId(user.uid, otherUserId);
    String validatedOtherUserName = otherUserName.trim();
    if (validatedOtherUserName.isEmpty || validatedOtherUserName == otherUserId) {
      logDebug('Fetching name for otherUserId: $otherUserId');
      try {
        final targetNode = isPatient ? 'Doctors' : 'Patients';
        final snapshot = await _database.child('$targetNode/$otherUserId').get();
        if (snapshot.exists) {
          validatedOtherUserName = (snapshot.value as Map)['fullName'] ?? 'Unknown';
        } else {
          validatedOtherUserName = 'Unknown';
          logDebug('No data found in $targetNode for otherUserId: $otherUserId');
        }
      } catch (e) {
        logDebug('Error fetching name for otherUserId: $otherUserId, error: $e');
        validatedOtherUserName = 'Unknown';
      }
    }

    bool hasInternet = await checkInternetConnection(context: context, ref: ref);
    if (!hasInternet) return;

    try {
      await _database.child('Chats/${user.uid}/$otherUserId').set({
        'chatId': chatId,
        'doctorName': isPatient ? validatedOtherUserName : user.fullName,
        'patientName': isPatient ? user.fullName : validatedOtherUserName,
        'lastMessage': messageController.text.trim(),
        'timestamp': ServerValue.timestamp,
        'typing': false,
      });

      await _database.child('Chats/$otherUserId/${user.uid}').set({
        'chatId': chatId,
        'doctorName': isPatient ? validatedOtherUserName : user.fullName,
        'patientName': isPatient ? user.fullName : validatedOtherUserName,
        'lastMessage': messageController.text.trim(),
        'timestamp': ServerValue.timestamp,
        'typing': false,
      });

      logDebug('Chat initialized for chatId: $chatId with otherUserName: $validatedOtherUserName');
    } catch (e) {
      logDebug('Failed to initialize chat: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize chat: $e')),
        );
      }
    }
  }

  Future<void> sendMessage({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    required TextEditingController messageController,
    required ScrollController scrollController,
    required BuildContext context,
    required WidgetRef ref,
    required bool isPatient,
    required AppUser currentUser,
  }) async {
    if (messageController.text.trim().isEmpty || otherUserId.isEmpty) {
      logDebug('sendMessage: Empty message or invalid otherUserId');
      return;
    }

    bool hasInternet = await checkInternetConnection(context: context, ref: ref);
    if (!hasInternet) {
      logDebug('sendMessage: No internet connection');
      return;
    }

    final chatId = generateChatId(currentUserId, otherUserId);
    final messageId = _database.child('Messages/$chatId').push().key;
    if (messageId == null) {
      logDebug('sendMessage: Failed to generate messageId for chatId=$chatId');
      return;
    }

    final messageText = messageController.text.trim();
    final message = {
      'senderId': currentUserId,
      'text': messageText,
      'timestamp': ServerValue.timestamp,
      'seen': false,
      'deletedForEveryone': false,
      'deletedFor': {},
      'reactions': {},
    };

    try {
      final chatSnapshot = await _database.child('Chats/$currentUserId/$otherUserId').get();
      if (!chatSnapshot.exists) {
        logDebug('sendMessage: Initializing chat for chatId=$chatId');
        await initChat(
          user: currentUser,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          isPatient: isPatient,
          context: context,
          ref: ref,
          messageController: messageController,
        );
      }

      logDebug('sendMessage: Sending message for chatId=$chatId, messageText="$messageText", messageId=$messageId');
      await Future.wait([
        _database.child('Messages/$chatId/$messageId').set(message),
        _database.child('Chats/$currentUserId/$otherUserId').update({
          'lastMessage': messageText,
          'timestamp': ServerValue.timestamp,
        }),
        _database.child('Chats/$otherUserId/$currentUserId').update({
          'lastMessage': messageText,
          'timestamp': ServerValue.timestamp,
        }),
      ]);

      logDebug('sendMessage: Message sent and Chats updated for chatId=$chatId, messageText="$messageText"');
      messageController.clear();
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      logDebug('sendMessage: Failed to send message for chatId=$chatId, error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  String generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> handleTyping({
    required AppUser? user,
    required String otherUserId,
    required bool isTyping,
    required Timer? typingTimer,
    required bool isInternet,
  }) async {
    if (user == null || !isInternet) return;
    try {
      typingTimer?.cancel();
      final chatSnapshot =
      await _database.child('Chats/${user.uid}/$otherUserId/typing').get();
      if (!chatSnapshot.exists) return;
      await _database
          .child('Chats/${user.uid}/$otherUserId/typing')
          .set(isTyping)
          .catchError((e) {
        print('Error updating typing status: $e');
      });

      if (isTyping) {
        typingTimer = Timer(const Duration(seconds: 2), () {
          _database
              .child('Chats/${user.uid}/$otherUserId/typing')
              .set(false)
              .catchError((e) {
            print('Error stopping typing status: $e');
          });
        });
      }
      _database
          .child('Chats/${user.uid}/$otherUserId/typing')
          .onDisconnect()
          .set(false);
    } catch (e) {
      print('Error handling typing: $e');
    }
  }

  Future<void> markAsSeen({
    required String messageId,
    required String chatId,
    required bool isInternet,
  }) async {
    if (!isInternet) return;
    await _database
        .child('Messages/$chatId/$messageId')
        .update({'seen': true})
        .catchError((e) {
      print('Error marking message as seen: $e');
    });
  }

  String getChatDisabledMessage({
    required Map<String, dynamic> currentSettings,
    required Map<String, dynamic> otherSettings,
    required AppUser user,
    required bool isPatient,
  }) {
    final currentAllowChat = currentSettings['allowChat'] == true;
    final otherAllowChat = otherSettings['allowChat'] == true;
    if (currentAllowChat && otherAllowChat) {
      return '';
    }
    final otherUserRole = isPatient ? 'doctor' : 'patient';
    if (!currentAllowChat && !otherAllowChat) {
      return 'Chat disabled by both sides.';
    } else if (!currentAllowChat) {
      return 'Chat is disabled by you.';
    } else {
      return 'Chat disabled by $otherUserRole.';
    }
  }

  bool isLastMessageFromCurrentUser({
    required List<Map<String, dynamic>> messages,
    required String currentUserId,
  }) {
    if (messages.isEmpty) return false;
    return messages.first['senderId'] == currentUserId;
  }

  // Future<void> deleteMessageForMe({
  //   required String messageId,
  //   required String chatId,
  //   required BuildContext context,
  //   required WidgetRef ref,
  // }) async {
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   try {
  //     final currentUserId = _auth.currentUser!.uid;
  //     await _database
  //         .child('Messages/$chatId/$messageId/deletedFor/$currentUserId')
  //         .set(true);
  //     print('Message deleted for user: $currentUserId');
  //   } catch (e) {
  //     print('Failed to delete message for me: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to delete message: $e')),
  //       );
  //     }
  //   }
  // }
  //
  // Future<void> deleteMessageForEveryone({
  //   required String messageId,
  //   required String chatId,
  //   required BuildContext context,
  //   required WidgetRef ref,
  //   required String originalText,
  // }) async {
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   try {
  //     await _database.child('Messages/$chatId/$messageId').update({
  //       'deletedForEveryone': true,
  //       'originalText': originalText,
  //       'text': 'This message was deleted',
  //     });
  //     print('Message deleted for everyone: $messageId');
  //   } catch (e) {
  //     print('Failed to delete message for everyone: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to delete message: $e')),
  //       );
  //     }
  //   }
  // }
  //
  // Future<void> editMessage({
  //   required String messageId,
  //   required String chatId,
  //   required String newText,
  //   required BuildContext context,
  //   required WidgetRef ref,
  // }) async {
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   try {
  //     await _database.child('Messages/$chatId/$messageId').update({
  //       'text': newText.trim(),
  //       'edited': true,
  //     });
  //     print('Message edited: $messageId');
  //   } catch (e) {
  //     print('Failed to edit message: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to edit message: $e')),
  //       );
  //     }
  //   }
  // }
  //
  // Future<void> addReaction({
  //   required String messageId,
  //   required String chatId,
  //   required String userId,
  //   required String emoji,
  //   required BuildContext context,
  //   required WidgetRef ref,
  // }) async {
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   try {
  //     await _database
  //         .child('Messages/$chatId/$messageId/reactions/$userId')
  //         .set(emoji);
  //     print('Reaction added: $emoji to message $messageId by user $userId');
  //   } catch (e) {
  //     print('Failed to add reaction: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to add reaction: $e')),
  //       );
  //     }
  //   }
  // }

  // Future<void> removeReaction({
  //   required String messageId,
  //   required String chatId,
  //   required String userId,
  //   required BuildContext context,
  //   required WidgetRef ref,
  // }) async {
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   try {
  //     await _database
  //         .child('Messages/$chatId/$messageId/reactions/$userId')
  //         .remove();
  //     print('Reaction removed from message $messageId by user $userId');
  //   } catch (e) {
  //     print('Failed to remove reaction: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to remove reaction: $e')),
  //       );
  //     }
  //   }
  // }

  // Future<void> forwardMessages({
  //   required List<Map<String, dynamic>> messages,
  //   required String sourceChatId,
  //   required List<String> targetUserIds,
  //   required BuildContext context,
  //   required WidgetRef ref,
  //   required AppUser currentUser,
  // }) async {
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   try {
  //     for (var targetUserId in targetUserIds) {
  //       final targetChatId = generateChatId(currentUser.uid, targetUserId);
  //       for (var msg in messages) {
  //         final newMessageId = _database.child('Messages/$targetChatId').push().key;
  //         if (newMessageId == null) continue;
  //
  //         final message = {
  //           'senderId': currentUser.uid,
  //           'text': msg['text'].trim(),
  //           'timestamp': ServerValue.timestamp,
  //           'seen': false,
  //           'deletedForEveryone': false,
  //           'deletedFor': {},
  //           'reactions': {},
  //           'forwardedFrom': {
  //             'chatId': sourceChatId,
  //             'messageId': msg['messageId'],
  //           },
  //         };
  //
  //         await _database.child('Messages/$targetChatId/$newMessageId').set(message);
  //         await _database.child('Chats/${currentUser.uid}/$targetUserId').update({
  //           'lastMessage': msg['text'].trim(),
  //           'timestamp': ServerValue.timestamp,
  //         });
  //         await _database.child('Chats/$targetUserId/${currentUser.uid}').update({
  //           'lastMessage': msg['text'].trim(),
  //           'timestamp': ServerValue.timestamp,
  //         });
  //       }
  //     }
  //     print('Messages forwarded to ${targetUserIds.length} chats');
  //   } catch (e) {
  //     print('Failed to forward messages: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to forward messages: $e')),
  //       );
  //     }
  //   }
  // }

  // Future<void> sendReplyMessage({
  //   required String currentUserId,
  //   required String otherUserId,
  //   required String replyToMessageId,
  //   required TextEditingController messageController,
  //   required ScrollController scrollController,
  //   required BuildContext context,
  //   required WidgetRef ref,
  //   required AppUser currentUser,
  // }) async {
  //   if (messageController.text.trim().isEmpty || otherUserId.isEmpty) return;
  //
  //   bool hasInternet = await checkInternetConnection(context: context, ref: ref);
  //   if (!hasInternet) return;
  //
  //   final chatId = generateChatId(currentUserId, otherUserId);
  //   final messageId = _database.child('Messages/$chatId').push().key;
  //   if (messageId == null) return;
  //
  //   final message = {
  //     'senderId': currentUserId,
  //     'text': messageController.text.trim(),
  //     'timestamp': ServerValue.timestamp,
  //     'seen': false,
  //     'deletedForEveryone': false,
  //     'deletedFor': {},
  //     'reactions': {},
  //     'replyTo': replyToMessageId,
  //   };
  //
  //   try {
  //     await _database.child('Messages/$chatId/$messageId').set(message);
  //     await _database.child('Chats/$currentUserId/$otherUserId').update({
  //       'lastMessage': messageController.text.trim(),
  //       'timestamp': ServerValue.timestamp,
  //     });
  //     await _database.child('Chats/$otherUserId/$currentUserId').update({
  //       'lastMessage': messageController.text.trim(),
  //       'timestamp': ServerValue.timestamp,
  //     });
  //     messageController.clear();
  //     scrollController.animateTo(
  //       0,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   } catch (e) {
  //     print('Failed to send reply: $e');
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to send reply: $e')),
  //       );
  //     }
  //   }
  // }

  Future<bool> checkInternetConnection({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final isInternet = ref.read(checkInternetConnectionProvider).value ?? false;
    if (!isInternet && context.mounted) {
      CustomSnackBarWidget.show(context: context, text: AppStrings.noInternetInSnackBar);
    }
    return isInternet;
  }
}