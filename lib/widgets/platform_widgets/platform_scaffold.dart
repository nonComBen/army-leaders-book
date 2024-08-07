import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../methods/theme_methods.dart';

abstract class PlatformScaffold extends StatelessWidget {
  factory PlatformScaffold({
    Key? key,
    String? title,
    List<Widget> actions = const [],
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    required Widget body,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidScaffold(
        key: key,
        title: title,
        actions: actions,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: body,
      );
    } else {
      return IOSScaffold(
        key: key,
        title: title,
        actions: actions,
        body: body,
      );
    }
  }
}

class AndroidScaffold extends StatelessWidget implements PlatformScaffold {
  const AndroidScaffold({
    super.key,
    this.title,
    this.actions = const [],
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    required this.body,
  });
  final String? title;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

class IOSScaffold extends StatelessWidget implements PlatformScaffold {
  const IOSScaffold({
    super.key,
    this.title,
    this.actions = const [],
    required this.body,
  });
  final String? title;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: title != null
          ? CupertinoNavigationBar(
              backgroundColor: getOnPrimaryColor(context),
              middle: Text(
                title!,
              ),
              trailing: actions.isNotEmpty
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: actions
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: e,
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : null,
            )
          : null,
      child: body,
    );
  }
}
