// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:leaders_book/providers/soldiers_provider.dart';
import 'package:provider/provider.dart';

import '../../methods/rank_sort.dart';
import '../../methods/upload_methods.dart';
import '../../models/soldier.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadSoldierPage extends StatefulWidget {
  const UploadSoldierPage({
    Key key,
    this.userId,
  }) : super(key: key);
  final String userId;

  @override
  UploadSoldierPageState createState() => UploadSoldierPageState();
}

class UploadSoldierPageState extends State<UploadSoldierPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
      rank,
      lastName,
      firstName,
      mi,
      assigned,
      section,
      dodId,
      dor,
      mos,
      duty,
      paraLn,
      reqMos,
      loss,
      ets,
      basd,
      pebd,
      gain,
      address,
      city,
      state,
      zip,
      phone,
      workPhone,
      email,
      workEmail,
      nok,
      nokPhone,
      maritalStatus,
      comments,
      civEd,
      milEd,
      nbcSuitSize,
      nbcMaskSize,
      nbcBootSize,
      nbcGloveSize,
      hatSize,
      bootSize,
      acuTopSize,
      acuTrouserSize,
      path;

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

  _readExcel(Sheet sheet) {
    rows = sheet.rows;
    columnHeaders = [''];
    for (var cell in rows.first) {
      if (cell.value != '') {
        columnHeaders.add(cell.value);
      }
    }
    soldierId = columnHeaders.contains('Soldier Id') ? 'Soldier Id' : '';
    rank = columnHeaders.contains('Rank') ? 'Rank' : '';
    lastName = columnHeaders.contains('Last Name') ? 'Last Name' : '';
    firstName = columnHeaders.contains('First Name') ? 'First Name' : '';
    mi = columnHeaders.contains('Middle Initial') ? 'Middle Initial' : '';
    assigned = columnHeaders.contains('Assigned') ? 'Assigned' : '';
    section = columnHeaders.contains('Section') ? 'Section' : '';
    dodId = columnHeaders.contains('DoD ID') ? 'DoD ID' : '';
    dor = columnHeaders.contains('Date of Rank') ? 'Date of Rank' : '';
    mos = columnHeaders.contains('MOS') ? 'MOS' : '';
    duty = columnHeaders.contains('Duty Position') ? 'Duty Position' : '';
    paraLn = columnHeaders.contains('Paragraph/Line No.')
        ? 'Paragraph/Line No.'
        : '';
    reqMos = columnHeaders.contains('Duty MOS') ? 'Duty MOS' : '';
    loss = columnHeaders.contains('Loss Date') ? 'Loss Date' : '';
    ets = columnHeaders.contains('ETS') ? 'ETS' : '';
    basd = columnHeaders.contains('BASD') ? 'BASD' : '';
    pebd = columnHeaders.contains('PEBD') ? 'PEBD' : '';
    gain = columnHeaders.contains('Gain Date') ? 'Gain Date' : '';
    address = columnHeaders.contains('Address') ? 'Address' : '';
    city = columnHeaders.contains('City') ? 'City' : '';
    state = columnHeaders.contains('State') ? 'State' : '';
    zip = columnHeaders.contains('Zip Code') ? 'Zip Code' : '';
    phone = columnHeaders.contains('Phone Number') ? 'Phone Number' : '';
    workPhone = columnHeaders.contains('Work Phone') ? 'Work Phone' : '';
    email = columnHeaders.contains('Email Address') ? 'Email Address' : '';
    workEmail = columnHeaders.contains('Work Email') ? 'Work Email' : '';
    nok = columnHeaders.contains('Next of Kin') ? 'Next of Kin' : '';
    nokPhone =
        columnHeaders.contains('Next of Kin Phone') ? 'Next of Kin Phone' : '';
    maritalStatus =
        columnHeaders.contains('Marital Status') ? 'Marital Status' : '';
    comments = columnHeaders.contains('Comments') ? 'Comments' : '';
    civEd = columnHeaders.contains('Civ Ed Level') ? 'Civ Ed Level' : '';
    milEd = columnHeaders.contains('Mil Ed Level') ? 'Mil Ed Level' : '';
    nbcBootSize =
        columnHeaders.contains('CBRN Boot Size') ? 'CBRN Boot Size' : '';
    nbcGloveSize =
        columnHeaders.contains('CBRN Glove Size') ? 'CBRN Glove Size' : '';
    nbcMaskSize =
        columnHeaders.contains('CBRN Mask Size') ? 'CBRN Mask Size' : '';
    nbcSuitSize =
        columnHeaders.contains('CBRN Suit Size') ? 'CBRN Suit Size' : '';
    hatSize = columnHeaders.contains('Hat Size') ? 'Hat Size' : '';
    bootSize = columnHeaders.contains('Boot Size') ? 'Boot Size' : '';
    acuTopSize = columnHeaders.contains('OCP Top Size') ? 'OCP Top Size' : '';
    acuTrouserSize =
        columnHeaders.contains('OCP Trouser Size') ? 'OCP Trouser Size' : '';
    setState(() {});
  }

  void _saveSoldiers(BuildContext context) {
    if (rows.length > 1) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final soldiers =
          Provider.of<SoldiersProvider>(context, listen: false).soldiers;

      List<String> soldierIds = soldiers.map((e) => e.id).toList();

      List<String> civEds = [
        '',
        'GED',
        '30 Semester Hours',
        '60 Semester Hours',
        '90 Semester Hours',
        'HS Diploma',
        'Associates',
        'Bachelors',
        'Masters',
        'Doctorate'
      ];

      List<String> milEds = [
        '',
        'None',
        'DLC1',
        'BLC',
        'DLC2',
        'ALC',
        'DLC3',
        'SLC',
        'DLC4',
        'MLC',
        'DLC5',
        'SMA'
      ];

      for (int i = 1; i < rows.length; i++) {
        String saveSoldierId;
        String currentSoldierId =
            getCellValue(rows[1], columnHeaders, soldierId);
        String owner = widget.userId;
        List<dynamic> users = [widget.userId];
        if (soldierIds.contains(currentSoldierId)) {
          var soldier =
              soldiers.firstWhere((element) => element.id == currentSoldierId);
          saveSoldierId = currentSoldierId;
          owner = soldier.owner;
          users = soldier.users;
        }

        String saveRank = getCellValue(rows[i], columnHeaders, rank);
        String saveLastName = getCellValue(rows[i], columnHeaders, lastName);
        String saveFirstName = getCellValue(rows[i], columnHeaders, firstName);
        String saveMi = getCellValue(rows[i], columnHeaders, mi);
        String saveAssigned = getCellValue(rows[i], columnHeaders, assigned);
        String saveSection = getCellValue(rows[i], columnHeaders, section);
        String saveDodId = getCellValue(rows[i], columnHeaders, dodId);
        String saveDor = getCellValue(rows[i], columnHeaders, dor);
        String saveMos = getCellValue(rows[i], columnHeaders, mos);
        String saveDuty = getCellValue(rows[i], columnHeaders, duty);
        String saveParaLn = getCellValue(rows[i], columnHeaders, paraLn);
        String saveReqMos = getCellValue(rows[i], columnHeaders, reqMos);
        String saveLoss = getCellValue(rows[i], columnHeaders, loss);
        String saveEts = getCellValue(rows[i], columnHeaders, ets);
        String saveBasd = getCellValue(rows[i], columnHeaders, basd);
        String savePebd = getCellValue(rows[i], columnHeaders, pebd);
        String saveGain = getCellValue(rows[i], columnHeaders, gain);
        String saveAddress = getCellValue(rows[i], columnHeaders, address);
        String saveCity = getCellValue(rows[i], columnHeaders, city);
        String saveState = getCellValue(rows[i], columnHeaders, state);
        String saveZip = getCellValue(rows[i], columnHeaders, zip);
        String savePhone = getCellValue(rows[i], columnHeaders, phone);
        String saveWorkPhone = getCellValue(rows[i], columnHeaders, workPhone);
        String saveEmail = getCellValue(rows[i], columnHeaders, email);
        String saveWorkEmail = getCellValue(rows[i], columnHeaders, workEmail);
        String saveNok = getCellValue(rows[i], columnHeaders, nok);
        String saveNokPhone = getCellValue(rows[i], columnHeaders, nokPhone);
        String saveMaritalStatus =
            getCellValue(rows[i], columnHeaders, maritalStatus);
        String saveComments = getCellValue(rows[i], columnHeaders, comments);
        String saveCivEd = getCellValue(rows[i], columnHeaders, civEd);
        if (!civEds.contains(saveCivEd)) {
          saveCivEd = '';
        }
        String saveMilEd = getCellValue(rows[i], columnHeaders, milEd);
        String saveNbcSuit = getCellValue(rows[i], columnHeaders, nbcSuitSize);
        String saveNbcMask = getCellValue(rows[i], columnHeaders, nbcMaskSize);
        String saveNbcBoot = getCellValue(rows[i], columnHeaders, nbcBootSize);
        String saveNbcGlove =
            getCellValue(rows[i], columnHeaders, nbcGloveSize);
        String saveHat = getCellValue(rows[i], columnHeaders, hatSize);
        String saveBoot = getCellValue(rows[i], columnHeaders, bootSize);
        String saveAcuTop = getCellValue(rows[i], columnHeaders, acuTopSize);
        String saveAcuTrouser =
            getCellValue(rows[i], columnHeaders, acuTrouserSize);

        if (saveMilEd.length == 4 &&
            saveMilEd.substring(0, 3).toLowerCase() == 'ssd') {
          saveMilEd = 'DLC${saveMilEd.substring(3)}';
        }
        if (!milEds.contains(saveMilEd)) {
          saveMilEd = '';
        }

        Soldier soldier = Soldier(
          id: saveSoldierId,
          owner: owner,
          users: users,
          rank: saveRank,
          rankSort: getRankSort(saveRank),
          lastName: saveLastName,
          firstName: saveFirstName,
          mi: saveMi,
          assigned: saveAssigned.toLowerCase() == 'true' ||
              saveAssigned.toLowerCase() == 'yes',
          section: saveSection,
          dodId: saveDodId,
          dor: saveDor,
          mos: saveMos,
          duty: saveDuty,
          paraLn: saveParaLn,
          reqMos: saveReqMos,
          lossDate: saveLoss,
          ets: saveEts,
          basd: saveBasd,
          pebd: savePebd,
          gainDate: saveGain,
          civEd: saveCivEd,
          milEd: saveMilEd,
          nbcSuitSize: saveNbcSuit,
          nbcMaskSize: saveNbcMask,
          nbcBootSize: saveNbcBoot,
          nbcGloveSize: saveNbcGlove,
          hatSize: saveHat,
          bootSize: saveBoot,
          acuTopSize: saveAcuTop,
          acuTrouserSize: saveAcuTrouser,
          address: saveAddress,
          city: saveCity,
          state: saveState,
          zip: saveZip,
          phone: savePhone,
          workPhone: saveWorkPhone,
          email: saveEmail,
          workEmail: saveWorkEmail,
          nok: saveNok,
          nokPhone: saveNokPhone,
          maritalStatus: saveMaritalStatus,
          comments: saveComments,
        );

        if (saveSoldierId != null) {
          firestore
              .collection('soldiers')
              .doc(saveSoldierId)
              .set(soldier.toMap(), SetOptions(merge: true));
        } else {
          firestore.collection('soldiers').add(soldier.toMap());
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
    rank = '';
    lastName = '';
    firstName = '';
    mi = '';
    assigned = '';
    section = '';
    dodId = '';
    dor = '';
    mos = '';
    duty = '';
    paraLn = '';
    reqMos = '';
    loss = '';
    ets = '';
    basd = '';
    pebd = '';
    gain = '';
    address = '';
    city = '';
    state = '';
    zip = '';
    phone = '';
    workPhone = '';
    email = '';
    workEmail = '';
    nok = '';
    nokPhone = '';
    maritalStatus = '';
    comments = '';
    civEd = '';
    milEd = '';
    nbcBootSize = '';
    nbcGloveSize = '';
    nbcMaskSize = '';
    nbcSuitSize = '';
    hatSize = '';
    bootSize = '';
    acuTopSize = '';
    acuTrouserSize = '';
    columnHeaders = [];
    columnHeaders.add('');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Soldier'),
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
                      'After picking .xlsx file, select the appropriate column header for each field. Leave selection blank to skip a field. Supervisor will '
                      'have to be added manually once each record is created.',
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
                              const InputDecoration(labelText: 'Soldier Id'),
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
                          decoration: const InputDecoration(labelText: 'Rank'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: rank,
                          onChanged: (value) {
                            setState(() {
                              rank = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Last Name'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: lastName,
                          onChanged: (value) {
                            setState(() {
                              lastName = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'First Name'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: firstName,
                          onChanged: (value) {
                            setState(() {
                              firstName = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Middle Initial'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mi,
                          onChanged: (value) {
                            setState(() {
                              mi = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Assigned'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: assigned,
                          onChanged: (value) {
                            setState(() {
                              assigned = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Section'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: section,
                          onChanged: (value) {
                            setState(() {
                              section = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'DoD ID'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: dodId,
                          onChanged: (value) {
                            setState(() {
                              dodId = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Date of Rank'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: dor,
                          onChanged: (value) {
                            setState(() {
                              dor = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'MOS'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mos,
                          onChanged: (value) {
                            setState(() {
                              mos = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Duty Position'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: duty,
                          onChanged: (value) {
                            setState(() {
                              duty = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Paragraph/Line No'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: paraLn,
                          onChanged: (value) {
                            setState(() {
                              paraLn = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Required MOS'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: reqMos,
                          onChanged: (value) {
                            setState(() {
                              reqMos = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Loss Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: loss,
                          onChanged: (value) {
                            setState(() {
                              loss = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'ETS Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: ets,
                          onChanged: (value) {
                            setState(() {
                              ets = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'BASD'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: basd,
                          onChanged: (value) {
                            setState(() {
                              basd = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'PEBD'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: pebd,
                          onChanged: (value) {
                            setState(() {
                              pebd = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Gain Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: gain,
                          onChanged: (value) {
                            setState(() {
                              gain = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Civilian Education'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: civEd,
                          onChanged: (value) {
                            setState(() {
                              civEd = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Military Education'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: milEd,
                          onChanged: (value) {
                            setState(() {
                              milEd = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'CBRN Suit Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: nbcSuitSize,
                          onChanged: (value) {
                            setState(() {
                              nbcSuitSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'CBRN Mask Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: nbcMaskSize,
                          onChanged: (value) {
                            setState(() {
                              nbcMaskSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'CBRN Boot Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: nbcBootSize,
                          onChanged: (value) {
                            setState(() {
                              nbcBootSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'CBRN Glove Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: nbcGloveSize,
                          onChanged: (value) {
                            setState(() {
                              nbcGloveSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Hat Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: hatSize,
                          onChanged: (value) {
                            setState(() {
                              hatSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Boot Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: bootSize,
                          onChanged: (value) {
                            setState(() {
                              bootSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'OCP Top Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: acuTopSize,
                          onChanged: (value) {
                            setState(() {
                              acuTopSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'OCP Trouser Size'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: acuTrouserSize,
                          onChanged: (value) {
                            setState(() {
                              acuTrouserSize = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Address'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: address,
                          onChanged: (value) {
                            setState(() {
                              address = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'City'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: city,
                          onChanged: (value) {
                            setState(() {
                              city = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'State'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: state,
                          onChanged: (value) {
                            setState(() {
                              state = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Zip Code'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: zip,
                          onChanged: (value) {
                            setState(() {
                              zip = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: phone,
                          onChanged: (value) {
                            setState(() {
                              phone = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Work Phone'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: workPhone,
                          onChanged: (value) {
                            setState(() {
                              workPhone = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: email,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Work Email'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: workEmail,
                          onChanged: (value) {
                            setState(() {
                              workEmail = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Next of Kin'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: nok,
                          onChanged: (value) {
                            setState(() {
                              nok = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'NOK Phone'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: nokPhone,
                          onChanged: (value) {
                            setState(() {
                              nokPhone = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Marital Status'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: maritalStatus,
                          onChanged: (value) {
                            setState(() {
                              maritalStatus = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Comments'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
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
                  FormattedElevatedButton(
                    onPressed: path == '' ? null : () => _saveSoldiers(context),
                    text: 'Upload Roster',
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
