import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../methods/theme_methods.dart';
import '../../widgets/platform_widgets/platform_text_field.dart';
import '../../methods/pick_time.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../methods/validate.dart';

class TimeTextField extends StatefulWidget {
  const TimeTextField(
      {super.key,
      required this.label,
      required this.time,
      required this.controller});
  final String label;
  final TimeOfDay? time;
  final TextEditingController controller;

  @override
  State<TimeTextField> createState() => _TimeTextFieldState();
}

class _TimeTextFieldState extends State<TimeTextField> {
  late TimeOfDay _time;
  DateFormat formatter = DateFormat('HHmm');

  @override
  void initState() {
    super.initState();
    _time = widget.time ?? const TimeOfDay(hour: 09, minute: 00);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: width <= 700
            ? 0.0
            : kIsWeb || Platform.isAndroid
                ? 26.0
                : 8,
        top: !kIsWeb && Platform.isIOS ? 8.0 : 0.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: PlatformTextField(
              controller: widget.controller,
              keyboardType: TextInputType.number,
              enabled: true,
              validator: (value) => isValidTime(value!) || value.isEmpty
                  ? null
                  : 'Time must be in hhmm format',
              label: widget.label,
              decoration: InputDecoration(
                labelText: widget.label,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    var time =
                        await pickAndroidTime(context: context, time: _time);
                    if (time != null) {
                      DateTime date =
                          DateTime(2023, 1, 1, time.hour, time.minute);
                      widget.controller.text = formatter.format(date);
                    }
                  },
                ),
              ),
              onChanged: (value) {
                if (isValidTime(value)) {
                  _time = TimeOfDay(
                    hour: int.tryParse(value.substring(0, 2)) ?? 9,
                    minute: int.tryParse(value.substring(2)) ?? 0,
                  );
                }
              },
            ),
          ),
          if (!kIsWeb && Platform.isIOS)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
              child: PlatformIconButton(
                icon: Icon(
                  CupertinoIcons.time,
                  size: 28,
                  color: getTextColor(context),
                ),
                onPressed: () => pickIosTime(
                  context: context,
                  time: DateTime(2023, 1, 1, _time.hour, _time.minute),
                  onPicked: (date) {
                    widget.controller.text = formatter.format(date);
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}
