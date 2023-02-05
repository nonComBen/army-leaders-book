// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

void updateUsersArray(String uid) async {
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
          print('Users does not exist: $e');
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
