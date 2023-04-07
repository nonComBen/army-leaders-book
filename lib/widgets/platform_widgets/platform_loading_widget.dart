import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformLoadingWidget extends StatelessWidget {
  factory PlatformLoadingWidget({Color color = Colors.white}) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidLoadingWidget(color: color);
    } else {
      return IOSLoadingWidget(color: color);
    }
  }
}

class AndroidLoadingWidget extends StatelessWidget
    implements PlatformLoadingWidget {
  const AndroidLoadingWidget({
    super.key,
    required this.color,
  });
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
    );
  }
}

class IOSLoadingWidget extends StatelessWidget
    implements PlatformLoadingWidget {
  const IOSLoadingWidget({
    super.key,
    required this.color,
  });
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      color: color,
    );
  }
}
