import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/methods/toast_messages.dart/file_is_blank_message.dart';
import 'package:leaders_book/methods/toast_messages.dart/soldier_id_is_blank.dart';

import '../../methods/theme_methods.dart';
import '../../methods/upload_methods.dart';
import '../../models/soldier.dart';
import '../../models/working_award.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class UploadWorkingAwardsPage extends ConsumerStatefulWidget {
  const UploadWorkingAwardsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadWorkingAwardsPageState createState() => UploadWorkingAwardsPageState();
}

class UploadWorkingAwardsPageState
    extends ConsumerState<UploadWorkingAwardsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, reason, ach1, ach2, ach3, ach4, citation, path;

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
      reason = columnHeaders.contains('Award Reason') ? 'Award Reason' : '';
      ach1 = columnHeaders.contains('Achievement 1') ? 'Achievement 1' : '';
      ach2 = columnHeaders.contains('Achievement 2') ? 'Achievement 2' : '';
      ach3 = columnHeaders.contains('Achievement 3') ? 'Achievement 3' : '';
      ach4 = columnHeaders.contains('Achievement 4') ? 'Achievement 4' : '';
      citation = columnHeaders.contains('Citation') ? 'Citation' : '';
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

      List<String> reasons = [
        'Achievement',
        'Service',
        'PCS',
        'ETS',
        'Retirement',
        'Heroism',
        'Valor'
      ];

      for (int i = 1; i < rows.length; i++) {
        String? rank, name, firstName, section, rankSort;
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

          String saveReason = getCellValue(rows[i], columnHeaders, reason);
          String saveAch1 = getCellValue(rows[i], columnHeaders, ach1);
          String saveAch2 = getCellValue(rows[i], columnHeaders, ach2);
          String saveAch3 = getCellValue(rows[i], columnHeaders, ach3);
          String saveAch4 = getCellValue(rows[i], columnHeaders, ach4);
          String saveCitation = getCellValue(rows[i], columnHeaders, citation);

          if (!reasons.contains(saveReason)) {
            saveReason = 'Achievement';
          }

          WorkingAward award = WorkingAward(
            soldierId: saveSoldierId,
            owner: owner,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            awardReason: saveReason,
            ach1: saveAch1,
            ach2: saveAch2,
            ach3: saveAch3,
            ach4: saveAch4,
            citation: saveCitation,
          );

          firestore.collection('workingAwards').add(award.toMap());
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
    reason = '';
    ach1 = '';
    ach2 = '';
    ach3 = '';
    ach4 = '';
    citation = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Working Awards',
      body: Center(
        child: Card(
          color: getContrastingBackgroundColor(context),
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
                          label: const Text('Award Reason'),
                          items: columnHeaders,
                          value: reason,
                          onChanged: (value) {
                            setState(() {
                              reason = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Achievement #1'),
                          items: columnHeaders,
                          value: ach1,
                          onChanged: (value) {
                            setState(() {
                              ach1 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Achievement #2'),
                          items: columnHeaders,
                          value: ach2,
                          onChanged: (value) {
                            setState(() {
                              ach2 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Achievement #3'),
                          items: columnHeaders,
                          value: ach3,
                          onChanged: (value) {
                            setState(() {
                              ach3 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Achievement #4'),
                          items: columnHeaders,
                          value: ach4,
                          onChanged: (value) {
                            setState(() {
                              ach4 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Citation'),
                          items: columnHeaders,
                          value: citation,
                          onChanged: (value) {
                            setState(() {
                              citation = value;
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
                    child: const Text('Upload Working Awards'),
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
