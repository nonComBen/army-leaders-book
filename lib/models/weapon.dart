import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Weapon {
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
  String score;
  String max;
  String badge;
  String qualType;
  bool pass;

  Weapon({
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
    this.type = '',
    this.score = '',
    this.max = '',
    this.badge = '',
    this.pass = true,
    this.qualType = 'Day',
  });

  static const String collectionName = 'weaponStats';

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
    map['score'] = score;
    map['max'] = max;
    map['badge'] = badge;
    map['pass'] = pass;
    map['qualType'] = qualType;

    return map;
  }

  factory Weapon.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Weapon(
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
      score: doc['score'],
      max: doc['max'],
      badge: doc['badge'],
      pass: doc['pass'],
      qualType: doc['qualType'],
    );
  }
}
