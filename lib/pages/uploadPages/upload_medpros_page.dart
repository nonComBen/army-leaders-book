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
import '../../models/medpro.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadMedProsPage extends ConsumerStatefulWidget {
  const UploadMedProsPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadMedProsPageState createState() => UploadMedProsPageState();
}

class UploadMedProsPageState extends ConsumerState<UploadMedProsPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
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

          firestore.collection(Medpro.collectionName).add(medpro.toMap());
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
    return PlatformScaffold(
      title: 'Upload MedPros',
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
                  label: const Text('PHA Date'),
                  items: columnHeaders,
                  value: pha,
                  onChanged: (value) {
                    setState(() {
                      pha = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Dental Date'),
                  items: columnHeaders,
                  value: dental,
                  onChanged: (value) {
                    setState(() {
                      dental = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Vision Date'),
                  items: columnHeaders,
                  value: vision,
                  onChanged: (value) {
                    setState(() {
                      vision = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Hearing Date'),
                  items: columnHeaders,
                  value: hearing,
                  onChanged: (value) {
                    setState(() {
                      hearing = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('HIV Date'),
                  items: columnHeaders,
                  value: hiv,
                  onChanged: (value) {
                    setState(() {
                      hiv = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Influenza Date'),
                  items: columnHeaders,
                  value: flu,
                  onChanged: (value) {
                    setState(() {
                      flu = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('MMR Date'),
                  items: columnHeaders,
                  value: mmr,
                  onChanged: (value) {
                    setState(() {
                      mmr = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Varicella Date'),
                  items: columnHeaders,
                  value: varicella,
                  onChanged: (value) {
                    setState(() {
                      varicella = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Polio Date'),
                  items: columnHeaders,
                  value: polio,
                  onChanged: (value) {
                    setState(() {
                      polio = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Tuberculin Date'),
                  items: columnHeaders,
                  value: tuber,
                  onChanged: (value) {
                    setState(() {
                      tuber = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Tetanus Date'),
                  items: columnHeaders,
                  value: tetanus,
                  onChanged: (value) {
                    setState(() {
                      tetanus = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Hepatitis A Date'),
                  items: columnHeaders,
                  value: hepA,
                  onChanged: (value) {
                    setState(() {
                      hepA = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Hepititis B Date'),
                  items: columnHeaders,
                  value: hepB,
                  onChanged: (value) {
                    setState(() {
                      hepB = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Encephalitis Date'),
                  items: columnHeaders,
                  value: enc,
                  onChanged: (value) {
                    setState(() {
                      enc = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Meningococcal Date'),
                  items: columnHeaders,
                  value: mening,
                  onChanged: (value) {
                    setState(() {
                      mening = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Typhoid Date'),
                  items: columnHeaders,
                  value: typhoid,
                  onChanged: (value) {
                    setState(() {
                      typhoid = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Yellow Fever Date'),
                  items: columnHeaders,
                  value: yellow,
                  onChanged: (value) {
                    setState(() {
                      yellow = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Small Pox Date'),
                  items: columnHeaders,
                  value: smallPox,
                  onChanged: (value) {
                    setState(() {
                      smallPox = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Anthrax Date'),
                  items: columnHeaders,
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
          PlatformButton(
            onPressed: () {
              if (path == '') {
                fileIsBlankMessage(context);
              }
              _saveData(context);
            },
            child: const Text('Upload MedPros'),
          )
        ],
      ),
    );
  }
}
