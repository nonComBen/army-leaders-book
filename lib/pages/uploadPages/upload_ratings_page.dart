import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../methods/toast_messages/file_is_blank_message.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/upload_methods.dart';
import '../../models/rating.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadRatingsPage extends ConsumerStatefulWidget {
  const UploadRatingsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadRatingsPageStat createState() => UploadRatingsPageStat();
}

class UploadRatingsPageStat extends ConsumerState<UploadRatingsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, rater, sr, reviewer, lastEval, nextEval, nextType, path;

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
      rater = columnHeaders.contains('Rater') ? 'Rater' : '';
      sr = columnHeaders.contains('Senior Rater') ? 'Senior Rater' : '';
      reviewer = columnHeaders.contains('Reviewer') ? 'Reviewer' : '';
      lastEval = columnHeaders.contains('Last Eval') ? 'Last Eval' : '';
      nextEval = columnHeaders.contains('Next Eval') ? 'Next Eval' : '';
      nextType =
          columnHeaders.contains('Next Eval Type') ? 'Next Eval Type' : '';
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

          firestore.collection(Rating.collectionName).add(rating.toMap());
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
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Rating Scheme',
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
                  label: const Text('Rater'),
                  items: columnHeaders,
                  value: rater,
                  onChanged: (value) {
                    setState(() {
                      rater = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Senior Rater'),
                  items: columnHeaders,
                  value: sr,
                  onChanged: (value) {
                    setState(() {
                      sr = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Reviewer'),
                  items: columnHeaders,
                  value: reviewer,
                  onChanged: (value) {
                    setState(() {
                      reviewer = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Last Eval'),
                  items: columnHeaders,
                  value: lastEval,
                  onChanged: (value) {
                    setState(() {
                      lastEval = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Next Eval Date'),
                  items: columnHeaders,
                  value: nextEval,
                  onChanged: (value) {
                    setState(() {
                      nextEval = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Next Eval Type'),
                  items: columnHeaders,
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
          PlatformButton(
            onPressed: () {
              if (path == '') {
                fileIsBlankMessage(context);
              }
              _saveData(context);
            },
            child: const Text('Upload Rating Schemes'),
          )
        ],
      ),
    );
  }
}
