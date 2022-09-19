import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/soldier.dart';

class SoldiersProvider with ChangeNotifier {
  List<Soldier> _soldiers = [];
  SoldiersProvider();

  void loadSoldiers(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> soldiersStream =
        FirebaseFirestore.instance
            .collection('soldiers')
            .where('users', isNotEqualTo: null)
            .where('users', arrayContains: userId)
            .snapshots();
    soldiersStream.listen((event) {
      _soldiers = event.docs.map((e) => Soldier.fromSnapshot(e)).toList();
      notifyListeners();
    });
  }

  List<Soldier> get soldiers {
    return _soldiers;
  }

  void sortSoldiers(int columnIndex, bool ascending) {
    if (ascending) {
      switch (columnIndex) {
        case 0:
          _soldiers.sort((a, b) => a.rankSort.compareTo(b.rankSort));
          break;
        case 1:
          _soldiers.sort((a, b) => a.lastName.compareTo(b.lastName));
          break;
        case 2:
          _soldiers.sort((a, b) => a.section.compareTo(b.section));
          break;
        case 3:
          _soldiers.sort((a, b) => a.duty.compareTo(b.duty));
          break;
        case 4:
          _soldiers.sort((a, b) => a.lossDate.compareTo(b.lossDate));
          break;
        case 5:
          _soldiers.sort((a, b) => a.ets.compareTo(b.ets));
          break;
        case 6:
          _soldiers.sort((a, b) => a.dor.compareTo(b.dor));
          break;
      }
    } else {
      switch (columnIndex) {
        case 0:
          _soldiers.sort((a, b) => b.rankSort.compareTo(a.rankSort));
          break;
        case 1:
          _soldiers.sort((a, b) => b.lastName.compareTo(a.lastName));
          break;
        case 2:
          _soldiers.sort((a, b) => b.section.compareTo(a.section));
          break;
        case 3:
          _soldiers.sort((a, b) => b.duty.compareTo(a.duty));
          break;
        case 4:
          _soldiers.sort((a, b) => b.lossDate.compareTo(a.lossDate));
          break;
        case 5:
          _soldiers.sort((a, b) => b.ets.compareTo(a.ets));
          break;
        case 6:
          _soldiers.sort((a, b) => b.dor.compareTo(a.dor));
          break;
      }
    }
    notifyListeners();
  }
}
