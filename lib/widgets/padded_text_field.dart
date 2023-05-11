import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/platform_widgets/platform_text_field.dart';

class PaddedTextField extends StatelessWidget {
  const PaddedTextField({
    super.key,
    this.padding,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    required this.label,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.autocorrect = false,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.onChanged,
    this.onEditingComplete,
    this.style,
    this.decoration,
    this.iosDecoration,
    this.validator,
    this.autovalidateMode,
  });

  final EdgeInsets? padding;
  final TextEditingController controller;
  final TextStyle? style;
  final FocusNode? focusNode;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool obscureText;
  final bool autofocus;
  final bool autocorrect;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int maxLines;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final InputDecoration? decoration;
  final BoxDecoration? iosDecoration;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.only(
              left: 8, right: 8, top: kIsWeb || Platform.isAndroid ? 14 : 12),
      child: PlatformTextField(
        controller: controller,
        decoration: decoration,
        iosDecoration: iosDecoration,
        style: style,
        focusNode: focusNode,
        label: label,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        enabled: enabled,
        autocorrect: autocorrect,
        autofocus: autofocus,
        obscureText: obscureText,
        textAlign: textAlign,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        maxLines: maxLines,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
      ),
    );
  }
}
