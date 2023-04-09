import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../methods/theme_methods.dart';

abstract class PlatformItemPicker extends Widget {
  factory PlatformItemPicker({
    required Widget label,
    String? value,
    required List<String> items,
    required void Function(dynamic) onChanged,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidItemPicker(
        decoration: InputDecoration(
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: label,
          ),
        ),
        value: value,
        items: items
            .map(
              (event) => DropdownMenuItem<String>(
                value: event,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    event,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        isExpanded: true,
      );
    } else {
      return IOSItemPicker(
        itemBuilder: (context) {
          return items
              .map((e) => PullDownMenuItem(onTap: () => onChanged(e), title: e))
              .toList();
        },
        buttonBuilder: (context, showMenu) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: label,
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: getTextColor(context),
                    ),
                    borderRadius: BorderRadius.circular(8.0)),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(8.0),
                  onPressed: showMenu,
                  child: Text(
                    value ?? '',
                    style: TextStyle(
                      color: getTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

class AndroidItemPicker extends DropdownButtonFormField
    implements PlatformItemPicker {
  AndroidItemPicker(
      {super.key,
      super.items,
      super.value,
      super.onChanged,
      super.decoration,
      super.isExpanded});
}

class IOSItemPicker extends PullDownButton implements PlatformItemPicker {
  const IOSItemPicker(
      {super.key, required super.itemBuilder, required super.buttonBuilder});
}
