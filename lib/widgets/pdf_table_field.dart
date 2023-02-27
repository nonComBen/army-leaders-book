import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdf;

class PdfTableField extends pdf.Widget {
  PdfTableField({
    @required this.text,
    @required this.width,
    this.isHeader = false,
  }) {
    SizedBox(
      width: width * 72,
      height: 24.0,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text,
            textAlign: isHeader ? TextAlign.center : TextAlign.left,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
  final String text;
  final double width;
  final bool isHeader;

  @override
  void layout(pdf.Context context, pdf.BoxConstraints constraints,
      {bool parentUsesSize = false}) {}
}
