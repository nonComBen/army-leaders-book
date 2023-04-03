import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class PlatformSlider extends Widget {
  factory PlatformSlider({
    required double value,
    Color? activeColor,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    void Function(double)? onChanged,
  }) {
    if (Platform.isAndroid) {
      return AndroidSlider(
        value: value,
        activeColor: activeColor,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      );
    } else {
      return IOSSlider(
        value: value,
        activeColor: activeColor,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      );
    }
  }
}

class AndroidSlider extends Slider implements PlatformSlider {
  const AndroidSlider({
    super.key,
    required super.value,
    super.activeColor,
    super.min,
    super.max,
    super.divisions,
    super.onChanged,
  });
}

class IOSSlider extends CupertinoSlider implements PlatformSlider {
  const IOSSlider({
    super.key,
    required super.value,
    super.activeColor,
    super.min,
    super.max,
    super.divisions,
    super.onChanged,
  });
}
