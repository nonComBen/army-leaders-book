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
import '../../models/bodyfat.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadBodyFatsPage extends ConsumerStatefulWidget {
  const UploadBodyFatsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadBodyFatsPageState createState() => UploadBodyFatsPageState();
}

class UploadBodyFatsPageState extends ConsumerState<UploadBodyFatsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      date,
      age,
      height,
      weight,
      bmiPass,
      neck,
      waist,
      hip,
      percent,
      bfPass,
      path,
      gender,
      heightDouble;

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
      age = columnHeaders.contains('Age') ? 'Age' : '';
      height = columnHeaders.contains('Height') ? 'Height' : '';
      weight = columnHeaders.contains('Weight') ? 'Weight' : '';
      bmiPass = columnHeaders.contains('BMI Pass') ? 'BMI Pass' : '';
      neck = columnHeaders.contains('Neck') ? 'Neck' : '';
      waist = columnHeaders.contains('Waist') ? 'Waist' : '';
      hip = columnHeaders.contains('Hip') ? 'Hip' : '';
      percent = columnHeaders.contains('BF Percent') ? 'BF Percent' : '';
      bfPass = columnHeaders.contains('BF Pass') ? 'BF Pass' : '';
      gender = columnHeaders.contains('Gender') ? 'Gender' : '';
      heightDouble = columnHeaders.contains('Height to Half Inch')
          ? 'Height to Half Inch'
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
        bool passBmi, passBf;
        int ageInt;
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
          String saveAge = getCellValue(rows[i], columnHeaders, age);
          String saveHeight = getCellValue(rows[i], columnHeaders, height);
          String saveWeight = getCellValue(rows[i], columnHeaders, weight);
          String saveBmiPass = getCellValue(rows[i], columnHeaders, bmiPass);
          String saveNeck = getCellValue(rows[i], columnHeaders, neck);
          String saveWaist = getCellValue(rows[i], columnHeaders, waist);
          String saveHip = getCellValue(rows[i], columnHeaders, hip);
          String savePercent = getCellValue(rows[i], columnHeaders, percent);
          String saveBfPass = getCellValue(rows[i], columnHeaders, bfPass);
          String saveGender = getCellValue(rows[i], columnHeaders, gender);
          String saveHeightDouble =
              getCellValue(rows[i], columnHeaders, heightDouble);

          ageInt = int.tryParse(saveAge) ?? 0;
          if (saveGender.toLowerCase() == 'female' ||
              saveGender.toLowerCase() == 'f') {
            saveGender = 'Female';
          } else {
            saveGender = 'Male';
          }

          passBmi = saveBmiPass.toLowerCase() == 'true' ||
              saveBmiPass.toLowerCase() == 'yes';
          passBf = saveBfPass.toLowerCase() == 'true' ||
              saveBfPass.toLowerCase() == 'yes';

          Bodyfat bf = Bodyfat(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            age: ageInt,
            gender: saveGender,
            date: saveDate,
            height: saveHeight,
            heightDouble: saveHeightDouble,
            weight: saveWeight,
            passBmi: passBmi,
            neck: saveNeck,
            waist: saveWaist,
            hip: saveHip,
            percent: savePercent,
            passBf: passBf,
          );

          firestore.collection(Bodyfat.collectionName).add(bf.toMap());
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
    age = '';
    height = '';
    weight = '';
    bmiPass = '';
    neck = '';
    waist = '';
    hip = '';
    percent = '';
    bfPass = '';
    gender = '';
    heightDouble = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Body Comp Stats',
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
                  label: const Text('Gender'),
                  items: columnHeaders,
                  value: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Age'),
                  items: columnHeaders,
                  value: age,
                  onChanged: (value) {
                    setState(() {
                      age = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Height'),
                  items: columnHeaders,
                  value: height,
                  onChanged: (value) {
                    setState(() {
                      height = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Weight'),
                  items: columnHeaders,
                  value: weight,
                  onChanged: (value) {
                    setState(() {
                      weight = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('BMI Pass'),
                  items: columnHeaders,
                  value: bmiPass,
                  onChanged: (value) {
                    setState(() {
                      bmiPass = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Height to Nearest Half Inch'),
                  items: columnHeaders,
                  value: heightDouble,
                  onChanged: (value) {
                    setState(() {
                      heightDouble = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Neck'),
                  items: columnHeaders,
                  value: neck,
                  onChanged: (value) {
                    setState(() {
                      neck = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Waist'),
                  items: columnHeaders,
                  value: waist,
                  onChanged: (value) {
                    setState(() {
                      waist = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Hip'),
                  items: columnHeaders,
                  value: hip,
                  onChanged: (value) {
                    setState(() {
                      hip = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('BF Percent'),
                  items: columnHeaders,
                  value: percent,
                  onChanged: (value) {
                    setState(() {
                      percent = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('BF Pass'),
                  items: columnHeaders,
                  value: bfPass,
                  onChanged: (value) {
                    setState(() {
                      bfPass = value;
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
            child: const Text('Upload Body Comp Stats'),
          )
        ],
      ),
    );
  }
}
