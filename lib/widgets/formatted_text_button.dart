import 'package:flutter/material.dart';

class FormattedTextButton extends StatelessWidget {
  const FormattedTextButton(
      {super.key, required this.label, required this.onPressed});
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.yellow,
        ),
      ),
    );
  }
}
