import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class POV {
  String? id;
  String? owner;
  List<dynamic>? users;
  String? soldierId;
  String year;
  String make;
  String model;
  String plate;
  String state;
  String regExp;
  String ins;
  String insExp;

  POV({
    this.id,
    this.owner,
    this.users,
    this.soldierId,
    this.year = '',
    this.make = '',
    this.model = '',
    this.plate = '',
    this.state = '',
    this.regExp = '',
    this.ins = '',
    this.insExp = '',
  });

  static const String collectionName = 'povs';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['soldierId'] = soldierId;
    map['year'] = year;
    map['make'] = make;
    map['model'] = model;
    map['plate'] = plate;
    map['state'] = state;
    map['regExp'] = regExp;
    map['ins'] = ins;
    map['insExp'] = insExp;

    return map;
  }

  factory POV.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return POV(
      id: doc.id,
      owner: doc['owner'],
      users: users,
      soldierId: doc['soldierId'],
      year: doc['year'],
      make: doc['make'],
      model: doc['model'],
      plate: doc['plate'],
      state: doc['state'],
      regExp: doc['regExp'],
      ins: doc['ins'],
      insExp: doc['insExp'],
    );
  }

  factory POV.fromMap(Map<String, dynamic> map) {
    List<dynamic> users = [map['owner']];
    try {
      users = map['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return POV(
      id: null,
      owner: map['owner'],
      users: users,
      soldierId: map['soldierId'],
      year: map['year'],
      make: map['make'],
      model: map['model'],
      plate: map['plate'],
      state: map['state'],
      regExp: map['regExp'],
      ins: map['ins'],
      insExp: map['insExp'],
    );
  }
}
