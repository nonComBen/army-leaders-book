import 'package:flutter/material.dart';

class HeaderText extends Text {
  const HeaderText(
    super.data, {
    super.key,
    super.textAlign = TextAlign.center,
    super.style = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  });
}
