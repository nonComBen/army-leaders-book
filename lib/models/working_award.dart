// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WorkingAward {
  String id;
  String soldierId;
  String owner;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String awardReason;
  String ach1;
  String ach2;
  String ach3;
  String ach4;
  String citation;

  WorkingAward({
    this.id,
    this.soldierId,
    @required this.owner,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.awardReason,
    this.ach1 = '',
    this.ach2 = '',
    this.ach3 = '',
    this.ach4 = '',
    this.citation = '',
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
    map['awardReason'] = awardReason;
    map['ach1'] = ach1;
    map['ach2'] = ach2;
    map['ach3'] = ach3;
    map['ach4'] = ach4;
    map['citation'] = citation;

    return map;
  }

  factory WorkingAward.fromSnapshot(DocumentSnapshot doc) {
    return WorkingAward(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      awardReason: doc['awardReason'],
      ach1: doc['ach1'],
      ach2: doc['ach2'],
      ach3: doc['ach3'],
      ach4: doc['ach4'],
      citation: doc['citation'],
    );
  }
}
