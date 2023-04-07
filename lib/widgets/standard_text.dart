import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

class StandardText extends StatelessWidget {
  const StandardText(this.data,
      {super.key, this.textAlign = TextAlign.start, this.textStyle});
  final String data;
  final TextStyle? textStyle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: textStyle ?? TextStyle(color: getTextColor(context)),
    );
  }
}
