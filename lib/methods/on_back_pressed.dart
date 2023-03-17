import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/formatted_text_button.dart';

Future<bool> onBackPressed(BuildContext context) async {
  bool stay = false;
  String title = 'Leave Without Saving?';
  Widget content = const Text('Do you want to leave the page without saving?');
  if (kIsWeb || Platform.isAndroid) {
    await showDialog(
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
            onPressed: () {
              stay = false;
              Navigator.pop(context2);
            },
          ),
          FormattedTextButton(
            label: 'Yes',
            onPressed: () {
              stay = true;
              Navigator.pop(context2);
            },
          )
        ],
      ),
    );
  } else {
    await showCupertinoDialog(
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
              onPressed: () {
                stay = false;
                Navigator.pop(context2);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () {
                stay = true;
                Navigator.pop(context2);
              },
            )
          ],
        );
      },
    );
  }
  return stay;
}
