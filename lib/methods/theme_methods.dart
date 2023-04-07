import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Color getPrimaryColor(BuildContext context) {
  if (kIsWeb || Platform.isAndroid) {
    return Theme.of(context).colorScheme.primary;
  } else {
    return CupertinoTheme.of(context).primaryColor;
  }
}

Color getOnPrimaryColor(BuildContext context) {
  if (kIsWeb || Platform.isAndroid) {
    return Theme.of(context).colorScheme.onPrimary;
  } else {
    return CupertinoTheme.of(context).primaryContrastingColor;
  }
}

Color getBackgroundColor(BuildContext context) {
  if (kIsWeb || Platform.isAndroid) {
    return Theme.of(context).scaffoldBackgroundColor;
  } else {
    return CupertinoTheme.of(context).scaffoldBackgroundColor;
  }
}

Color getContrastingBackgroundColor(BuildContext context) {
  if (kIsWeb || Platform.isAndroid) {
    return Theme.of(context).dialogBackgroundColor;
  } else {
    return CupertinoTheme.of(context).barBackgroundColor;
  }
}

Brightness getThemeBrightness(BuildContext context) {
  if (kIsWeb || Platform.isAndroid) {
    return Theme.of(context).brightness;
  } else {
    return CupertinoTheme.of(context).brightness!;
  }
}

Color getTextColor(BuildContext context) {
  if (kIsWeb || Platform.isAndroid) {
    return getThemeBrightness(context) == Brightness.light
        ? Colors.black
        : Colors.white;
  } else {
    return getThemeBrightness(context) == Brightness.light
        ? Colors.black
        : Colors.white;
  }
}
