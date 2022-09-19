// ignore_for_file: file_names, avoid_print

import 'package:excel/excel.dart';
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
  DateFormat dateFormat = DateFormat('yy-MM-dd');

  try {
    DateTime dateTime = DateFormat.yMd().parse(date);
    formattedDate = '20${dateFormat.format(dateTime)}';
  } catch (e) {
    print('DateTime Parse Error: $e');
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

String getCellValue(List<Data> row, List<String> headers, String header) {
  if (header == '') {
    return '';
  }
  if (row[headers.indexOf(header) - 1] == null) {
    return '';
  } else {
    return row[headers.indexOf(header) - 1].value.toString();
  }
}
