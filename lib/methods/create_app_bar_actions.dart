import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../models/app_bar_option.dart';
import '../widgets/platform_widgets/platform_icon_button.dart';

List<Widget> createAppBarActions(double width, List<AppBarOption> options) {
  List<Widget> actions = [];
  int iconCount = getIconCount(width);
  List<AppBarOption> iconOptions = options;
  List<AppBarOption> overflowOptions = [];
  if (options.length > iconCount) {
    iconOptions = options.sublist(0, iconCount - 1);
    overflowOptions = options.sublist(iconCount - 1);
  }
  for (var icon in iconOptions) {
    actions.add(Tooltip(
        message: icon.title,
        child: PlatformIconButton(icon: icon.icon, onPressed: icon.onPressed)));
  }
  if (overflowOptions.isNotEmpty) {
    actions.add(
      PullDownButton(
        buttonBuilder: (context, showMenu) => PlatformIconButton(
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: getOnPrimaryColor(context),
          ),
          onPressed: showMenu,
        ),
        itemBuilder: (context) => overflowOptions
            .map((e) => PullDownMenuItem(onTap: e.onPressed, title: e.title))
            .toList(),
      ),
    );
  }

  return actions;
}

int getIconCount(double width) {
  if (width > 900) {
    return kIsWeb || Platform.isAndroid ? 6 : 5;
  }
  if (width > 700) {
    return kIsWeb || Platform.isAndroid ? 5 : 4;
  }
  if (width > 500) {
    return kIsWeb || Platform.isAndroid ? 4 : 3;
  }
  if (width > 400) {
    return kIsWeb || Platform.isAndroid ? 3 : 2;
  }
  return 1;
}
