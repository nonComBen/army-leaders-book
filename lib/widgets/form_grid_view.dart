import 'package:flutter/material.dart';

class FormGridView extends StatelessWidget {
  const FormGridView({
    super.key,
    required this.width,
    required this.children,
  });
  final double width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      primary: false,
      crossAxisCount: width > 700 ? 2 : 1,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: width > 900
          ? 900 / 210
          : width > 700
              ? (width - 32) / 210
              : (width - 32) / 110,
      shrinkWrap: true,
      children: children,
    );
  }
}
