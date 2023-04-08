import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../methods/show_snackbar.dart';
import '../../methods/upload_methods.dart';
import '../../models/soldier.dart';
import '../../models/tasking.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class UploadTaskingsPage extends ConsumerStatefulWidget {
  const UploadTaskingsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadTaskingsPageState createState() => UploadTaskingsPageState();
}

class UploadTaskingsPageState extends ConsumerState<UploadTaskingsPage> {
  List<String?>? columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, title, start, end, comments, path, location;

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
      soldierId = columnHeaders!.contains('Soldier Id') ? 'Soldier Id' : '';
      title = columnHeaders!.contains('Tasking') ? 'Tasking' : '';
      start = columnHeaders!.contains('Start Date') ? 'Start Date' : '';
      end = columnHeaders!.contains('End Date') ? 'End Date' : '';
      comments = columnHeaders!.contains('Comments') ? 'Comments' : '';
      location = columnHeaders!.contains('Location') ? 'Location' : '';
    });
  }

  void _saveData(BuildContext context) {
    if (soldierId == '') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Soldier Id must not be blank. To get your Soldiers\' Ids, download their data from the Soldiers page.')));
      return;
    }
    if (rows.length > 1) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final soldiers = ref.read(soldiersProvider);

      List<String?> soldierIds = soldiers.map((e) => e.id).toList();

      for (int i = 1; i < rows.length; i++) {
        String? rank, name, firstName, section, rankSort, owner;
        List<dynamic>? users;
        String saveSoldierId = getCellValue(rows[i], columnHeaders, soldierId);

        if (soldierIds.contains(saveSoldierId)) {
          Soldier soldier =
              soldiers.elementAt(soldierIds.indexOf(saveSoldierId));
          rank = soldier.rank;
          rankSort = soldier.rankSort.toString();
          name = soldier.lastName;
          firstName = soldier.firstName;
          section = soldier.section;
          owner = soldier.owner;
          users = soldier.users;

          String saveStart =
              convertDate(getCellValue(rows[i], columnHeaders, start));
          String saveEnd =
              convertDate(getCellValue(rows[i], columnHeaders, end));
          String saveTitle = getCellValue(rows[i], columnHeaders, title);
          String saveComments = getCellValue(rows[i], columnHeaders, comments);
          String saveLoc = getCellValue(rows[i], columnHeaders, location);

          Tasking tasking = Tasking(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            start: saveStart,
            end: saveEnd,
            type: saveTitle,
            comments: saveComments,
            location: saveLoc,
          );

          firestore.collection('taskings').add(tasking.toMap());
        }
      }
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    path = '';
    soldierId = '';
    title = '';
    start = '';
    end = '';
    comments = '';
    location = '';
    columnHeaders = [];
    columnHeaders!.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Taskings',
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
                          decoration:
                              const InputDecoration(labelText: 'SoldierId'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: soldierId,
                          onChanged: (value) {
                            setState(() {
                              soldierId = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Tasking'),
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
                          decoration:
                              const InputDecoration(labelText: 'Location'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: location,
                          onChanged: (value) {
                            setState(() {
                              location = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Start Date'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: start,
                          onChanged: (value) {
                            setState(() {
                              start = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'End Date'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: end,
                          onChanged: (value) {
                            setState(() {
                              end = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Comments'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: comments,
                          onChanged: (value) {
                            setState(() {
                              comments = value;
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
                    child: const Text('Upload Taskings'),
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
