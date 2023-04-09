import 'package:excel/excel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';

import '../methods/validate.dart';

String convertDate(String date) {
  if (isValidDate(date) || date == 'Exempt') return date;
  if (isYyyyMMdd(date)) {
    String newDate =
        '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6)}';
    return newDate;
  }

  String formattedDate = '';
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  try {
    final dateInt = int.tryParse(date) ?? 0;
    if (dateInt > 0) {
      final dateTime = DateTime(1899, 12, 30).add(Duration(days: dateInt));
      formattedDate = dateFormat.format(dateTime);
    } else {
      formattedDate = date.substring(0, 10);
    }
  } catch (e) {
    FirebaseAnalytics.instance.logEvent(name: 'DateTime Parse Error');
  }

  return formattedDate;
}

List<Map<dynamic, dynamic>> convertToMap(String mapString) {
  List<Map<dynamic, dynamic>> listMap = [{}];
  List<String> list = mapString.split(';');

  for (String string in list) {
    Map<String, String> map = {};
    map['title'] =
        string.substring(string.indexOf('title:'), string.indexOf(',')).trim();
    map['date'] =
        string.substring(string.indexOf('date:'), string.indexOf('}')).trim();
    listMap.add(map);
  }

  return listMap;
}

String getCellValue(List<Data?> row, List<String?>? headers, String? header) {
  if (header == '') {
    return '';
  }
  if (row[headers!.indexOf(header) - 1] == null) {
    return '';
  } else {
    return row[headers.indexOf(header) - 1]!.value.toString();
  }
}

List<String> getColumnHeaders(List<Data?> row) {
  List<String> columnHeaders = [''];
  for (var cell in row) {
    if (cell!.value.toString() != '') {
      columnHeaders.add(cell.value.toString());
    }
  }
  return columnHeaders;
}
