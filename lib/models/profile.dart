// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TempProfile {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String date;
  String exp;
  String recExp;
  String type;
  String comments;
  String eventId;
  String calendarId;

  TempProfile(
      {this.id,
      this.soldierId,
      @required this.owner,
      @required this.users,
      this.rank = '',
      this.name = '',
      this.firstName = '',
      this.section = '',
      this.rankSort = '',
      this.date = '',
      this.exp = '',
      this.recExp = '',
      this.type = 'Temporary',
      this.comments = '',
      this.eventId,
      this.calendarId});

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
    map['date'] = date;
    map['exp'] = exp;
    map['recExp'] = recExp;
    map['type'] = type;
    map['comments'] = comments;
    map['eventId'] = eventId;
    map['calendarId'] = calendarId;

    return map;
  }

  factory TempProfile.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return TempProfile(
        id: doc.id,
        soldierId: doc['soldierId'],
        owner: doc['owner'],
        users: users,
        rank: doc['rank'],
        name: doc['name'],
        firstName: doc['firstName'],
        section: doc['section'],
        rankSort: doc['rankSort'],
        date: doc['date'],
        exp: doc['exp'],
        recExp: doc['recExp'],
        type: doc['type'],
        comments: doc['comments'],
        eventId: null,
        calendarId: null);
  }
}

class PermProfile {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String date;
  String type;
  bool shaving;
  bool pu;
  bool su;
  bool run;
  String altEvent;
  String comments;

  PermProfile({
    this.id,
    this.soldierId,
    @required this.owner,
    @required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.date = '',
    this.type = 'Permanent',
    this.shaving = false,
    this.pu = false,
    this.su = false,
    this.run = false,
    this.altEvent = '',
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
    map['date'] = date;
    map['type'] = type;
    map['shaving'] = shaving;
    map['pu'] = pu;
    map['su'] = su;
    map['run'] = run;
    map['altEvent'] = altEvent;
    map['comments'] = comments;

    return map;
  }

  factory PermProfile.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return PermProfile(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      date: doc['date'],
      type: doc['type'],
      shaving: doc['shaving'],
      pu: doc['pu'],
      su: doc['su'],
      run: doc['run'],
      altEvent: doc['altEvent'],
      comments: doc['comments'],
    );
  }
}
