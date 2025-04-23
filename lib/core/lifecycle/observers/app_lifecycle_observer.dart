import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../src/shared/chat/providers/chatting_auth_providers.dart';

final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  return AppLifecycleObserver(ref);
});

class AppLifecycleObserver with WidgetsBindingObserver {
  final Ref ref;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  Timer? _pingTimer;

  AppLifecycleObserver(this.ref) {
    print('AppLifecycleObserver created at ${DateTime.now()}');
    WidgetsBinding.instance.addObserver(this);
    _setupInitialStatus();
  }

  Future<void> _setupInitialStatus() async {
    final user = ref.read(currentUserProvider).value;
    print('Setup initial status: user = ${user?.uid}, details = ${user?.toString()} at ${DateTime.now()}');
    if (user != null) {
      await _updateStatus(user.uid, true);
      _setOnDisconnect(user.uid);
      _startPinging(user.uid);
    } else {
      print('No authenticated user found for initial status setup at ${DateTime.now()}');
    }
  }

  void _setOnDisconnect(String uid) {
    print('Setting onDisconnect for $uid at ${DateTime.now()}');
    _db.child('Users/$uid/status').onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
      'ping': ServerValue.timestamp,
    }).catchError((e) {
      print('Error setting onDisconnect: $e at ${DateTime.now()}');
    });
  }

  Future<void> _updateStatus(String uid, bool isOnline) async {
    try {
      final userRef = _db.child('Users/$uid');
      final statusRef = userRef.child('status');
      final userSnapshot = await userRef.get();

      print('Checking user node for $uid: exists = ${userSnapshot.exists} at ${DateTime.now()}');
      if (!userSnapshot.exists) {
        print('Creating Users/$uid with status for $uid: isOnline=$isOnline at ${DateTime.now()}');
        await userRef.set({
          'status': {
            'isOnline': isOnline,
            'lastSeen': ServerValue.timestamp,
            'ping': ServerValue.timestamp,
          },
        });
      } else if (!(await statusRef.get()).exists) {
        print('Creating status for $uid: isOnline=$isOnline at ${DateTime.now()}');
        await statusRef.set({
          'isOnline': isOnline,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      } else {
        print('Updating status for $uid: isOnline=$isOnline at ${DateTime.now()}');
        await statusRef.update({
          'isOnline': isOnline,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      }
    } catch (e) {
      print('Error updating status: $e at ${DateTime.now()}');
    }
  }

  void _startPinging(String uid) {
    _pingTimer?.cancel();
    print('Starting ping timer for $uid at ${DateTime.now()}');
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        print('Updating ping for $uid at ${DateTime.now()}');
        await _db.child('Users/$uid/status').update({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      } catch (e) {
        print('Error updating ping: $e at ${DateTime.now()}');
      }
    });
  }

  void _stopPinging() {
    print('Stopping ping timer at ${DateTime.now()}');
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('Lifecycle state changed: $state at ${DateTime.now()}');
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      print('No authenticated user for lifecycle update at ${DateTime.now()}');
      return;
    }

    try {
      if (state == AppLifecycleState.resumed) {
        print('App resumed, setting online for ${user.uid} at ${DateTime.now()}');
        _updateStatus(user.uid, true);
        _startPinging(user.uid);
      } else if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached ||
          state == AppLifecycleState.inactive) {
        print('App paused/detached/inactive, setting offline for ${user.uid} at ${DateTime.now()}');
        _updateStatus(user.uid, false);
        _stopPinging();
      }
    } catch (e) {
      print('Error handling lifecycle state change: $e at ${DateTime.now()}');
    }
  }

  void dispose() {
    print('Disposing AppLifecycleObserver at ${DateTime.now()}');
    WidgetsBinding.instance.removeObserver(this);
    _stopPinging();
  }
}