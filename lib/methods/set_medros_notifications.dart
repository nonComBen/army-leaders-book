import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../methods/validate.dart';
import '../../models/medpro.dart';
import '../models/setting.dart';
import '../models/user.dart';
import 'notification_methods.dart';

void setMedprosNotifications({
  required Setting setting,
  required Medpro medpro,
  required UserObj user,
}) async {
  String soldier = '${medpro.rank} ${medpro.name}';
  List<String?> tokens = await getDeviceTokens(user);
  List<String> topics = ['PHA', 'Dental', 'Vision', 'Hearing', 'HIV'];

  for (String topic in topics) {
    String topicDate = getDate(medpro: medpro, topic: topic);
    if (!isValidDate(topicDate) || topicDate == '') {
      break;
    }
    List<int> days = getDays(topic, setting);
    List<DocumentSnapshot> docs = await getNotificationDocs(
      userId: user.userId!,
      soldierId: medpro.soldierId!,
      topic: topic,
    );
    List<String> dates = docs.map((e) => e['date'].toString()).toList();
    DateTime date = DateTime.parse(topicDate);
    DateTime dueDate =
        date.add(Duration(days: getDueMonths(topic, setting) * 30));

    for (int day in days) {
      DateFormat format = DateFormat('yyyy-MM-dd');
      String notificationDate =
          format.format(dueDate.subtract(Duration(days: day)));
      if (dates.contains(notificationDate)) {
        updateNotification(
          user: user,
          tokens: tokens,
          docs: docs,
          notificationDate: notificationDate,
        );
      } else {
        setNotification(
          soldierId: medpro.soldierId!,
          soldierName: soldier,
          topic: topic,
          daysDue: day.toString(),
          dueDate: format.format(dueDate),
          notificationDate: notificationDate,
          tokens: tokens,
          users: medpro.users.map((e) => e.toString()).toList(),
        );
      }
    }
  }
}

String getDate({required Medpro medpro, required String topic}) {
  switch (topic) {
    case 'PHA':
      return medpro.pha;
    case 'Dental':
      return medpro.dental;
    case 'Vision':
      return medpro.vision;
    case 'Hearing':
      return medpro.hearing;
    case 'HIV':
      return medpro.hiv;
    default:
      return '';
  }
}
