import 'package:cloud_firestore/cloud_firestore.dart';

class AlertSoldiers {
  String? id;
  String? owner;
  List<dynamic>? soldiers;

  AlertSoldiers(this.id, this.owner, this.soldiers);

  static const String collectionName = 'alertSoldiers';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['soldiers'] = soldiers;

    return map;
  }

  factory AlertSoldiers.fromSnapshot(DocumentSnapshot doc) {
    return AlertSoldiers(doc.id, doc['owner'], doc['soldiers']);
  }
}

class AlertSoldier {
  String soldierId;
  String? supervisorId;
  String name;
  String rankSort;
  String phone;
  String workPhone;

  AlertSoldier({
    required this.soldierId,
    this.supervisorId,
    required this.name,
    required this.rankSort,
    required this.phone,
    required this.workPhone,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['soldierId'] = soldierId;
    map['supervisorId'] = supervisorId;
    map['soldier'] = name;
    map['rankSort'] = rankSort;
    map['phone'] = phone;
    map['workPhone'] = workPhone;

    return map;
  }

  factory AlertSoldier.fromMap(Map<String, dynamic> map) {
    return AlertSoldier(
      soldierId: map['soldierId'],
      supervisorId: map['supervisorId'],
      name: map['soldier'],
      rankSort: map['rankSort'],
      phone: map['phone'],
      workPhone: map['workPhone'],
    );
  }
}
