import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Flag {
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
  String? type;
  String comments;

  Flag({
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
    this.type,
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
    map['type'] = type;
    map['comments'] = comments;

    return map;
  }

  factory Flag.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Flag(
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
        type: doc['type'],
        comments: doc['comments']);
  }
}
