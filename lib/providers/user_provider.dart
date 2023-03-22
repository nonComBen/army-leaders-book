import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

final userProvider = Provider<UserService>((ref) {
  return UserService();
});

class UserService {
  UserObj? _user;
  UserService();

  void loadUser(String userId) {
    final userStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    userStream.listen((event) {
      _user = UserObj.fromSnapshot(event);
    });
  }

  UserObj? get user {
    return _user;
  }
}
