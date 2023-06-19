import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/validate.dart';

import '../../models/setting.dart';
import '../../models/user.dart';
import 'notification_methods.dart';

void setDateNotifications({
  required Setting setting,
  required Map<String, dynamic> map,
  required UserObj user,
  required String topic,
}) async {
  if (!isValidDate(map['date']) || map['date'] == '') {
    return;
  }
  List<int> days = getDays(topic, setting);
  String soldier = '${map['rank']} ${map['name']}';
  List<String?> tokens = await getDeviceTokens(user);
  List<DocumentSnapshot> docs = await getNotificationDocs(
    userId: user.userId!,
    soldierId: map['soldierId'],
    topic: topic,
  );
  List<String> dates = docs.map((e) => e['date'].toString()).toList();
  DateTime date = DateTime.parse(map['date']);
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
        soldierId: map['soldierId'],
        soldierName: soldier,
        topic: topic,
        daysDue: day.toString(),
        dueDate: format.format(dueDate),
        notificationDate: notificationDate,
        tokens: tokens,
        users: map['users'],
      );
    }
  }
}
