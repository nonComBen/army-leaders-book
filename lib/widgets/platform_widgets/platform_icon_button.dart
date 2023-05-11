import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformIconButton extends StatelessWidget {
  factory PlatformIconButton({
    required Icon icon,
    required void Function()? onPressed,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidIconButton(icon: icon, onPressed: onPressed);
    } else {
      return IOSIconButton(onTap: onPressed, child: icon);
    }
  }
}

class AndroidIconButton extends IconButton implements PlatformIconButton {
  const AndroidIconButton(
      {super.key, required super.icon, required super.onPressed});
}

class IOSIconButton extends GestureDetector implements PlatformIconButton {
  IOSIconButton({super.key, required super.child, required super.onTap});
}
