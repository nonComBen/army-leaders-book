import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/widgets/formatted_text_button.dart';

Future<void> customAlertDialog({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required String primaryText,
  required Function primary,
  String secondaryText = 'Cancel',
  void Function()? secondary,
}) async {
  if (kIsWeb || Platform.isAndroid) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: title,
            content: content,
            actions: [
              if (secondary != null)
                FormattedTextButton(
                  onPressed: () {
                    secondary();
                    Navigator.pop(ctx);
                  },
                  label: secondaryText,
                ),
              FormattedTextButton(
                onPressed: () {
                  primary();
                  Navigator.pop(ctx);
                },
                label: primaryText,
              ),
            ],
          );
        });
  } else {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context2) {
        return CupertinoAlertDialog(
          title: title,
          content: content,
          actions: [
            if (secondary != null)
              CupertinoDialogAction(
                child: Text(secondaryText),
                onPressed: () {
                  secondary();
                  Navigator.pop(context2);
                },
              ),
            CupertinoDialogAction(
              child: Text(primaryText),
              onPressed: () {
                Navigator.pop(context2);
                primary();
              },
            )
          ],
        );
      },
    );
  }
}
