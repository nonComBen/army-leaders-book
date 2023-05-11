import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

abstract class PlatformExpansionTile extends Widget {
  factory PlatformExpansionTile({
    required Widget title,
    Widget? trailing,
    Widget? leading,
    bool initiallyExpanded = false,
    Color? collapsedBackgroundColor,
    Color? collapsedTextColor,
    Color? collapsedIconColor,
    Color? textColor,
    required List<Widget> children,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidExpansionTile(
        title: title,
        trailing: trailing,
        leading: leading,
        initiallyExpanded: initiallyExpanded,
        collapsedBackgroundColor: collapsedBackgroundColor,
        collapsedIconColor: collapsedIconColor,
        collapsedTextColor: collapsedTextColor,
        textColor: textColor,
        children: children,
      );
    } else {
      return IOSExpansionTile(
        title: title,
        leading: leading,
        trailing: trailing,
        initiallyExpanded: initiallyExpanded,
        collapsedBackgroundColor: collapsedBackgroundColor,
        children: children,
      );
    }
  }
}

class AndroidExpansionTile extends ExpansionTile
    implements PlatformExpansionTile {
  const AndroidExpansionTile({
    super.key,
    required super.title,
    super.trailing,
    super.leading,
    super.initiallyExpanded,
    super.collapsedBackgroundColor,
    super.collapsedTextColor,
    super.collapsedIconColor,
    super.textColor,
    required super.children,
  });
}

class IOSExpansionTile extends StatefulWidget implements PlatformExpansionTile {
  const IOSExpansionTile({
    super.key,
    required this.title,
    this.trailing,
    this.leading,
    this.initiallyExpanded = false,
    this.collapsedBackgroundColor,
    required this.children,
  });
  final Widget title;
  final Widget? trailing;
  final Widget? leading;
  final bool initiallyExpanded;
  final Color? collapsedBackgroundColor;
  final List<Widget> children;

  @override
  State<IOSExpansionTile> createState() => _IOSExpansionTileState();
}

class _IOSExpansionTileState extends State<IOSExpansionTile> {
  bool isExpanded = false;
  late Widget rotatedIcon;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
    rotatedIcon = RotatedBox(
      quarterTurns: 2,
      child: widget.trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExpanded
                  ? getBackgroundColor(context)
                  : getPrimaryColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: widget.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isExpanded ? rotatedIcon : widget.trailing!,
                )
              ],
            ),
          ),
        ),
        if (isExpanded) Column(children: widget.children)
      ],
    );
  }
}
