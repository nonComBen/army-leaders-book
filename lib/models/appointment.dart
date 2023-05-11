import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Appointment {
  String? id;
  List<dynamic> users;
  String? soldierId;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String aptTitle;
  String date;
  String start;
  String end;
  String status;
  String comments;
  String owner;
  String location;

  Appointment({
    this.id,
    required this.users,
    this.soldierId,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.aptTitle = '',
    this.date = '',
    this.start = '',
    this.end = '',
    this.status = 'Scheduled',
    this.comments = '',
    required this.owner,
    this.location = '',
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
    map['aptTitle'] = aptTitle;
    map['date'] = date;
    map['start'] = start;
    map['end'] = end;
    map['status'] = status;
    map['comments'] = comments;
    map['eventId'] = null;
    map['calendarId'] = null;
    map['location'] = location;

    return map;
  }

  factory Appointment.fromSnapshot(DocumentSnapshot doc) {
    String location = '';
    List<dynamic> users = [doc['owner']];
    try {
      location = doc['location'];
      users = doc['users'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Users Does Not Exist');
    }
    //soldierId is null - only use for sharing
    return Appointment(
      id: doc.id,
      users: users,
      soldierId: doc['soldierId'],
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      aptTitle: doc['aptTitle'],
      date: doc['date'],
      start: doc['start'],
      end: doc['end'],
      status: doc['status'],
      comments: doc['comments'],
      owner: doc['owner'],
      location: location,
    );
  }
}
