import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

Future<TimeOfDay?> pickAndroidTime({
  required BuildContext context,
  required TimeOfDay time,
}) async {
  return await showTimePicker(
    context: context,
    initialTime: time,
  );
}

Future<void> pickIosTime({
  required BuildContext context,
  required DateTime time,
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
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: time,
          onDateTimeChanged: onPicked,
        ),
      );
    },
  );
}
