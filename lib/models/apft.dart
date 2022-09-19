// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Apft {
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
  String gender;
  int age;
  String puRaw;
  String suRaw;
  String runRaw;
  int puScore;
  int suScore;
  int runScore;
  int total;
  String altEvent;
  bool pass;

  Apft(
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
      this.puRaw = '',
      this.suRaw = '',
      this.runRaw = '',
      this.puScore = 0,
      this.suScore = 0,
      this.runScore = 0,
      this.total = 0,
      this.altEvent = 'Run',
      this.pass = true,
      this.age = 17,
      this.gender = 'Male'});

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
    map['puRaw'] = puRaw;
    map['suRaw'] = suRaw;
    map['runRaw'] = runRaw;
    map['puScore'] = puScore;
    map['suScore'] = suScore;
    map['runScore'] = runScore;
    map['total'] = total;
    map['altEvent'] = altEvent;
    map['pass'] = pass;
    map['age'] = age;
    map['gender'] = gender;

    return map;
  }

  factory Apft.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return Apft(
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
        puRaw: doc['puRaw'],
        suRaw: doc['suRaw'],
        runRaw: doc['runRaw'],
        puScore: doc['puScore'],
        suScore: doc['suScore'],
        runScore: doc['runScore'],
        total: doc['total'],
        altEvent: doc['altEvent'],
        pass: doc['pass'],
        age: doc['age'],
        gender: doc['gender'] ?? 'Male');
  }
}
