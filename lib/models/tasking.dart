// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Tasking {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String start;
  String end;
  String type;
  String comments;
  String location;
  String calendarId;
  String eventId;

  Tasking({
    this.id,
    this.soldierId,
    @required this.owner,
    @required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.start = '',
    this.end = '',
    this.type = '',
    this.comments = '',
    this.location = '',
    this.calendarId,
    this.eventId,
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
    map['start'] = start;
    map['end'] = end;
    map['type'] = type;
    map['comments'] = comments;
    map['location'] = location;
    map['calendarId'] = null;
    map['eventId'] = null;

    return map;
  }

  factory Tasking.fromSnapshot(DocumentSnapshot doc) {
    String location = '';
    try {
      location = doc['location'];
    } catch (e) {
      location = '';
    }
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return Tasking(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      users: users,
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      start: doc['start'],
      end: doc['end'],
      type: doc['type'],
      comments: doc['comments'],
      location: location,
      eventId: null,
      calendarId: null,
    );
  }
}
