import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class Award {
  String id;
  String owner;
  List<dynamic> users;
  String soldierId;
  String name;
  String number;

  Award(
      {this.id,
      @required this.owner,
      @required this.users,
      @required this.soldierId,
      this.name = '',
      this.number = ''});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['soldierId'] = soldierId;
    map['name'] = name;
    map['number'] = number;

    return map;
  }

  factory Award.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Award(
        id: doc.id,
        owner: doc['owner'],
        users: users,
        soldierId: doc['soldierId'],
        name: doc['name'],
        number: doc['number']);
  }
}
