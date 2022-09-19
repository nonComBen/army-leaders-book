// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WorkingEval {
  String id;
  String soldierId;
  String owner;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String dutyDescription;
  String appointedDuties;
  String specialEmphasis;
  String character;
  String presence;
  String intellect;
  String leads;
  String develops;
  String achieves;
  String performance;

  WorkingEval({
    this.id,
    this.soldierId,
    @required this.owner,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.dutyDescription = '',
    this.appointedDuties = '',
    this.specialEmphasis = '',
    this.character = '',
    this.presence = '',
    this.intellect = '',
    this.leads = '',
    this.develops = '',
    this.achieves = '',
    this.performance = '',
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
    map['dutyDescription'] = dutyDescription;
    map['appointedDuties'] = appointedDuties;
    map['specialEmphasis'] = specialEmphasis;
    map['character'] = character;
    map['presence'] = presence;
    map['intellect'] = intellect;
    map['leads'] = leads;
    map['develops'] = develops;
    map['achieves'] = achieves;
    map['performance'] = performance;

    return map;
  }

  factory WorkingEval.fromSnapshot(DocumentSnapshot doc) {
    //soldierId is null - only use for sharing
    return WorkingEval(
      id: doc.id,
      soldierId: doc['soldierId'],
      owner: doc['owner'],
      rank: doc['rank'],
      name: doc['name'],
      firstName: doc['firstName'],
      section: doc['section'],
      rankSort: doc['rankSort'],
      dutyDescription: doc['dutyDescription'],
      appointedDuties: doc['appointedDuties'],
      specialEmphasis: doc['specialEmphasis'],
      character: doc['character'],
      presence: doc['presence'],
      intellect: doc['intellect'],
      leads: doc['leads'],
      develops: doc['develops'],
      achieves: doc['achieves'],
      performance: doc['performance'],
    );
  }
}
