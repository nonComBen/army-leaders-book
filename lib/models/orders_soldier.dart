// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersSoldier {
  String owner;
  List<dynamic> users;
  String rank;
  String rankSort;
  String name;
  String section;
  bool required;
  String status;
  DateTime apt;
  String comments;

  OrdersSoldier({
    this.owner,
    this.users,
    this.rank = '',
    this.rankSort = '',
    this.name = '',
    this.section = '',
    this.required = false,
    this.status = '',
    this.apt,
    this.comments = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['rank'] = rank;
    map['rankSort'] = rankSort;
    map['name'] = name;
    map['section'] = section;
    map['required'] = required;
    map['status'] = status;
    map['apt'] = apt;
    map['comments'] = comments;

    return map;
  }

  factory OrdersSoldier.fromSnapshot(DocumentSnapshot doc) {
    String name =
        '${doc['lastName']}, ${doc['firstName']} ${doc['middleInitial']}';
    return OrdersSoldier(
      owner: doc['owner'],
      users: doc['users'],
      rank: doc['rank'],
      rankSort: doc['rankSort'],
      name: name,
      section: doc['section'],
      required: doc['required'],
      status: doc['status'],
      apt: doc['apt'],
      comments: doc['comments'],
    );
  }
}
