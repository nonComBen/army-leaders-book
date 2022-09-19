// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ActionObj {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String action;
  String dateSubmitted;
  String currentStatus;
  String statusDate;
  String remarks;

  ActionObj({
    this.id,
    this.soldierId,
    @required this.owner,
    @required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.action = '',
    this.dateSubmitted = '',
    this.currentStatus = '',
    this.statusDate = '',
    this.remarks = '',
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
    map['action'] = action;
    map['dateSubmitted'] = dateSubmitted;
    map['currentStatus'] = currentStatus;
    map['statusDate'] = statusDate;
    map['remarks'] = remarks;

    return map;
  }

  factory ActionObj.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return ActionObj(
        id: doc.id,
        soldierId: doc['soldierId'],
        owner: doc['owner'],
        users: users,
        rank: doc['rank'],
        name: doc['name'],
        firstName: doc['firstName'],
        section: doc['section'],
        rankSort: doc['rankSort'],
        action: doc['action'],
        dateSubmitted: doc['dateSubmitted'],
        currentStatus: doc['currentStatus'],
        statusDate: doc['statusDate'],
        remarks: doc['remarks']);
  }
}
