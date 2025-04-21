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
    WidgetsBinding.instance.addObserver(this);
    _setupInitialStatus();
  }

  Future<void> _setupInitialStatus() async {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      await _updateStatus(user.uid, true);
      _setOnDisconnect(user.uid);
      _startPinging(user.uid);
    }
  }

  void _setOnDisconnect(String uid) {
    _db.child('Users/$uid/status').onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  Future<void> _updateStatus(String uid, bool isOnline) async {
    await _db.child('Users/$uid/status').update({
      'isOnline': isOnline,
      'lastSeen': ServerValue.timestamp,
    });
  }

  void _startPinging(String uid) {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _db.child('Users/$uid/status/ping').set(ServerValue.timestamp);
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

    if (state == AppLifecycleState.resumed) {
      _updateStatus(user.uid, true);
      _startPinging(user.uid);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _updateStatus(user.uid, false);
      _stopPinging();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPinging();
  }
}
