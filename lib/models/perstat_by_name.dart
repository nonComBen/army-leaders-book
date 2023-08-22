import 'package:cloud_firestore/cloud_firestore.dart';

class PerstatByName {
  String? owner;
  String date;
  List<dynamic> dailies;

  PerstatByName({
    required this.owner,
    this.date = '',
    this.dailies = const [],
  });

  static const String collectionName = 'perstatByName';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['date'] = date;
    map['dailies'] = dailies;

    return map;
  }

  factory PerstatByName.fromSnapshot(DocumentSnapshot snapshot) {
    return PerstatByName(
        owner: snapshot['owner'],
        date: snapshot['date'],
        dailies: snapshot['dailies']);
  }
}
