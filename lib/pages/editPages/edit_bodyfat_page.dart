import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../calculators/bf_calculator.dart';
import '../../constants/firestore_collections.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/set_notifications.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/bodyfat.dart';
import '../../models/soldier.dart';
import '../../providers/settings_provider.dart';
import '../../providers/soldiers_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_selection_widget.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/platform_widgets/platform_text_field.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditBodyfatPage extends ConsumerStatefulWidget {
  const EditBodyfatPage({
    Key? key,
    required this.bodyfat,
  }) : super(key: key);
  final Bodyfat bodyfat;

  @override
  EditBodyfatPageState createState() => EditBodyfatPageState();
}

class EditBodyfatPageState extends ConsumerState<EditBodyfatPage> {
  String _title = 'New Body Composition';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightDoubleController = TextEditingController();
  bool bmiPass = true,
      bfPass = true,
      removeSoldiers = false,
      updated = false,
      underweight = false;
  String _gender = 'Male';
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  late int height;
  double? heightDouble;
  List<Soldier>? allSoldiers, lessSoldiers;
  DateTime? _dateTime;
  BfCalculator bfCalculator = BfCalculator();
  FToast toast = FToast();

  @override
  void dispose() {
    _dateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _percentController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.bodyfat.id != null) {
      _title = '${widget.bodyfat.rank} ${widget.bodyfat.name}';
    }

    _soldierId = widget.bodyfat.soldierId;
    _rank = widget.bodyfat.rank;
    _lastName = widget.bodyfat.name;
    _firstName = widget.bodyfat.firstName;
    _section = widget.bodyfat.section;
    _rankSort = widget.bodyfat.rankSort;
    _gender = widget.bodyfat.gender;
    _owner = widget.bodyfat.owner;
    _users = widget.bodyfat.users;

    height = int.tryParse(widget.bodyfat.height) ?? 0;
    if (widget.bodyfat.heightDouble == '') {
      heightDouble = height.toDouble();
    } else {
      heightDouble = double.tryParse(widget.bodyfat.heightDouble);
    }

    bmiPass = widget.bodyfat.passBmi;
    bfPass = widget.bodyfat.passBf;

    _dateController.text = widget.bodyfat.date;
    _heightController.text = widget.bodyfat.height;
    _weightController.text = widget.bodyfat.weight;
    _neckController.text = widget.bodyfat.neck;
    _waistController.text = widget.bodyfat.waist;
    _hipController.text = widget.bodyfat.hip;
    _percentController.text = widget.bodyfat.percent;
    _ageController.text = widget.bodyfat.age.toString();
    _heightDoubleController.text = heightDouble.toString();

    _dateTime = DateTime.tryParse(widget.bodyfat.date) ?? DateTime.now();
  }

  int ageGroupIndex() {
    int age = int.tryParse(_ageController.text) ?? 0;
    if (age < 21) return 0;
    if (age < 28) return 1;
    if (age < 40) return 2;
    return 3;
  }

  void calcBmi() {
    int height = int.tryParse(_heightController.text) ?? 58;
    int weight = int.tryParse(_weightController.text) ?? 0;
    List<int> benchmarks = bfCalculator.setBenchmarks(
      ageGroupIndex: ageGroupIndex(),
      height: height,
      male: _gender == 'Male',
    );

    if (weight < benchmarks[0]) {
      setState(() {
        bmiPass = true;
        underweight = true;
      });
    } else if (weight > benchmarks[1]) {
      setState(() {
        bmiPass = false;
        underweight = false;
      });
    } else {
      setState(() {
        bmiPass = true;
        underweight = false;
      });
    }
  }

  double roundToPointFive(double number) {
    return (number * 2).round() / 2;
  }

  calcBf() {
    int maxPercent = bfCalculator.percentTable[
        _gender == 'Male' ? ageGroupIndex() : ageGroupIndex() + 4];
    double neck = double.tryParse(_neckController.text) ?? 0;
    double waist = double.tryParse(_waistController.text) ?? 0;
    double hip = double.tryParse(_hipController.text) ?? 0;
    neck = roundToPointFive(neck);
    waist = roundToPointFive(waist);
    hip = roundToPointFive(hip);
    double cirValue = _gender == 'Male' ? waist - neck : hip + waist - neck;

    int bfPercent = bfCalculator.getBfPercent(
      cirValue: cirValue,
      height: heightDouble!,
      male: _gender == 'Male',
    );
    _percentController.text = bfPercent.toString();
    setState(() {
      bfPass = bfPercent <= maxPercent;
    });
  }

  Widget _buildTape(double width) {
    return Column(
      children: <Widget>[
        const Divider(),
        const HeaderText(
          'Height to nearest 1/2 in.',
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 92,
                height: 64,
                child: PlatformButton(
                  onPressed: () {
                    if (!(heightDouble == (height.toDouble() - 0.5))) {
                      setState(() {
                        heightDouble = heightDouble! - 0.5;
                        _heightDoubleController.text = heightDouble.toString();
                      });
                      calcBf();
                    }
                  },
                  child: const Text('- 0.5'),
                ),
              ),
              SizedBox(
                width: 64,
                child: PlatformTextField(
                  controller: _heightDoubleController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.normal),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              SizedBox(
                width: 92,
                height: 64,
                child: PlatformButton(
                  child: const Text('+ 0.5'),
                  onPressed: () {
                    if (!(heightDouble == (height.toDouble() + 0.5))) {
                      setState(() {
                        heightDouble = heightDouble! + 0.5;
                        _heightDoubleController.text = heightDouble.toString();
                      });
                      calcBf();
                    }
                  },
                ),
              )
            ],
          ),
        ),
        FormGridView(width: width, children: tapes())
      ],
    );
  }

  List<Widget> tapes() {
    List<Widget> tapes = [
      PaddedTextField(
        controller: _neckController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        label: 'Neck',
        decoration: const InputDecoration(
          labelText: 'Neck',
        ),
        onChanged: (value) {
          calcBf();
        },
      ),
      PaddedTextField(
        controller: _waistController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        label: 'Waist',
        decoration: const InputDecoration(
          labelText: 'Waist',
        ),
        onChanged: (value) {
          calcBf();
        },
      ),
    ];
    if (_gender == 'Female') {
      tapes.add(
        PaddedTextField(
          controller: _hipController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          label: 'Hip',
          decoration: const InputDecoration(
            labelText: 'Hip',
          ),
          onChanged: (value) {
            calcBf();
          },
        ),
      );
    }
    tapes.add(
      PaddedTextField(
          controller: _percentController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: false,
          label: 'Bodyfat Percentage',
          decoration: const InputDecoration(
            labelText: 'Bodyfat Percent',
          )),
    );
    tapes.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: PlatformCheckboxListTile(
        title: const Text('Pass Bodyfat'),
        controlAffinity: ListTileControlAffinity.leading,
        value: bfPass,
        onChanged: (value) {
          setState(() {
            bfPass = value!;
          });
        },
      ),
    ));
    return tapes;
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
      Bodyfat saveBodyfat = Bodyfat(
        id: widget.bodyfat.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _gender,
        date: _dateController.text,
        height: _heightController.text,
        heightDouble: heightDouble.toString(),
        weight: _weightController.text,
        passBmi: bmiPass,
        neck: _neckController.text,
        waist: _waistController.text,
        hip: _hipController.text,
        percent: _percentController.text,
        passBf: bfPass,
      );

      setDateNotifications(
        setting: ref.read(settingsProvider.notifier).settings,
        map: saveBodyfat.toMap(),
        user: ref.read(userProvider).user!,
        topic: 'Body Composition',
      );

      if (widget.bodyfat.id == null) {
        DocumentReference docRef = await firestore
            .collection(kBodyfatCollection)
            .add(saveBodyfat.toMap());

        saveBodyfat.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kBodyfatCollection)
            .doc(widget.bodyfat.id)
            .set(saveBodyfat.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Bodyfat');
        });
      }
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
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                child: PlatformCheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: removeSoldiers,
                  title: const Text('Remove Soldiers already added'),
                  onChanged: (checked) {
                    createLessSoldiers(
                        collection: kBodyfatCollection,
                        userId: user.uid,
                        allSoldiers: allSoldiers!);
                  },
                ),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Date',
                date: _dateTime,
              ),
              PlatformSelectionWidget(
                titles: const [Text('M'), Text('F')],
                values: const ['Male', 'Female'],
                groupValue: _gender,
                onChanged: (dynamic gender) {
                  _gender = gender;
                  calcBmi();
                  calcBf();
                },
              ),
              PaddedTextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                label: 'Age',
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
                onChanged: (value) {
                  updated = true;
                  calcBmi();
                  calcBf();
                },
              ),
              PaddedTextField(
                controller: _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                label: 'Height',
                decoration: const InputDecoration(
                  labelText: 'Height',
                ),
                onChanged: (value) {
                  updated = true;
                  height = int.tryParse(value) ?? 0;
                  heightDouble = height.toDouble();
                  _heightDoubleController.text = heightDouble.toString();
                  calcBmi();
                  calcBf();
                },
              ),
              PaddedTextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                label: 'Weight',
                decoration: const InputDecoration(
                  labelText: 'Weight',
                ),
                onChanged: (value) {
                  updated = true;
                  calcBmi();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Pass BMI'),
                  value: bmiPass,
                  onChanged: (value) {
                    if (mounted) {
                      bmiPass = value!;
                    }
                  },
                ),
              )
            ],
          ),
          if (underweight)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: HeaderText(
                'Soldier is Under Weight',
              ),
            ),
          if (!bmiPass) _buildTape(width),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(widget.bodyfat.id == null
                ? 'Add Body Comp'
                : 'Update Body Comp'),
          ),
        ],
      ),
    );
  }
}
