import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

void openFile(String filePath) async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    final result = await OpenFile.open(filePath);
    debugPrint('type: ${result.type}, message: ${result.message}');
  }
}
