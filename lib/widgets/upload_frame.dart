import 'package:flutter/material.dart';

class UploadFrame extends StatelessWidget {
  const UploadFrame({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}
