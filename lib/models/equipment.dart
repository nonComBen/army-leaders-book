// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Equipment {
  String id;
  String soldierId;
  String owner;
  List<dynamic> users;
  String rank;
  String name;
  String firstName;
  String section;
  String rankSort;
  String weapon;
  String buttStock;
  String serial;
  String weapon2;
  String buttStock2;
  String serial2;
  String optic;
  String opticSerial;
  String optic2;
  String opticSerial2;
  String mask;
  String veh;
  String vehType;
  String license;
  String other;
  String otherSerial;

  Equipment({
    this.id,
    this.soldierId,
    @required this.owner,
    @required this.users,
    this.rank = '',
    this.name = '',
    this.firstName = '',
    this.section = '',
    this.rankSort = '',
    this.weapon = '',
    this.buttStock = '',
    this.serial = '',
    this.weapon2 = '',
    this.buttStock2 = '',
    this.serial2 = '',
    this.optic = '',
    this.opticSerial = '',
    this.optic2 = '',
    this.opticSerial2 = '',
    this.mask = '',
    this.veh = '',
    this.vehType = '',
    this.license = '',
    this.other = '',
    this.otherSerial = '',
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
    map['weapon'] = weapon;
    map['buttStock'] = buttStock;
    map['serial'] = serial;
    map['weapon2'] = weapon2;
    map['buttStock2'] = buttStock2;
    map['serial2'] = serial2;
    map['optic'] = optic;
    map['opticSerial'] = opticSerial;
    map['optic2'] = optic2;
    map['opticSerial2'] = opticSerial2;
    map['mask'] = mask;
    map['veh'] = veh;
    map['vehType'] = vehType;
    map['license'] = license;
    map['misc'] = other;
    map['miscSerial'] = otherSerial;

    return map;
  }

  factory Equipment.fromSnapshot(DocumentSnapshot doc) {
    List<dynamic> users = [doc['owner']];
    try {
      users = doc['users'];
    } catch (e) {
      print('Error: $e');
    }
    return Equipment(
        id: doc.id,
        soldierId: doc['soldierId'],
        owner: doc['owner'],
        users: users,
        rank: doc['rank'],
        name: doc['name'],
        firstName: doc['firstName'],
        section: doc['section'],
        rankSort: doc['rankSort'],
        weapon: doc['weapon'],
        buttStock: doc['buttStock'],
        serial: doc['serial'],
        weapon2: doc['weapon2'],
        buttStock2: doc['buttStock2'],
        serial2: doc['serial2'],
        optic: doc['optic'],
        opticSerial: doc['opticSerial'],
        optic2: doc['optic2'],
        opticSerial2: doc['opticSerial2'],
        mask: doc['mask'],
        veh: doc['veh'],
        vehType: doc['vehType'],
        license: doc['license'],
        other: doc['misc'],
        otherSerial: doc['miscSerial']);
  }
}
