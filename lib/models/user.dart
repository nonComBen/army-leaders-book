import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class UserObj {
  String? userId;
  String userRank;
  String userEmail;
  String userUnit;
  String userName;
  String? subToken;
  bool adFree;
  bool tosAgree;
  DateTime? agreeDate;
  bool updatedUserArray;
  bool updatedPovs;
  bool updatedAwards;
  bool updatedTraining;
  DateTime? createdDate;
  DateTime? lastLoginDate;
  List<dynamic> deviceTokens;

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
    this.updatedPovs = false,
    this.updatedAwards = false,
    this.updatedTraining = false,
    this.createdDate,
    this.lastLoginDate,
    this.deviceTokens = const [],
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
    map['updatedPovs'] = updatedPovs;
    map['updatedAwards'] = updatedAwards;
    map['updatedTraining'] = updatedTraining;
    map['deviceTokens'] = deviceTokens;

    return map;
  }

  factory UserObj.fromSnapshot(DocumentSnapshot doc) {
    Timestamp agreeTimestamp = Timestamp.fromDate(DateTime.now()),
        createdTimestamp = Timestamp.fromDate(DateTime.now()),
        lastLoginTimestamp = Timestamp.fromDate(DateTime.now());
    String rank = '', userName = '', userUnit = '';
    bool isUserArrayUpdated = false,
        isPovsUpdated = false,
        isAwardsUpdated = false,
        isTrainingUpdated = false;
    List<dynamic> tokens = [];
    try {
      rank = doc['rank'];
      userName = doc['userName'];
      userUnit = doc['userUnit'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'New Fields Do Not Exist');
    }

    try {
      agreeTimestamp = doc['agreeDate'] ?? Timestamp.fromDate(DateTime.now());
    } catch (e) {
      FirebaseAnalytics.instance
          .logEvent(name: 'AgreeTimeStamp Does Not Exist');
    }

    try {
      isUserArrayUpdated = doc['updatedUsersArray'];
    } catch (e) {
      FirebaseAnalytics.instance
          .logEvent(name: 'IsUsersArrayUpdated Does Not Exist');
    }

    try {
      isPovsUpdated = doc['updatedPovs'];
      isAwardsUpdated = doc['updatedAwards'];
      isTrainingUpdated = doc['updatedTraining'];
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'updatedPovs Does Not Exist');
    }

    try {
      createdTimestamp = doc['created'] ?? Timestamp.fromDate(DateTime.now());
      lastLoginTimestamp =
          doc['lastLogin'] ?? Timestamp.fromDate(DateTime.now());
    } catch (e) {
      FirebaseAnalytics.instance
          .logEvent(name: 'CreatedTimeStamp Does Not Exist');
    }

    try {
      tokens = doc['deviceTokens'];
    } catch (e) {
      debugPrint('Error: $e');
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
      agreeDate: agreeTimestamp.toDate(),
      updatedUserArray: isUserArrayUpdated,
      updatedPovs: isPovsUpdated,
      updatedAwards: isAwardsUpdated,
      updatedTraining: isTrainingUpdated,
      createdDate: createdTimestamp.toDate(),
      lastLoginDate: lastLoginTimestamp.toDate(),
      deviceTokens: tokens,
    );
  }
}
