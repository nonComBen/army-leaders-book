import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../methods/toast_messages/file_is_blank_message.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../providers/auth_provider.dart';
import '../../methods/upload_methods.dart';
import '../../models/counseling.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadCounselingsPage extends ConsumerStatefulWidget {
  const UploadCounselingsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadCounselingsPageState createState() => UploadCounselingsPageState();
}

class UploadCounselingsPageState extends ConsumerState<UploadCounselingsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      date,
      assessment,
      indivRemarks,
      keyPoints,
      leaderResp,
      planOfAction,
      purpose,
      path;

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
      soldierIdIsBlankMessage(context);
      return;
    }
    if (rows.length > 1) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final soldiers = ref.read(soldiersProvider);

      List<String?> soldierIds = soldiers.map((e) => e.id).toList();

      for (int i = 1; i < rows.length; i++) {
        String? rank, name, firstName, section, rankSort;
        String owner = ref.read(authProvider).currentUser()!.uid;
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

          firestore
              .collection(Counseling.collectionName)
              .add(counseling.toMap());
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
    return PlatformScaffold(
      title: 'Upload Counselings',
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
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
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
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Purpose of Counseling'),
                  items: columnHeaders,
                  value: purpose,
                  onChanged: (value) {
                    setState(() {
                      purpose = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Key Points'),
                  items: columnHeaders,
                  value: keyPoints,
                  onChanged: (value) {
                    setState(() {
                      keyPoints = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Plan of Action'),
                  items: columnHeaders,
                  value: planOfAction,
                  onChanged: (value) {
                    setState(() {
                      planOfAction = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Individual Remarks'),
                  items: columnHeaders,
                  value: indivRemarks,
                  onChanged: (value) {
                    setState(() {
                      indivRemarks = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Leader Responsibilities'),
                  items: columnHeaders,
                  value: leaderResp,
                  onChanged: (value) {
                    setState(() {
                      leaderResp = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Assessment'),
                  items: columnHeaders,
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
          PlatformButton(
            onPressed: () {
              if (path == '') {
                fileIsBlankMessage(context);
              }
              _saveData(context);
            },
            child: const Text('Upload Counselings'),
          )
        ],
      ),
    );
  }
}
