import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leader.dart';

final leaderProvider = Provider<LeaderService>((ref) {
  return LeaderService();
});

class LeaderService {
  Leader? _leader;
  LeaderService();

  void init(String userId) {
    final userStream = FirebaseFirestore.instance
        .collection(Leader.collectionName)
        .doc(userId)
        .snapshots();
    userStream.listen((event) {
      _leader = Leader.fromSnapshot(event);
    });
  }

  void nullLeader() {
    _leader = null;
  }

  Leader? get leader {
    return _leader;
  }
}
