import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../methods/show_snackbar.dart';
import '../../methods/upload_methods.dart';
import '../../models/apft.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class UploadApftPage extends ConsumerStatefulWidget {
  const UploadApftPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadApftPageState createState() => UploadApftPageState();
}

class UploadApftPageState extends ConsumerState<UploadApftPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      date,
      age,
      puRaw,
      puScore,
      suRaw,
      suScore,
      runEvent,
      runRaw,
      runScore,
      path,
      gender;

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
      soldierId = columnHeaders.contains('Soldier Id') ? 'Soldier Id' : '';
      date = columnHeaders.contains('Date') ? 'Date' : '';
      age = columnHeaders.contains('Age') ? 'Age' : '';
      puRaw = columnHeaders.contains('PU Raw') ? 'PU Raw' : '';
      puScore = columnHeaders.contains('PU Score') ? 'PU Score' : '';
      suRaw = columnHeaders.contains('SU Raw') ? 'SU Raw' : '';
      suScore = columnHeaders.contains('SU Score') ? 'SU Score' : '';
      runEvent = columnHeaders.contains('Alt Event') ? 'Alt Event' : '';
      runRaw = columnHeaders.contains('Run Raw') ? 'Run Raw' : '';
      runScore = columnHeaders.contains('Run Score') ? 'Run Score' : '';
      gender = columnHeaders.contains('Gender') ? 'Gender' : '';
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

      List<String> events = [];
      events.add('');
      events.add('Run');
      events.add('Walk');
      events.add('Bike');
      events.add('Swim');

      for (int i = 1; i < rows.length; i++) {
        String? rank, name, firstName, section, rankSort, owner;
        List<dynamic>? users;
        bool pass;
        int? puInt, suInt, runInt, ageInt, total;
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

          String saveDate =
              convertDate(getCellValue(rows[i], columnHeaders, date));
          String saveAge = getCellValue(rows[i], columnHeaders, age);
          String savePuRaw = getCellValue(rows[i], columnHeaders, puRaw);
          String savePuScore = getCellValue(rows[i], columnHeaders, puScore);
          String saveSuRaw = getCellValue(rows[i], columnHeaders, suRaw);
          String saveSuScore = getCellValue(rows[i], columnHeaders, suScore);
          String saveRunEvent = getCellValue(rows[i], columnHeaders, runEvent);
          String saveRunRaw = getCellValue(rows[i], columnHeaders, runRaw);
          String saveRunScore = getCellValue(rows[i], columnHeaders, runScore);
          String saveGender = getCellValue(rows[i], columnHeaders, gender);

          if (!events.contains(saveRunEvent)) {
            saveRunEvent = 'Run';
          }
          if (saveGender.toLowerCase() == 'female' ||
              saveGender.toLowerCase() == 'f') {
            saveGender = 'Female';
          } else {
            saveGender = 'Male';
          }
          ageInt = int.tryParse(saveAge);
          ageInt ??= 0;
          puInt = int.tryParse(savePuScore);
          puInt ??= 0;
          suInt = int.tryParse(saveSuScore);
          suInt ??= 0;
          runInt = int.tryParse(saveRunScore);
          runInt ??= 0;
          total = puInt + suInt + runInt;

          pass = (puInt == 0 || puInt > 60) &&
              (suInt == 0 || suInt > 60) &&
              (runInt == 0 || runInt > 60);

          Apft apft = Apft(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            date: saveDate,
            puRaw: savePuRaw,
            suRaw: saveSuRaw,
            runRaw: saveRunRaw,
            puScore: puInt,
            suScore: suInt,
            runScore: runInt,
            total: total,
            altEvent: saveRunEvent,
            pass: pass,
            age: ageInt,
            gender: saveGender,
          );

          firestore.collection('apftStats').add(apft.toMap());
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
    date = '';
    age = '';
    puRaw = '';
    puScore = '';
    suRaw = '';
    suScore = '';
    runEvent = '';
    runRaw = '';
    runScore = '';
    gender = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload APFT Stats',
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
                        child: PlatformItemPicker(
                          label: const Text('SoldierId'),
                          items: columnHeaders,
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
                        child: PlatformItemPicker(
                          label: const Text('Date'),
                          items: columnHeaders,
                          value: date,
                          onChanged: (value) {
                            setState(() {
                              date = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Age'),
                          items: columnHeaders,
                          value: age,
                          onChanged: (value) {
                            setState(() {
                              age = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Gender'),
                          items: columnHeaders,
                          value: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('PU Raw'),
                          items: columnHeaders,
                          value: puRaw,
                          onChanged: (value) {
                            setState(() {
                              puRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('PU Score'),
                          items: columnHeaders,
                          value: puScore,
                          onChanged: (value) {
                            setState(() {
                              puScore = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('SU Raw'),
                          items: columnHeaders,
                          value: suRaw,
                          onChanged: (value) {
                            setState(() {
                              suRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('SU Score'),
                          items: columnHeaders,
                          value: suScore,
                          onChanged: (value) {
                            setState(() {
                              suScore = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Aerobic Event'),
                          items: columnHeaders,
                          value: runEvent,
                          onChanged: (value) {
                            setState(() {
                              runEvent = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Aerobic Raw'),
                          items: columnHeaders,
                          value: runRaw,
                          onChanged: (value) {
                            setState(() {
                              runRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Aerobic Score'),
                          items: columnHeaders,
                          value: runScore,
                          onChanged: (value) {
                            setState(() {
                              runScore = value;
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
                    child: const Text('Upload APFT Stats'),
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
