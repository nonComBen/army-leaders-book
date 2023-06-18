import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/setting.dart';

final settingsProvider =
    StateNotifierProvider<SettingsService, Setting?>((ref) {
  return SettingsService();
});

class SettingsService extends StateNotifier<Setting?> {
  SettingsService() : super(null);

  get settings {
    return state;
  }

  void init(String userId) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> settingsStream =
        FirebaseFirestore.instance
            .collection(Setting.collectionName)
            .doc(userId)
            .snapshots();
    settingsStream.listen((doc) {
      state = Setting.fromMap(doc.data(), userId);
    });
  }
}
