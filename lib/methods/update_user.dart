import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/leader.dart';

void updateUser(User firebaseUser, Leader? user) async {
  List<dynamic> tokens = [];
  String? currentToken = await FirebaseMessaging.instance.getToken();
  if (user != null && !kIsWeb) {
    tokens = user.deviceTokens;
    if (!tokens.contains(currentToken)) {
      tokens.add(currentToken);
    }
    FirebaseFirestore.instance.doc('users/${firebaseUser.uid}').update({
      'lastLogin': DateTime.now(),
      'created': firebaseUser.metadata.creationTime,
      'deviceTokens': tokens,
    });
  }
}
