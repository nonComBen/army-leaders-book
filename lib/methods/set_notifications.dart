import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

import '../../models/notification.dart';
import '../../models/setting.dart';
import '../../models/user.dart';

void setDateNotifications({
  required Setting setting,
  required Map<String, dynamic> map,
  required UserObj user,
  required String topic,
}) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<int> days = getDays(topic, setting);
  String soldier = '${map['rank']} ${map['name']}';
  List<String?> tokens = user.deviceTokens.map((e) => e.toString()).toList();
  List<String> dates = [];
  List<DocumentSnapshot>? docs;
  if (tokens.isEmpty) {
    tokens = [await FirebaseMessaging.instance.getToken()];
  }
  QuerySnapshot snapshot = await firestore
      .collection(Notification.collectionName)
      .where('users', arrayContains: user.userId)
      .where('soldierId', isEqualTo: map['soldierId'])
      .where('topic', isEqualTo: topic)
      .get();
  if (snapshot.docs.isNotEmpty) {
    docs = snapshot.docs;
    dates = docs.map((e) => e['date'].toString()).toList();
  }

  for (int day in days) {
    DateTime date = DateTime.parse(map['date']);
    DateTime dueDate =
        date.add(Duration(days: getDueMonths(topic, setting) * 30));
    date = dueDate.subtract(Duration(days: day));
    DateFormat format = DateFormat('yyyy-MM-dd');
    String formattedDate = format.format(date);
    if (dates.contains(formattedDate)) {
      List<String?> docTokens =
          user.deviceTokens.map((e) => e.toString()).toList();
      bool allContained = true;
      for (String? token in tokens) {
        if (!docTokens.contains(token)) {
          allContained = false;
          break;
        }
      }
      if (!allContained) {
        final doc = docs!.firstWhere((e) => e['date'] == formattedDate);
        tokens.addAll(docTokens);
        doc.reference.update({'tokens': tokens});
      }
    } else {
      Notification notification = Notification(
          soldierId: map['soldierId'],
          body:
              '$soldier is due for $topic in $day days on ${format.format(dueDate)}',
          date: formattedDate,
          title: '$topic is Due',
          tokens: tokens,
          topic: topic,
          users: map['users']);

      firestore
          .collection(Notification.collectionName)
          .add(notification.toMap());
    }
  }
}

List<int> getDays(String topic, Setting setting) {
  switch (topic) {
    case 'ACFT':
      return setting.acftNotifications.map((e) => e as int).toSet().toList();
    case 'Body Composition':
      return setting.bfNotifications.map((e) => e as int).toSet().toList();
    case 'Weapons Qualification':
      return setting.weaponsNotifications.map((e) => e as int).toSet().toList();
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
    default:
      return 6;
  }
}
