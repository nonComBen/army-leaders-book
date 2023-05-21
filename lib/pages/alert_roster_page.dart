import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leaders_book/methods/custom_modal_bottom_sheet.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/widgets/header_text.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_button.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_item_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/create_app_bar_actions.dart';
import '../models/app_bar_option.dart';
import '../pdf/alert_roster_pdf.dart';
import '../../providers/subscription_state.dart';
import '../methods/download_methods.dart';
import '../models/alert_soldier.dart';
import '../../models/soldier.dart';
import '../../widgets/anon_warning_banner.dart';
import '../providers/soldiers_provider.dart';
import '../widgets/formatted_text_button.dart';
import '../widgets/alert_tile.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../../auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../providers/shared_prefs_provider.dart';
import 'package:open_file/open_file.dart';

class AlertRosterPage extends ConsumerStatefulWidget {
  const AlertRosterPage({Key? key}) : super(key: key);

  static const routeName = '/alert-roster-page';

  @override
  AlertRosterPageState createState() => AlertRosterPageState();
}

class AlertRosterPageState extends ConsumerState<AlertRosterPage> {
  List<AlertSoldier?> _soldiers = [];
  List<Soldier> _allSoldiers = [];
  final List<dynamic> _supervisors = [
    {'soldier': '', 'soldierId': ''},
    {'soldier': 'Top of Hierarchy', 'soldierId': 'Top of Hierarchy'},
  ];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  bool isSubscribed = false, isInitial = true;
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isInitial) {
      isInitial = false;
      initialize();
    }
  }

  @override
  void initState() {
    super.initState();
    _userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    prefs = ref.read(sharedPreferencesProvider);
  }

  initialize() async {
    _allSoldiers = ref.read(soldiersProvider);
    _supervisors.addAll(_allSoldiers
        .map((e) => {
              'soldier': '${e.rank} ${e.lastName}, ${e.firstName}',
              'soldierId': e.id
            })
        .toList());
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
      buildNewSoldiers();
    } else {
      setState(() {
        _soldiers = alertSoldiers!.soldiers!
            .map((e) => AlertSoldier.fromMap(e))
            .toList();
        List<String> soldierIds =
            _allSoldiers.map((e) => e.id.toString()).toList();
        _soldiers.removeWhere((e) => !soldierIds.contains(e!.soldierId));
        if (_allSoldiers.length > _soldiers.length) {
          final addedSoldierIds = _soldiers.map((e) => e!.soldierId).toList();
          final extraSoldiers = _allSoldiers
              .where((e) => !addedSoldierIds.contains(e.id))
              .toList();
          for (Soldier soldier in extraSoldiers) {
            addSoldier(soldier);
          }
        }
      });
    }

    bool dontShow = prefs.getBool('dontShowHelpAlert') ?? false;
    if (!dontShow) {
      _showHelp();
    }
  }

  void _textAll() async {
    String recipients = 'sms:';
    for (var soldier in _soldiers) {
      if (soldier!.phone != '') {
        recipients = '${recipients + soldier.phone},';
      }
    }

    if (await canLaunchUrl(Uri.parse(recipients))) {
      await launchUrl(Uri.parse(recipients));
    } else {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'Failed to initiate text message',
        ),
      );
    }
  }

  void _editSupervisor(AlertSoldier soldier) {
    List<dynamic> supervisors = List.from(_supervisors);
    supervisors
        .removeWhere((element) => element['soldierId'] == soldier.soldierId);

    String supervisorId = soldier.supervisorId ?? '';

    if (!supervisors
        .map((e) => e['soldierId'])
        .toList()
        .contains(supervisorId)) {
      supervisorId = '';
    }

    customModalBottomSheet(
      context,
      StatefulBuilder(builder: (context, refresh) {
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: HeaderText('Edit Supervisor'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'Select ${soldier.name}\'s supervisor from the drop down to place them in the hierarchy.'),
            ),
            PlatformItemPicker(
              label: const Text('Supervisor'),
              value: supervisorId,
              items: supervisors.map((e) => e['soldierId'].toString()).toList(),
              itemLabels:
                  supervisors.map((e) => e['soldier'].toString()).toList(),
              onChanged: (dynamic value) {
                refresh(() {
                  supervisorId = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlatformButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  PlatformButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      setState(() {
                        soldier.supervisorId = supervisorId;
                      });
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> buildRoster() {
    List<dynamic> soldiers = List.from(_soldiers);
    List<Widget> list = [];
    AlertSoldier? top = soldiers.firstWhere(
        (element) => element.supervisorId == 'Top of Hierarchy',
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
        GestureDetector(
          onLongPress: () {
            _editSupervisor(top);
          },
          child: AlertTile(
              soldier: top.name, phone: top.phone, workPhone: top.workPhone),
        ),
      );
      soldiers.removeWhere((element) => element.soldierId == top.soldierId);
      for (var soldierA in _soldiers
          .where((e) => e!.supervisorId == top.soldierId)
          .toList()) {
        list.add(
          Container(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: GestureDetector(
              onLongPress: () {
                _editSupervisor(soldierA!);
              },
              child: AlertTile(
                  soldier: soldierA!.name,
                  phone: soldierA.phone,
                  workPhone: soldierA.workPhone),
            ),
          ),
        );
        soldiers
            .removeWhere((element) => element.soldierId == soldierA.soldierId);
        for (var soldierB in _soldiers
            .where((e) => e!.supervisorId == soldierA.soldierId)
            .toList()) {
          list.add(
            Container(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: GestureDetector(
                onLongPress: () {
                  _editSupervisor(soldierB!);
                },
                child: AlertTile(
                    soldier: soldierB!.name,
                    phone: soldierB.phone,
                    workPhone: soldierB.workPhone),
              ),
            ),
          );
          soldiers.removeWhere(
              (element) => element.soldierId == soldierB.soldierId);
          for (var soldierC in _soldiers
              .where((e) => e!.supervisorId == soldierB.soldierId)
              .toList()) {
            list.add(
              Container(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: GestureDetector(
                  onLongPress: () {
                    _editSupervisor(soldierC!);
                  },
                  child: AlertTile(
                      soldier: soldierC!.name,
                      phone: soldierC.phone,
                      workPhone: soldierC.workPhone),
                ),
              ),
            );
            soldiers.removeWhere(
                (element) => element.soldierId == soldierC.soldierId);
            for (var soldierD in _soldiers
                .where((e) => e!.supervisorId == soldierB.soldierId)
                .toList()) {
              list.add(
                Container(
                  padding: const EdgeInsets.only(left: 64, top: 4),
                  child: GestureDetector(
                    onLongPress: () {
                      _editSupervisor(soldierD!);
                    },
                    child: AlertTile(
                        soldier: soldierD!.name,
                        phone: soldierD.phone,
                        workPhone: soldierD.workPhone),
                  ),
                ),
              );
              soldiers.removeWhere(
                  (element) => element.soldierId == soldierD.soldierId);
              for (var soldierE in _soldiers
                  .where((e) => e!.supervisorId == soldierB.soldierId)
                  .toList()) {
                list.add(
                  Container(
                    padding: const EdgeInsets.only(left: 80, top: 4),
                    child: GestureDetector(
                      onLongPress: () {
                        _editSupervisor(soldierE!);
                      },
                      child: AlertTile(
                          soldier: soldierE!.name,
                          phone: soldierE.phone,
                          workPhone: soldierE.workPhone),
                    ),
                  ),
                );
                soldiers.removeWhere(
                    (element) => element.soldierId == soldierE.soldierId);
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
    for (var soldier in soldiers) {
      list.add(
        Container(
          padding: const EdgeInsets.only(
            top: 4.0,
            left: 4.0,
          ),
          child: GestureDetector(
            onLongPress: () {
              _editSupervisor(soldier!);
            },
            child: AlertTile(
              soldier: soldier.name,
              phone: soldier.phone,
              workPhone: soldier.workPhone,
            ),
          ),
        ),
      );
    }
    return list;
  }

  void _downloadPdf() async {
    if (isSubscribed) {
      AlertSoldier? top = _soldiers.firstWhere(
          (doc) => doc!.supervisorId == 'Top of Hierarchy', orElse: () {
        FToast toast = FToast();
        toast.context = context;
        toast.showToast(
          child: const MyToast(
            message: 'Hierarchy must be set before downloading to Pdf.',
          ),
        );
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
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message:
              'Downloading PDF files is only available for subscribed users.',
        ),
      );
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
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: MyToast(
          message: message,
          buttonText: kIsWeb ? null : 'Open',
          onPressed:
              kIsWeb ? null : () => OpenFile.open('$location/alertRoster.pdf'),
        ),
      );
    }
  }

  void buildNewSoldiers() {
    for (Soldier soldier in _allSoldiers) {
      addSoldier(soldier);
    }
    setState(() {});
  }

  void addSoldier(Soldier soldier) {
    var map = <String, dynamic>{
      'soldierId': soldier.id,
      'supervisorId': '',
      'soldier': '${soldier.rank} ${soldier.lastName}, ${soldier.firstName}',
      'rankSort': soldier.rankSort.toString(),
      'phone': soldier.phone,
      'workPhone': soldier.workPhone,
    };
    _soldiers.add(AlertSoldier.fromMap(map));
  }

  void removeSoldier(String soldierId) {
    _soldiers.removeWhere((element) => element!.soldierId == soldierId);
  }

  void _showHelp() {
    Widget title = const Text('How to Build Alert Roster');
    Widget content = const Text(
        'In order to set the hierarchy, long press on each card and a pop up will allow you to select the Soldier\'s supervisor.  '
        'Select \'Top of Hierarchy\' for the starting point of the hierarchy');
    bool dontShow = false;
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
                        PlatformCheckboxListTile(
                          title: const Text('Don\'t Show Again'),
                          value: dontShow,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            refresh(() {
                              dontShow = value!;
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
                        prefs.setBool('dontShowHelpAlert', dontShow);
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
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(8.0), child: content),
                      PlatformCheckboxListTile(
                        title: const Text('Don\'t Show Again'),
                        value: dontShow,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          refresh(() {
                            dontShow = value!;
                          });
                        },
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: getTextColor(context),
                      ),
                    ),
                    onPressed: () async {
                      prefs.setBool('dontShowHelpAlert', dontShow);
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
    AlertSoldiers alertSoldiers = AlertSoldiers(
        _userId, _userId, _soldiers.map((e) => e!.toMap()).toList());
    firestore
        .collection('alertSoldiers')
        .doc(_userId)
        .set(alertSoldiers.toMap());
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    return PlatformScaffold(
      title: 'Alert Roster',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isAndroid)
            AppBarOption(
              title: 'Text All',
              icon: Icon(
                Icons.sms,
                color: getOnPrimaryColor(context),
              ),
              onPressed: _textAll,
            ),
          AppBarOption(
            title: 'Download PDF',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.picture_as_pdf
                  : CupertinoIcons.doc,
              color: getOnPrimaryColor(context),
            ),
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 900),
          child: WillPopScope(
            onWillPop: onWillPop,
            child: ListView(
              children: <Widget>[
                if (user.isAnonymous) const AnonWarningBanner(),
                Column(
                  children: _allSoldiers.isEmpty
                      ? [
                          const Center(
                            child: Card(
                                color: Colors.redAccent,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'You need to add Soldiers before setting your Alert Roster'),
                                )),
                          )
                        ]
                      : _soldiers.isEmpty
                          ? [const CircularProgressIndicator()]
                          : buildRoster(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
