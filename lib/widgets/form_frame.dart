import 'package:flutter/material.dart';

class FormFrame extends StatelessWidget {
  const FormFrame({
    super.key,
    required this.formKey,
    this.onWillPop,
    required this.children,
  });
  final Key formKey;
  final Future<bool> Function()? onWillPop;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onWillPop: onWillPop,
      child: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            children: children,
          ),
        ),
      ),
    );
  }
}
