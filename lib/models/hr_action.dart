import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class HrAction {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String dd93;
  String sglv;
  String prr;

  HrAction({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.dd93 = '',
    this.sglv = '',
    this.prr = '',
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
    map['dd93'] = dd93;
    map['sglv'] = sglv;
    map['prr'] = prr;

    return map;
  }

  factory HrAction.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return HrAction(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      dd93: doc['dd93'],
      sglv: doc['sglv'],
      prr: doc['prr'],
    );
  }
}
