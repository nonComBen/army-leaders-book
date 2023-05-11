import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../methods/theme_methods.dart';

void customModalBottomSheet(BuildContext context, Widget content) {
  if (kIsWeb || Platform.isAndroid) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom == 0
              ? MediaQuery.of(context).padding.bottom
              : MediaQuery.of(context).viewInsets.bottom,
        ),
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 2 / 3,
        ),
        decoration: BoxDecoration(
          color: getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: content,
      ),
    );
  } else {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom == 0
              ? MediaQuery.of(context).padding.bottom
              : MediaQuery.of(context).viewInsets.bottom,
        ),
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 2 / 3,
        ),
        decoration: BoxDecoration(
          color: getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: content,
      ),
    );
  }
}
