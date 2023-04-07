import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void showPlatformModalBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  if (kIsWeb || Platform.isAndroid) {
    showModalBottomSheet(
      context: context,
      builder: builder,
      constraints: const BoxConstraints(maxWidth: 900),
    );
  } else {
    showCupertinoModalPopup(
      context: context,
      builder: builder,
    );
  }
}
