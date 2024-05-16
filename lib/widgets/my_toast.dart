import 'package:flutter/material.dart';

import '../methods/theme_methods.dart';
import 'platform_widgets/platform_text_button.dart';

class MyToast extends StatelessWidget {
  const MyToast({
    super.key,
    required this.message,
    this.buttonText,
    this.onPressed,
  });
  final String message;
  final String? buttonText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: getOnPrimaryColor(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: getPrimaryColor(context),
              ),
            ),
          ),
          if (buttonText != null && onPressed != null)
            PlatformTextButton(
              onPressed: onPressed!,
              child: Text(
                buttonText!,
                style: TextStyle(color: getPrimaryColor(context)),
              ),
            ),
        ],
      ),
    );
  }
}
