import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformButton extends StatelessWidget {
  factory PlatformButton(
      {required VoidCallback onPressed,
      double buttonPadding = 8.0,
      required Widget child}) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidButton(
          onPressed: onPressed, buttonPadding: buttonPadding, child: child);
    } else {
      return IOSButton(
          onPressed: onPressed, buttonPadding: buttonPadding, child: child);
    }
  }
}

class AndroidButton extends StatelessWidget implements PlatformButton {
  const AndroidButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.buttonPadding = 8.0,
  });
  final Widget child;
  final VoidCallback onPressed;
  final double buttonPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(vertical: buttonPadding, horizontal: 20.0),
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class IOSButton extends StatelessWidget implements PlatformButton {
  const IOSButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.buttonPadding = 8.0,
  });
  final Widget child;
  final VoidCallback onPressed;
  final double buttonPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoButton.filled(
        padding:
            EdgeInsets.symmetric(vertical: buttonPadding, horizontal: 20.0),
        borderRadius: BorderRadius.circular(25),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
