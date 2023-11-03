import 'package:flutter/material.dart';

import '../../methods/theme_methods.dart';
import '../../widgets/platform_widgets/platform_loading_widget.dart';

class CenterProgressIndicator extends StatelessWidget {
  const CenterProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
        child: PlatformLoadingWidget(
          color: getTextColor(context),
        ),
      ),
    );
  }
}
