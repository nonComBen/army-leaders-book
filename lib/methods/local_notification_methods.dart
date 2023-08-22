import 'package:flutter/material.dart';

DateTime getDueDate(String date, int months) {
  DateTime dueDate = DateTime.tryParse(date) ?? DateTime.now();
  final result = dueDate.add(Duration(days: months * 30));
  debugPrint('Due Date: $result');
  return DateTime(result.year, result.month, result.day, 9);
}
