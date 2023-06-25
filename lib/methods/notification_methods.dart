import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/notification.dart';
import '../models/setting.dart';
import '../models/user.dart';

List<int> getDays(String topic, Setting setting) {
  switch (topic) {
    case 'ACFT':
      return setting.acftNotifications.map((e) => e as int).toSet().toList();
    case 'Body Composition':
      return setting.bfNotifications.map((e) => e as int).toSet().toList();
    case 'Weapons Qualification':
      return setting.weaponsNotifications.map((e) => e as int).toSet().toList();
    case 'PHA':
      return setting.phaNotifications.map((e) => e as int).toSet().toList();
    case 'Dental':
      return setting.dentalNotifications.map((e) => e as int).toSet().toList();
    case 'Vision':
      return setting.visionNotifications.map((e) => e as int).toSet().toList();
    case 'Hearing':
      return setting.hearingNotifications.map((e) => e as int).toSet().toList();
    case 'HIV':
      return setting.hivNotifications.map((e) => e as int).toSet().toList();
    default:
      return [0];
  }
}

int getDueMonths(String topic, Setting setting) {
  switch (topic) {
    case 'ACFT':
      return setting.acftMonths;
    case 'Body Composition':
      return setting.bfMonths;
    case 'Weapons Qualification':
      return setting.weaponsMonths;
    case 'PHA':
      return setting.phaMonths;
    case 'Dental':
      return setting.dentalMonths;
    case 'Vision':
      return setting.visionMonths;
    case 'Hearing':
      return setting.hearingMonths;
    case 'HIV':
      return setting.hivMonths;
    default:
      return 6;
  }
}

Future<List<String?>> getDeviceTokens(UserObj user) async {
  List<String?> result = user.deviceTokens.map((e) => e.toString()).toList();
  if (result.isEmpty) {
    result = [await FirebaseMessaging.instance.getToken()];
  }
  return result;
}

void updateNotification({
  required UserObj user,
  required List<String?> tokens,
  required List<DocumentSnapshot> docs,
  required String notificationDate,
}) {
  List<String?> docTokens = user.deviceTokens.map((e) => e.toString()).toList();
  bool allContained = true;
  for (String? token in tokens) {
    if (!docTokens.contains(token)) {
      allContained = false;
      break;
    }
  }
  if (!allContained) {
    final doc = docs.firstWhere((e) => e['date'] == notificationDate);
    tokens.addAll(docTokens);
    doc.reference.update({'tokens': tokens});
  }
}

void setNotification({
  required String soldierId,
  required String soldierName,
  required String topic,
  required String daysDue,
  required String dueDate,
  required String notificationDate,
  required List<String?> tokens,
  required List<String> users,
}) {
  Notification notification = Notification(
      soldierId: soldierId,
      body: '$soldierName is due for $topic in $daysDue days on $dueDate',
      date: notificationDate,
      title: '$topic is Due',
      tokens: tokens,
      topic: topic,
      users: users);

  FirebaseFirestore.instance
      .collection(Notification.collectionName)
      .add(notification.toMap());
}

Future<List<DocumentSnapshot<Object?>>> getNotificationDocs(
    {required String userId,
    required String soldierId,
    required String topic}) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(Notification.collectionName)
      .where('users', arrayContains: userId)
      .where('soldierId', isEqualTo: soldierId)
      .where('topic', isEqualTo: topic)
      .get();
  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs;
  } else {
    return [];
  }
}
