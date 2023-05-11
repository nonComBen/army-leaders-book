import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../methods/theme_methods.dart';
import '../../models/soldier.dart';

abstract class PlatformSoldierPicker extends Widget {
  factory PlatformSoldierPicker({
    required String label,
    String? title,
    String? value,
    required List<Soldier> soldiers,
    required void Function(dynamic) onChanged,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidItemPicker(
        decoration: InputDecoration(
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(label),
          ),
        ),
        value: value,
        items: soldiers
            .map(
              (soldier) => DropdownMenuItem<String>(
                value: soldier.id,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${soldier.rank} ${soldier.lastName}, ${soldier.firstName}',
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
          return soldiers
              .map(
                (soldier) => PullDownMenuItem(
                    onTap: () => onChanged(soldier.id),
                    title:
                        '${soldier.rank} ${soldier.lastName}, ${soldier.firstName}'),
              )
              .toList();
        },
        buttonBuilder: (context, showMenu) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(label),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: getTextColor(context),
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(8.0),
                  onPressed: showMenu,
                  child: Text(
                    value != null
                        ? getDisplay(soldiers.firstWhere((e) => e.id == value))
                        : '',
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

String getDisplay(Soldier soldier) {
  return '${soldier.rank} ${soldier.lastName}, ${soldier.firstName}';
}

class AndroidItemPicker extends DropdownButtonFormField
    implements PlatformSoldierPicker {
  AndroidItemPicker(
      {super.key,
      super.items,
      super.value,
      super.onChanged,
      super.decoration,
      super.isExpanded});
}

class IOSItemPicker extends PullDownButton implements PlatformSoldierPicker {
  const IOSItemPicker(
      {super.key, required super.itemBuilder, required super.buttonBuilder});
}
