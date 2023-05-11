import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:leaders_book/models/award.dart';
import 'package:leaders_book/models/pov.dart';

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

void updatePovs(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<POV> povs = [];
  List<String> soldierIds = [];
  final snapshot =
      await db.collection('povs').where('users', arrayContains: uid).get();
  povs = snapshot.docs.map((e) => POV.fromSnapshot(e)).toList();
  soldierIds = povs.map((e) => e.soldierId!).toList();
  soldierIds = soldierIds.toSet().toList();
  for (String id in soldierIds) {
    List<Map<String, dynamic>> newPovs =
        povs.where((e) => e.soldierId == id).toList().map((e) {
      Map<String, dynamic> map = e.toMap();
      map.remove('owner');
      map.remove('users');
      map.remove('soldierId');
      return map;
    }).toList();
    db.collection('soldiers').doc(id).update({'povs': newPovs});
  }
  db.collection('users').doc(uid).update({'updatedPovs': true});
  for (POV pov in povs) {
    db.doc('povs/${pov.id}').delete();
  }
}

void updateAwards(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Award> awards = [];
  List<String> soldierIds = [];
  final snapshot =
      await db.collection('awards').where('users', arrayContains: uid).get();
  awards = snapshot.docs.map((e) => Award.fromSnapshot(e)).toList();
  soldierIds = awards.map((e) => e.soldierId!).toList();
  soldierIds = soldierIds.toSet().toList();
  for (String id in soldierIds) {
    List<Map<String, dynamic>> newAwards =
        awards.where((e) => e.soldierId == id).toList().map((e) {
      Map<String, dynamic> map = e.toMap();
      map.remove('owner');
      map.remove('users');
      map.remove('soldierId');
      return map;
    }).toList();
    db.collection('soldiers').doc(id).update({'awards': newAwards});
  }
  db.collection('users').doc(uid).update({'updatedAwards': true});
  for (Award award in awards) {
    db.doc('awards/${award.id}').delete();
  }
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
