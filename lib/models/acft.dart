import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Acft {
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
  String ageGroup;
  String gender;
  String deadliftRaw;
  String powerThrowRaw;
  String puRaw;
  String dragRaw;
  String plankRaw;
  String runRaw;
  int deadliftScore;
  int powerThrowScore;
  int puScore;
  int dragScore;
  int plankScore;
  int runScore;
  int total;
  String altEvent;
  bool pass;

  Acft({
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
    this.ageGroup = '17-21',
    this.gender = 'Male',
    this.deadliftRaw = '',
    this.powerThrowRaw = '',
    this.puRaw = '',
    this.dragRaw = '',
    this.plankRaw = '',
    this.runRaw = '',
    this.deadliftScore = 0,
    this.powerThrowScore = 0,
    this.puScore = 0,
    this.dragScore = 0,
    this.plankScore = 0,
    this.runScore = 0,
    this.total = 0,
    this.altEvent = 'Run',
    this.pass = true,
  });

  static const String collectionName = 'acftStats';

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
    map['ageGroup'] = ageGroup;
    map['gender'] = gender;
    map['deadliftRaw'] = deadliftRaw;
    map['powerThrowRaw'] = powerThrowRaw;
    map['puRaw'] = puRaw;
    map['dragRaw'] = dragRaw;
    map['legTuckRaw'] = plankRaw;
    map['runRaw'] = runRaw;
    map['deadliftScore'] = deadliftScore;
    map['powerThrowScore'] = powerThrowScore;
    map['puScore'] = puScore;
    map['dragScore'] = dragScore;
    map['legTuckScore'] = plankScore;
    map['runScore'] = runScore;
    map['total'] = total;
    map['altEvent'] = altEvent;
    map['pass'] = pass;

    return map;
  }

  factory Acft.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    String ageGroup = '17-21', gender = 'Male';
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    try {
      ageGroup = doc['ageGroup'];
      gender = doc['gender'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'AgeGroup Does Not Exist');
    }
    return Acft(
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
      ageGroup: ageGroup,
      gender: gender,
      deadliftRaw: doc['deadliftRaw'],
      powerThrowRaw: doc['powerThrowRaw'],
      puRaw: doc['puRaw'],
      dragRaw: doc['dragRaw'],
      plankRaw: doc['legTuckRaw'],
      runRaw: doc['runRaw'],
      deadliftScore: doc['deadliftScore'],
      powerThrowScore: doc['powerThrowScore'],
      puScore: doc['puScore'],
      dragScore: doc['dragScore'],
      plankScore: doc['legTuckScore'],
      runScore: doc['runScore'],
      total: doc['total'],
      altEvent: doc['altEvent'],
      pass: doc['pass'],
    );
  }
}
