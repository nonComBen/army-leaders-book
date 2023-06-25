import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class NotificationMedpro {
  String date;
  int months;
  List<dynamic> notifications;

  NotificationMedpro({
    this.date = '',
    this.months = 0,
    this.notifications = const [],
  });
}

class Medpro {
  String? id;
  String? soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String pha;
  String dental;
  String vision;
  String hearing;
  String hiv;
  String flu;
  String anthrax;
  String encephalitis;
  String hepA;
  String hepB;
  String meningococcal;
  String mmr;
  String polio;
  String smallPox;
  String tetanus;
  String tuberculin;
  String typhoid;
  String varicella;
  String yellow;
  List<dynamic>? otherImms;
  List<dynamic>? notificationIds;

  Medpro({
    this.id,
    this.soldierId,
    required this.owner,
    required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.pha = '',
    this.dental = '',
    this.vision = '',
    this.hearing = '',
    this.hiv = '',
    this.flu = '',
    this.anthrax = '',
    this.encephalitis = '',
    this.hepA = '',
    this.hepB = '',
    this.meningococcal = '',
    this.mmr = '',
    this.polio = '',
    this.smallPox = '',
    this.tetanus = '',
    this.tuberculin = '',
    this.typhoid = '',
    this.varicella = '',
    this.yellow = '',
    this.otherImms,
    this.notificationIds,
  });

  static const String collectionName = 'medpros';

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
    map['pha'] = pha;
    map['dental'] = dental;
    map['vision'] = vision;
    map['hearing'] = hearing;
    map['hiv'] = hiv;
    map['flu'] = flu;
    map['anthrax'] = anthrax;
    map['encephalitis'] = encephalitis;
    map['hepA'] = hepA;
    map['hepB'] = hepB;
    map['meningococcal'] = meningococcal;
    map['mmr'] = mmr;
    map['polio'] = polio;
    map['smallPox'] = smallPox;
    map['tetanus'] = tetanus;
    map['tuberculin'] = tuberculin;
    map['typhoid'] = typhoid;
    map['varicella'] = varicella;
    map['yellow'] = yellow;
    map['otherImms'] = otherImms;
    map['notificationIds'] = notificationIds;

    return map;
  }

  factory Medpro.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    List<dynamic> otherImms = [];
    List<dynamic>? notificationIds;
    try {
      users = doc['users'];
      otherImms = doc['otherImms'];
      notificationIds = doc['notificationIds'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }

    return Medpro(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      pha: doc['pha'],
      dental: doc['dental'],
      vision: doc['vision'],
      hearing: doc['hearing'],
      hiv: doc['hiv'],
      flu: doc['flu'],
      anthrax: doc['anthrax'],
      encephalitis: doc['encephalitis'],
      hepA: doc['hepA'],
      hepB: doc['hepB'],
      meningococcal: doc['meningococcal'],
      mmr: doc['mmr'],
      polio: doc['polio'],
      smallPox: doc['smallPox'],
      tetanus: doc['tetanus'],
      tuberculin: doc['tuberculin'],
      typhoid: doc['typhoid'],
      varicella: doc['varicella'],
      yellow: doc['yellow'],
      otherImms: otherImms,
      notificationIds: notificationIds,
    );
  }
}
