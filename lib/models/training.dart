import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Training {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String cyber;
  String opsec;
  String antiTerror;
  String lawOfWar;
  String persRec;
  String infoSec;
  String ctip;
  String gat;
  String sere;
  String tarp;
  String eo;
  String asap;
  String suicide;
  String sharp;
  String add1;
  String add1Date;
  String add2;
  String add2Date;
  String add3;
  String add3Date;
  String add4;
  String add4Date;
  String add5;
  String add5Date;

  Training({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.cyber = '',
    this.opsec = '',
    this.antiTerror = '',
    this.lawOfWar = '',
    this.persRec = '',
    this.infoSec = '',
    this.ctip = '',
    this.gat = '',
    this.sere = '',
    this.tarp = '',
    this.eo = '',
    this.asap = '',
    this.suicide = '',
    this.sharp = '',
    this.add1 = '',
    this.add1Date = '',
    this.add2 = '',
    this.add2Date = '',
    this.add3 = '',
    this.add3Date = '',
    this.add4 = '',
    this.add4Date = '',
    this.add5 = '',
    this.add5Date = '',
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
    map['cyber'] = cyber;
    map['opsec'] = opsec;
    map['antiTerror'] = antiTerror;
    map['lawOfWar'] = lawOfWar;
    map['persRec'] = persRec;
    map['infoSec'] = infoSec;
    map['ctip'] = ctip;
    map['gat'] = gat;
    map['sere'] = sere;
    map['tarp'] = tarp;
    map['eo'] = eo;
    map['asap'] = asap;
    map['suicide'] = suicide;
    map['sharp'] = sharp;
    map['add1'] = add1;
    map['add1Date'] = add1Date;
    map['add2'] = add2;
    map['add2Date'] = add2Date;
    map['add3'] = add3;
    map['add3Date'] = add3Date;
    map['add4'] = add4;
    map['add4Date'] = add4Date;
    map['add5'] = add5;
    map['add5Date'] = add5Date;

    return map;
  }

  factory Training.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    return Training(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      cyber: doc['cyber'],
      opsec: doc['opsec'],
      antiTerror: doc['antiTerror'],
      lawOfWar: doc['lawOfWar'],
      persRec: doc['persRec'],
      infoSec: doc['infoSec'],
      ctip: doc['ctip'],
      gat: doc['gat'],
      sere: doc['sere'],
      tarp: doc['tarp'],
      eo: doc['eo'],
      asap: doc['asap'],
      suicide: doc['suicide'],
      sharp: doc['sharp'],
      add1: doc['add1'],
      add1Date: doc['add1Date'],
      add2: doc['add2'],
      add2Date: doc['add2Date'],
      add3: doc['add3'],
      add3Date: doc['add3Date'],
      add4: doc['add4'],
      add4Date: doc['add4Date'],
      add5: doc['add5'],
      add5Date: doc['add5Date'],
    );
  }
}
