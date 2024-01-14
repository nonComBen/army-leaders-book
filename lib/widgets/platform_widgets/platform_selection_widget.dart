import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../methods/theme_methods.dart';

abstract class PlatformSelectionWidget extends Widget {
  factory PlatformSelectionWidget({
    required List<Widget> titles,
    required List<Object> values,
    Object? groupValue,
    required void Function(Object?) onChanged,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidSelectionWidget(
          titles: titles,
          values: values,
          groupValue: groupValue,
          onChanged: onChanged);
    } else {
      return IOSSelectionWidget(
        titles: titles,
        values: values,
        groupValue: groupValue,
        onChanged: onChanged,
      );
    }
  }
}

class AndroidSelectionWidget extends StatelessWidget
    implements PlatformSelectionWidget {
  const AndroidSelectionWidget(
      {super.key,
      required this.titles,
      required this.values,
      required this.groupValue,
      required this.onChanged});
  final List<Widget> titles;
  final List<Object> values;
  final Object? groupValue;
  final void Function(Object?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
          child: RadioListTile(
            title: titles[0],
            value: values[0],
            groupValue: groupValue,
            activeColor: getPrimaryColor(context),
            onChanged: (dynamic value) {
              onChanged(value);
            },
          ),
        ),
        Flexible(
          child: RadioListTile(
            title: titles[1],
            value: values[1],
            groupValue: groupValue,
            activeColor: getPrimaryColor(context),
            onChanged: (dynamic value) {
              onChanged(value);
            },
          ),
        ),
        if (values.length == 3)
          Flexible(
            child: RadioListTile(
              title: titles[2],
              value: values[2],
              groupValue: groupValue,
              activeColor: getPrimaryColor(context),
              onChanged: (dynamic value) {
                onChanged(value);
              },
            ),
          ),
      ],
    );
  }
}

class IOSSelectionWidget extends StatelessWidget
    implements PlatformSelectionWidget {
  const IOSSelectionWidget({
    super.key,
    required this.titles,
    required this.values,
    this.groupValue,
    required this.onChanged,
  });
  final List<Widget> titles;
  final List<Object> values;
  final Object? groupValue;
  final void Function(Object?) onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSlidingSegmentedControl<Object>(
        children: {
          values[0]: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: titles[0],
          ),
          values[1]: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: titles[1],
          ),
          if (values.length == 3)
            values[2]: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: titles[2],
            ),
        },
        groupValue: groupValue,
        onValueChanged: onChanged,
      ),
    );
  }
}
