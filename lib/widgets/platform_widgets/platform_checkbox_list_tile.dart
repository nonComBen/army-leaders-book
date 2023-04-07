import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

abstract class PlatformCheckboxListTile extends Widget {
  factory PlatformCheckboxListTile({
    required Widget title,
    required bool value,
    Widget? subtitle,
    Color? activeColor,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
    void Function(bool?)? onChanged,
    void Function()? onIosTap,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidCheckboxListTile(
        value: value,
        title: title,
        subtitle: subtitle,
        activeColor: activeColor,
        controlAffinity: controlAffinity,
        onChanged: onChanged,
      );
    } else {
      return IOSCheckboxListTile(
        title: title,
        subtitle: subtitle,
        value: value,
        activeColor: activeColor,
        controlAffinity: controlAffinity,
        onChanged: onChanged,
        onIosTap: onIosTap,
      );
    }
  }
}

class AndroidCheckboxListTile extends CheckboxListTile
    implements PlatformCheckboxListTile {
  const AndroidCheckboxListTile({
    super.key,
    super.value,
    super.title,
    super.subtitle,
    super.activeColor,
    super.controlAffinity,
    super.onChanged,
  });
}

class IOSCheckboxListTile extends StatelessWidget
    implements PlatformCheckboxListTile {
  const IOSCheckboxListTile({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.activeColor,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.onChanged,
    this.onIosTap,
  });

  final Widget title;
  final Widget? subtitle;
  final bool value;
  final Color? activeColor;
  final ListTileControlAffinity? controlAffinity;
  final void Function(bool?)? onChanged;
  final void Function()? onIosTap;

  @override
  Widget build(BuildContext context) {
    final cupertinoSwitch = CupertinoSwitch(
      value: value,
      activeColor: activeColor ?? getOnPrimaryColor(context),
      onChanged: onChanged,
    );
    return CupertinoListTile(
      title: title,
      subtitle: subtitle,
      leading: controlAffinity == ListTileControlAffinity.leading
          ? cupertinoSwitch
          : null,
      trailing: controlAffinity == ListTileControlAffinity.trailing
          ? cupertinoSwitch
          : null,
      onTap: onIosTap,
    );
  }
}
