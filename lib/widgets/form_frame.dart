import 'package:flutter/material.dart';
import 'package:leaders_book/methods/on_back_pressed.dart';

class FormFrame extends StatelessWidget {
  const FormFrame({
    super.key,
    required this.formKey,
    this.canPop = true,
    required this.children,
  });
  final Key formKey;
  final bool canPop;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      canPop: canPop,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onBackPressed(context);
      },
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
