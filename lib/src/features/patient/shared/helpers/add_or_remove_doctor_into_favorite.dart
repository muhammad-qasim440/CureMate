import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/custom_snackbar_widget.dart';

class AddORRemoveDoctorIntoFavorite {
 static void toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    String doctorUid,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final database = FirebaseDatabase.instance.ref();
    final favoritesRef = database
        .child('Patients')
        .child(user.uid)
        .child('favorites')
        .child(doctorUid);

    try {
      final snapshot = await favoritesRef.get();
      if (snapshot.exists) {
        await favoritesRef.remove();
      } else {
        await favoritesRef.set(true);
      }
    } catch (e) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'Error toggling favorite: $e',
      );
    }
  }
}
