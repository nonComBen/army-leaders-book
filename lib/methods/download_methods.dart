// ignore_for_file: file_names, avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:permission_handler/permission_handler.dart';

import 'web_download.dart';

Future<List<String>> getPath() async {
  String newPath = '', location = '', path;
  path = Platform.isAndroid
      ? (await getTemporaryDirectory()).path
      : (await getApplicationDocumentsDirectory()).path;
  location = Platform.isAndroid
      ? 'Temporary Directory. Please open and save to a permanent location.'
      : '\'On My iPhone(iPad)/Leader\'s Book\'';

  newPath = path;
  Directory dir = Directory(newPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return [newPath, location];
}

Future<bool> checkPermission(
    BuildContext context, Permission permission) async {
  if (kIsWeb || Platform.isIOS) {
    return true;
  }
  var status = await permission.status;
  print(status.toString());
  if (status.isDenied) {
    var requestStatus = await permission.request();
    if (requestStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  } else if (status.isGranted || status.isLimited) {
    return true;
  } else {
    return false;
  }
}

Future<String> pdfDownload(pdf.Document pdf, String filename) async {
  String location;
  Directory dir;
  if (kIsWeb) {
    WebDownload webDownload = WebDownload(
        data: await pdf.save(),
        type: 'pdf',
        fileName: '/$filename(${DateTime.now().toString()}).pdf');
    webDownload.download();
    return '/Downloads';
  } else {
    //List<String> strings = await getPath();
    dir = Platform.isAndroid
        ? await getTemporaryDirectory()
        : await getApplicationDocumentsDirectory();
    location = dir.path;
    print(dir);
    File f = File("$location/$filename.pdf");

    try {
      f.writeAsBytesSync(await pdf.save());
      return location;
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }
}
