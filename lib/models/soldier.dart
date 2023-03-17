import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
  String dor;
  String mos;
  String duty;
  String paraLn;
  String reqMos;
  String lossDate;
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
  String nokPhone;
  String maritalStatus;
  String comments;

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
    this.dor = '',
    this.mos = '',
    this.duty = '',
    this.paraLn = '',
    this.reqMos = '',
    this.lossDate = '',
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
    this.nokPhone = '',
    this.maritalStatus = '',
    this.comments = '',
  });

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
    map['dor'] = dor;
    map['mos'] = mos;
    map['duty'] = duty;
    map['paraLn'] = paraLn;
    map['reqMos'] = reqMos;
    map['deros'] = lossDate;
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
    map['nokPhone'] = nokPhone;
    map['maritalStatus'] = maritalStatus;
    map['comments'] = comments;

    return map;
  }

  factory Soldier.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
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
        maritalStatus = '';
    bool assigned = true;
    try {
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    try {
      workEmail = doc['workEmail'];
      workPhone = doc['workPhone'];
      email = doc['email'];
      pebd = doc['pebd'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'New Fields Do Not Exist');
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
      FirebaseAnalytics.instance.logEvent(name: 'New Fields Do Not Exist');
    }
    try {
      address = doc['address'];
      city = doc['city'];
      state = doc['state'];
      zip = doc['zip'];
      dodId = doc['dodId'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'New Fields Do Not Exist');
    }
    try {
      maritalStatus = doc['maritalStatus'];
    } catch (e) {
      FirebaseAnalytics.instance
          .logEvent(name: 'Marital Status Does Not Exist');
    }
    try {
      assigned = doc['assigned'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Assigned Does Not Exist');
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
      dor: doc['dor'],
      mos: doc['mos'],
      duty: doc['duty'],
      paraLn: doc['paraLn'],
      reqMos: doc['reqMos'],
      lossDate: doc['deros'],
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
      nokPhone: doc['nokPhone'],
      maritalStatus: maritalStatus,
      comments: doc['comments'],
    );
  }
}
