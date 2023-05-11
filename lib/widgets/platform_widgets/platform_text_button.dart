import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformTextButton extends StatelessWidget {
  factory PlatformTextButton(
      {required Widget child, required VoidCallback onPressed}) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidTextButton(onPressed: onPressed, child: child);
    } else {
      return IOSTextButton(onPressed: onPressed, child: child);
    }
  }
}

class AndroidTextButton extends StatelessWidget implements PlatformTextButton {
  const AndroidTextButton({
    super.key,
    required this.child,
    required this.onPressed,
  });
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

class IOSTextButton extends StatelessWidget implements PlatformTextButton {
  const IOSTextButton({
    super.key,
    required this.child,
    required this.onPressed,
  });
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
