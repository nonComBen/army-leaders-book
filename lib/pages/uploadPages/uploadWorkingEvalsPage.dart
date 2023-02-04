// ignore_for_file: file_names

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../methods/upload_methods.dart';
import '../../models/soldier.dart';
import '../../models/working_eval.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadWorkingEvalsPage extends StatefulWidget {
  const UploadWorkingEvalsPage({
    Key key,
  }) : super(key: key);

  @override
  UploadWorkingEvalsPageState createState() => UploadWorkingEvalsPageState();
}

class UploadWorkingEvalsPageState extends State<UploadWorkingEvalsPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
      duties,
      emphasis,
      appointed,
      character,
      presence,
      intellect,
      leads,
      develops,
      achieves,
      performance,
      path;

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
      columnHeaders = getColumnHeaders(rows.first);
      soldierId = columnHeaders.contains('Soldier Id') ? 'Soldier Id' : '';
      duties =
          columnHeaders.contains('Duty Description') ? 'Duty Description' : '';
      emphasis =
          columnHeaders.contains('Special Emphasis') ? 'Special Emphasis' : '';
      appointed =
          columnHeaders.contains('Appointed Duties') ? 'Appointed Duties' : '';
      character = columnHeaders.contains('Character') ? 'Character' : '';
      presence = columnHeaders.contains('Presence') ? 'Presence' : '';
      intellect = columnHeaders.contains('Intellect') ? 'Intellect' : '';
      leads = columnHeaders.contains('Leads') ? 'Leads' : '';
      develops = columnHeaders.contains('Develops') ? 'Develops' : '';
      achieves = columnHeaders.contains('Achieves') ? 'Achieves' : '';
      performance = columnHeaders.contains('Performance') ? 'Performance' : '';
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

      for (int i = 1; i < rows.length; i++) {
        String rank, name, firstName, section, rankSort;
        String saveSoldierId = getCellValue(rows[i], columnHeaders, soldierId);

        if (soldierIds.contains(saveSoldierId)) {
          Soldier soldier =
              soldiers.elementAt(soldierIds.indexOf(saveSoldierId));
          rank = soldier.rank;
          rankSort = soldier.rankSort.toString();
          name = soldier.lastName;
          firstName = soldier.firstName;
          section = soldier.section;
          final owner = soldier.owner;

          String saveDuties = getCellValue(rows[i], columnHeaders, duties);
          String saveEmphasis = getCellValue(rows[i], columnHeaders, emphasis);
          String saveAppointed =
              getCellValue(rows[i], columnHeaders, appointed);
          String saveCharacter =
              getCellValue(rows[i], columnHeaders, character);
          String savePresence = getCellValue(rows[i], columnHeaders, presence);
          String saveIntellect =
              getCellValue(rows[i], columnHeaders, intellect);
          String saveLeads = getCellValue(rows[i], columnHeaders, leads);
          String saveDevelops = getCellValue(rows[i], columnHeaders, develops);
          String saveAchieves = getCellValue(rows[i], columnHeaders, achieves);
          String savePerformance =
              getCellValue(rows[i], columnHeaders, performance);

          WorkingEval eval = WorkingEval(
            soldierId: saveSoldierId,
            owner: owner,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            dutyDescription: saveDuties,
            appointedDuties: saveAppointed,
            specialEmphasis: saveEmphasis,
            character: saveCharacter,
            presence: savePresence,
            intellect: saveIntellect,
            leads: saveLeads,
            develops: saveDevelops,
            achieves: saveAchieves,
            performance: savePerformance,
          );

          firestore.collection('workingEvals').add(eval.toMap());
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
    duties = '';
    emphasis = '';
    appointed = '';
    character = '';
    presence = '';
    intellect = '';
    leads = '';
    develops = '';
    achieves = '';
    performance = '';
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
        title: const Text('Upload Working Evals'),
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
                          decoration: const InputDecoration(
                              labelText: 'Daily Duties and Scope'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: duties,
                          onChanged: (value) {
                            setState(() {
                              duties = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Areas of Special Emphasis'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: emphasis,
                          onChanged: (value) {
                            setState(() {
                              emphasis = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Appointed Duties'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: appointed,
                          onChanged: (value) {
                            setState(() {
                              appointed = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Character'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: character,
                          onChanged: (value) {
                            setState(() {
                              character = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Presence'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: presence,
                          onChanged: (value) {
                            setState(() {
                              presence = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Intellect'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: intellect,
                          onChanged: (value) {
                            setState(() {
                              intellect = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Leads'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: leads,
                          onChanged: (value) {
                            setState(() {
                              leads = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Develops'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: develops,
                          onChanged: (value) {
                            setState(() {
                              develops = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Achieves'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: achieves,
                          onChanged: (value) {
                            setState(() {
                              achieves = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Overall Performance'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: performance,
                          onChanged: (value) {
                            setState(() {
                              performance = value;
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
                    text: 'Upload Working Evals',
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
