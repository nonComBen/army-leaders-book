import 'package:cloud_firestore/cloud_firestore.dart';

class AlertSoldiers {
  String id;
  String owner;
  List<dynamic> soldiers;

  AlertSoldiers(this.id, this.owner, this.soldiers);

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
