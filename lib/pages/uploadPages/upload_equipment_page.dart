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
import '../../models/equipment.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadEquipmentPage extends ConsumerStatefulWidget {
  const UploadEquipmentPage({
    super.key,
  });

  @override
  UploadEquipmentPageState createState() => UploadEquipmentPageState();
}

class UploadEquipmentPageState extends ConsumerState<UploadEquipmentPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      weapon,
      buttStock,
      serial,
      optic,
      opticSerial,
      weapon2,
      buttStock2,
      serial2,
      optic2,
      opticSerial2,
      mask,
      veh,
      bumper,
      misc,
      miscSerial,
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
      weapon = columnHeaders.contains('Weapon') ? 'Weapon' : '';
      buttStock = columnHeaders.contains('Butt Stock') ? 'Butt Stock' : '';
      serial = columnHeaders.contains('Serial #') ? 'Serial #' : '';
      optic = columnHeaders.contains('Optics') ? 'Optics' : '';
      opticSerial =
          columnHeaders.contains('Optics Serial #') ? 'Optics Serial #' : '';
      weapon2 =
          columnHeaders.contains('Secondary Weapon') ? 'Secondary Weapon' : '';
      buttStock2 = columnHeaders.contains('Secondary Butt Stock')
          ? 'Secondary Butt Stock'
          : '';
      serial2 = columnHeaders.contains('Secondary Serial #')
          ? 'Secondary Serial #'
          : '';
      optic2 =
          columnHeaders.contains('Secondary Optics') ? 'Secondary Optics' : '';
      opticSerial2 = columnHeaders.contains('Secondary Optics Serial #')
          ? 'Secondary Optics Serial #'
          : '';
      mask = columnHeaders.contains('Mask') ? 'Mask' : '';
      veh = columnHeaders.contains('Vehicle Type') ? 'Vehicle Type' : '';
      bumper =
          columnHeaders.contains('Vehicle Bumper #') ? 'Vehicle Bumper #' : '';
      misc = columnHeaders.contains('Miscellaneous') ? 'Miscellaneous' : '';
      miscSerial = columnHeaders.contains('Miscellaneous Serial #')
          ? 'Miscellaneous Serial #'
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

          String saveWeapon = getCellValue(rows[i], columnHeaders, weapon);
          String saveButtStock =
              getCellValue(rows[i], columnHeaders, buttStock);
          String saveSerial = getCellValue(rows[i], columnHeaders, serial);
          String saveOptic = getCellValue(rows[i], columnHeaders, optic);
          String saveOpticSerial =
              getCellValue(rows[i], columnHeaders, opticSerial);
          String saveWeapon2 = getCellValue(rows[i], columnHeaders, weapon2);
          String saveButtStock2 =
              getCellValue(rows[i], columnHeaders, buttStock2);
          String saveSerial2 = getCellValue(rows[i], columnHeaders, serial2);
          String saveOptic2 = getCellValue(rows[i], columnHeaders, optic2);
          String saveOpticSerial2 =
              getCellValue(rows[i], columnHeaders, opticSerial2);
          String saveMask = getCellValue(rows[i], columnHeaders, mask);
          String saveVeh = getCellValue(rows[i], columnHeaders, veh);
          String saveBumper = getCellValue(rows[i], columnHeaders, bumper);
          String saveMisc = getCellValue(rows[i], columnHeaders, misc);
          String saveMiscSerial =
              getCellValue(rows[i], columnHeaders, miscSerial);

          Equipment equipment = Equipment(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            weapon: saveWeapon,
            buttStock: saveButtStock,
            serial: saveSerial,
            weapon2: saveWeapon2,
            buttStock2: saveButtStock2,
            serial2: saveSerial2,
            optic: saveOptic,
            opticSerial: saveOpticSerial,
            optic2: saveOptic2,
            opticSerial2: saveOpticSerial2,
            mask: saveMask,
            veh: saveBumper,
            vehType: saveVeh,
            other: saveMisc,
            otherSerial: saveMiscSerial,
          );

          firestore.collection(Equipment.collectionName).add(equipment.toMap());
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
    weapon = '';
    buttStock = '';
    serial = '';
    optic = '';
    opticSerial = '';
    weapon2 = '';
    buttStock2 = '';
    serial2 = '';
    optic2 = '';
    opticSerial2 = '';
    mask = '';
    veh = '';
    bumper = '';
    misc = '';
    miscSerial = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Equipment',
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
                  label: const Text('Weapon'),
                  items: columnHeaders,
                  value: weapon,
                  onChanged: (value) {
                    setState(() {
                      weapon = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Butt Stock'),
                  items: columnHeaders,
                  value: buttStock,
                  onChanged: (value) {
                    setState(() {
                      buttStock = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Serial No.'),
                  items: columnHeaders,
                  value: serial,
                  onChanged: (value) {
                    setState(() {
                      serial = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Optics'),
                  items: columnHeaders,
                  value: optic,
                  onChanged: (value) {
                    setState(() {
                      optic = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Optics Serial No.'),
                  items: columnHeaders,
                  value: opticSerial,
                  onChanged: (value) {
                    setState(() {
                      opticSerial = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Secondary Weapon'),
                  items: columnHeaders,
                  value: weapon2,
                  onChanged: (value) {
                    setState(() {
                      weapon2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Secondary Butt Stock'),
                  items: columnHeaders,
                  value: buttStock2,
                  onChanged: (value) {
                    setState(() {
                      buttStock2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Secondary Serial No.'),
                  items: columnHeaders,
                  value: serial2,
                  onChanged: (value) {
                    setState(() {
                      serial2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Secondary Optics'),
                  items: columnHeaders,
                  value: optic2,
                  onChanged: (value) {
                    setState(() {
                      optic2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Secondary Optics Serial No.'),
                  items: columnHeaders,
                  value: opticSerial2,
                  onChanged: (value) {
                    setState(() {
                      opticSerial2 = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Mask'),
                  items: columnHeaders,
                  value: mask,
                  onChanged: (value) {
                    setState(() {
                      mask = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Vehicle'),
                  items: columnHeaders,
                  value: veh,
                  onChanged: (value) {
                    setState(() {
                      veh = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Vehicle Bumper'),
                  items: columnHeaders,
                  value: bumper,
                  onChanged: (value) {
                    setState(() {
                      bumper = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Other Item'),
                  items: columnHeaders,
                  value: misc,
                  onChanged: (value) {
                    setState(() {
                      misc = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Other Item Serial No.'),
                  items: columnHeaders,
                  value: miscSerial,
                  onChanged: (value) {
                    setState(() {
                      miscSerial = value;
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
            child: const Text('Upload Equipment'),
          )
        ],
      ),
    );
  }
}
