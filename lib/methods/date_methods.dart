import 'package:intl/intl.dart';

import 'validate.dart';

bool isOverdue(String date, int days) {
  if (date == '' || !isValidDate(date)) {
    return false;
  }
  var dateTime = DateTime.parse('$date 00:00:00');
  bool overdue = false;
  try {
    overdue = DateTime.now().isAfter(dateTime.add(Duration(days: days)));
  } catch (e) {
    return false;
  }
  return overdue;
}

String calcRecDate(String date, String exp) {
  var dateTime = DateTime.parse('$date 00:00:00');
  var expTime = DateTime.parse('$exp 00:00:00');

  int days = expTime.difference(dateTime).inDays + 1;

  days = days * 2;
  if (days > 90) days = 90;

  var recExp = expTime.add(Duration(days: days));
  DateFormat format = DateFormat('yyyy-MM-dd');
  return format.format(recExp);
}
