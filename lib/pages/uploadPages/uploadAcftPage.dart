// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../methods/upload_methods.dart';
import '../../models/acft.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadAcftPage extends StatefulWidget {
  const UploadAcftPage({
    Key key,
  }) : super(key: key);

  @override
  UploadAcftPageState createState() => UploadAcftPageState();
}

class UploadAcftPageState extends State<UploadAcftPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
      date,
      ageGroup,
      gender,
      mdlRaw,
      mdlScore,
      sptRaw,
      sptScore,
      puRaw,
      puScore,
      sdcRaw,
      sdcScore,
      plkRaw,
      plkScore,
      runEvent,
      runRaw,
      runScore,
      path,
      passDropdown;

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
    if (mounted) {
      setState(() {
        rows = sheet.rows;
        columnHeaders = getColumnHeaders(rows.first);
        soldierId = columnHeaders.contains('Soldier Id') ? 'Soldier Id' : '';
        date = columnHeaders.contains('Date') ? 'Date' : '';
        ageGroup = columnHeaders.contains('Age Group') ? 'Age Group' : '';
        gender = columnHeaders.contains('Gender') ? 'Gender' : '';
        mdlRaw = columnHeaders.contains('MDL Raw') ? 'MDL Raw' : '';
        mdlScore = columnHeaders.contains('MDL Score') ? 'MDL Score' : '';
        sptRaw = columnHeaders.contains('SPT Raw') ? 'SPT Raw' : '';
        sptScore = columnHeaders.contains('SPT Score') ? 'SPT Score' : '';
        puRaw = columnHeaders.contains('HRP Raw') ? 'HRP Raw' : '';
        puScore = columnHeaders.contains('HRP Score') ? 'HRP Score' : '';
        sdcRaw = columnHeaders.contains('SDC Raw') ? 'SDC Raw' : '';
        sdcScore = columnHeaders.contains('SDC Score') ? 'SDC Score' : '';
        plkRaw = columnHeaders.contains('PLK Raw') ? 'PLK Raw' : '';
        plkScore = columnHeaders.contains('PLK Score') ? 'PLK Score' : '';
        runEvent = columnHeaders.contains('Alt Event') ? 'Alt Event' : '';
        runRaw = columnHeaders.contains('2MR Raw') ? '2MR Raw' : '';
        runScore = columnHeaders.contains('2MR Score') ? '2MR Score' : '';
        passDropdown = columnHeaders.contains('Pass') ? 'Pass' : '';
      });
    }
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

      List<String> events = ['', 'Run', 'Row', 'Bike', 'Swim'];
      List<String> ageGroups = [
        '17-21',
        '22-26',
        '27-31',
        '32-36',
        '37-41',
        '42-46',
        '47-51',
        '52-56',
        '57-61',
        '62+'
      ];

      for (int i = 1; i < rows.length; i++) {
        String rank, name, firstName, section, rankSort, owner;
        List<dynamic> users;
        bool pass;
        int mdlInt, sptInt, puInt, sdcInt, plkInt, runInt, total;
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
          String saveAge = getCellValue(rows[i], columnHeaders, ageGroup);
          String saveGender = getCellValue(rows[i], columnHeaders, gender);
          String saveMdlRaw = getCellValue(rows[i], columnHeaders, mdlRaw);
          String saveMdlScore = getCellValue(rows[i], columnHeaders, mdlScore);
          String saveSptRaw = getCellValue(rows[i], columnHeaders, sptRaw);
          String saveSptScore = getCellValue(rows[i], columnHeaders, sptScore);
          String savePuRaw = getCellValue(rows[i], columnHeaders, puRaw);
          String savePuScore = getCellValue(rows[i], columnHeaders, puScore);
          String saveSdcRaw = getCellValue(rows[i], columnHeaders, sdcRaw);
          String saveSdcScore = getCellValue(rows[i], columnHeaders, sdcScore);
          String savePlkRaw = getCellValue(rows[i], columnHeaders, plkRaw);
          String savePlkScore = getCellValue(rows[i], columnHeaders, plkScore);
          String saveRunEvent = getCellValue(rows[i], columnHeaders, runEvent);
          String saveRunRaw = getCellValue(rows[i], columnHeaders, runRaw);
          String saveRunScore = getCellValue(rows[i], columnHeaders, runScore);

          if (!events.contains(saveRunEvent)) {
            saveRunEvent = 'Run';
          }
          if (!ageGroups.contains(saveAge)) {
            saveAge = '17-21';
          }
          if (saveGender != 'Male' || saveGender != 'Female') {
            saveGender = 'Male';
          }
          mdlInt = int.tryParse(saveMdlScore);
          mdlInt ??= 0;
          sptInt = int.tryParse(saveSptScore);
          sptInt ??= 0;
          puInt = int.tryParse(savePuScore);
          puInt ??= 0;
          sdcInt = int.tryParse(saveSdcScore);
          sdcInt ??= 0;
          plkInt = int.tryParse(savePlkScore);
          plkInt ??= 0;
          runInt = int.tryParse(saveRunScore);
          runInt ??= 0;
          total = mdlInt + sptInt + puInt + sdcInt + plkInt + runInt;

          pass = passDropdown == ''
              ? true
              : rows[i][columnHeaders.indexOf(passDropdown) - 1]
                      .value
                      .toString()
                      .toUpperCase() ==
                  'TRUE';

          Acft acft = Acft(
              soldierId: saveSoldierId,
              owner: owner,
              users: users,
              rank: rank,
              name: name,
              firstName: firstName,
              section: section,
              rankSort: rankSort,
              date: saveDate,
              ageGroup: saveAge,
              gender: saveGender,
              deadliftRaw: saveMdlRaw,
              powerThrowRaw: saveSptRaw,
              puRaw: savePuRaw,
              dragRaw: saveSdcRaw,
              legTuckRaw: savePlkRaw,
              runRaw: saveRunRaw,
              deadliftScore: mdlInt,
              powerThrowScore: sptInt,
              puScore: puInt,
              dragScore: sdcInt,
              legTuckScore: plkInt,
              runScore: runInt,
              total: total,
              altEvent: saveRunEvent,
              pass: pass);

          firestore.collection('acftStats').add(acft.toMap());
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
    ageGroup = '';
    gender = '';
    mdlRaw = '';
    mdlScore = '';
    sptRaw = '';
    sptScore = '';
    puRaw = '';
    puScore = '';
    sdcRaw = '';
    sdcScore = '';
    plkRaw = '';
    plkScore = '';
    runEvent = '';
    runRaw = '';
    runScore = '';
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
        title: const Text('Upload ACFT Stats'),
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
                          decoration:
                              const InputDecoration(labelText: 'Age Group'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: ageGroup,
                          onChanged: (value) {
                            setState(() {
                              ageGroup = value;
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
                              const InputDecoration(labelText: 'MDL Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mdlRaw,
                          onChanged: (value) {
                            setState(() {
                              mdlRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'MDL Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mdlScore,
                          onChanged: (value) {
                            setState(() {
                              mdlScore = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'SPT Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: sptRaw,
                          onChanged: (value) {
                            setState(() {
                              sptRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'SPT Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: sptScore,
                          onChanged: (value) {
                            setState(() {
                              sptScore = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'HRP Raw'),
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
                              const InputDecoration(labelText: 'HRP Score'),
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
                              const InputDecoration(labelText: 'SDC Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: sdcRaw,
                          onChanged: (value) {
                            setState(() {
                              sdcRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'SDC Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: sdcScore,
                          onChanged: (value) {
                            setState(() {
                              sdcScore = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'PLK Raw'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: plkRaw,
                          onChanged: (value) {
                            setState(() {
                              plkRaw = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'PLK Score'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: plkScore,
                          onChanged: (value) {
                            setState(() {
                              plkScore = value;
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Pass'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: passDropdown,
                          onChanged: (value) {
                            setState(() {
                              passDropdown = value;
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
                    text: 'Upload ACFT Stats',
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
