import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_list_tile.dart';

class EditDeleteListTile extends StatelessWidget {
  const EditDeleteListTile({
    super.key,
    required this.title,
    this.subTitle,
    this.onIconPressed,
    this.onTap,
  });
  final String title;
  final Widget? subTitle;
  final void Function()? onIconPressed;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getPrimaryColor(context),
      child: Padding(
        padding: kIsWeb || Platform.isAndroid
            ? const EdgeInsets.all(0.0)
            : const EdgeInsets.all(8.0),
        child: PlatformListTile(
          title: Text(
            title,
            style: TextStyle(color: getTextColor(context)),
          ),
          subtitle: subTitle,
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: getTextColor(context),
            ),
            onPressed: onIconPressed,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
