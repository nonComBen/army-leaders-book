import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/auth_provider.dart';
import '../../calculators/pu_calculator.dart';
import '../../calculators/run_calculator.dart';
import '../../calculators/su_calculator.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/theme_methods.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/apft.dart';
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

class EditApftPage extends ConsumerStatefulWidget {
  const EditApftPage({
    super.key,
    required this.apft,
  });
  final Apft apft;

  @override
  EditApftPageState createState() => EditApftPageState();
}

class EditApftPageState extends ConsumerState<EditApftPage> {
  String _title = 'New APFT';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _puController = TextEditingController();
  final TextEditingController _suController = TextEditingController();
  final TextEditingController _runController = TextEditingController();
  final TextEditingController _puRawController = TextEditingController();
  final TextEditingController _suRawController = TextEditingController();
  final TextEditingController _runRawController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _runType = 'Run', _gender = 'Male';
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  int _total = 0, _puScore = 0, _suScore = 0, _runScore = 0;
  List<Soldier>? allSoldiers, lessSoldiers;
  bool pass = true,
      removeSoldiers = false,
      updated = false,
      forProPoints = false,
      puPass = true,
      suPass = true,
      runPass = true;
  final List<String> _runTypes = ['Run', 'Walk', 'Bike', 'Swim'];
  DateTime? _dateTime;
  FToast toast = FToast();

  PuCalculator puCalculator = PuCalculator();
  SuCalculator suCalculator = SuCalculator();
  RunCalculator runCalculator = RunCalculator();

  @override
  void dispose() {
    _dateController.dispose();
    _puController.dispose();
    _suController.dispose();
    _runController.dispose();
    _puRawController.dispose();
    _suRawController.dispose();
    _runRawController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    _runType = widget.apft.altEvent;

    if (widget.apft.id != null) {
      _title = '${widget.apft.rank} ${widget.apft.name}';
    }

    _gender = widget.apft.gender;

    _soldierId = widget.apft.soldierId;
    _rank = widget.apft.rank;
    _lastName = widget.apft.name;
    _firstName = widget.apft.firstName;
    _section = widget.apft.section;
    _rankSort = widget.apft.rankSort;
    _owner = widget.apft.owner;
    _users = widget.apft.users;

    _total = widget.apft.total;
    _puScore = widget.apft.puScore;
    _suScore = widget.apft.suScore;
    _runScore = widget.apft.runScore;

    _dateController.text = widget.apft.date;
    _puController.text = _puScore.toString();
    _suController.text = _suScore.toString();
    _runController.text = _runScore.toString();
    _puRawController.text = widget.apft.puRaw;
    _suRawController.text = widget.apft.suRaw;
    _runRawController.text = widget.apft.runRaw;
    _ageController.text = widget.apft.age.toString();

    pass = widget.apft.pass;

    _dateTime = DateTime.tryParse(widget.apft.date) ?? DateTime.now();
  }

  int ageGroupIndex() {
    int age = int.tryParse(_ageController.text) ?? 17;
    if (age < 22) return 0;
    if (age < 27) return 1;
    if (age < 32) return 2;
    if (age < 37) return 3;
    if (age < 42) return 4;
    if (age < 47) return 5;
    if (age < 52) return 6;
    if (age < 57) return 7;
    if (age < 62) return 8;
    return 9;
  }

  void calcTotal() {
    _total = _puScore + _suScore + _runScore;
    pass = puPass && suPass && runPass;
  }

  void calcPu() {
    int puRaw = int.tryParse(_puRawController.text) ?? 0;
    if (_puRawController.text == '00') {
      puPass = true;
      if (forProPoints) {
        _puScore = 60;
      } else {
        _puScore = 0;
      }
    } else {
      _puScore = puCalculator.getPuScore(
          ageGroupIndex: ageGroupIndex(),
          male: _gender == 'Male',
          puRaw: puRaw);
      if (_puScore < 60) {
        puPass = false;
      } else {
        puPass = true;
      }
    }
    _puController.text = _puScore.toString();
  }

  void calcSu() {
    int suRaw = int.tryParse(_suRawController.text) ?? 0;
    if (_suRawController.text == '00') {
      suPass = true;
      if (forProPoints) {
        _suScore = 60;
      } else {
        _suScore = 0;
      }
    } else {
      _suScore = suCalculator.getSuScore(
        ageGroupIndex: ageGroupIndex(),
        suRaw: suRaw,
      );
      if (_suScore < 60) {
        suPass = false;
      } else {
        suPass = true;
      }
    }
    _suController.text = _suScore.toString();
  }

  void calcRun() {
    String runText = _runRawController.text;
    String mins = runText.contains(':')
        ? runText.substring(0, runText.indexOf(':'))
        : '50';
    String secs = runText.contains(':')
        ? runText.substring(runText.indexOf(':') + 1)
        : '00';
    if (secs.length == 1) secs = '0$secs';
    int runRaw = int.tryParse(mins + secs) ?? 2800;
    if (_runType != 'Run') {
      if (forProPoints) {
        if (runCalculator.passAltEvent(
          ageGroupIndex: ageGroupIndex(),
          event: _runType,
          male: _gender == 'Male',
          runRaw: runRaw,
        )) {
          _runScore = (_puScore + _suScore) ~/ 2;
          runPass = true;
        } else {
          _runScore = 0;
          runPass = false;
        }
      } else {
        _runScore = 0;
      }
    } else {
      _runScore = runCalculator.getRunScore(
        ageGroupIndex: ageGroupIndex(),
        male: _gender == 'Male',
        runRaw: runRaw,
      )!;
      if (_runScore < 60) {
        runPass = false;
      } else {
        runPass = true;
      }
    }
    _runController.text = _runScore.toString();
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text],
    )) {
      int age = int.tryParse(_ageController.text.trim()) ?? 0;
      Apft saveApft = Apft(
        id: widget.apft.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        puRaw: _puRawController.text,
        suRaw: _suRawController.text,
        runRaw: _runRawController.text,
        puScore: _puScore,
        suScore: _suScore,
        runScore: _runScore,
        total: _total,
        altEvent: _runType,
        pass: pass,
        age: age,
        gender: _gender,
      );

      if (widget.apft.id == null) {
        firestore.collection(Apft.collectionName).add(saveApft.toMap());
      } else {
        try {
          firestore
              .collection(Apft.collectionName)
              .doc(widget.apft.id)
              .set(saveApft.toMap(), SetOptions(merge: true));
        } on Exception catch (e) {
          debugPrint('Error updating APFT: $e');
        }
      }
      Navigator.of(context).pop();
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
    final user = ref.read(authProvider).currentUser()!;
    toast.context = context;
    return PlatformScaffold(
      title: _title,
      body: FormFrame(
        formKey: _formKey,
        canPop: !updated,
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
                  soldiers: removeSoldiers ? lessSoldiers! : allSoldiers!,
                  value: _soldierId,
                  onChanged: (soldierId) {
                    final soldier =
                        allSoldiers!.firstWhere((e) => e.id == soldierId);
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
                    lessSoldiers = await createLessSoldiers(
                      collection: Apft.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
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
                  values: const ['Male', 'Female'],
                  groupValue: _gender,
                  onChanged: (dynamic gender) {
                    setState(() {
                      _gender = gender;
                      calcPu();
                      calcSu();
                      calcRun();
                      calcTotal();
                    });
                  },
                ),
              ),
              PaddedTextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                label: 'Age',
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    calcPu();
                    calcSu();
                    calcRun();
                    calcTotal();
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: Text(
                    'Aerobic Event',
                    style: TextStyle(color: getTextColor(context)),
                  ),
                  items: _runTypes,
                  onChanged: (dynamic value) {
                    if (mounted) {
                      setState(() {
                        _runType = value;
                        updated = true;
                        calcRun();
                        calcTotal();
                      });
                    }
                  },
                  value: _runType,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                  value: forProPoints,
                  title: const Text('For Promotion Points'),
                  subtitle: const Text('Type "00" in PU/SU Raw if Profile'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (forPoints) {
                    setState(() {
                      updated = true;
                      forProPoints = forPoints!;
                      calcPu();
                      calcSu();
                      calcRun();
                      calcTotal();
                    });
                  },
                ),
              )
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
                  child: HeaderText(
                    'Pushup',
                    textAlign: TextAlign.start,
                  )),
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
                    calcPu();
                    if (forProPoints) {
                      calcRun();
                    }
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _puController,
                keyboardType: TextInputType.number,
                enabled: false,
                label: 'Score',
                decoration: const InputDecoration(
                  labelText: 'Score',
                ),
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                  child: HeaderText(
                    'Situp',
                    textAlign: TextAlign.start,
                  )),
              PaddedTextField(
                controller: _suRawController,
                keyboardType: TextInputType.number,
                label: 'Raw',
                decoration: const InputDecoration(
                  labelText: 'Raw',
                ),
                onChanged: (value) {
                  setState(() {
                    updated = true;
                    calcSu();
                    if (forProPoints) {
                      calcRun();
                    }
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _suController,
                keyboardType: TextInputType.number,
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
                    calcRun();
                    calcTotal();
                  });
                },
              ),
              PaddedTextField(
                controller: _runController,
                keyboardType: TextInputType.number,
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
                ),
              ),
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
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  child: Center(
                    child: HeaderText(
                      _total.toString(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformCheckboxListTile(
              title: const Text('Pass'),
              value: pass,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  updated = true;
                  pass = value!;
                });
              },
            ),
          ),
          PlatformButton(
            child: Text(widget.apft.id == null ? 'Add APFT' : 'Update APFT'),
            onPressed: () => submit(context),
          ),
        ],
      ),
    );
  }
}
