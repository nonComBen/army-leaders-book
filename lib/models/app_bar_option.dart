import 'package:flutter/widgets.dart';

class AppBarOption {
  final String title;
  final Icon icon;
  final void Function() onPressed;
  AppBarOption(
      {required this.title, required this.icon, required this.onPressed});
}
