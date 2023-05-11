import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformListTile extends Widget {
  factory PlatformListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    void Function()? onTap,
    Color? color,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        tileColor: color,
      );
    } else {
      return IOSListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        backgroundColor: color,
      );
    }
  }
}

class AndroidListTile extends ListTile implements PlatformListTile {
  const AndroidListTile(
      {super.key,
      super.title,
      super.subtitle,
      super.leading,
      super.trailing,
      super.onTap,
      super.tileColor});
}

class IOSListTile extends CupertinoListTile implements PlatformListTile {
  const IOSListTile(
      {super.key,
      required super.title,
      super.subtitle,
      super.leading,
      super.trailing,
      super.onTap,
      super.backgroundColor});
}
