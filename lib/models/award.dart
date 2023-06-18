import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Award {
  String? id;
  String? owner;
  List<dynamic>? users;
  String? soldierId;
  String name;
  String number;

  Award({
    this.id,
    this.owner,
    this.users,
    this.soldierId,
    this.name = '',
    this.number = '',
  });

  static const String collectionName = 'awards';

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
      number: doc['number'],
    );
  }

  factory Award.fromMap(Map<String, dynamic> map) {
    List<dynamic> users = [map['owner']];
    try {
      users = map['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Award(
      id: null,
      owner: map['owner'],
      users: users,
      soldierId: map['soldierId'],
      name: map['name'],
      number: map['number'],
    );
  }
}
