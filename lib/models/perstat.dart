import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Perstat {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String start;
  String end;
  String type;
  String comments;
  String location;

  Perstat({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.start = '',
    this.end = '',
    this.type = 'Leave',
    this.comments = '',
    this.location = '',
  });

  static const String collectionName = 'perstat';

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
    map['start'] = start;
    map['end'] = end;
    map['type'] = type;
    map['comments'] = comments;
    map['location'] = location;

    return map;
  }

  factory Perstat.fromSnapshot(DocumentSnapshot doc) {
    String location = '';
    try {
      location = doc['location'];
    } catch (e) {
      location = '';
    }
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Perstat(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      start: doc['start'],
      end: doc['end'],
      type: doc['type'],
      comments: doc['comments'],
      location: location,
    );
  }
}
