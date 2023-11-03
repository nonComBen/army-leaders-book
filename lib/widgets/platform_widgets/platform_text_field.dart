import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../methods/theme_methods.dart';

abstract class PlatformTextField extends Widget {
  factory PlatformTextField({
    required TextEditingController controller,
    TextStyle? style = const TextStyle(fontSize: 18),
    FocusNode? focusNode,
    String? label,
    InputDecoration? decoration,
    BoxDecoration? iosDecoration,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    bool obscureText = false,
    bool autofocus = false,
    bool autocorrect = false,
    TextInputAction textInputAction = TextInputAction.done,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.start,
    int maxLines = 1,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidTextField(
        controller: controller,
        style: style,
        focusNode: focusNode,
        enabled: enabled,
        decoration: decoration,
        validator: validator,
        autovalidateMode: autovalidateMode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        autofocus: autofocus,
        textAlign: textAlign,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
      );
    } else {
      return IOSTextField(
        controller: controller,
        style: style,
        focusNode: focusNode,
        enabled: enabled,
        label: label,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        autofocus: autofocus,
        textAlign: textAlign,
        maxLines: maxLines,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        textCapitalization: textCapitalization,
      );
    }
  }
}

class AndroidTextField extends TextFormField implements PlatformTextField {
  AndroidTextField({
    super.key,
    required super.controller,
    super.focusNode,
    super.enabled = true,
    super.decoration,
    super.validator,
    super.obscureText,
    super.textInputAction,
    super.autovalidateMode,
    super.keyboardType,
    super.inputFormatters,
    super.textCapitalization,
    super.autofocus,
    super.autocorrect,
    super.textAlign,
    super.maxLines,
    super.onChanged,
    super.onEditingComplete,
    super.style,
  });
}

class IOSTextField extends StatelessWidget implements PlatformTextField {
  const IOSTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.label,
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
  });

  final TextEditingController controller;
  final TextStyle? style;
  final FocusNode? focusNode;
  final String? label;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              label!,
              style: TextStyle(color: getTextColor(context)),
            ),
          ),
        CupertinoTextField(
          padding: const EdgeInsets.all(12.0),
          controller: controller,
          style: style ?? TextStyle(color: getTextColor(context)),
          focusNode: focusNode,
          decoration: BoxDecoration(
            border: Border.all(color: getTextColor(context)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          obscureText: obscureText,
          autofocus: autofocus,
          autocorrect: autocorrect,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          maxLines: maxLines,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          cursorColor: getTextColor(context),
        )
      ],
    );
  }
}
