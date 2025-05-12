import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../src/shared/chat/models/models_for_patient_and_doctors_for_chatting.dart';
import '../../../src/shared/chat/providers/chatting_auth_providers.dart';
import 'package:curemate/core/utils/debug_print.dart';

final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  return AppLifecycleObserver(ref);
});

class AppLifecycleObserver with WidgetsBindingObserver {
  final Ref ref;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  ProviderSubscription? _userListener;
  String? _currentUid;

  AppLifecycleObserver(this.ref) {
    WidgetsBinding.instance.addObserver(this);

    _userListener = ref.listen<AsyncValue<AppUser?>>(
      currentUserProvider,
          (prev, next) async {
        final user = next.value;
        if (user != null && user.uid != _currentUid) {
          _currentUid = user.uid;
          await _updateStatus(user.uid, true);
          _setOnDisconnect(user.uid);
        } else if (user == null) {
          _currentUid = null;
        }
      },
    );
  }

  void _setOnDisconnect(String uid) {
    _db.child('Users/$uid/status').onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    }).catchError((e) {
      logDebug('onDisconnect error: $e');
    });
  }

  Future<void> _updateStatus(String uid, bool isOnline) async {
    try {
      final userRef = _db.child('Users/$uid');
      final statusRef = userRef.child('status');
      const timestamp = ServerValue.timestamp;

      await statusRef.update({
        'isOnline': isOnline,
        'lastSeen': timestamp,
      });
    } catch (e) {
      logDebug('Error updating status: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (state == AppLifecycleState.resumed) {
      logDebug('App resumed → Online');
      _updateStatus(user.uid, true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      logDebug('App backgrounded → Offline');
      _updateStatus(user.uid, false);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userListener?.close();
    _userListener = null;
    logDebug("AppLifecycleObserver disposed");
  }
}
