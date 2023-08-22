import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

class StandardText extends StatelessWidget {
  const StandardText(
    this.data, {
    super.key,
    this.textAlign = TextAlign.start,
    this.style,
    this.textColor,
  });
  final String data;
  final TextStyle? style;
  final TextAlign textAlign;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: style ?? TextStyle(color: textColor ?? getTextColor(context)),
    );
  }
}
