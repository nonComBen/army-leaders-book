import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/pick_date.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/widgets/padded_text_field.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_icon_button.dart';

import '../../methods/validate.dart';

class DateTextField extends StatefulWidget {
  const DateTextField(
      {super.key,
      required this.label,
      required this.date,
      required this.controller});
  final String label;
  final DateTime? date;
  final TextEditingController controller;

  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  DateTime _date = DateTime.now();
  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (widget.date != null) {
      _date = widget.date!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PaddedTextField(
            controller: widget.controller,
            keyboardType: TextInputType.datetime,
            enabled: true,
            validator: (value) => isValidDate(value!) || value.isEmpty
                ? null
                : 'Date must be in yyyy-MM-dd format',
            label: widget.label,
            decoration: InputDecoration(
              labelText: widget.label,
              suffixIcon: IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  DateTime? newDate =
                      await pickAndroidDate(context: context, date: _date);
                  if (newDate != null) {
                    _date = newDate;
                    widget.controller.text = dateFormat.format(newDate);
                  }
                },
              ),
            ),
            onChanged: (value) {
              _date = DateTime.tryParse(value) ?? _date;
            },
          ),
        ),
        if (!kIsWeb && Platform.isIOS)
          PlatformIconButton(
            icon: Icon(
              CupertinoIcons.calendar,
              color: getTextColor(context),
            ),
            onPressed: () => pickIosDate(
              context: context,
              date: _date,
              onPicked: (newDate) {
                _date = newDate;
                widget.controller.text = dateFormat.format(_date);
              },
            ),
          )
      ],
    );
  }
}
