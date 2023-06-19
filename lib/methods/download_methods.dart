import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/toast_messages/show_toast.dart';
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
    return Future.delayed(Duration.zero, () => true);
  }
  bool allowed = false;
  allowed = await permission.status.isGranted;
  if (!allowed) {
    allowed = await permission.request().isGranted;
  }
  if (!allowed) {
    // ignore: use_build_context_synchronously
    showToast(
        context, 'You must allow access to Files and Media to download files.');
  }
  return allowed;
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
    File f = File("$location/$filename.pdf");

    try {
      f.writeAsBytesSync(await pdf.save());
      return location;
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Download Failed');
      return '';
    }
  }
}
