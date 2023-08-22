import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Soldier {
  String? id;
  String owner;
  List<dynamic> users;
  String rank;
  int rankSort;
  String promotable;
  String lastName;
  String firstName;
  String mi;
  bool assigned;
  String supervisor;
  String section;
  String dodId;
  String cacExpiration;
  String dor;
  String mos;
  String duty;
  String paraLn;
  String reqMos;
  String lossDate;
  String ymav;
  String ets;
  String basd;
  String pebd;
  String gainDate;
  String civEd;
  String milEd;
  String nbcSuitSize;
  String nbcMaskSize;
  String nbcBootSize;
  String nbcGloveSize;
  String hatSize;
  String bootSize;
  String acuTopSize;
  String acuTrouserSize;
  String address;
  String city;
  String state;
  String zip;
  String phone;
  String workPhone;
  String email;
  String workEmail;
  String nok;
  String nokRelationship;
  String nokPhone;
  String maritalStatus;
  String comments;
  List<dynamic> povs;
  List<dynamic> awards;

  Soldier({
    this.id,
    required this.owner,
    required this.users,
    this.rank = '',
    this.rankSort = 0,
    this.promotable = '',
    this.lastName = '',
    this.firstName = '',
    this.mi = '',
    this.assigned = true,
    this.supervisor = '',
    this.section = '',
    this.dodId = '',
    this.cacExpiration = '',
    this.dor = '',
    this.mos = '',
    this.duty = '',
    this.paraLn = '',
    this.reqMos = '',
    this.lossDate = '',
    this.ymav = '',
    this.ets = '',
    this.basd = '',
    this.pebd = '',
    this.gainDate = '',
    this.civEd = '',
    this.milEd = '',
    this.nbcSuitSize = '',
    this.nbcMaskSize = '',
    this.nbcBootSize = '',
    this.nbcGloveSize = '',
    this.hatSize = '',
    this.bootSize = '',
    this.acuTopSize = '',
    this.acuTrouserSize = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zip = '',
    this.phone = '',
    this.workPhone = '',
    this.email = '',
    this.workEmail = '',
    this.nok = '',
    this.nokRelationship = '',
    this.nokPhone = '',
    this.maritalStatus = '',
    this.comments = '',
    this.awards = const [],
    this.povs = const [],
  });

  static const String collectionName = 'soldiers';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['rank'] = rank;
    map['rankSort'] = rankSort;
    map['promotable'] = promotable;
    map['lastName'] = lastName;
    map['firstName'] = firstName;
    map['middleInitial'] = mi;
    map['assigned'] = assigned;
    map['supervisorId'] = supervisor;
    map['section'] = section;
    map['dodId'] = dodId;
    map['cacExpiration'] = cacExpiration;
    map['dor'] = dor;
    map['mos'] = mos;
    map['duty'] = duty;
    map['paraLn'] = paraLn;
    map['reqMos'] = reqMos;
    map['deros'] = lossDate;
    map['ymav'] = ymav;
    map['ets'] = ets;
    map['basd'] = basd;
    map['pebd'] = pebd;
    map['arrival'] = gainDate;
    map['civEd'] = civEd;
    map['milEd'] = milEd;
    map['nbcSuitSize'] = nbcSuitSize;
    map['nbcMaskSize'] = nbcMaskSize;
    map['nbcBootSize'] = nbcBootSize;
    map['nbcGloveSize'] = nbcGloveSize;
    map['hatSize'] = hatSize;
    map['bootSize'] = bootSize;
    map['acuTopSize'] = acuTopSize;
    map['acuTrouserSize'] = acuTrouserSize;
    map['address'] = address;
    map['city'] = city;
    map['state'] = state;
    map['zip'] = zip;
    map['phone'] = phone;
    map['workPhone'] = workPhone;
    map['email'] = email;
    map['workEmail'] = workEmail;
    map['nok'] = nok;
    map['nokRelationship'] = nokRelationship;
    map['nokPhone'] = nokPhone;
    map['maritalStatus'] = maritalStatus;
    map['comments'] = comments;
    map['povs'] = povs;
    map['awards'] = awards;

    return map;
  }

  factory Soldier.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    List<dynamic> newPovs = [], newAwards = [];
    String nbcSuit = '',
        nbcMask = '',
        nbcBoot = '',
        nbcGloves = '',
        hat = '',
        boot = '',
        acuTop = '',
        acuTrouser = '',
        workEmail = '',
        workPhone = '',
        email = '',
        pebd = '',
        address = '',
        city = '',
        state = '',
        zip = '',
        dodId = '',
        maritalStatus = '',
        cacExpiration = '',
        nokRelationship = '',
        ymav = '';
    bool assigned = true;
    try {
      users = doc['users'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      workEmail = doc['workEmail'];
      workPhone = doc['workPhone'];
      email = doc['email'];
      pebd = doc['pebd'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      nbcSuit = doc['nbcSuitSize'];
      nbcMask = doc['nbcMaskSize'];
      nbcBoot = doc['nbcBootSize'];
      nbcGloves = doc['nbcGloveSize'];
      hat = doc['hatSize'];
      boot = doc['bootSize'];
      acuTop = doc['acuTopSize'];
      acuTrouser = doc['acuTrouserSize'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      address = doc['address'];
      city = doc['city'];
      state = doc['state'];
      zip = doc['zip'];
      dodId = doc['dodId'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      maritalStatus = doc['maritalStatus'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      assigned = doc['assigned'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      newPovs = doc['povs'];
      newAwards = doc['awards'];
    } catch (e) {
      debugPrint('Error: $e');
    }
    try {
      cacExpiration = doc['cacExpiration'];
      nokRelationship = doc['nokRelationship'];
      ymav = doc['ymav'];
    } catch (e) {
      debugPrint('Error: $e');
    }

    return Soldier(
      id: doc.id,
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      rankSort: doc['rankSort'],
      promotable: doc['promotable'],
      lastName: doc['lastName'],
      firstName: doc['firstName'],
      mi: doc['middleInitial'],
      assigned: assigned,
      supervisor: doc['supervisorId'],
      section: doc['section'],
      dodId: dodId,
      cacExpiration: cacExpiration,
      dor: doc['dor'],
      mos: doc['mos'],
      duty: doc['duty'],
      paraLn: doc['paraLn'],
      reqMos: doc['reqMos'],
      lossDate: doc['deros'],
      ymav: ymav,
      ets: doc['ets'],
      basd: doc['basd'],
      pebd: pebd,
      gainDate: doc['arrival'],
      civEd: doc['civEd'],
      milEd: doc['milEd'],
      nbcSuitSize: nbcSuit,
      nbcMaskSize: nbcMask,
      nbcBootSize: nbcBoot,
      nbcGloveSize: nbcGloves,
      hatSize: hat,
      bootSize: boot,
      acuTopSize: acuTop,
      acuTrouserSize: acuTrouser,
      address: address,
      city: city,
      state: state,
      zip: zip,
      phone: doc['phone'],
      workPhone: workPhone,
      email: email,
      workEmail: workEmail,
      nok: doc['nok'],
      nokRelationship: nokRelationship,
      nokPhone: doc['nokPhone'],
      maritalStatus: maritalStatus,
      comments: doc['comments'],
      povs: newPovs,
      awards: newAwards,
    );
  }
}
