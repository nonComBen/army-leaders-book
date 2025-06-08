import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

void openFile(String filePath) async {
  final result = await OpenFile.open(filePath);
  debugPrint('type: ${result.type}, message: ${result.message}');
}
