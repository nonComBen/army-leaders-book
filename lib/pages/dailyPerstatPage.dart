// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../methods/date_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../../models/perstat.dart';
import '../models/perstat_by_name.dart';
import '../models/soldier.dart';
import '../providers/soldiers_provider.dart';
import '../widgets/formatted_text_button.dart';

class DailyPerstatPage extends StatefulWidget {
  const DailyPerstatPage({Key key, @required this.userId}) : super(key: key);
  final String userId;

  static const routeName = '/daily-perstat-page';

  @override
  DailyPerstatPageState createState() => DailyPerstatPageState();
}

class DailyPerstatPageState extends State<DailyPerstatPage> {
  List<DocumentSnapshot> perstats;
  List<Soldier> soldiers;
  List<dynamic> dailies, filteredDailies;
  List<String> sections = [];
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  FirebaseFirestore firestore;
  bool expanded = true;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey _globalKey = GlobalKey();

  List<String> types = [
    'PDY',
    'Leave',
    'Pass',
    'TDY',
    'Duty',
    'Comp Day',
    'SUTA',
    'ADOS',
    'FTR',
    'Other',
  ];

  void _downloadPng() async {
    bool approved = await checkPermission(context, Permission.storage);
    if (!approved || !mounted) return;
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      var pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

      String location;
      if (kIsWeb) {
        WebDownload webDownload = WebDownload(
            type: 'png',
            fileName: 'perstat.png',
            data: pngBytes.buffer.asUint8List());
        webDownload.download();
      } else {
        List<String> strings = await getPath();
        location = strings[1];
        String path = strings[0];

        File file = File('$path/PERSTAT.png');
        file.writeAsBytesSync(pngBytes.buffer.asUint8List());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PERSTAT By Name Downloaded to $location'),
            duration: const Duration(seconds: 5),
            action: Platform.isAndroid
                ? SnackBarAction(
                    label: 'Open',
                    onPressed: () {
                      OpenFile.open('$path/PERSTAT.png');
                    },
                  )
                : null,
          ));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

  void _downloadExcel() async {
    bool approved = await checkPermission(context, Permission.storage);
    if (!approved) return;
    List<List<dynamic>> docsList = [];
    docsList.add([dateFormat.format(DateTime.now())]);
    docsList.add([
      'Soldier',
      'Assigned',
      'Status',
      'Start Date',
      'End Date',
    ]);
    for (Map<dynamic, dynamic> daily in dailies) {
      List<String> doc = [
        daily['soldier'],
        daily['assigned'].toString(),
        daily['type'],
        daily['start'],
        daily['end']
      ];
      docsList.add(doc);
    }

    var excel = Excel.createExcel();
    var sheet = excel.sheets[excel.getDefaultSheet()];
    for (var docs in docsList) {
      sheet.appendRow(docs);
    }

    String dir, location;
    if (kIsWeb) {
      WebDownload webDownload = WebDownload(
          type: 'xlsx', fileName: 'perstat.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/PERSTAT (${dateFormat.format(DateTime.now())}).xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Data successfully downloaded to $location'),
            duration: const Duration(seconds: 5),
            action: Platform.isAndroid
                ? SnackBarAction(
                    label: 'Open',
                    onPressed: () {
                      OpenFile.open(
                          '$dir/PERSTAT (${dateFormat.format(DateTime.now())}).xlsx');
                    },
                  )
                : null,
          ));
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error: $e');
      }
    }
  }

  Widget statusHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              }),
        ],
      ),
    );
  }

  Widget soldierCard(Map<dynamic, dynamic> soldier, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(soldier['soldier']),
          subtitle:
              soldier['end'] == '' ? null : Text('Returns: ${soldier['end']}'),
          trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                editRecord(index, soldier);
              }),
        ),
      ),
    );
  }

  editRecord(int index, Map<dynamic, dynamic> soldier) {
    int dailyIndex = dailies.indexOf(soldier);
    int filteredIndex = filteredDailies.indexOf(soldier);
    String type = soldier['type'];
    String otherType = '';
    if (!types.contains(type)) {
      otherType = type;
      type = 'Other';
    }
    Widget title = const Text('Edit Status');
    if (kIsWeb || Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (BuildContext context2) {
            return StatefulBuilder(
              builder: (context, refresh) {
                return AlertDialog(
                  title: title,
                  content: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        DropdownButtonFormField(
                            items: types.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            value: type,
                            decoration:
                                const InputDecoration(labelText: 'Status'),
                            onChanged: (value) {
                              refresh(() {
                                type = value;
                                soldier['type'] = value;
                                if (value == 'PDY') {
                                  soldier['typeSort'] = '0';
                                } else if (value == 'Leave') {
                                  soldier['typeSort'] = '1';
                                } else if (value == 'TDY') {
                                  soldier['typeSort'] = '2';
                                } else if (value == 'FTR') {
                                  soldier['typeSort'] = '4';
                                } else {
                                  soldier['typeSort'] = '3';
                                }
                              });
                            }),
                        type == 'Other'
                            ? TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Other Status'),
                                initialValue: otherType,
                                onChanged: (value) {
                                  refresh(() {
                                    otherType = value;
                                    soldier['type'] = value;
                                    soldier['typeSort'] = '3';
                                  });
                                },
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FormattedTextButton(
                      label: 'Cancel',
                      onPressed: () {
                        Navigator.pop(context2);
                      },
                    ),
                    FormattedTextButton(
                      label: 'Ok',
                      onPressed: () {
                        setState(() {
                          soldier['end'] = '';
                          filteredDailies[filteredIndex] = soldier;
                          dailies[dailyIndex] = soldier;
                          //sortDailies();
                        });
                        Navigator.pop(context2);
                      },
                    )
                  ],
                );
              },
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context2) => StatefulBuilder(
                builder: (context, refresh) => CupertinoAlertDialog(
                  title: title,
                  content: SingleChildScrollView(
                    child: Material(
                      color: Theme.of(context).dialogBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            DropdownButtonFormField(
                                items: types.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                value: type,
                                decoration:
                                    const InputDecoration(labelText: 'Status'),
                                onChanged: (value) {
                                  refresh(() {
                                    type = value;
                                    soldier['type'] = type;
                                    if (type == 'PDY') {
                                      soldier['typeSort'] = '0';
                                    } else if (type == 'Leave') {
                                      soldier['typeSort'] = '1';
                                    } else if (type == 'TDY') {
                                      soldier['typeSort'] = '2';
                                    } else if (type == 'FTR') {
                                      soldier['typeSort'] = '4';
                                    } else {
                                      soldier['typeSort'] = '3';
                                    }
                                  });
                                }),
                            type == 'Other'
                                ? TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Other Status'),
                                    initialValue: otherType,
                                    onChanged: (value) {
                                      refresh(() {
                                        otherType = value;
                                        soldier['type'] = value;
                                        soldier['typeSort'] = '3';
                                      });
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context2);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('Ok'),
                      onPressed: () {
                        setState(() {
                          soldier['end'] = '';
                          filteredDailies[filteredIndex] = soldier;
                          dailies[dailyIndex] = soldier;
                          //sortDailies();
                        });
                        Navigator.pop(context2);
                      },
                    )
                  ],
                ),
              ));
    }
  }

  void _filterRecords(String section) {
    if (section == 'All') {
      filteredDailies = List.from(dailies);
    } else {
      filteredDailies =
          dailies.where((element) => element['section'] == section).toList();
    }
    setState(() {});
  }

  List<Widget> dailyStatuses() {
    List<Widget> statuses = [
      statusHeader(
          'ASSGN (${filteredDailies.where((e) => e['assigned'] == 'true').length}); ATTCH (${filteredDailies.where((e) => e['assigned'] != 'true').length})')
    ];

    sortDailies();

    for (int i = 0; i < filteredDailies.length; i++) {
      if (i == 0) {
        statuses.add(statusHeader(filteredDailies[i]['type'] +
            ' (${filteredDailies.where((daily) => daily['type'] == filteredDailies[i]['type']).toList().length})'));
        if (expanded) {
          statuses.add(soldierCard(filteredDailies[i], i));
        }
      } else if (filteredDailies[i]['type'] != filteredDailies[i - 1]['type']) {
        statuses.add(statusHeader(filteredDailies[i]['type'] +
            ' (${filteredDailies.where((daily) => daily['type'] == filteredDailies[i]['type']).toList().length})'));
        if (expanded) {
          statuses.add(soldierCard(filteredDailies[i], i));
        }
        if (!types.contains(filteredDailies[i]['type'])) {
          types.insertAll(types.length - 2, [filteredDailies[i]['type']]);
        }
      } else {
        if (expanded) {
          statuses.add(soldierCard(filteredDailies[i], i));
        }
      }
    }

    return statuses;
  }

  sortDailies() {
    filteredDailies.sort((a, b) {
      int c = a['typeSort'].compareTo(b['typeSort']);
      if (c == 0) {
        c = a['type'].compareTo(b['type']);
      }
      if (c == 0) {
        c = b['rankSort'].compareTo(a['rankSort']);
      }
      return c;
    });
  }

  Future<bool> onWillPop() {
    PerstatByName byName = PerstatByName(
      owner: widget.userId,
      date: dateFormat.format(DateTime.now()),
      dailies: dailies,
    );
    firestore
        .collection('perstatByName')
        .doc(widget.userId)
        .set(byName.toMap());
    return Future.value(true);
  }

  buildNewDailies() async {
    // QuerySnapshot soldierSnapshot = await firestore
    //     .collection('soldiers')
    //     .where('users', isNotEqualTo: null)
    //     .where('users', arrayContains: widget.userId)
    //     .get();
    soldiers = Provider.of<SoldiersProvider>(context, listen: false).soldiers;
    QuerySnapshot perstatSnapshot = await firestore
        .collection('perstat')
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: widget.userId)
        .get();
    perstats = perstatSnapshot.docs
        .where((doc) => isOverdue(doc['start'], 0) && !isOverdue(doc['end'], 1))
        .toList();
    List<String> soldierIds = [];

    setState(() {
      for (DocumentSnapshot perstat in perstats) {
        bool assigned = true;
        try {
          final soldier =
              soldiers.firstWhere((e) => e.id == perstat['soldierId']);
          assigned = soldier.assigned ?? true;
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
        soldierIds.add(perstat['soldierId']);
        var map = <String, String>{};
        map['soldierId'] = perstat['soldierId'];
        map['soldier'] =
            '${perstat['rank']} ${perstat['name']}, ${perstat['firstName']}';
        map['assigned'] = assigned.toString().toLowerCase();
        map['type'] = perstat['type'];
        map['typeSort'] = perstat['type'] == 'Leave'
            ? '1'
            : perstat['type'] == 'TDY'
                ? '2'
                : perstat['type'] == 'FTR'
                    ? '4'
                    : '3';
        map['start'] = perstat['start'];
        map['end'] = perstat['end'];
        map['rankSort'] = perstat['rankSort'];
        map['section'] = perstat['section'];
        dailies.add(map);
      }

      for (Soldier soldier in soldiers) {
        bool assigned = true;
        try {
          assigned = soldier.assigned;
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
        if (!soldierIds.contains(soldier.id)) {
          var map = <String, String>{};
          map['soldierId'] = soldier.id;
          map['soldier'] =
              '${soldier.rank} ${soldier.lastName}, ${soldier.firstName}';
          map['assigned'] = assigned.toString().toLowerCase();
          map['type'] = 'PDY';
          map['typeSort'] = '0';
          map['start'] = dateFormat.format(DateTime.now());
          map['end'] = '';
          map['rankSort'] = soldier.rankSort.toString();
          map['section'] = soldier.section;
          dailies.add(map);
        }
      }
      filteredDailies = List.from(dailies);
      sortDailies();
    });
  }

  void submit(BuildContext context) async {
    onWillPop();
    soldiers ??= Provider.of<SoldiersProvider>(context, listen: false).soldiers;
    if (perstats == null) {
      QuerySnapshot perstatSnapshot = await firestore
          .collection('perstat')
          .where('users', isNotEqualTo: null)
          .where('users', arrayContains: widget.userId)
          .get();
      perstats = perstatSnapshot.docs
          .where(
              (doc) => isOverdue(doc['start'], 0) && !isOverdue(doc['end'], 1))
          .toList();
    }
    var perstatSoldiers =
        perstats.map((e) => e['soldierId'].toString()).toList();
    for (Map<String, dynamic> daily in dailies) {
      if (daily['type'] == 'PDY') {
        String yesterday =
            dateFormat.format(DateTime.now().add(const Duration(days: -1)));
        if (perstatSoldiers.contains(daily['soldierId'])) {
          var perstatsToDelete = perstats
              .where((element) => element['soldierId'] == daily['soldierId'])
              .toList();
          for (var perstat in perstatsToDelete) {
            if (perstat['start'] != dateFormat.format(DateTime.now())) {
              perstat.reference.update({'end': yesterday});
            } else {
              perstat.reference.delete();
            }
          }
        }
      } else {
        if (!perstatSoldiers.contains(daily['soldierId'])) {
          var soldier = soldiers
              .firstWhere((element) => element.id == daily['soldierId']);
          var perstat = Perstat(
            soldierId: soldier.id,
            owner: soldier.owner,
            users: soldier.users,
            rank: soldier.rank,
            name: soldier.lastName,
            firstName: soldier.firstName,
            section: soldier.section,
            rankSort: soldier.rankSort.toString(),
            start: dateFormat.format(DateTime.now()),
            type: daily['type'],
          );
          firestore.collection('perstat').add(perstat.toMap());
        }
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    dailies = [];
    filteredDailies = [];
    firestore = FirebaseFirestore.instance;
    initialize();
  }

  initialize() async {
    DocumentSnapshot snapshot;
    PerstatByName byName;
    try {
      snapshot =
          await firestore.collection('perstatByName').doc(widget.userId).get();
      byName = PerstatByName.fromSnapshot(snapshot);
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
    if (byName == null || byName.dailies[0]['section'] == null) {
      buildNewDailies();
    } else {
      setState(() {
        dailies = byName.dailies.toList();
        filteredDailies = List.from(dailies);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    List<PopupMenuEntry<String>> sections = [
      const PopupMenuItem(
        value: 'All',
        child: Text('All'),
      )
    ];
    dailies.sort((a, b) => a['section'].compareTo(b['section']));
    for (int i = 0; i < dailies.length; i++) {
      if (i == 0) {
        sections.add(PopupMenuItem(
          value: dailies[i]['section'],
          child: Text(dailies[i]['section']),
        ));
      } else if (dailies[i]['section'] != dailies[i - 1]['section']) {
        sections.add(PopupMenuItem(
          value: dailies[i]['section'],
          child: Text(dailies[i]['section']),
        ));
      }
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('PERSTAT By Name'),
        actions: <Widget>[
          Tooltip(
            message: 'Refresh',
            child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  dailies.clear();
                  buildNewDailies();
                }),
          ),
          Tooltip(
              message: 'Filter Records',
              child: PopupMenuButton(
                icon: const Icon(Icons.filter_alt),
                onSelected: (String result) => _filterRecords(result),
                itemBuilder: (context) {
                  return sections;
                },
              )),
          Tooltip(
              message: kIsWeb ? 'Feature Not Available' : 'Download as Image',
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: kIsWeb
                    ? null
                    : () {
                        _downloadPng();
                      },
              )),
          Tooltip(
              message: 'Download as Excel',
              child: IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: _downloadExcel))
        ],
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: ListView(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width > 932 ? (width - 916) / 2 : 16),
                child: Card(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(16.0),
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: dailyStatuses()),
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  submit(context);
                },
                child: const Text('Update PERSTAT Section'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
