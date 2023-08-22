import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

class HeaderText extends StatelessWidget {
  const HeaderText(
    this.data, {
    super.key,
    this.textAlign = TextAlign.center,
    this.color,
  });
  final String data;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color ?? getTextColor(context),
      ),
    );
  }
}
