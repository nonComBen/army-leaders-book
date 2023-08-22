import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Rating {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String last;
  String next;
  String nextType;
  String rater;
  String sr;
  String reviewer;

  Rating({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.last = '',
    this.next = '',
    this.nextType = '',
    this.rater = '',
    this.sr = '',
    this.reviewer = '',
  });

  static const String collectionName = 'ratings';

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
    map['last'] = last;
    map['next'] = next;
    map['nextType'] = nextType;
    map['rater'] = rater;
    map['sr'] = sr;
    map['reviewer'] = reviewer;

    return map;
  }

  factory Rating.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Rating(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      last: doc['last'],
      next: doc['next'],
      nextType: doc['nextType'],
      rater: doc['rater'],
      sr: doc['sr'],
      reviewer: doc['reviewer'],
    );
  }
}
