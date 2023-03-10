import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../methods/upload_methods.dart';
import '../../models/equipment.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadEquipmentPage extends StatefulWidget {
  const UploadEquipmentPage({
    Key key,
  }) : super(key: key);

  @override
  UploadEquipmentPageState createState() => UploadEquipmentPageState();
}

class UploadEquipmentPageState extends State<UploadEquipmentPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
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

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void _openFileExplorer() async {
    try {
      var result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
      path = result.files.first.name;
      if (kIsWeb) {
        var excel = Excel.decodeBytes(result.files.first.bytes);
        _readExcel(excel.sheets.values.first);
      } else {
        var file = File(result.files.first.path);
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Soldier Id must not be blank. To get your Soldiers\' Ids, download their data from the Soldiers page.')));
      return;
    }
    if (rows.length > 1) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final soldiers =
          Provider.of<SoldiersProvider>(context, listen: false).soldiers;

      List<String> soldierIds = soldiers.map((e) => e.id).toList();

      for (int i = 1; i < rows.length; i++) {
        String rank, name, firstName, section, rankSort, owner;
        List<dynamic> users;
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

          firestore.collection('equipment').add(equipment.toMap());
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
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Upload Equipment'),
      ),
      body: Center(
        child: Card(
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
                  FormattedElevatedButton(
                    onPressed: () {
                      _openFileExplorer();
                    },
                    text: 'Pick File',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      path,
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'SoldierId'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Weapon'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: weapon,
                          onChanged: (value) {
                            setState(() {
                              weapon = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Butt Stock'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: buttStock,
                          onChanged: (value) {
                            setState(() {
                              buttStock = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Serial No.'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: serial,
                          onChanged: (value) {
                            setState(() {
                              serial = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Optics'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: optic,
                          onChanged: (value) {
                            setState(() {
                              optic = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Optics Serial No.'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: opticSerial,
                          onChanged: (value) {
                            setState(() {
                              opticSerial = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Secondary Weapon'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: weapon2,
                          onChanged: (value) {
                            setState(() {
                              weapon2 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Secondary Butt Stock'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: buttStock2,
                          onChanged: (value) {
                            setState(() {
                              buttStock2 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Secondary Serial No.'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: serial2,
                          onChanged: (value) {
                            setState(() {
                              serial2 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Secondary Optics'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: optic2,
                          onChanged: (value) {
                            setState(() {
                              optic2 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Secondary Optics Serial No.'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: opticSerial2,
                          onChanged: (value) {
                            setState(() {
                              opticSerial2 = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Mask'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mask,
                          onChanged: (value) {
                            setState(() {
                              mask = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Vehicle'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: veh,
                          onChanged: (value) {
                            setState(() {
                              veh = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Vehicle Bumper'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: bumper,
                          onChanged: (value) {
                            setState(() {
                              bumper = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Other Item'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: misc,
                          onChanged: (value) {
                            setState(() {
                              misc = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Other Item Serial No.'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                  FormattedElevatedButton(
                    onPressed: path == ''
                        ? null
                        : () {
                            _saveData(context);
                          },
                    text: 'Upload Equipment',
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
