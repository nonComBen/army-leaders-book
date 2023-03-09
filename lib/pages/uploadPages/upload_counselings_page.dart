// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../methods/upload_methods.dart';
import '../../models/counseling.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadCounselingsPage extends StatefulWidget {
  const UploadCounselingsPage({
    Key key,
  }) : super(key: key);

  @override
  UploadCounselingsPageState createState() => UploadCounselingsPageState();
}

class UploadCounselingsPageState extends State<UploadCounselingsPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
      date,
      assessment,
      indivRemarks,
      keyPoints,
      leaderResp,
      planOfAction,
      purpose,
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
      date = columnHeaders.contains('Date') ? 'Date' : '';
      assessment = columnHeaders.contains('Assessment') ? 'Assessment' : '';
      indivRemarks = columnHeaders.contains('Individual Remarks')
          ? 'Individual Remarks'
          : '';
      keyPoints = columnHeaders.contains('Key Points') ? 'Key Points' : '';
      leaderResp = columnHeaders.contains('Leader Responsibilities')
          ? 'Leader Responsibilities'
          : '';
      planOfAction =
          columnHeaders.contains('Plan of Action') ? 'Plan of Action' : '';
      purpose = columnHeaders.contains('Purpose of Counseling')
          ? 'Purpose of Counseling'
          : '';
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
        String owner = AuthProvider.of(context).auth.currentUser().uid;
        String saveSoldierId = getCellValue(rows[i], columnHeaders, soldierId);

        if (soldierIds.contains(saveSoldierId)) {
          Soldier soldier =
              soldiers.elementAt(soldierIds.indexOf(saveSoldierId));
          rank = soldier.rank;
          rankSort = soldier.rankSort.toString();
          name = soldier.lastName;
          firstName = soldier.firstName;
          section = soldier.section;

          String saveDate =
              convertDate(getCellValue(rows[i], columnHeaders, date));
          String saveAssessment =
              getCellValue(rows[i], columnHeaders, assessment);
          String saveKeyPoints =
              getCellValue(rows[i], columnHeaders, keyPoints);
          String saveIndivRemarks =
              getCellValue(rows[i], columnHeaders, indivRemarks);
          String saveLeaderResp =
              getCellValue(rows[i], columnHeaders, leaderResp);
          String savePlan = getCellValue(rows[i], columnHeaders, planOfAction);
          String savePurpose = getCellValue(rows[i], columnHeaders, purpose);

          Counseling counseling = Counseling(
            soldierId: saveSoldierId,
            owner: owner,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            date: saveDate,
            assessment: saveAssessment,
            indivRemarks: saveIndivRemarks,
            keyPoints: saveKeyPoints,
            leaderResp: saveLeaderResp,
            planOfAction: savePlan,
            purpose: savePurpose,
          );

          firestore.collection('counselings').add(counseling.toMap());
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
    assessment = '';
    indivRemarks = '';
    keyPoints = '';
    leaderResp = '';
    planOfAction = '';
    purpose = '';
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
        title: const Text('Upload Counselings'),
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
                          decoration: const InputDecoration(
                              labelText: 'Purpose of Counseling'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: purpose,
                          onChanged: (value) {
                            setState(() {
                              purpose = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Key Points'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: keyPoints,
                          onChanged: (value) {
                            setState(() {
                              keyPoints = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Plan of Action'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: planOfAction,
                          onChanged: (value) {
                            setState(() {
                              planOfAction = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Individual Remarks'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: indivRemarks,
                          onChanged: (value) {
                            setState(() {
                              indivRemarks = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Leader Responsibilities'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: leaderResp,
                          onChanged: (value) {
                            setState(() {
                              leaderResp = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Assessment'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: assessment,
                          onChanged: (value) {
                            setState(() {
                              assessment = value;
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
                    text: 'Upload Counselings',
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
