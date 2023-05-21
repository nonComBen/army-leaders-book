import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';
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
        builder: (context) {
          return AlertDialog(
            title: title,
            content: content,
            actions: [
              if (secondary != null)
                FormattedTextButton(
                  onPressed: () {
                    secondary();
                    Future.delayed(const Duration(milliseconds: 200),
                        () => Navigator.pop(context));
                  },
                  label: secondaryText,
                ),
              FormattedTextButton(
                onPressed: () {
                  primary();
                  Future.delayed(const Duration(milliseconds: 200),
                      () => Navigator.pop(context));
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
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: title,
          content: content,
          actions: [
            if (secondary != null)
              CupertinoDialogAction(
                child: Text(
                  secondaryText,
                  style: TextStyle(
                    color: getTextColor(ctx),
                  ),
                ),
                onPressed: () {
                  secondary();
                  Future.delayed(const Duration(milliseconds: 200),
                      () => Navigator.pop(ctx));
                },
              ),
            CupertinoDialogAction(
              child: Text(
                primaryText,
                style: TextStyle(
                  color: getTextColor(ctx),
                ),
              ),
              onPressed: () {
                primary();
                Future.delayed(const Duration(milliseconds: 200),
                    () => Navigator.pop(ctx));
              },
            )
          ],
        );
      },
    );
  }
}
