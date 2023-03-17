import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  UserObj? _user;
  UserProvider();

  void loadUser(String userId) {
    final userStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    userStream.listen((event) {
      _user = UserObj.fromSnapshot(event);
      notifyListeners();
    });
  }

  UserObj? get user {
    return _user;
  }
}
