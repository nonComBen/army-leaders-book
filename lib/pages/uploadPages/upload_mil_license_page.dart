import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../methods/show_snackbar.dart';
import '../../methods/theme_methods.dart';
import '../../methods/upload_methods.dart';
import '../../models/mil_license.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class UploadMilLicensePage extends ConsumerStatefulWidget {
  const UploadMilLicensePage({
    Key? key,
  }) : super(key: key);

  @override
  UploadMilLicensePageState createState() => UploadMilLicensePageState();
}

class UploadMilLicensePageState extends ConsumerState<UploadMilLicensePage> {
  late FirebaseFirestore firestore;

  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId, date, exp, license, restrictions, vehicles, path;

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
      exp = columnHeaders.contains('Expiration Date') ? 'Expiration Date' : '';
      license = columnHeaders.contains('License #') ? 'License #' : '';
      restrictions =
          columnHeaders.contains('Restrictions') ? 'Restrictions' : '';
      vehicles = columnHeaders.contains('Qualified Vehicles')
          ? 'Qualified Vehicles'
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
      firestore = FirebaseFirestore.instance;
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

          String saveDate =
              convertDate(getCellValue(rows[i], columnHeaders, date));
          String saveExp =
              convertDate(getCellValue(rows[i], columnHeaders, exp));
          String saveLicense = getCellValue(rows[i], columnHeaders, license);
          String saveRestrictions =
              getCellValue(rows[i], columnHeaders, restrictions);
          List<String> saveVehicles;
          if (vehicles == '') {
            saveVehicles = [];
          } else {
            saveVehicles =
                getCellValue(rows[i], columnHeaders, vehicles).split(',');
            for (int i = 0; i < saveVehicles.length; i++) {
              saveVehicles[i] = saveVehicles[i].trim();
            }
          }

          MilLic milLic = MilLic(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            date: saveDate,
            exp: saveExp,
            license: saveLicense,
            restrictions: saveRestrictions,
            vehicles: saveVehicles,
          );

          firestore.collection('milLic').add(milLic.toMap());
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
    exp = '';
    license = '';
    restrictions = '';
    vehicles = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Military Licenses',
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
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Expiration Date'),
                          items: columnHeaders,
                          value: exp,
                          onChanged: (value) {
                            setState(() {
                              exp = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('License No.'),
                          items: columnHeaders,
                          value: license,
                          onChanged: (value) {
                            setState(() {
                              license = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Restrictions'),
                          items: columnHeaders,
                          value: restrictions,
                          onChanged: (value) {
                            setState(() {
                              restrictions = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlatformItemPicker(
                          label: const Text('Qualified Vehicles'),
                          items: columnHeaders,
                          value: vehicles,
                          onChanged: (value) {
                            setState(() {
                              vehicles = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  PlatformButton(
                    onPressed: () {
                      if (path == '') {
                        showSnackbar(context, 'Please select a file to upload');
                      }
                      _saveData(context);
                    },
                    child: const Text('Upload Military Licenses'),
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
