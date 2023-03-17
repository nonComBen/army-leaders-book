import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class TempProfile {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String date;
  String exp;
  String recExp;
  String type;
  String comments;

  TempProfile({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.date = '',
    this.exp = '',
    this.recExp = '',
    this.type = 'Temporary',
    this.comments = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['soldierId'] = soldierId;
    map['rank'] = rank;
    map['name'] = name;
    map['firstName'] = firstName;
    map['section'] = section;
    map['rankSort'] = rankSort;
    map['date'] = date;
    map['exp'] = exp;
    map['recExp'] = recExp;
    map['type'] = type;
    map['comments'] = comments;

    return map;
  }

  factory TempProfile.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return TempProfile(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      date: doc['date'],
      exp: doc['exp'],
      recExp: doc['recExp'],
      type: doc['type'],
      comments: doc['comments'],
    );
  }
}

class PermProfile {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String date;
  String type;
  bool shaving;
  bool pu;
  bool su;
  bool run;
  String altEvent;
  String comments;

  PermProfile({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.date = '',
    this.type = 'Permanent',
    this.shaving = false,
    this.pu = false,
    this.su = false,
    this.run = false,
    this.altEvent = '',
    this.comments = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['soldierId'] = soldierId;
    map['rank'] = rank;
    map['name'] = name;
    map['firstName'] = firstName;
    map['section'] = section;
    map['rankSort'] = rankSort;
    map['date'] = date;
    map['type'] = type;
    map['shaving'] = shaving;
    map['pu'] = pu;
    map['su'] = su;
    map['run'] = run;
    map['altEvent'] = altEvent;
    map['comments'] = comments;

    return map;
  }

  factory PermProfile.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return PermProfile(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      date: doc['date'],
      type: doc['type'],
      shaving: doc['shaving'],
      pu: doc['pu'],
      su: doc['su'],
      run: doc['run'],
      altEvent: doc['altEvent'],
      comments: doc['comments'],
    );
  }
}
