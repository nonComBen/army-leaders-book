import 'package:flutter/material.dart';

import '../methods/theme_methods.dart';

class MyToast extends StatelessWidget {
  const MyToast({
    super.key,
    required this.contents,
  });
  final List<Widget> contents;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: getPrimaryColor(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: contents,
      ),
    );
  }
}
