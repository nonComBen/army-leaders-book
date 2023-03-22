import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:leaders_book/methods/show_snackbar.dart';
import 'package:leaders_book/providers/shared_prefs_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pdf/alert_roster_pdf.dart';
import '../../providers/subscription_state.dart';
import '../methods/download_methods.dart';
import '../models/alert_soldier.dart';
import '../../models/soldier.dart';
import '../../widgets/anon_warning_banner.dart';
import '../providers/soldiers_provider.dart';
import '../widgets/formatted_text_button.dart';
import '../widgets/alert_tile.dart';

class AlertRosterPage extends ConsumerStatefulWidget {
  const AlertRosterPage({Key? key}) : super(key: key);

  static const routeName = '/alert-roster-page';

  @override
  AlertRosterPageState createState() => AlertRosterPageState();
}

class AlertRosterPageState extends ConsumerState<AlertRosterPage> {
  List<dynamic> _soldiers = [];
  List<Soldier> _allSoldiers = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  bool isSubscribed = false, isInitial = true;
  String? _userId;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey _globalKey = GlobalKey();

  void _textAll() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (Platform.isIOS) {
      showSnackbar(
        context,
        'Unfortunately, mass texting all subordinates is not available on iOS at this time.',
      );
      return;
    }
    String recipients = 'sms:';
    for (var soldier in _soldiers) {
      if (soldier['phone'] != '') {
        recipients = '${recipients + soldier['phone']},';
      }
    }

    if (await canLaunchUrl(Uri.parse(recipients))) {
      await launchUrl(Uri.parse(recipients));
    } else {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to initiate text message')));
    }
  }

  void _editSupervisor(Map<String, dynamic> soldier) {
    List<dynamic> supervisors = [];
    supervisors.add({'soldier': '', 'soldierId': ''});
    supervisors
        .add({'soldier': 'Top of Hierarchy', 'soldierId': 'Top of Hierarchy'});
    supervisors.addAll(_soldiers);
    supervisors
        .removeWhere((element) => element['soldierId'] == soldier['soldierId']);
    if (!supervisors
        .map((e) => e['soldierId'])
        .toList()
        .contains(soldier['supervisorId'])) {
      soldier['supervisorId'] = '';
    }

    String? supervisorId = soldier['supervisorId'] ?? '';

    Text title = const Text('Edit Supervisor');
    Text content = Text(
        'Select ${soldier['soldier']}\'s supervisor from the drop down to place them in the hierarchy.');

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
                        content,
                        DropdownButtonFormField(
                            items: supervisors.map((supervisor) {
                              return DropdownMenuItem(
                                value: supervisor['soldierId'],
                                child: Text(supervisor['soldier']),
                              );
                            }).toList(),
                            value: supervisorId,
                            decoration:
                                const InputDecoration(labelText: 'Supervisor'),
                            onChanged: (dynamic value) {
                              refresh(() {
                                supervisorId = value;
                              });
                            }),
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
                          soldier['supervisorId'] = supervisorId;
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
                            content,
                            DropdownButtonFormField(
                                items: supervisors.map((supervisor) {
                                  return DropdownMenuItem(
                                    value: supervisor['soldierId'],
                                    child: Text(supervisor['soldier']),
                                  );
                                }).toList(),
                                value: supervisorId,
                                decoration: const InputDecoration(
                                    labelText: 'Supervisor'),
                                onChanged: (dynamic value) {
                                  refresh(() {
                                    supervisorId = value;
                                  });
                                }),
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
                          soldier['supervisorId'] = supervisorId;
                        });
                        Navigator.pop(context2);
                      },
                    )
                  ],
                ),
              ));
    }
  }

  List<Widget> _addSoldiersWarning() {
    return [
      const Center(
        child: Card(
            color: Colors.redAccent,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  'You need to add Soldiers before setting your Alert Roster'),
            )),
      )
    ];
  }

  List<Widget> buildRoster() {
    List<dynamic> soldiers = List.from(_soldiers);
    List<Widget> list = [];
    Map<String, dynamic>? top = soldiers.firstWhere(
        (element) => element['supervisorId'] == 'Top of Hierarchy',
        orElse: () => null);
    if (top == null) {
      list.add(
        const Center(
          child: Card(
            color: Colors.redAccent,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  'IOT establish a starting point, you need to select one Soldier as the \'Top of Hierarchy\''),
            ),
          ),
        ),
      );
    } else {
      list.add(
        InkWell(
          onLongPress: () {
            _editSupervisor(top);
          },
          child: AlertTile(
              soldier: top['soldier'],
              phone: top['phone'],
              workPhone: top['workPhone']),
        ),
      );
      soldiers
          .removeWhere((element) => element['soldierId'] == top['soldierId']);
      for (var soldierA in _soldiers
          .where((e) => e['supervisorId'] == top['soldierId'])
          .toList()) {
        list.add(
          Container(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: InkWell(
              onLongPress: () {
                _editSupervisor(soldierA);
              },
              child: AlertTile(
                  soldier: soldierA['soldier'],
                  phone: soldierA['phone'],
                  workPhone: soldierA['workPhone']),
            ),
          ),
        );
        soldiers.removeWhere(
            (element) => element['soldierId'] == soldierA['soldierId']);
        for (var soldierB in _soldiers
            .where((e) => e['supervisorId'] == soldierA['soldierId'])
            .toList()) {
          list.add(
            Container(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: InkWell(
                onLongPress: () {
                  _editSupervisor(soldierB);
                },
                child: AlertTile(
                    soldier: soldierB['soldier'],
                    phone: soldierB['phone'],
                    workPhone: soldierB['workPhone']),
              ),
            ),
          );
          soldiers.removeWhere(
              (element) => element['soldierId'] == soldierB['soldierId']);
          for (var soldierC in _soldiers
              .where((e) => e['supervisorId'] == soldierB['soldierId'])
              .toList()) {
            list.add(
              Container(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: InkWell(
                  onLongPress: () {
                    _editSupervisor(soldierC);
                  },
                  child: AlertTile(
                      soldier: soldierC['soldier'],
                      phone: soldierC['phone'],
                      workPhone: soldierC['workPhone']),
                ),
              ),
            );
            soldiers.removeWhere(
                (element) => element['soldierId'] == soldierC['soldierId']);
            for (var soldierD in _soldiers
                .where((e) => e['supervisorId'] == soldierB['soldierId'])
                .toList()) {
              list.add(
                Container(
                  padding: const EdgeInsets.only(left: 64, top: 4),
                  child: InkWell(
                    onLongPress: () {
                      _editSupervisor(soldierD);
                    },
                    child: AlertTile(
                        soldier: soldierD['soldier'],
                        phone: soldierD['phone'],
                        workPhone: soldierD['workPhone']),
                  ),
                ),
              );
              soldiers.removeWhere(
                  (element) => element['soldierId'] == soldierD['soldierId']);
              for (var soldierE in _soldiers
                  .where((e) => e['supervisorId'] == soldierB['soldierId'])
                  .toList()) {
                list.add(
                  Container(
                    padding: const EdgeInsets.only(left: 80, top: 4),
                    child: InkWell(
                      onLongPress: () {
                        _editSupervisor(soldierE);
                      },
                      child: AlertTile(
                          soldier: soldierE['soldier'],
                          phone: soldierE['phone'],
                          workPhone: soldierE['workPhone']),
                    ),
                  ),
                );
                soldiers.removeWhere(
                    (element) => element['soldierId'] == soldierE['soldierId']);
              }
            }
          }
        }
      }
    }
    if (soldiers.isNotEmpty) {
      list.add(
        Divider(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
    for (Map<String, dynamic> soldier in soldiers) {
      list.add(
        Container(
          padding: const EdgeInsets.only(
            top: 4.0,
            left: 4.0,
          ),
          child: InkWell(
            onLongPress: () {
              _editSupervisor(soldier);
            },
            child: AlertTile(
              soldier: soldier['soldier'],
              phone: soldier['phone'],
              workPhone: soldier['workPhone'],
            ),
          ),
        ),
      );
    }
    return list;
  }

  // void _shareRoster() async {
  //   bool approved = await checkPermission(Permission.storage);
  //   if (!approved || !mounted) return;
  //   try {
  //     RenderRepaintBoundary boundary = _globalKey.currentContext!
  //         .findRenderObject() as RenderRepaintBoundary;
  //     ui.Image image = await boundary.toImage();
  //     var pngBytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;

  //     String location;

  //     Directory dir = Platform.isAndroid
  //         ? await getTemporaryDirectory()
  //         : getApplicationDocumentsDirectory() as Directory;
  //     String path = dir.path;
  //     location = Platform.isAndroid
  //         ? 'temporary storage. Please open and save to a permanent location.'
  //         : 'On my iPhone(iPad)/Leader\'s Book';

  //     File file = File('$path/Alert Roster.png');
  //     file.writeAsBytesSync(pngBytes.buffer.asUint8List());

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Alert Roster Downloaded to $location'),
  //           duration: const Duration(seconds: 5),
  //           action: SnackBarAction(
  //             label: 'Open',
  //             onPressed: () {
  //               OpenFile.open(file.path);
  //             },
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     FirebaseAnalytics.instance.logEvent(name: 'Download Fail');
  //   }
  // }

  void _downloadPdf() async {
    if (isSubscribed) {
      Map<String, dynamic>? top = _soldiers.firstWhere(
          (doc) => doc['supervisorId'] == 'Top of Hierarchy', orElse: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Hierarchy must be set before downloading to Pdf.')));
        return null;
      });
      if (top == null) return;
      Widget title = const Text('Download PDF');
      Widget content = Container(
        padding: const EdgeInsets.all(8.0),
        child: const Text('Select full page or half page format.'),
      );
      customAlertDialog(
        context: context,
        title: title,
        content: content,
        primaryText: 'Full Page',
        primary: () {
          completePdfDownload(true);
        },
        secondaryText: 'Half Page',
        secondary: () {
          completePdfDownload(false);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Downloading PDF files is only available for subscribed users.'),
      ));
    }
  }

  void completePdfDownload(bool fullPage) async {
    bool approved = await checkPermission(Permission.storage);
    if (!approved) return;
    AlertRosterPdf pdf = AlertRosterPdf(
      documents: _soldiers,
    );
    String location;
    if (fullPage) {
      location = await pdf.createFullPage();
    } else {
      location = await pdf.createHalfPage();
    }
    String message;
    if (location == '') {
      message = 'Failed to download pdf';
    } else {
      String directory =
          kIsWeb ? '/Downloads' : '\'On My iPhone(iPad)/Leader\'s Book\'';
      message = kIsWeb
          ? 'Pdf successfully downloaded to $directory'
          : 'Pdf successfully downloaded to temporary storage. Please open and save to permanent location.';
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: location == ''
              ? null
              : SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    OpenFile.open('$location/alertRoster.pdf');
                  },
                )));
    }
  }

  void buildNewSoldiers() {
    for (Soldier soldier in _allSoldiers) {
      addSoldier(soldier);
    }
    setState(() {});
  }

  void addSoldier(Soldier soldier) {
    var map = <String, dynamic>{};
    map['soldierId'] = soldier.id;
    map['soldier'] =
        '${soldier.rank} ${soldier.lastName}, ${soldier.firstName}';
    map['supervisorId'] = '';
    map['rankSort'] = soldier.rankSort.toString();
    map['phone'] = soldier.phone;
    map['workPhone'] = soldier.workPhone;
    _soldiers.add(map);
  }

  void _showHelp() {
    Widget title = const Text('How to Build Alert Roster');
    Widget content = const Text(
        'In order to set the hierarchy, long press on each card and a pop up will allow you to select the Soldier\'s supervisor.  '
        'Select \'Top of Hierarchy\' for the starting point of the hierarchy');
    bool? dontShow = false;
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
                        Padding(
                            padding: const EdgeInsets.all(8.0), child: content),
                        CheckboxListTile(
                          title: const Text('Don\'t Show Again'),
                          value: dontShow,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            refresh(() {
                              dontShow = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FormattedTextButton(
                      label: 'OK',
                      onPressed: () {
                        prefs.setBool('dontShowHelpAlert', dontShow!);
                        Navigator.of(context2).pop();
                      },
                    ),
                  ],
                );
              },
            );
          });
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context2) {
          return StatefulBuilder(
            builder: (context, refresh) {
              return CupertinoAlertDialog(
                title: title,
                content: SingleChildScrollView(
                  child: Material(
                    color: Theme.of(context).dialogBackgroundColor,
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0), child: content),
                        CheckboxListTile(
                          title: const Text('Don\'t Show Again'),
                          value: dontShow,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            refresh(() {
                              dontShow = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () async {
                      prefs.setBool('dontShowHelpAlert', dontShow!);
                      Navigator.of(context2).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Future<bool> onWillPop() {
    AlertSoldiers alertSoldiers = AlertSoldiers(_userId, _userId, _soldiers);
    firestore
        .collection('alertSoldiers')
        .doc(_userId)
        .set(alertSoldiers.toMap());
    return Future.value(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    prefs = ref.read(sharedPreferencesProvider);
    bool dontShow = prefs.getBool('dontShowHelpAlert') ?? false;
    if (!dontShow) {
      _showHelp();
    }
    if (isInitial) {
      isInitial = false;
      initialize();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  initialize() async {
    _allSoldiers = ref.read(soldiersProvider);
    DocumentSnapshot snapshot;
    AlertSoldiers? alertSoldiers;
    try {
      snapshot = await firestore.collection('alertSoldiers').doc(_userId).get();
      alertSoldiers = AlertSoldiers.fromSnapshot(snapshot);
    } catch (e) {
      FirebaseAnalytics.instance
          .logEvent(name: 'Alert Soldiers Does Not Exist');
    }
    if (alertSoldiers == null) {
      debugPrint('Alert Soldiers is null.');
      buildNewSoldiers();
    } else {
      debugPrint('Alert Soldiers Length: ${alertSoldiers.soldiers!.length}');
      setState(() {
        _soldiers = alertSoldiers!.soldiers!.toList();
        buildRoster();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Alert Roster'),
        actions: <Widget>[
          Tooltip(
            message:
                kIsWeb || Platform.isIOS ? 'Feature Unavailable' : 'Text All',
            child: IconButton(
              icon: const Icon(
                Icons.sms,
              ),
              onPressed: kIsWeb || Platform.isIOS
                  ? null
                  : () {
                      _textAll();
                    },
            ),
          ),
          Tooltip(
              message: 'Download as PDF',
              child: IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () {
                  _downloadPdf();
                },
              ))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width < 816 ? 16 : (width - 800) / 2),
        child: Card(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: WillPopScope(
              onWillPop: onWillPop,
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: <Widget>[
                  if (user.isAnonymous) const AnonWarningBanner(),
                  RepaintBoundary(
                    key: _globalKey,
                    child: Column(
                      children: _allSoldiers.isEmpty
                          ? _addSoldiersWarning()
                          : _soldiers.isEmpty
                              ? [const CircularProgressIndicator()]
                              : buildRoster(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
