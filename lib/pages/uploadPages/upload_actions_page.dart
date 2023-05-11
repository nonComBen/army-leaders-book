import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/methods/toast_messages.dart/file_is_blank_message.dart';
import 'package:leaders_book/methods/toast_messages.dart/soldier_id_is_blank.dart';

import '../../methods/upload_methods.dart';
import '../../models/action.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadActionsPage extends ConsumerStatefulWidget {
  const UploadActionsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadActionsPageState createState() => UploadActionsPageState();
}

class UploadActionsPageState extends ConsumerState<UploadActionsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      dateSubmitted,
      action,
      currentStatus,
      statusDate,
      remarks,
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
      dateSubmitted =
          columnHeaders.contains('Date Submitted') ? 'Date Submitted' : '';
      action = columnHeaders.contains('Action') ? 'Action' : '';
      currentStatus =
          columnHeaders.contains('Current Status') ? 'Current Status' : '';
      statusDate = columnHeaders.contains('Status Date') ? 'Status Date' : '';
      remarks = columnHeaders.contains('Remarks') ? 'Remarks' : '';
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

          String saveDateSubmitted =
              convertDate(getCellValue(rows[i], columnHeaders, dateSubmitted));
          String saveAction = getCellValue(rows[i], columnHeaders, action);
          String saveCurrentStatus =
              getCellValue(rows[i], columnHeaders, currentStatus);
          String saveStatusDate =
              convertDate(getCellValue(rows[i], columnHeaders, statusDate));
          String saveRemarks = getCellValue(rows[i], columnHeaders, remarks);

          ActionObj actionObj = ActionObj(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            action: saveAction,
            dateSubmitted: saveDateSubmitted,
            currentStatus: saveCurrentStatus,
            statusDate: saveStatusDate,
            remarks: saveRemarks,
          );

          firestore.collection('actions').add(actionObj.toMap());
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
    dateSubmitted = '';
    action = '';
    currentStatus = '';
    statusDate = '';
    remarks = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Actions',
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
                  label: const Text('Action'),
                  items: columnHeaders,
                  value: action,
                  onChanged: (value) {
                    setState(() {
                      action = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Date Submitted'),
                  items: columnHeaders,
                  value: dateSubmitted,
                  onChanged: (value) {
                    setState(() {
                      dateSubmitted = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Current Status'),
                  items: columnHeaders,
                  value: currentStatus,
                  onChanged: (value) {
                    setState(() {
                      currentStatus = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Status Date'),
                  items: columnHeaders,
                  value: statusDate,
                  onChanged: (value) {
                    setState(() {
                      statusDate = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Remarks'),
                  items: columnHeaders,
                  value: remarks,
                  onChanged: (value) {
                    setState(() {
                      remarks = value;
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
            child: const Text('Upload Actions'),
          )
        ],
      ),
    );
  }
}
