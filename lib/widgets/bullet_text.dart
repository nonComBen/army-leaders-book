import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

import '../../widgets/standard_text.dart';

class BulletText extends StatelessWidget {
  const BulletText({
    super.key,
    this.iconData = Icons.circle,
    required this.text,
  });
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              iconData,
              color: getTextColor(context),
              size: 10,
            ),
          ),
          Expanded(child: StandardText(text)),
        ],
      ),
    );
  }
}
