import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import '../widgets/formatted_text_button.dart';

Future<bool> onBackPressed(BuildContext context) async {
  String title = 'Leave Without Saving?';
  Widget content = const Text('Do you want to leave the page without saving?');
  if (kIsWeb || Platform.isAndroid) {
    return await showDialog(
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
                  Navigator.pop(context2, false);
                },
              ),
              FormattedTextButton(
                label: 'Yes',
                onPressed: () {
                  Navigator.pop(context2, true);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ) ??
        false;
  } else {
    return await showCupertinoDialog(
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
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: getTextColor(context),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context2, false);
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: getTextColor(context),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context2, true);
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }
}
