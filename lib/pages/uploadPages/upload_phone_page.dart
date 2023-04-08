import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_provider.dart';

import '../../methods/show_snackbar.dart';
import '../../methods/upload_methods.dart';
import '../../models/phone_number.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class UploadPhonePage extends ConsumerStatefulWidget {
  const UploadPhonePage({
    Key? key,
  }) : super(key: key);

  @override
  UploadPhonePageState createState() => UploadPhonePageState();
}

class UploadPhonePageState extends ConsumerState<UploadPhonePage> {
  List<String?>? columnHeaders;
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
      title = columnHeaders!.contains('Title') ? 'Title' : '';
      poc = columnHeaders!.contains('POC') ? 'POC' : '';
      phone = columnHeaders!.contains('Phone Number') ? 'Phone Number' : '';
      loc = columnHeaders!.contains('Location') ? 'Location' : '';
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

        firestore.collection('phoneNumbers').add(phoneObj.toMap());
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
    columnHeaders!.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Phone Numbers',
      body: Center(
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              child: Column(
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
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Title'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: title,
                          onChanged: (value) {
                            setState(() {
                              title = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'POC'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: poc,
                          onChanged: (value) {
                            setState(() {
                              poc = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: phone,
                          onChanged: (value) {
                            setState(() {
                              phone = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Location'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
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
                        showSnackbar(context, 'Please select a file to upload');
                      }
                      _saveData(context);
                    },
                    child: const Text('Upload Phone Numbers'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
