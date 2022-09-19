// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Bodyfat {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  int age;
  String gender;
  String date;
  String height;
  String heightDouble;
  String weight;
  bool passBmi;
  String neck;
  String waist;
  String hip;
  String percent;
  bool passBf;

  Bodyfat({
    this.id,
    this.soldierId,
    @required this.owner,
    @required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.age = 0,
    this.gender = 'Male',
    this.date = '',
    this.height = '',
    this.heightDouble = '',
    this.weight = '',
    this.passBmi = true,
    this.neck = '',
    this.waist = '',
    this.hip = '',
    this.percent = '',
    this.passBf = true,
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
    map['age'] = age;
    map['date'] = date;
    map['height'] = height;
    map['weight'] = weight;
    map['passBmi'] = passBmi;
    map['neck'] = neck;
    map['waist'] = waist;
    map['hip'] = hip;
    map['percent'] = percent;
    map['passBf'] = passBf;
    map['gender'] = gender;
    map['heightDouble'] = heightDouble;

    return map;
  }

  factory Bodyfat.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return Bodyfat(
        id: doc.id,
        soldierId: doc['soldierId'],
        owner: doc['owner'],
        users: users,
        rank: doc['rank'],
        name: doc['name'],
        firstName: doc['firstName'],
        section: doc['section'],
        rankSort: doc['rankSort'],
        age: doc['age'],
        gender: doc['gender'] ?? 'Male',
        date: doc['date'],
        height: doc['height'],
        heightDouble: doc['heightDouble'],
        weight: doc['weight'],
        passBmi: doc['passBmi'],
        neck: doc['neck'],
        waist: doc['waist'],
        hip: doc['hip'],
        percent: doc['percent'],
        passBf: doc['passBf']);
  }
}
