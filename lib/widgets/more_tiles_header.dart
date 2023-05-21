import 'package:flutter/material.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_icon_button.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_list_tile.dart';

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
      child: PlatformListTile(
        title: Text(
          label,
          style: TextStyle(color: getOnPrimaryColor(context)),
        ),
        color: getPrimaryColor(context),
        trailing: PlatformIconButton(
          icon: Icon(
            Icons.add,
            color: getOnPrimaryColor(context),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
