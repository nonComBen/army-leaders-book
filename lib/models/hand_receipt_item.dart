// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class HandReceiptItem {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String item;
  String model;
  String serial;
  String nsn;
  String location;
  String value;
  List<dynamic> subComponents;
  String comments;

  HandReceiptItem({
    this.id,
    this.soldierId,
    @required this.owner,
    @required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.item = '',
    this.model = '',
    this.serial = '',
    this.nsn = '',
    this.location = '',
    this.value = '',
    @required this.subComponents,
    this.comments = '',
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
    map['item'] = item;
    map['model'] = model;
    map['serial'] = serial;
    map['nsn'] = nsn;
    map['location'] = location;
    map['value'] = value;
    map['subComponents'] = subComponents;
    map['comments'] = comments;

    return map;
  }

  factory HandReceiptItem.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return HandReceiptItem(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      item: doc['item'],
      model: doc['model'],
      serial: doc['serial'],
      nsn: doc['nsn'],
      location: doc['location'],
      value: doc['value'],
      subComponents: doc['subComponents'],
      comments: doc['comments'],
    );
  }
}
