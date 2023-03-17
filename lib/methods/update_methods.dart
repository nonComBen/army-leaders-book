import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void updateUsersArray(String? uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> users = [];

  db
      .collection('soldiers')
      .where('owner', isEqualTo: uid)
      .get()
      .then((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot doc in snapshot.docs) {
        try {
          users = doc['users'];
        } catch (e) {
          FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
        }
        if (!users.contains(uid)) {
          users.add(uid);
        }
        doc.reference.update({'users': users});
      }
    }
  });
}

void syncFromWebApp(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, dynamic> users = {
    'users': [uid]
  };
  db
      .collection('soldiers')
      .where('owner', isEqualTo: uid)
      .where('users', isEqualTo: null)
      .get()
      .then((value) {
    updateRecords(value, users);
    return;
  });
}

void updateRecords(QuerySnapshot snapshot, Map<String, dynamic> users) {
  if (snapshot.docs.isNotEmpty) {
    for (DocumentSnapshot doc in snapshot.docs) {
      doc.reference.update(users);
    }
  }
}
