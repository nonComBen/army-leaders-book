import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/soldier.dart';

Future<List<Soldier>> createLessSoldiers({
  required String collection,
  required String userId,
  required List<Soldier> allSoldiers,
  String? profileType,
}) async {
  List<Soldier> lessSoldiers = List.from(allSoldiers, growable: true);
  Query? query = FirebaseFirestore.instance.collection(collection).where(
        'users',
        arrayContains: userId,
      );

  if (profileType != null) {
    query = query.where('type', isEqualTo: profileType);
  }
  late QuerySnapshot snapshot;
  try {
    snapshot = await query.get();
  } on Exception catch (e) {
    debugPrint('Error: $e');
    snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('owner', isEqualTo: userId)
        .get();
  }
  if (snapshot.docs.isNotEmpty) {
    for (var doc in snapshot.docs) {
      lessSoldiers.removeWhere((soldier) => soldier.id == doc['soldierId']);
    }
  }
  return lessSoldiers;
}
