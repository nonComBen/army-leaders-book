import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

Future<DateTime?> pickAndroidDate({
  required BuildContext context,
  required DateTime date,
  required int minYears,
  required int maxYears,
}) async {
  DateTime minDate = DateTime.now().add(Duration(days: -365 * minYears));
  DateTime maxDate = DateTime.now().add(Duration(days: 365 * maxYears));
  return await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: minDate,
      lastDate: maxDate);
}

Future<void> pickIosDate({
  required BuildContext context,
  required DateTime date,
  required int minYears,
  required int maxYears,
  required void Function(DateTime) onPicked,
}) async {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        color: getBackgroundColor(context),
        constraints: const BoxConstraints(maxWidth: 900),
        height: MediaQuery.of(context).size.height / 4,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: date,
          minimumDate: DateTime.now().add(Duration(days: -365 * minYears)),
          maximumDate: DateTime.now().add(Duration(days: 365 * maxYears)),
          onDateTimeChanged: onPicked,
        ),
      );
    },
  );
}
