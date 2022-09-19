// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class UserObj {
  String userId;
  String userRank;
  String userEmail;
  String userUnit;
  String userName;
  String subToken;
  bool adFree;
  bool tosAgree;
  DateTime agreeDate;
  bool updatedUserArray;
  DateTime createdDate;
  DateTime lastLoginDate;

  UserObj({
    this.userId,
    this.userRank = '',
    this.userName = '',
    this.userUnit = '',
    this.userEmail = '',
    this.subToken = '',
    this.adFree = false,
    this.tosAgree = false,
    this.agreeDate,
    this.updatedUserArray = false,
    this.createdDate,
    this.lastLoginDate,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['userId'] = userId;
    map['userEmail'] = userEmail;
    map['userName'] = userName;
    map['rank'] = userRank;
    map['userUnit'] = userUnit;
    map['subToken'] = subToken;
    map['adFree'] = adFree;
    map['tosAgree'] = tosAgree;
    map['agreeDate'] = agreeDate;
    map['updatedUsersArray'] = updatedUserArray;
    map['created'] = createdDate;
    map['lastLogin'] = lastLoginDate;

    return map;
  }

  factory UserObj.fromSnapshot(DocumentSnapshot doc) {
    Timestamp timestamp = Timestamp.fromDate(DateTime.now()),
        created = Timestamp.fromDate(DateTime.now()),
        lastLogin = Timestamp.fromDate(DateTime.now());
    String rank = '', userName = '', userUnit = '';
    bool updatedArray = false;

    try {
      rank = doc['rank'];
      userName = doc['userName'];
      userUnit = doc['userUnit'];
    } catch (e) {
      print(e);
    }

    try {
      timestamp = doc['agreeDate'];
    } on Exception catch (e) {
      print('Error: $e');
    }

    try {
      updatedArray = doc['updatedUsersArray'];
    } catch (e) {
      print('Error: $e');
    }

    try {
      created = doc['created'];
      lastLogin = doc['lastLogin'];
    } catch (e) {
      print('Error: $e');
    }

    return UserObj(
      userId: doc.id,
      userRank: rank,
      userName: userName,
      userUnit: userUnit,
      userEmail: doc['userEmail'],
      subToken: doc['subToken'],
      adFree: doc['adFree'],
      tosAgree: doc['tosAgree'],
      agreeDate: timestamp.toDate(),
      updatedUserArray: updatedArray,
      createdDate: created.toDate(),
      lastLoginDate: lastLogin.toDate(),
    );
  }
}
