import 'package:flutter/material.dart';

class CenterProgressIndicator extends StatelessWidget {
  const CenterProgressIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            constraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
            child: const CircularProgressIndicator()));
  }
}
