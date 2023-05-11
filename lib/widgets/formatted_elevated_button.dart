import 'package:flutter/material.dart';

class FormattedElevatedButton extends StatelessWidget {
  const FormattedElevatedButton(
      {Key? key, required this.text, required this.onPressed})
      : super(key: key);

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      child: Text(
        text,
      ),
    );
  }
}
