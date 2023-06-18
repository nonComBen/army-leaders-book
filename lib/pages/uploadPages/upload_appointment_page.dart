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
import '../../methods/validate.dart';
import '../../models/appointment.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadAppointmentsPage extends ConsumerStatefulWidget {
  const UploadAppointmentsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadAppointmentsPageState createState() => UploadAppointmentsPageState();
}

class UploadAppointmentsPageState
    extends ConsumerState<UploadAppointmentsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, title, date, start, end, status, comments, path, location;

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
      title = columnHeaders.contains('Title') ? 'Title' : '';
      date = columnHeaders.contains('Date') ? 'Date' : '';
      start = columnHeaders.contains('Start Time') ? 'Start Time' : '';
      end = columnHeaders.contains('End Time') ? 'End Time' : '';
      status = columnHeaders.contains('Status') ? 'Status' : '';
      comments = columnHeaders.contains('Comments') ? 'Comments' : '';
      location = columnHeaders.contains('Location') ? 'Location' : '';
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

      List<String> statuses = [];
      statuses.add('Scheduled');
      statuses.add('Rescheduled');
      statuses.add('Kept');
      statuses.add('Cancelled');
      statuses.add('Missed');

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
          String saveTitle = getCellValue(rows[i], columnHeaders, title);
          String saveStart = getCellValue(rows[i], columnHeaders, start);
          String saveEnd = getCellValue(rows[i], columnHeaders, end);
          String saveStatus = getCellValue(rows[i], columnHeaders, status);
          String saveComments = getCellValue(rows[i], columnHeaders, comments);
          String saveLoc = getCellValue(rows[i], columnHeaders, location);

          if (!statuses.contains(saveStatus)) {
            saveStatus = 'Scheduled';
          }
          if (saveStart.length < 4) {
            if (saveStart.length == 3) {
              saveStart = '0$saveStart';
            }
            if (saveStart.length == 2) {
              saveStart = '00$saveStart';
            }
            if (saveStart.length == 1) {
              saveStart = '000$saveStart';
            }
          }
          if (!isValidTime(saveStart)) saveStart = '';
          if (saveEnd.length < 4) {
            if (saveEnd.length == 3) {
              saveEnd = '0$saveEnd';
            }
            if (saveEnd.length == 2) {
              saveEnd = '00$saveEnd';
            }
            if (saveEnd.length == 1) {
              saveEnd = '000$saveEnd';
            }
          }
          if (!isValidTime(saveEnd)) saveEnd = '';

          Appointment apt = Appointment(
            users: users,
            soldierId: saveSoldierId,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            aptTitle: saveTitle,
            date: saveDate,
            start: saveStart,
            end: saveEnd,
            status: saveStatus,
            comments: saveComments,
            owner: owner,
            location: saveLoc,
          );

          firestore.collection(Appointment.collectionName).add(apt.toMap());
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
    title = '';
    date = '';
    start = '';
    end = '';
    status = '';
    comments = '';
    location = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Appointments',
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
                  label: const Text('Title'),
                  items: columnHeaders,
                  value: title,
                  onChanged: (value) {
                    setState(() {
                      title = value;
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
                  label: const Text('Start Time'),
                  items: columnHeaders,
                  value: start,
                  onChanged: (value) {
                    setState(() {
                      start = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('End Time'),
                  items: columnHeaders,
                  value: end,
                  onChanged: (value) {
                    setState(() {
                      end = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Location'),
                  items: columnHeaders,
                  value: location,
                  onChanged: (value) {
                    setState(() {
                      location = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Status'),
                  items: columnHeaders,
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
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
            child: const Text('Upload Appointments'),
          )
        ],
      ),
    );
  }
}
