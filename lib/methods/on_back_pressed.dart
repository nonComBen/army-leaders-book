// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/formatted_text_button.dart';

Future<bool> onBackPressed(BuildContext context) {
  String title = 'Leave Without Saving?';
  Widget content = const Text('Do you want to leave the page without saving?');
  if (kIsWeb || Platform.isAndroid) {
    return showDialog(
        context: context,
        builder: (context2) => AlertDialog(
              title: Text(title),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: content,
              ),
              actions: <Widget>[
                FormattedTextButton(
                  label: 'No',
                  onPressed: () => Navigator.pop(context2, false),
                ),
                FormattedTextButton(
                  label: 'Yes',
                  onPressed: () => Navigator.pop(context2, true),
                )
              ],
            ));
  } else {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context2) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: content,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () => Navigator.pop(context2, false),
              ),
              CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () => Navigator.pop(context2, true),
              )
            ],
          );
        });
  }
}
