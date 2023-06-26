import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leader.dart';

final userProvider = Provider<UserService>((ref) {
  return UserService();
});

class UserService {
  Leader? _user;
  UserService();

  void loadUser(String userId) {
    final userStream = FirebaseFirestore.instance
        .collection(Leader.collectionName)
        .doc(userId)
        .snapshots();
    userStream.listen((event) {
      _user = Leader.fromSnapshot(event);
    });
  }

  void nullUser() {
    _user = null;
  }

  Leader? get user {
    return _user;
  }
}
