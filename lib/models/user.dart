import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
  DateTime? createdDate;
  DateTime? lastLoginDate;

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
    Timestamp agreeTimestamp = Timestamp.fromDate(DateTime.now()),
        createdTimestamp = Timestamp.fromDate(DateTime.now()),
        lastLoginTimestamp = Timestamp.fromDate(DateTime.now());
    String rank = '', userName = '', userUnit = '';
    bool isUserArrayUpdated = false;

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
      createdTimestamp = doc['created'] ?? Timestamp.fromDate(DateTime.now());
      lastLoginTimestamp =
          doc['lastLogin'] ?? Timestamp.fromDate(DateTime.now());
    } catch (e) {
      FirebaseAnalytics.instance
          .logEvent(name: 'CreatedTimeStamp Does Not Exist');
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
      createdDate: createdTimestamp.toDate(),
      lastLoginDate: lastLoginTimestamp.toDate(),
    );
  }
}
