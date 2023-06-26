import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../models/award.dart';
import '../../models/pov.dart';
import '../../models/soldier.dart';
import '../models/leader.dart';
import '../models/training.dart';

void updateUsersArray(String? uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> users = [];

  db
      .collection(Soldier.collectionName)
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
  final snapshot = await db
      .collection(POV.collectionName)
      .where('users', arrayContains: uid)
      .get();
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
    db.collection(Soldier.collectionName).doc(id).update({'povs': newPovs});
  }
  db.collection(Leader.collectionName).doc(uid).update({'updatedPovs': true});
  for (POV pov in povs) {
    db.doc('povs/${pov.id}').delete();
  }
}

void updateAwards(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Award> awards = [];
  List<String> soldierIds = [];
  final snapshot = await db
      .collection(Award.collectionName)
      .where('users', arrayContains: uid)
      .get();
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
    db.collection(Soldier.collectionName).doc(id).update({'awards': newAwards});
  }
  db.collection(Leader.collectionName).doc(uid).update({'updatedAwards': true});
  for (Award award in awards) {
    db.doc('awards/${award.id}').delete();
  }
}

void updateTraining(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Training> trainings = [];
  final snapshot = await db
      .collection(Training.collectionName)
      .where('users', arrayContains: uid)
      .get();
  if (snapshot.docs.isNotEmpty) {
    trainings = snapshot.docs.map((e) => Training.fromSnapshot(e)).toList();
    for (Training training in trainings) {
      if (training.add1 != '') {
        training.addTraining!
            .add({'name': training.add1, 'date': training.add1Date});
      }
      if (training.add2 != '') {
        training.addTraining!
            .add({'name': training.add2, 'date': training.add2Date});
      }
      if (training.add3 != '') {
        training.addTraining!
            .add({'name': training.add3, 'date': training.add3Date});
      }
      if (training.add4 != '') {
        training.addTraining!
            .add({'name': training.add4, 'date': training.add4Date});
      }
      if (training.add5 != '') {
        training.addTraining!
            .add({'name': training.add5, 'date': training.add5Date});
      }
      db
          .collection(Training.collectionName)
          .doc(training.id)
          .update({'addTraining': training.addTraining});
    }
  }
  db
      .collection(Leader.collectionName)
      .doc(uid)
      .update({'updatedTraining': true});
}

void syncFromWebApp(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, dynamic> users = {
    'users': [uid]
  };
  db
      .collection(Soldier.collectionName)
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
