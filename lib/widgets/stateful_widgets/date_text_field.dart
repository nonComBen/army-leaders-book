import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/widgets/padded_text_field.dart';

import '../../methods/pick_date.dart';
import '../../methods/theme_methods.dart';
import '../../methods/validate.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';

class DateTextField extends StatefulWidget {
  const DateTextField({
    super.key,
    required this.label,
    this.date,
    this.minYears = 5,
    this.maxYears = 1,
    required this.controller,
  });
  final String label;
  final DateTime? date;
  final TextEditingController controller;
  final int minYears;
  final int maxYears;

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
      widget.controller.text = dateFormat.format(widget.date!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb || Platform.isAndroid
        ? PaddedTextField(
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
                  DateTime? newDate = await pickAndroidDate(
                    context: context,
                    date: _date,
                    minYears: widget.minYears,
                    maxYears: widget.maxYears,
                  );
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
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PaddedTextField(
                  padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                  controller: widget.controller,
                  keyboardType: TextInputType.datetime,
                  validator: (value) => isValidDate(value!) || value.isEmpty
                      ? null
                      : 'Date must be in yyyy-MM-dd format',
                  label: widget.label,
                  onChanged: (value) {
                    _date = DateTime.tryParse(value) ?? _date;
                  },
                ),
              ),
              if (!kIsWeb && Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                  child: PlatformIconButton(
                    icon: Icon(
                      CupertinoIcons.calendar,
                      size: 32,
                      color: getTextColor(context),
                    ),
                    onPressed: () => pickIosDate(
                      context: context,
                      date: _date,
                      minYears: widget.minYears,
                      maxYears: widget.maxYears,
                      onPicked: (newDate) {
                        _date = newDate;
                        widget.controller.text = dateFormat.format(_date);
                      },
                    ),
                  ),
                )
            ],
          );
  }
}
