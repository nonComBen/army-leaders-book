// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../methods/upload_methods.dart';
import '../../models/medpro.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/formatted_elevated_button.dart';

class UploadMedProsPage extends StatefulWidget {
  const UploadMedProsPage({
    Key key,
    this.userId,
    this.isSubscribed,
  }) : super(key: key);
  final String userId;
  final bool isSubscribed;

  @override
  UploadMedProsPageState createState() => UploadMedProsPageState();
}

class UploadMedProsPageState extends State<UploadMedProsPage> {
  List<String> columnHeaders;
  List<List<Data>> rows;
  String soldierId,
      pha,
      dental,
      vision,
      hearing,
      hiv,
      flu,
      mmr,
      varicella,
      polio,
      tuber,
      tetanus,
      hepA,
      hepB,
      enc,
      mening,
      typhoid,
      yellow,
      smallPox,
      anthrax,
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
      columnHeaders = [''];
      for (var cell in rows.first) {
        if (cell.value != '') {
          columnHeaders.add(cell.value);
        }
      }
      soldierId = columnHeaders.contains('Soldier Id') ? 'Soldier Id' : '';
      pha = columnHeaders.contains('PHA Date') ? 'PHA Date' : '';
      dental = columnHeaders.contains('Dental Date') ? 'Dental Date' : '';
      vision = columnHeaders.contains('Vision Date') ? 'Vision Date' : '';
      hearing = columnHeaders.contains('Hearing Date') ? 'Hearing Date' : '';
      hiv = columnHeaders.contains('HIV Date') ? 'HIV Date' : '';
      flu = columnHeaders.contains('Flu Date') ? 'Flu Date' : '';
      mmr = columnHeaders.contains('MMR Date') ? 'MMR Date' : '';
      varicella =
          columnHeaders.contains('Varicella Date') ? 'Varicella Date' : '';
      polio = columnHeaders.contains('Polio Date') ? 'Polio Date' : '';
      tuber = columnHeaders.contains('Tuberculosis Date')
          ? 'Tuberculosis Date'
          : '';
      tetanus = columnHeaders.contains('Tetanus Date') ? 'Tetanus Date' : '';
      hepA =
          columnHeaders.contains('Hepatitis A Date') ? 'Hepatitis A Date' : '';
      hepB =
          columnHeaders.contains('Hepatitis B Date') ? 'Hepatitis B Date' : '';
      enc = columnHeaders.contains('Encephalitis Date')
          ? 'Encephalitis Date'
          : '';
      mening = columnHeaders.contains('Meningococcal Date')
          ? 'Meningococcal Date'
          : '';
      typhoid = columnHeaders.contains('Typhoid Date') ? 'Typhoid Date' : '';
      yellow = columnHeaders.contains('Yellow Fever Date')
          ? 'Yellow Fever Date'
          : '';
      smallPox =
          columnHeaders.contains('Small Pox Date') ? 'Small Pox Date' : '';
      anthrax = columnHeaders.contains('Anthrax Date') ? 'Anthrax Date' : '';
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

          String savePha =
              convertDate(getCellValue(rows[i], columnHeaders, pha));
          String saveDental =
              convertDate(getCellValue(rows[i], columnHeaders, dental));
          String saveVision =
              convertDate(getCellValue(rows[i], columnHeaders, vision));
          String saveHearing =
              convertDate(getCellValue(rows[i], columnHeaders, hearing));
          String saveHiv =
              convertDate(getCellValue(rows[i], columnHeaders, hiv));
          String saveFlu =
              convertDate(getCellValue(rows[i], columnHeaders, flu));
          String saveMmr =
              convertDate(getCellValue(rows[i], columnHeaders, mmr));
          String saveVaricella =
              convertDate(getCellValue(rows[i], columnHeaders, varicella));
          String savePolio =
              convertDate(getCellValue(rows[i], columnHeaders, polio));
          String saveTuber =
              convertDate(getCellValue(rows[i], columnHeaders, tuber));
          String saveTetanus =
              convertDate(getCellValue(rows[i], columnHeaders, tetanus));
          String saveHepA =
              convertDate(getCellValue(rows[i], columnHeaders, hepA));
          String saveHepB =
              convertDate(getCellValue(rows[i], columnHeaders, hepB));
          String saveEnc =
              convertDate(getCellValue(rows[i], columnHeaders, enc));
          String saveMening =
              convertDate(getCellValue(rows[i], columnHeaders, mening));
          String saveTyphoid =
              convertDate(getCellValue(rows[i], columnHeaders, typhoid));
          String saveYellow =
              convertDate(getCellValue(rows[i], columnHeaders, yellow));
          String saveSmallPox =
              convertDate(getCellValue(rows[i], columnHeaders, smallPox));
          String saveAnthrax =
              convertDate(getCellValue(rows[i], columnHeaders, anthrax));

          Medpro medpro = Medpro(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            pha: savePha,
            dental: saveDental,
            vision: saveVision,
            hearing: saveHearing,
            hiv: saveHiv,
            flu: saveFlu,
            anthrax: saveAnthrax,
            encephalitis: saveEnc,
            hepA: saveHepA,
            hepB: saveHepB,
            meningococcal: saveMening,
            mmr: saveMmr,
            polio: savePolio,
            smallPox: saveSmallPox,
            tetanus: saveTetanus,
            tuberculin: saveTuber,
            typhoid: saveTyphoid,
            varicella: saveVaricella,
            yellow: saveYellow,
            otherImms: [],
          );

          firestore.collection('medpros').add(medpro.toMap());
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
    pha = '';
    dental = '';
    vision = '';
    hearing = '';
    hiv = '';
    flu = '';
    mmr = '';
    varicella = '';
    polio = '';
    tuber = '';
    tetanus = '';
    hepA = '';
    hepB = '';
    enc = '';
    mening = '';
    typhoid = '';
    yellow = '';
    smallPox = '';
    anthrax = '';
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
        title: const Text('Upload MedPros'),
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
                              const InputDecoration(labelText: 'PHA Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: pha,
                          onChanged: (value) {
                            setState(() {
                              pha = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Dental Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: dental,
                          onChanged: (value) {
                            setState(() {
                              dental = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Vision Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: vision,
                          onChanged: (value) {
                            setState(() {
                              vision = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Hearing Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: hearing,
                          onChanged: (value) {
                            setState(() {
                              hearing = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'HIV Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: hiv,
                          onChanged: (value) {
                            setState(() {
                              hiv = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Influenza Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: flu,
                          onChanged: (value) {
                            setState(() {
                              flu = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'MMR Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mmr,
                          onChanged: (value) {
                            setState(() {
                              mmr = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Varicella Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: varicella,
                          onChanged: (value) {
                            setState(() {
                              varicella = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Polio Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: polio,
                          onChanged: (value) {
                            setState(() {
                              polio = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Tuberculin Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: tuber,
                          onChanged: (value) {
                            setState(() {
                              tuber = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Tetanus Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: tetanus,
                          onChanged: (value) {
                            setState(() {
                              tetanus = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Hepatitis A Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: hepA,
                          onChanged: (value) {
                            setState(() {
                              hepA = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Hepititis B Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: hepB,
                          onChanged: (value) {
                            setState(() {
                              hepB = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Encephalitis Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: enc,
                          onChanged: (value) {
                            setState(() {
                              enc = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Meningococcal Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: mening,
                          onChanged: (value) {
                            setState(() {
                              mening = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Typhoid Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: typhoid,
                          onChanged: (value) {
                            setState(() {
                              typhoid = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Yellow Fever Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: yellow,
                          onChanged: (value) {
                            setState(() {
                              yellow = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Small Pox Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: smallPox,
                          onChanged: (value) {
                            setState(() {
                              smallPox = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Anthrax Date'),
                          items: columnHeaders.map((header) {
                            return DropdownMenuItem<String>(
                              value: header,
                              child: Text(header),
                            );
                          }).toList(),
                          value: anthrax,
                          onChanged: (value) {
                            setState(() {
                              anthrax = value;
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
                    text: 'Upload MedPros',
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
