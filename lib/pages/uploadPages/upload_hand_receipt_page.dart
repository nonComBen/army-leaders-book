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
import '../../models/hand_receipt_item.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';

class UploadHandReceiptPage extends ConsumerStatefulWidget {
  const UploadHandReceiptPage({
    Key? key,
  }) : super(key: key);

  @override
  UploadHandReceiptPageState createState() => UploadHandReceiptPageState();
}

class UploadHandReceiptPageState extends ConsumerState<UploadHandReceiptPage> {
  late List<String> columnHeaders;
  late List<List<Data?>> rows;
  String? soldierId,
      item,
      model,
      serial,
      nsn,
      location,
      value,
      subComponents,
      comments,
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
      item = columnHeaders.contains('Item') ? 'Item' : '';
      model = columnHeaders.contains('Model #') ? 'Model #' : '';
      serial = columnHeaders.contains('Serial #') ? 'Serial #' : '';
      nsn = columnHeaders.contains('NSN #') ? 'NSN #' : '';
      location = columnHeaders.contains('Location') ? 'Location' : '';
      value = columnHeaders.contains('Value') ? 'Value' : '';
      subComponents =
          columnHeaders.contains('Subcomponents') ? 'Subcomponents' : '';
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

          String saveItem = getCellValue(rows[i], columnHeaders, item);
          String saveModel = getCellValue(rows[i], columnHeaders, model);
          String saveSerial = getCellValue(rows[i], columnHeaders, serial);
          String saveNsn = getCellValue(rows[i], columnHeaders, nsn);
          String saveLocation = getCellValue(rows[i], columnHeaders, location);
          String saveValue = getCellValue(rows[i], columnHeaders, value);
          String saveComments = getCellValue(rows[i], columnHeaders, comments);
          String subComponentsString =
              getCellValue(rows[i], columnHeaders, subComponents);

          List<String> subList = subComponentsString.split(';');
          List<Map<String, dynamic>> saveSubList = [];

          for (String items in subList) {
            if (items.length > 1) {
              List<String> itemList = items.split(',');
              Map<String, dynamic> map = {
                'item': '',
                'nsn': '',
                'onHand': '',
                'required': '',
              };
              if (itemList.isNotEmpty) {
                map['item'] = itemList[0].toString().trim();
              }
              if (itemList.length > 1) {
                map['nsn'] = itemList[1].toString().trim();
              }
              if (itemList.length > 2) {
                map['onHand'] = itemList[2].toString().trim();
              }
              if (itemList.length > 3) {
                map['required'] = itemList[3].toString().trim();
              }
              saveSubList.add(map);
            }
          }

          HandReceiptItem handReceipt = HandReceiptItem(
            soldierId: saveSoldierId,
            owner: owner,
            users: users,
            rank: rank,
            name: name,
            firstName: firstName,
            section: section,
            rankSort: rankSort,
            item: saveItem,
            model: saveModel,
            serial: saveSerial,
            nsn: saveNsn,
            location: saveLocation,
            value: saveValue,
            subComponents: saveSubList,
            comments: saveComments,
          );

          firestore.collection('handReceipt').add(handReceipt.toMap());
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
    item = '';
    model = '';
    serial = '';
    nsn = '';
    location = '';
    value = '';
    subComponents = '';
    comments = '';
    columnHeaders = [];
    columnHeaders.add('');
    rows = [];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Upload Hand Receipt',
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
                  label: const Text('Item'),
                  items: columnHeaders,
                  value: item,
                  onChanged: (value) {
                    setState(() {
                      item = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Model No.'),
                  items: columnHeaders,
                  value: model,
                  onChanged: (value) {
                    setState(() {
                      model = value;
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
                  label: const Text('NSN No.'),
                  items: columnHeaders,
                  value: nsn,
                  onChanged: (value) {
                    setState(() {
                      nsn = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Locataion'),
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
                  label: const Text('Value'),
                  items: columnHeaders,
                  value: value,
                  onChanged: (value) {
                    setState(() {
                      value = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Subcomponents'),
                  items: columnHeaders,
                  value: subComponents,
                  onChanged: (value) {
                    setState(() {
                      subComponents = value;
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
            child: const Text('Upload Hand Receipt'),
          )
        ],
      ),
    );
  }
}
