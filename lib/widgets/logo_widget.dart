import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
    this.vertPadding = 32,
    this.radius = 96,
  });
  final double vertPadding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertPadding),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius,
        child: Image.asset('assets/icon-512.png'),
      ),
    );
  }
}
