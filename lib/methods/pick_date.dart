import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

Future<DateTime?> pickAndroidDate({
  required BuildContext context,
  required DateTime date,
}) async {
  DateTime minDate = DateTime.now().add(const Duration(days: -365 * 20));
  DateTime maxDate = DateTime.now().add(const Duration(days: 365 * 5));
  return await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: minDate,
      lastDate: maxDate);
}

Future<void> pickIosDate({
  required BuildContext context,
  required DateTime date,
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
            minimumDate: DateTime.now().add(const Duration(days: -365 * 10)),
            maximumDate: DateTime.now().add(const Duration(days: 365 * 1)),
            onDateTimeChanged: onPicked,
          ),
        );
      });
}
