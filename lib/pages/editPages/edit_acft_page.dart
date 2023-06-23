import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../calculators/hrp_calculator.dart';
import '../../calculators/mdl_calculator.dart';
import '../../calculators/plk_calculator.dart';
import '../../calculators/sdc_calculator.dart';
import '../../calculators/spt_calculator.dart';
import '../../calculators/twomr_calculator.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/theme_methods.dart';
import '../../methods/validate.dart';
import '../../models/acft.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_selection_widget.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditAcftPage extends ConsumerStatefulWidget {
  const EditAcftPage({
    Key? key,
    required this.acft,
  }) : super(key: key);
  final Acft acft;

  @override
  EditAcftPageState createState() => EditAcftPageState();
}

class EditAcftPageState extends ConsumerState<EditAcftPage> {
  String _title = 'New ACFT';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _deadliftController = TextEditingController();
  final TextEditingController _powerThrowController = TextEditingController();
  final TextEditingController _puController = TextEditingController();
  final TextEditingController _dragController = TextEditingController();
  final TextEditingController _plankController = TextEditingController();
  final TextEditingController _runController = TextEditingController();
  final TextEditingController _deadliftRawController = TextEditingController();
  final TextEditingController _powerThrowRawController =
      TextEditingController();
  final TextEditingController _puRawController = TextEditingController();
  final TextEditingController _dragRawController = TextEditingController();
  final TextEditingController _plankRawController = TextEditingController();
  final TextEditingController _runRawController = TextEditingController();
  String _ageGroup = '17-21', _gender = 'Male', _runType = 'Run';
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  late User user;
  List<dynamic>? _users;
  int? _total,
      _mdlScore,
      _sptScore,
      _hrpScore,
      _sdcScore,
      _plkScore,
      _runScore,
      _sdcMins,
      _sdcSecs,
      _plkMins,
      _plkSecs,
      _runMins,
      _runSecs,
      _mdlRaw,
      _hrpRaw;
  double? _sptRaw;
  List<Soldier>? lessSoldiers;
  late List<Soldier> allSoldiers;
  bool pass = true,
      removeSoldiers = false,
      updated = false,
      mdlPass = true,
      sptPass = true,
      hrpPass = true,
      sdcPass = true,
      plkPass = true,
      runPass = true;
  final List<String> _runTypes = ['Run', 'Walk', 'Row', 'Bike', 'Swim'];
  DateTime? _dateTime;
  FToast toast = FToast();

  List<String> ageGroups = [
    '17-21',
    '22-26',
    '27-31',
    '32-36',
    '37-41',
    '42-46',
    '47-51',
    '52-56',
    '57-61',
    '62+'
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _deadliftController.dispose();
    _powerThrowController.dispose();
    _puController.dispose();
    _dragController.dispose();
    _plankController.dispose();
    _runController.dispose();
    _deadliftRawController.dispose();
    _powerThrowRawController.dispose();
    _puRawController.dispose();
    _dragRawController.dispose();
    _plankRawController.dispose();
    _runRawController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = ref.read(authProvider).currentUser()!;
    allSoldiers = ref.read(soldiersProvider);

    _runType = widget.acft.altEvent;

    if (widget.acft.id != null) {
      _title = '${widget.acft.rank} ${widget.acft.name}';
    }
    _ageGroup = widget.acft.ageGroup;
    _gender = widget.acft.gender;

    _soldierId = widget.acft.soldierId;
    _rank = widget.acft.rank;
    _lastName = widget.acft.name;
    _firstName = widget.acft.firstName;
    _section = widget.acft.section;
    _rankSort = widget.acft.rankSort;
    _owner = widget.acft.owner;
    _users = widget.acft.users;

    _total = widget.acft.total;
    _mdlScore = widget.acft.deadliftScore;
    _sptScore = widget.acft.powerThrowScore;
    _hrpScore = widget.acft.puScore;
    _sdcScore = widget.acft.dragScore;
    _plkScore = widget.acft.plankScore;
    _runScore = widget.acft.runScore;

    _mdlRaw = int.tryParse(widget.acft.deadliftRaw) ?? 0;
    _sptRaw = double.tryParse(widget.acft.powerThrowRaw) ?? 0;
    _hrpRaw = int.tryParse(widget.acft.puRaw) ?? 0;
    if (widget.acft.dragRaw.characters.contains(":")) {
      _sdcMins = int.tryParse(widget.acft.dragRaw
              .substring(0, widget.acft.dragRaw.indexOf(":"))) ??
          0;
      _sdcSecs = int.tryParse(widget.acft.dragRaw
              .substring(widget.acft.dragRaw.indexOf(":") + 1)) ??
          0;
    } else {
      _sdcMins = 0;
      _sdcSecs = 0;
    }
    if (widget.acft.plankRaw.characters.contains(":")) {
      _plkMins = int.tryParse(widget.acft.plankRaw
              .substring(0, widget.acft.plankRaw.indexOf(":"))) ??
          0;
      _plkSecs = int.tryParse(widget.acft.plankRaw
              .substring(widget.acft.plankRaw.indexOf(":") + 1)) ??
          0;
    } else {
      _plkMins = 0;
      _plkMins = 0;
    }
    if (widget.acft.runRaw.characters.contains(":")) {
      _runMins = int.tryParse(widget.acft.runRaw
              .substring(0, widget.acft.runRaw.indexOf(":"))) ??
          0;
      _runSecs = int.tryParse(widget.acft.runRaw
              .substring(widget.acft.runRaw.indexOf(":") + 1)) ??
          0;
    } else {
      _runMins = 0;
      _runSecs = 0;
    }

    _dateController.text = widget.acft.date;
    _deadliftController.text = _mdlScore.toString();
    _powerThrowController.text = _sptScore.toString();
    _puController.text = _hrpScore.toString();
    _dragController.text = _sdcScore.toString();
    _plankController.text = _plkScore.toString();
    _runController.text = _runScore.toString();
    _deadliftRawController.text = widget.acft.deadliftRaw;
    _powerThrowRawController.text = widget.acft.powerThrowRaw;
    _puRawController.text = widget.acft.puRaw;
    _dragRawController.text = widget.acft.dragRaw;
    _plankRawController.text = widget.acft.plankRaw;
    _runRawController.text = widget.acft.runRaw;

    pass = widget.acft.pass;
    if (pass) {
      mdlPass = true;
      sptPass = true;
      hrpPass = true;
      sdcPass = true;
      plkPass = true;
      runPass = true;
    } else {
      mdlPass = _mdlScore! >= 60;
      sptPass = _sptScore! >= 60;
      hrpPass = _hrpScore! >= 60;
      sdcPass = _sdcScore! >= 60;
      plkPass = _plkScore! >= 60;
      runPass = _runScore! >= 60;
    }
    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(widget.acft.date) ?? DateTime.now();
  }

  int getIntTime(int? mins, int? secs) {
    String secString = secs.toString().length == 2 ? secs.toString() : '0$secs';
    return int.tryParse(mins.toString() + secString) ?? 0;
  }

  List<String> getAltBenchmarks(int ageGroup, bool male) {
    // walk, bike, swim/row
    if (ageGroup < 1) {
      return male ? ['31:00', '26:25', '30:48'] : ['34:00', '28:58', '33:48'];
    } else if (ageGroup < 2) {
      return male ? ['30:45', '26:12', '30:30'] : ['33:30', '28:31', '33:18'];
    } else if (ageGroup < 3) {
      return male ? ['30:30', '26:00', '30:20'] : ['33:00', '28:07', '32:48'];
    } else if (ageGroup < 4) {
      return male ? ['30:45', '26:12', '30:30'] : ['33:30', '28:31', '33:18'];
    } else if (ageGroup < 5) {
      return male ? ['31:00', '26:25', '30:48'] : ['34:00', '28:58', '33:48'];
    } else if (ageGroup < 6) {
      return male ? ['31:00', '26:25', '30:48'] : ['34:00', '28:58', '33:48'];
    } else if (ageGroup < 7) {
      return male ? ['32:00', '27:16', '31:48'] : ['35:00', '29:50', '34:48'];
    } else if (ageGroup < 8) {
      return male ? ['32:00', '27:16', '31:48'] : ['35:00', '29:50', '34:48'];
    } else if (ageGroup < 9) {
      return male ? ['33:00', '28:07', '32:50'] : ['36:00', '30:41', '35:48'];
    } else {
      return male ? ['33:00', '28:07', '32:50'] : ['36:00', '30:41', '35:48'];
    }
  }

  void calcMdl() {
    _mdlScore = getMdlScore(
      ageGroup: ageGroups.indexOf(_ageGroup) + 1,
      male: _gender == 'Male',
      weight: _mdlRaw!,
    );
    mdlPass = _mdlScore! >= 60;
    _deadliftController.text = _mdlScore.toString();
  }

  void calcSpt() {
    _sptScore = getSptScore(
      ageGroup: ageGroups.indexOf(_ageGroup) + 1,
      dist: _sptRaw!,
      male: _gender == 'Male',
    );
    sptPass = _sptScore! >= 60;
    _powerThrowController.text = _sptScore.toString();
  }

  void calcHrp() {
    _hrpScore = getHrpScore(
      ageGroup: ageGroups.indexOf(_ageGroup) + 1,
      male: _gender == 'Male',
      pushups: _hrpRaw!,
    );
    hrpPass = _hrpScore! >= 60;
    _puController.text = _hrpScore.toString();
  }

  void calcSdc() {
    _sdcScore = getSdcScore(
      ageGroup: ageGroups.indexOf(_ageGroup) + 1,
      male: _gender == 'Male',
      time: getIntTime(_sdcMins, _sdcSecs),
    );
    sdcPass = _sdcScore! >= 60;
    _dragController.text = _sdcScore.toString();
  }

  void calcPlk() {
    _plkScore = getPlkScore(
      ageGroup: ageGroups.indexOf(_ageGroup) + 1,
      male: _gender == 'Male',
      time: getIntTime(_plkMins, _plkSecs),
    );
    plkPass = _plkScore! >= 60;
    _plankController.text = _plkScore.toString();
  }

  void calcRunScore() {
    int time = getIntTime(_runMins, _runSecs);
    if (_runType == 'Run') {
      _runScore = get2mrScore(
        ageGroup: ageGroups.indexOf(_ageGroup) + 1,
        male: _gender == 'Male',
        time: time,
      );
    } else {
      List<String> altMins =
          getAltBenchmarks(ageGroups.indexOf(_ageGroup), _gender == 'Male');
      String runMin = altMins[2];
      if (_runType == 'Walk') {
        runMin = altMins[0];
      } else if (_runType == 'Bike') {
        runMin = altMins[1];
      }
      int min = int.tryParse(runMin.replaceRange(2, 3, "")) ?? 0;
      if (time <= min) {
        _runScore = 60;
      } else {
        _runScore = 0;
      }
    }
    runPass = _runScore! >= 60;
    _runController.text = _runScore.toString();
  }

  void calcTotal() {
    _total = _mdlScore! +
        _sptScore! +
        _hrpScore! +
        _sdcScore! +
        _plkScore! +
        _runScore!;
    pass = mdlPass && sptPass && hrpPass && sdcPass && plkPass && runPass;
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      toast.showToast(
        child: const MyToast(
          message: 'Please select a Soldier',
        ),
      );
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text],
    )) {
      Acft saveAcft = Acft(
        id: widget.acft.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        ageGroup: _ageGroup,
        gender: _gender,
        deadliftRaw: _deadliftRawController.text,
        powerThrowRaw: _powerThrowRawController.text,
        puRaw: _puRawController.text,
        dragRaw: _dragRawController.text,
        plankRaw: _plankRawController.text,
        runRaw: _runRawController.text,
        deadliftScore: _mdlScore!,
        powerThrowScore: _sptScore!,
        puScore: _hrpScore!,
        dragScore: _sdcScore!,
        plankScore: _plkScore!,
        runScore: _runScore!,
        total: _total!,
        altEvent: _runType,
        pass: pass,
      );

      // setDateNotifications(
      //   setting: ref.read(settingsProvider.notifier).settings,
      //   map: saveAcft.toMap(),
      //   user: ref.read(userProvider).user!,
      //   topic: 'ACFT',
      // );

      if (widget.acft.id == null) {
        firestore.collection(Acft.collectionName).add(saveAcft.toMap());
      } else {
        firestore
            .collection(Acft.collectionName)
            .doc(widget.acft.id)
            .set(saveAcft.toMap())
            .then((value) {})
            .catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating ACFT');
        });
      }
      Navigator.pop(context);
    } else {
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    toast.context = context;
    return PlatformScaffold(
      title: _title,
      body: FormFrame(
        formKey: _formKey,
        onWillPop:
            updated ? () => onBackPressed(context) : () => Future(() => true),
        children: <Widget>[
          if (user.isAnonymous) const AnonWarningBanner(),
          FormGridView(
            width: width,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformSoldierPicker(
                  label: 'Soldier',
                  soldiers: removeSoldiers ? lessSoldiers! : allSoldiers,
                  value: _soldierId,
                  onChanged: (soldierId) {
                    final soldier =
                        allSoldiers.firstWhere((e) => e.id == soldierId);
                    setState(() {
                      _soldierId = soldierId;
                      _rank = soldier.rank;
                      _lastName = soldier.lastName;
                      _firstName = soldier.firstName;
                      _section = soldier.section;
                      _rankSort = soldier.rankSort.toString();
                      _owner = soldier.owner;
                      _users = soldier.users;
                      updated = true;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: removeSoldiers,
                  title: const Text('Remove Soldiers already added'),
                  onChanged: (checked) async {
                    lessSoldiers ??= await createLessSoldiers(
                      userId: user.uid,
                      collection: Acft.collectionName,
                      allSoldiers: allSoldiers,
                    );
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Date',
                date: _dateTime,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformSelectionWidget(
                  titles: const [Text('M'), Text('F')],
                  groupValue: _gender,
                  values: const ['Male', 'Female'],
                  onChanged: (dynamic value) {
                    setState(() {
                      updated = true;
                      _gender = value;
                      calcMdl();
                      calcSpt();
                      calcHrp();
                      calcSdc();
                      calcPlk();
                      calcRunScore();
                      calcTotal();
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  value: _ageGroup,
                  label: const Text('Age Group'),
                  items: ageGroups,
                  onChanged: (dynamic value) {
                    setState(() {
                      updated = true;
                      _ageGroup = value;
                      calcMdl();
                      calcSpt();
                      calcHrp();
                      calcSdc();
                      calcPlk();
                      calcRunScore();
                      calcTotal();
                      calcRunScore();
                      calcTotal();
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Aerobic Event'),
                  items: _runTypes,
                  onChanged: (dynamic value) {
                    setState(() {
                      _runType = value;
                      updated = true;
                      calcRunScore();
                      calcTotal();
                    });
                  },
                  value: _runType,
                ),
              ),
            ],
          ),
          GridView.count(
            primary: false,
            crossAxisCount: 3,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            childAspectRatio: width > 900 ? 900 / 325 : width / 325,
            shrinkWrap: true,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                  child: Text(
                    'MDL',
                    style: TextStyle(fontSize: 18),
                  )),
              PaddedTextField(
                controller: _deadliftRawController,
                keyboardType: TextInputType.number,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    _mdlRaw = int.tryParse(value) ?? 0;
                    calcMdl();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _deadliftController,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                  child: HeaderText(
                    'SPT',
                    textAlign: TextAlign.start,
                  )),
              PaddedTextField(
                controller: _powerThrowRawController,
                keyboardType: TextInputType.text,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    _sptRaw = double.tryParse(value) ?? 0;
                    calcSpt();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _powerThrowController,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                child: HeaderText(
                  'HRP',
                  textAlign: TextAlign.start,
                ),
              ),
              PaddedTextField(
                controller: _puRawController,
                keyboardType: TextInputType.number,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    _hrpRaw = int.tryParse(value) ?? 0;
                    calcHrp();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _puController,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                  child: HeaderText(
                    'SDC',
                    textAlign: TextAlign.start,
                  )),
              PaddedTextField(
                controller: _dragRawController,
                keyboardType: TextInputType.text,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  String mins = value.contains(':')
                      ? value.substring(0, value.indexOf(':'))
                      : '5';
                  _sdcMins = int.tryParse(mins) ?? 5;
                  String secs = value.substring(value.indexOf(':') + 1);
                  _sdcSecs = int.tryParse(secs) ?? 0;
                  setState(() {
                    updated = true;
                    calcSdc();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _dragController,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                child: HeaderText(
                  'PLK',
                  textAlign: TextAlign.start,
                ),
              ),
              PaddedTextField(
                controller: _plankRawController,
                keyboardType: TextInputType.text,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    String mins = value.contains(':')
                        ? value.substring(0, value.indexOf(':'))
                        : '0';
                    _plkMins = int.tryParse(mins) ?? 0;
                    String secs = value.substring(value.indexOf(':') + 1);
                    _plkSecs = int.tryParse(secs) ?? 0;
                    calcPlk();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _plankController,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                child: HeaderText(
                  _runType,
                  textAlign: TextAlign.start,
                ),
              ),
              PaddedTextField(
                controller: _runRawController,
                keyboardType: TextInputType.text,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    String mins = value.contains(':')
                        ? value.substring(0, value.indexOf(':'))
                        : '30';
                    _runMins = int.tryParse(mins) ?? 30;
                    String secs = value.substring(value.indexOf(':') + 1);
                    _runSecs = int.tryParse(secs) ?? 0;
                    calcRunScore();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _runController,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
                  child: HeaderText(
                    'Total',
                    textAlign: TextAlign.start,
                  )),
              const Padding(padding: EdgeInsets.all(8.0), child: SizedBox()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: getTextColor(context),
                        width: 2.0,
                        style: BorderStyle.solid,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0))),
                  child: Center(
                    child: HeaderText(
                      _total.toString(),
                    ),
                  ),
                ),
              )
            ],
          ),
          FormGridView(
            width: width,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                  title: const Text('Pass'),
                  value: pass,
                  onChanged: (value) {
                    setState(() {
                      pass = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          PlatformButton(
            child: Text(widget.acft.id == null ? 'Add ACFT' : 'Update ACFT'),
            onPressed: () => submit(context),
          ),
        ],
      ),
    );
  }
}
