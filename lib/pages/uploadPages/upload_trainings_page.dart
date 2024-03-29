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
import '../../models/soldier.dart';
import '../../models/training.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadTrainingsPage extends ConsumerStatefulWidget {
  const UploadTrainingsPage({
    super.key,
  });

  @override
  UploadTrainingsPageState createState() => UploadTrainingsPageState();
}

class UploadTrainingsPageState extends ConsumerState<UploadTrainingsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      cyber,
      opsec,
      antiTerror,
      law,
      persRec,
      infoSec,
      ctip,
      gat,
      sere,
      tarp,
      eo,
      asap,
      suicide,
      sharp,
      add1,
      add1Date,
      add2,
      add2Date,
      add3,
      add3Date,
      add4,
      add4Date,
      add5,
      add5Date,
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
      cyber =
          columnHeaders.contains('Cyber Awareness') ? 'Cyber Awareness' : '';
      opsec = columnHeaders.contains('OPSEC') ? 'OPSEC' : '';
      antiTerror = columnHeaders.contains('AT Level 1') ? 'AT Level 1' : '';
      law = columnHeaders.contains('Law of War') ? 'Law of War' : '';
      persRec = columnHeaders.contains('Personnel Recovery')
          ? 'Personnel Recovery'
          : '';
      infoSec = columnHeaders.contains('Information Security')
          ? 'Information Security'
          : '';
      ctip = columnHeaders.contains('CTIP') ? 'CTIP' : '';
      gat = columnHeaders.contains('GAT') ? 'GAT' : '';
      tarp = columnHeaders.contains('TARP') ? 'TARP' : '';
      sere = columnHeaders.contains('SERE') ? 'SERE' : '';
      eo = columnHeaders.contains('Equal Opportunity')
          ? 'Equal Opportunity'
          : '';
      asap = columnHeaders.contains('ASAP') ? 'ASAP' : '';
      suicide = columnHeaders.contains('Suicide Prevention')
          ? 'Suicide Prevention'
          : '';
      sharp = columnHeaders.contains('SHARP') ? 'SHARP' : '';
      add1 = columnHeaders.contains('Additional 1') ? 'Additional 1' : '';
      add1Date = columnHeaders.contains('Additional 1 Date')
          ? 'Additional 1 Date'
          : '';
      add2 = columnHeaders.contains('Additional 2') ? 'Additional 2' : '';
      add2Date = columnHeaders.contains('Additional 2 Date')
          ? 'Additional 2 Date'
          : '';
      add3 = columnHeaders.contains('Additional 3') ? 'Additional 3' : '';
      add3Date = columnHeaders.contains('Additional 3 Date')
          ? 'Additional 3 Date'
          : '';
      add4 = columnHeaders.contains('Additional 4') ? 'Additional 4' : '';
      add4Date = columnHeaders.contains('Additional 4 Date')
          ? 'Additional 4 Date'
          : '';
      add5 = columnHeaders.contains('Additional 5') ? 'Additional 5' : '';
      add5Date = columnHeaders.contains('Additional 5 Date')
          ? 'Additional 5 Date'
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

          String saveCyber =
              convertDate(getCellValue(rows[i], columnHeaders, cyber));
          String saveOpsec =
              convertDate(getCellValue(rows[i], columnHeaders, opsec));
          String saveAt =
              convertDate(getCellValue(rows[i], columnHeaders, antiTerror));
          String saveLaw =
              convertDate(getCellValue(rows[i], columnHeaders, law));
          String savePersRec =
              convertDate(getCellValue(rows[i], columnHeaders, persRec));
          String saveInfoSec =
              convertDate(getCellValue(rows[i], columnHeaders, infoSec));
          String saveCtip =
              convertDate(getCellValue(rows[i], columnHeaders, ctip));
          String saveGat =
              convertDate(getCellValue(rows[i], columnHeaders, gat));
          String saveSere =
              convertDate(getCellValue(rows[i], columnHeaders, sere));
          String saveTarp =
              convertDate(getCellValue(rows[i], columnHeaders, tarp));
          String saveEo = convertDate(getCellValue(rows[i], columnHeaders, eo));
          String saveAsap =
              convertDate(getCellValue(rows[i], columnHeaders, asap));
          String saveSuicide =
              convertDate(getCellValue(rows[i], columnHeaders, suicide));
          String saveSharp =
              convertDate(getCellValue(rows[i], columnHeaders, sharp));
          String saveAdd1Date =
              convertDate(getCellValue(rows[i], columnHeaders, add1Date));
          String saveAdd2Date =
              convertDate(getCellValue(rows[i], columnHeaders, add2Date));
          String saveAdd3Date =
              convertDate(getCellValue(rows[i], columnHeaders, add3Date));
          String saveAdd4Date =
              convertDate(getCellValue(rows[i], columnHeaders, add4Date));
          String saveAdd5Date =
              convertDate(getCellValue(rows[i], columnHeaders, add5Date));
          String saveAdd1 = getCellValue(rows[i], columnHeaders, add1);
          String saveAdd2 = getCellValue(rows[i], columnHeaders, add2);
          String saveAdd3 = getCellValue(rows[i], columnHeaders, add3);
          String saveAdd4 = getCellValue(rows[i], columnHeaders, add4);
          String saveAdd5 = getCellValue(rows[i], columnHeaders, add5);

          Training training = Training(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            cyber: saveCyber,
            opsec: saveOpsec,
            antiTerror: saveAt,
            lawOfWar: saveLaw,
            persRec: savePersRec,
            infoSec: saveInfoSec,
            ctip: saveCtip,
            gat: saveGat,
            sere: saveSere,
            tarp: saveTarp,
            eo: saveEo,
            asap: saveAsap,
            suicide: saveSuicide,
            sharp: saveSharp,
            add1: saveAdd1,
            add1Date: saveAdd1Date,
            add2: saveAdd2,
            add2Date: saveAdd2Date,
            add3: saveAdd3,
            add3Date: saveAdd3Date,
            add4: saveAdd4,
            add4Date: saveAdd4Date,
            add5: saveAdd5,
            add5Date: saveAdd5Date,
          );

          firestore.collection(Training.collectionName).add(training.toMap());
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
    cyber = '';
    opsec = '';
    antiTerror = '';
    law = '';
    persRec = '';
    infoSec = '';
    ctip = '';
    gat = '';
    tarp = '';
    sere = '';
    eo = '';
    asap = '';
    suicide = '';
    sharp = '';
    add1 = '';
    add1Date = '';
    add2 = '';
    add2Date = '';
    add3 = '';
    add3Date = '';
    add4 = '';
    add4Date = '';
    add5 = '';
    add5Date = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Training',
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
                  label: const Text('Cyber Awareness Date'),
                  items: columnHeaders,
                  value: cyber,
                  onChanged: (value) {
                    setState(() {
                      cyber = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('OPSEC Date'),
                  items: columnHeaders,
                  value: opsec,
                  onChanged: (value) {
                    setState(() {
                      opsec = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Anti-Terror Date'),
                  items: columnHeaders,
                  value: antiTerror,
                  onChanged: (value) {
                    setState(() {
                      antiTerror = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Law of War Date'),
                  items: columnHeaders,
                  value: law,
                  onChanged: (value) {
                    setState(() {
                      law = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Personnel Recovery Date'),
                  items: columnHeaders,
                  value: persRec,
                  onChanged: (value) {
                    setState(() {
                      persRec = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Info Security Date'),
                  items: columnHeaders,
                  value: infoSec,
                  onChanged: (value) {
                    setState(() {
                      infoSec = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('CTIP Date'),
                  items: columnHeaders,
                  value: ctip,
                  onChanged: (value) {
                    setState(() {
                      ctip = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('GAT Date'),
                  items: columnHeaders,
                  value: gat,
                  onChanged: (value) {
                    setState(() {
                      gat = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('SERE Date'),
                  items: columnHeaders,
                  value: sere,
                  onChanged: (value) {
                    setState(() {
                      sere = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('TARP Date'),
                  items: columnHeaders,
                  value: tarp,
                  onChanged: (value) {
                    setState(() {
                      tarp = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('EO Date'),
                  items: columnHeaders,
                  value: eo,
                  onChanged: (value) {
                    setState(() {
                      eo = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('ASAP Date'),
                  items: columnHeaders,
                  value: asap,
                  onChanged: (value) {
                    setState(() {
                      asap = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Suicide Prev Date'),
                  items: columnHeaders,
                  value: suicide,
                  onChanged: (value) {
                    setState(() {
                      suicide = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('SHARP Date'),
                  items: columnHeaders,
                  value: sharp,
                  onChanged: (value) {
                    setState(() {
                      sharp = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 1'),
                  items: columnHeaders,
                  value: add1,
                  onChanged: (value) {
                    setState(() {
                      add1 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 1 Date'),
                  items: columnHeaders,
                  value: add1Date,
                  onChanged: (value) {
                    setState(() {
                      add1Date = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 2'),
                  items: columnHeaders,
                  value: add2,
                  onChanged: (value) {
                    setState(() {
                      add2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 2 Date'),
                  items: columnHeaders,
                  value: add2Date,
                  onChanged: (value) {
                    setState(() {
                      add2Date = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 3'),
                  items: columnHeaders,
                  value: add3,
                  onChanged: (value) {
                    setState(() {
                      add3 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 3 Date'),
                  items: columnHeaders,
                  value: add3Date,
                  onChanged: (value) {
                    setState(() {
                      add3Date = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 4'),
                  items: columnHeaders,
                  value: add4,
                  onChanged: (value) {
                    setState(() {
                      add4 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 4 Date'),
                  items: columnHeaders,
                  value: add4Date,
                  onChanged: (value) {
                    setState(() {
                      add4Date = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 5'),
                  items: columnHeaders,
                  value: add5,
                  onChanged: (value) {
                    setState(() {
                      add5 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Additional Training 5 Date'),
                  items: columnHeaders,
                  value: add5Date,
                  onChanged: (value) {
                    setState(() {
                      add5Date = value;
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
            child: const Text('Upload Training'),
          )
        ],
      ),
    );
  }
}
