import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../methods/show_snackbar.dart';
import '../../methods/upload_methods.dart';
import '../../models/rating.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadRatingsPage extends StatefulWidget {
  const UploadRatingsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadRatingsPageStat createState() => UploadRatingsPageStat();
}

class UploadRatingsPageStat extends State<UploadRatingsPage> {
  List<String?>? columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, rater, sr, reviewer, lastEval, nextEval, nextType, path;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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
      rater = columnHeaders!.contains('Rater') ? 'Rater' : '';
      sr = columnHeaders!.contains('Senior Rater') ? 'Senior Rater' : '';
      reviewer = columnHeaders!.contains('Reviewer') ? 'Reviewer' : '';
      lastEval = columnHeaders!.contains('Last Eval') ? 'Last Eval' : '';
      nextEval = columnHeaders!.contains('Next Eval') ? 'Next Eval' : '';
      nextType =
          columnHeaders!.contains('Next Eval Type') ? 'Next Eval Type' : '';
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

      List<String?> soldierIds = soldiers.map((e) => e.id).toList();

      List<String> events = [];
      events.add('');
      events.add('Annual');
      events.add('Ext Annual');
      events.add('Change of Rater');
      events.add('Relief for Cause');
      events.add('Complete the Record');
      events.add('60 Day Rater Option');
      events.add('60 Day Senior Rater Option');
      events.add('Temporary Duty/Special Duty');
      events.add('Change of Duty');
      events.add('Officer Failing Promotion Selection');

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

          String saveLast =
              convertDate(getCellValue(rows[i], columnHeaders, lastEval));
          String saveNext =
              convertDate(getCellValue(rows[i], columnHeaders, nextEval));
          String saveRater = getCellValue(rows[i], columnHeaders, rater);
          String saveSr = getCellValue(rows[i], columnHeaders, sr);
          String saveReviewer = getCellValue(rows[i], columnHeaders, reviewer);
          String saveNextType = getCellValue(rows[i], columnHeaders, nextType);

          if (!events.contains(saveNextType)) {
            saveNextType = '';
          }

          Rating rating = Rating(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            last: saveLast,
            next: saveNext,
            nextType: saveNextType,
            rater: saveRater,
            sr: saveSr,
            reviewer: saveReviewer,
          );

          firestore.collection('ratings').add(rating.toMap());
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
    rater = '';
    sr = '';
    reviewer = '';
    lastEval = '';
    nextEval = '';
    nextType = '';
    columnHeaders = [];
    columnHeaders!.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Upload Rating Scheme'),
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
                          decoration: const InputDecoration(labelText: 'Rater'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: rater,
                          onChanged: (value) {
                            setState(() {
                              rater = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Senior Rater'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: sr,
                          onChanged: (value) {
                            setState(() {
                              sr = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Reviewer'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: reviewer,
                          onChanged: (value) {
                            setState(() {
                              reviewer = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Last Eval'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: lastEval,
                          onChanged: (value) {
                            setState(() {
                              lastEval = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Next Eval Date'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: nextEval,
                          onChanged: (value) {
                            setState(() {
                              nextEval = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Next Eval Type'),
                          items: columnHeaders!.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header!),
                            );
                          }).toList(),
                          value: nextType,
                          onChanged: (value) {
                            setState(() {
                              nextType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  FormattedElevatedButton(
                    onPressed: () {
                      if (path == '') {
                        showSnackbar(context, 'Please select a file to upload');
                      }
                      _saveData(context);
                    },
                    text: 'Upload Rating Schemes',
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
