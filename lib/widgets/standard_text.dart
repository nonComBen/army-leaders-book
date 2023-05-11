import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

class StandardText extends StatelessWidget {
  const StandardText(this.data,
      {super.key, this.textAlign = TextAlign.start, this.style});
  final String data;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: style ?? TextStyle(color: getTextColor(context)),
    );
  }
}
