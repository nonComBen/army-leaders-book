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
import '../../models/profile.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadPermProfilePage extends ConsumerStatefulWidget {
  const UploadPermProfilePage({
    super.key,
  });

  @override
  UploadPermProfilePageState createState() => UploadPermProfilePageState();
}

class UploadPermProfilePageState extends ConsumerState<UploadPermProfilePage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, date, shaving, pu, su, run, altEvent, comments, path;

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
      shaving = columnHeaders.contains('Shaving') ? 'Shaving' : '';
      pu = columnHeaders.contains('PU') ? 'PU' : '';
      su = columnHeaders.contains('SU') ? 'SU' : '';
      run = columnHeaders.contains('Run') ? 'Run' : '';
      altEvent = columnHeaders.contains('Alt Event') ? 'Alt Event' : '';
      comments = columnHeaders.contains('Comments') ? 'Comments' : '';
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
      events.add('Walk');
      events.add('Bike');
      events.add('Swim');

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

          String saveDate =
              convertDate(getCellValue(rows[i], columnHeaders, date));
          String saveShaving = getCellValue(rows[i], columnHeaders, shaving);
          String savePu = getCellValue(rows[i], columnHeaders, pu);
          String saveSu = getCellValue(rows[i], columnHeaders, su);
          String saveRun = getCellValue(rows[i], columnHeaders, run);
          String saveAltEvent = getCellValue(rows[i], columnHeaders, altEvent);
          String saveComments = getCellValue(rows[i], columnHeaders, comments);

          if (!events.contains(saveAltEvent)) {
            saveAltEvent = '';
          }

          PermProfile profile = PermProfile(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            date: saveDate,
            shaving: saveShaving.toLowerCase() == 'true' ||
                saveShaving.toLowerCase() == 'yes',
            pu: savePu.toLowerCase() == 'true' || savePu.toLowerCase() == 'yes',
            su: saveSu.toLowerCase() == 'true' || saveSu.toLowerCase() == 'yes',
            run: saveRun.toLowerCase() == 'true' ||
                saveRun.toLowerCase() == 'yes',
            altEvent: saveAltEvent,
            comments: saveComments,
          );

          firestore.collection(TempProfile.collectionName).add(profile.toMap());
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
    shaving = '';
    pu = '';
    su = '';
    run = '';
    altEvent = '';
    comments = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Permanent Profiles',
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
                  label: const Text('Shaving'),
                  items: columnHeaders,
                  value: shaving,
                  onChanged: (value) {
                    setState(() {
                      shaving = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Push Ups'),
                  items: columnHeaders,
                  value: pu,
                  onChanged: (value) {
                    setState(() {
                      pu = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Sit Ups'),
                  items: columnHeaders,
                  value: su,
                  onChanged: (value) {
                    setState(() {
                      su = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Run'),
                  items: columnHeaders,
                  value: run,
                  onChanged: (value) {
                    setState(() {
                      run = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Alternative Event'),
                  items: columnHeaders,
                  value: altEvent,
                  onChanged: (value) {
                    setState(() {
                      altEvent = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Comments'),
                  items: columnHeaders,
                  value: comments,
                  onChanged: (value) {
                    setState(() {
                      comments = value;
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
            child: const Text('Upload Profiles'),
          )
        ],
      ),
    );
  }
}
