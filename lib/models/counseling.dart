import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Counseling {
  String id;
  String soldierId;
  String owner;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String date;
  String assessment;
  String indivRemarks;
  String keyPoints;
  String leaderResp;
  String planOfAction;
  String purpose;

  Counseling({
    this.id,
    this.soldierId,
    @required this.owner,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.date = '',
    this.assessment = '',
    this.indivRemarks = '',
    this.keyPoints = '',
    this.leaderResp = '',
    this.planOfAction = '',
    this.purpose = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['soldierId'] = soldierId;
    map['rank'] = rank;
    map['name'] = name;
    map['firstName'] = firstName;
    map['section'] = section;
    map['rankSort'] = rankSort;
    map['date'] = date;
    map['assessment'] = assessment;
    map['indivRemarks'] = indivRemarks;
    map['keyPoints'] = keyPoints;
    map['leaderResp'] = leaderResp;
    map['planOfAction'] = planOfAction;
    map['purpose'] = purpose;

    return map;
  }

  factory Counseling.fromSnapshot(DocumentSnapshot doc) {
    return Counseling(
        id: doc.id,
        soldierId: doc['soldierId'],
        owner: doc['owner'],
        rank: doc['rank'],
        name: doc['name'],
        firstName: doc['firstName'],
        section: doc['section'],
        rankSort: doc['rankSort'],
        date: doc['date'],
        assessment: doc['assessment'],
        indivRemarks: doc['indivRemarks'],
        keyPoints: doc['keyPoints'],
        leaderResp: doc['leaderResp'],
        planOfAction: doc['planOfAction'],
        purpose: doc['purpose']);
  }
}
