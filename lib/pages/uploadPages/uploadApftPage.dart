// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../methods/upload_methods.dart';
import '../../models/apft.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadApftPage extends StatefulWidget {
  const UploadApftPage({
    Key key,
  }) : super(key: key);

  @override
  UploadApftPageState createState() => UploadApftPageState();
}

class UploadApftPageState extends State<UploadApftPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
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

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void _openFileExplorer() async {
    try {
      var result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
      path = result.files.first.name;
      if (kIsWeb) {
        var excel = Excel.decodeBytes(result.files.first.bytes);
        _readExcel(excel.sheets.values.first);
      } else {
        var file = File(result.files.first.path);
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
      columnHeaders = [''];
      for (var cell in rows.first) {
        if (cell.value != '') {
          columnHeaders.add(cell.value);
        }
      }
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
      final soldiers =
          Provider.of<SoldiersProvider>(context, listen: false).soldiers;

      List<String> soldierIds = soldiers.map((e) => e.id).toList();

      List<String> events = [];
      events.add('');
      events.add('Run');
      events.add('Walk');
      events.add('Bike');
      events.add('Swim');

      for (int i = 1; i < rows.length; i++) {
        String rank, name, firstName, section, rankSort, owner;
        List<dynamic> users;
        bool pass;
        int puInt, suInt, runInt, ageInt, total;
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
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Upload APFT Stats'),
      ),
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
                  FormattedElevatedButton(
                    onPressed: () {
                      _openFileExplorer();
                    },
                    text: 'Pick File',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      path,
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
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
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
                          decoration: const InputDecoration(labelText: 'Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Age'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Gender'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'PU Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'PU Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'SU Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'SU Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Aerobic Event'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Aerobic Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Aerobic Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                  FormattedElevatedButton(
                    onPressed: path == ''
                        ? null
                        : () {
                            _saveData(context);
                          },
                    text: 'Upload APFT Stats',
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
