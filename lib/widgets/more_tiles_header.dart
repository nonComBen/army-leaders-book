import 'package:flutter/material.dart';

import '../widgets/header_text.dart';
import '../widgets/platform_widgets/platform_icon_button.dart';

import '../methods/theme_methods.dart';

class MoreTilesHeader extends StatelessWidget {
  const MoreTilesHeader({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: getOnPrimaryColor(context),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: HeaderText(
                  label,
                  textAlign: TextAlign.start,
                  color: getPrimaryColor(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformIconButton(
                icon: Icon(
                  Icons.add,
                  size: 24,
                  color: getPrimaryColor(context),
                ),
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
