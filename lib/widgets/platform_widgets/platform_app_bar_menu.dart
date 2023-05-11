import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_icon_button.dart';

import '../../models/app_bar_option.dart';

abstract class PlatformAppBarMenu extends StatelessWidget {
  factory PlatformAppBarMenu({required List<AppBarOption> options}) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidAppBarMenu(
        options: options,
      );
    } else {
      return IOSAppBarMenu(
        options: options,
      );
    }
  }
}

class AndroidAppBarMenu extends StatelessWidget implements PlatformAppBarMenu {
  const AndroidAppBarMenu({
    super.key,
    required this.options,
  });
  final List<AppBarOption> options;

  List<PlatformIconButton> iconButtons(double width) {
    List<PlatformIconButton> buttons = [];

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: iconButtons(width),
    );
  }
}

class IOSAppBarMenu extends StatelessWidget implements PlatformAppBarMenu {
  const IOSAppBarMenu({
    super.key,
    required this.options,
  });
  final List<AppBarOption> options;

  List<PlatformIconButton> iconButtons(double width) {
    List<PlatformIconButton> buttons = [];

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: iconButtons(width),
    );
  }
}
