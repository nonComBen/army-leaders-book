import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/methods/create_app_bar_actions.dart';
import 'package:leaders_book/methods/filter_documents.dart';
import 'package:leaders_book/widgets/padded_text_field.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_item_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../methods/date_methods.dart';
import '../methods/download_methods.dart';
import '../methods/theme_methods.dart';
import '../methods/web_download.dart';
import '../../models/perstat.dart';
import '../models/app_bar_option.dart';
import '../models/perstat_by_name.dart';
import '../models/soldier.dart';
import '../providers/soldiers_provider.dart';
import '../widgets/formatted_text_button.dart';
import '../widgets/header_text.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_icon_button.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class DailyPerstatPage extends ConsumerStatefulWidget {
  const DailyPerstatPage({Key? key}) : super(key: key);

  static const routeName = '/daily-perstat-page';

  @override
  DailyPerstatPageState createState() => DailyPerstatPageState();
}

class DailyPerstatPageState extends ConsumerState<DailyPerstatPage> {
  List<DocumentSnapshot> perstats = [];
  List<Soldier> soldiers = [];
  List<dynamic> dailies = [], filteredDailies = [];
  List<String> sections = [];
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isExpanded = true, isInitial = true;
  String? _userId;

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
    bool approved = await checkPermission(Permission.storage);
    if (!approved || !mounted) return;
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      var pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

      String location;
      if (kIsWeb) {
        WebDownload webDownload = WebDownload(
            type: 'png',
            fileName: 'perstat.png',
            data: pngBytes!.buffer.asUint8List());
        webDownload.download();
      } else {
        List<String> strings = await getPath();
        location = strings[1];
        String path = strings[0];

        File file = File('$path/PERSTAT.png');
        file.writeAsBytesSync(pngBytes!.buffer.asUint8List());

        if (mounted) {
          FToast toast = FToast();
          toast.context = context;
          toast.showToast(
            child: MyToast(
              message: 'PERSTAT By Name Downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed:
                  kIsWeb ? null : () => OpenFile.open('$path/PERSTAT.png'),
            ),
          );
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

  void _downloadExcel() async {
    bool approved = await checkPermission(Permission.storage);
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
      List<String?> doc = [
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
      sheet!.appendRow(docs);
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
        var bytes = excel.encode()!;
        File('$dir/PERSTAT (${dateFormat.format(DateTime.now())}).xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          FToast toast = FToast();
          toast.context = context;
          toast.showToast(
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed: kIsWeb
                  ? null
                  : () => OpenFile.open(
                      '$dir/PERSTAT (${dateFormat.format(DateTime.now())}).xlsx'),
            ),
          );
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
          HeaderText(
            text,
            textAlign: TextAlign.start,
          ),
          PlatformIconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
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
        color: getContrastingBackgroundColor(context),
        child: ListTile(
          title: Text(soldier['soldier']),
          subtitle:
              soldier['end'] == '' ? null : Text('Returns: ${soldier['end']}'),
          trailing: PlatformIconButton(
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
    final controller = TextEditingController(text: '');
    if (!types.contains(type)) {
      controller.text = type;
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
                        PlatformItemPicker(
                            items: types,
                            value: type,
                            label: const Text('Status'),
                            onChanged: (dynamic value) {
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
                            ? PaddedTextField(
                                label: 'Other Status',
                                decoration: const InputDecoration(
                                    labelText: 'Other Status'),
                                controller: controller,
                                onChanged: (value) {
                                  refresh(() {
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    PlatformItemPicker(
                        items: types,
                        value: type,
                        label: const Text('Status'),
                        onChanged: (dynamic value) {
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
                        ? PaddedTextField(
                            label: 'Other Status',
                            decoration: const InputDecoration(
                                labelText: 'Other Status'),
                            controller: controller,
                            onChanged: (value) {
                              refresh(() {
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
                  });
                  Navigator.pop(context2);
                },
              )
            ],
          ),
        ),
      );
    }
  }

  void _filterRecords(List<String> sections) {
    filteredDailies = dailies
        .where((element) => sections.contains(element['section']))
        .toList();

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
        if (isExpanded) {
          statuses.add(soldierCard(filteredDailies[i], i));
        }
      } else if (filteredDailies[i]['type'] != filteredDailies[i - 1]['type']) {
        statuses.add(statusHeader(filteredDailies[i]['type'] +
            ' (${filteredDailies.where((daily) => daily['type'] == filteredDailies[i]['type']).toList().length})'));
        if (isExpanded) {
          statuses.add(soldierCard(filteredDailies[i], i));
        }
        if (!types.contains(filteredDailies[i]['type'])) {
          types.insertAll(types.length - 2, [filteredDailies[i]['type']]);
        }
      } else {
        if (isExpanded) {
          statuses.add(soldierCard(filteredDailies[i], i));
        }
      }
    }

    return statuses;
  }

  sortDailies() {
    filteredDailies.sort((a, b) {
      int? c = a['typeSort'].compareTo(b['typeSort']);
      if (c == 0) {
        c = a['type'].compareTo(b['type']);
      }
      if (c == 0) {
        c = b['rankSort'].compareTo(a['rankSort']);
      }
      return c!;
    });
  }

  Future<bool> onWillPop() {
    PerstatByName byName = PerstatByName(
      owner: _userId,
      date: dateFormat.format(DateTime.now()),
      dailies: dailies,
    );
    firestore.collection('perstatByName').doc(_userId).set(byName.toMap());
    return Future.value(true);
  }

  buildNewDailies() async {
    soldiers = ref.read(soldiersProvider);
    QuerySnapshot perstatSnapshot = await firestore
        .collection('perstat')
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: _userId)
        .get();
    perstats = perstatSnapshot.docs
        .where((doc) => isOverdue(doc['start'], 0) && !isOverdue(doc['end'], 1))
        .toList();
    List<String?> soldierIds = [];

    setState(() {
      for (DocumentSnapshot perstat in perstats) {
        bool assigned = true;
        try {
          final soldier =
              soldiers.firstWhere((e) => e.id == perstat['soldierId']);
          assigned = soldier.assigned;
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
        soldierIds.add(perstat['soldierId']);
        var map = <String, String?>{};
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
        bool? assigned = true;
        try {
          assigned = soldier.assigned;
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
        if (!soldierIds.contains(soldier.id)) {
          var map = <String, String?>{};
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
    soldiers = ref.read(soldiersProvider);
    debugPrint(soldiers.length.toString());
    if (perstats.isEmpty) {
      QuerySnapshot perstatSnapshot = await firestore
          .collection('perstat')
          .where('users', isNotEqualTo: null)
          .where('users', arrayContains: _userId)
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userId = ref.read(authProvider).currentUser()!.uid;
    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  initialize() async {
    DocumentSnapshot snapshot;
    PerstatByName? byName;
    try {
      snapshot = await firestore.collection('perstatByName').doc(_userId).get();
      byName = PerstatByName.fromSnapshot(snapshot);
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
    if (byName == null || byName.dailies[0]['section'] == null) {
      buildNewDailies();
    } else {
      setState(() {
        dailies = byName!.dailies.toList();
        filteredDailies = List.from(dailies);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'PERSTAT By Name',
      actions: createAppBarActions(
        width,
        [
          AppBarOption(
              title: 'Refresh',
              icon: Icon(kIsWeb || Platform.isAndroid
                  ? Icons.refresh
                  : CupertinoIcons.refresh),
              onPressed: () {
                dailies.clear();
                buildNewDailies();
              }),
          AppBarOption(
              title: 'Filter Records',
              icon: const Icon(Icons.filter_alt),
              onPressed: () {
                showFilterOptions(
                  context,
                  dailies.map((e) => e['section'].toString()).toList(),
                  (sections) => _filterRecords(sections),
                );
              }),
          if (!kIsWeb)
            AppBarOption(
                title: 'Download Image',
                icon: Icon(kIsWeb || Platform.isAndroid
                    ? Icons.image
                    : CupertinoIcons.photo),
                onPressed: () => _downloadPng()),
          AppBarOption(
              title: 'Download Excel',
              icon: Icon(kIsWeb || Platform.isAndroid
                  ? Icons.download
                  : CupertinoIcons.cloud_download),
              onPressed: () => _downloadExcel()),
        ],
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Center(
          heightFactor: 1,
          child: ListView(
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dailyStatuses(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformButton(
                  onPressed: () {
                    submit(context);
                  },
                  child: const Text('Update PERSTAT Section'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
