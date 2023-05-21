import 'package:flutter/material.dart';

import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../methods/theme_methods.dart';

class EditDeleteListTile extends StatelessWidget {
  const EditDeleteListTile({
    super.key,
    required this.title,
    this.subTitle,
    this.onIconPressed,
    this.onTap,
  });
  final String title;
  final String? subTitle;
  final void Function()? onIconPressed;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: getContrastingBackgroundColor(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: getTextColor(context),
                        ),
                      ),
                    ),
                    if (subTitle != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          subTitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: getTextColor(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PlatformIconButton(
                  icon: Icon(
                    Icons.delete,
                    color: getTextColor(context),
                  ),
                  onPressed: onIconPressed),
            ],
          ),
        ),
      ),
    );
  }
}
