import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../methods/toast_messages/file_is_blank_message.dart';
import '../../methods/upload_methods.dart';
import '../../models/phone_number.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadPhonePage extends ConsumerStatefulWidget {
  const UploadPhonePage({
    Key? key,
  }) : super(key: key);

  @override
  UploadPhonePageState createState() => UploadPhonePageState();
}

class UploadPhonePageState extends ConsumerState<UploadPhonePage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? title, poc, phone, loc, path;

  void _openFileExplorer() async {
    try {
      var result = (await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']))!;
      path = result.files.first.name;
      if (kIsWeb) {
        var excel = Excel.decodeBytes(result.files.first.bytes!);
        _readExcel(excel.sheets.values.first);
      } else {
        var file = File(result.files.first.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        _readExcel(excel.sheets.values.first);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Unsupported operation: ${e.toString()}');
    }
  }

  void _readExcel(Sheet sheet) {
    setState(() {
      rows = sheet.rows;
      columnHeaders = getColumnHeaders(rows.first);
      title = columnHeaders.contains('Title') ? 'Title' : '';
      poc = columnHeaders.contains('POC') ? 'POC' : '';
      phone = columnHeaders.contains('Phone Number') ? 'Phone Number' : '';
      loc = columnHeaders.contains('Location') ? 'Location' : '';
    });
  }

  void _saveData(BuildContext context) {
    if (rows.length > 1) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final owner = ref.read(authProvider).currentUser()!.uid;

      for (int i = 1; i < rows.length; i++) {
        String saveTitle = getCellValue(rows[i], columnHeaders, title);
        String savePoc = getCellValue(rows[i], columnHeaders, poc);
        String savePhone = getCellValue(rows[i], columnHeaders, phone);
        String saveLoc = getCellValue(rows[i], columnHeaders, loc);

        Phone phoneObj = Phone(
          owner: owner,
          title: saveTitle,
          name: savePoc,
          phone: savePhone,
          location: saveLoc,
        );

        firestore.collection(Phone.collectionName).add(phoneObj.toMap());
      }
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    path = '';
    title = '';
    poc = '';
    phone = '';
    loc = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Phone Numbers',
      body: UploadFrame(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'After picking .xlsx file, select the appropriate column header for each field. Leave selection blank to skip a field, but Soldier Id '
              'cannot be skipped. To get your Soldiers\' Ids, download their data from the Soldiers page.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          PlatformButton(
            onPressed: () {
              _openFileExplorer();
            },
            child: const Text('Pick File'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              path!,
              textAlign: TextAlign.center,
            ),
          ),
          GridView.count(
            primary: false,
            crossAxisCount: width > 700 ? 2 : 1,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            childAspectRatio: width > 900
                ? 900 / 230
                : width > 700
                    ? width / 230
                    : width / 115,
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Title'),
                  items: columnHeaders,
                  value: title,
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('POC'),
                  items: columnHeaders,
                  value: poc,
                  onChanged: (value) {
                    setState(() {
                      poc = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Phone Number'),
                  items: columnHeaders,
                  value: phone,
                  onChanged: (value) {
                    setState(() {
                      phone = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Location'),
                  items: columnHeaders,
                  value: loc,
                  onChanged: (value) {
                    setState(() {
                      loc = value;
                    });
                  },
                ),
              ),
            ],
          ),
          PlatformButton(
            onPressed: () {
              if (path == '') {
                fileIsBlankMessage(context);
              }
              _saveData(context);
            },
            child: const Text('Upload Phone Numbers'),
          )
        ],
      ),
    );
  }
}
