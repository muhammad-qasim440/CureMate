import 'dart:async';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../src/shared/chat/models/models_for_patient_and_doctors_for_chatting.dart';
import '../../../src/shared/chat/providers/chatting_auth_providers.dart';

final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  return AppLifecycleObserver(ref);
});

class AppLifecycleObserver with WidgetsBindingObserver {
  final Ref ref;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  Timer? _pingTimer;
  ProviderSubscription? _userListener;
  String? _currentUid;

  AppLifecycleObserver(this.ref) {
    WidgetsBinding.instance.addObserver(this);

    _userListener = ref.listen<AsyncValue<AppUser?>>(
      currentUserProvider,
          (prev, next) async {
        if (next.value != null) {
          final newUser = next.value!;
          if (_currentUid != newUser.uid) {
            logDebug('User changed or loaded: ${newUser.uid}');
            _currentUid = newUser.uid;
            await _handleNewUser(newUser.uid);
          }
        } else {
          logDebug('User logged out. Stopping ping...');
          _stopPinging();
          _currentUid = null;
        }
      },
    );
  }

  Future<void> _handleNewUser(String uid) async {
    await _updateStatus(uid, true);
    // _setOnDisconnect(uid);
    // _startPinging(uid);
  }

  void _setOnDisconnect(String uid) {
    _db.child('Users/$uid/status').onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
      'ping': ServerValue.timestamp,
    }).catchError((e) {
      logDebug('onDisconnect error: $e');
    });
  }

  Future<void> _updateStatus(String uid, bool isOnline) async {
    try {
      final userRef = _db.child('Users/$uid');
      final statusRef = userRef.child('status');
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        await userRef.set({
          'status': {
            'isOnline': isOnline,
            'lastSeen': ServerValue.timestamp,
            'ping': ServerValue.timestamp,
          },
        });
      } else if (!(await statusRef.get()).exists) {
        await statusRef.set({
          'isOnline': isOnline,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      } else {
        await statusRef.update({
          'isOnline': isOnline,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      }
    } catch (e) {
      logDebug('Error updating status: $e at ${DateTime.now()}');
    }
  }

  void _startPinging(String uid) {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        await _db.child('Users/$uid/status').update({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      } catch (e) {
        logDebug('Ping error: $e at ${DateTime.now()}');
      }
    });
  }

  void _stopPinging() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      if (state == AppLifecycleState.resumed) {
        logDebug('App resumed');
        // _updateStatus(user.uid, true);
        // _startPinging(user.uid);
      } else if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached ||
          state == AppLifecycleState.inactive) {
        logDebug('App backgrounded');
        _updateStatus(user.uid, false);
        _stopPinging();
      }
    } catch (e) {
      logDebug('Lifecycle error: $e at ${DateTime.now()}');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPinging();
    _userListener?.close();
    _userListener = null;
    print("AppLifecycleObserver disposed");
  }
}