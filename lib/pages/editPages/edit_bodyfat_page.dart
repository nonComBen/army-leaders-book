import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/validate.dart';
import '../../models/bodyfat.dart';
import '../../calculators/bf_calculator.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  DateTime? _dateTime;
  BfCalculator bfCalculator = BfCalculator();

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateTime!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dateController.text = formatter.format(picked);
            updated = true;
          });
        }
      }
    } else {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _dateTime,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _dateTime = value;
                  _dateController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
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
    if (!bmiPass) {
      return Column(
        children: <Widget>[
          const Divider(),
          const Text(
            'Height to nearest 1/2 in.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 72,
                  height: 42,
                  child: PlatformButton(
                    onPressed: () {
                      if (!(heightDouble == (height.toDouble() - 0.5))) {
                        setState(() {
                          heightDouble = heightDouble! - 0.5;
                          _heightDoubleController.text =
                              heightDouble.toString();
                        });
                        calcBf();
                      }
                    },
                    child: const Text('- 0.5'),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: TextField(
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
                  width: 72,
                  height: 42,
                  child: PlatformButton(
                    child: const Text('+ 0.5'),
                    onPressed: () {
                      if (!(heightDouble == (height.toDouble() + 0.5))) {
                        setState(() {
                          heightDouble = heightDouble! + 0.5;
                          _heightDoubleController.text =
                              heightDouble.toString();
                        });
                        calcBf();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          GridView.count(
              primary: false,
              crossAxisCount: width > 700 ? 2 : 1,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              childAspectRatio: width > 900
                  ? 900 / 200
                  : width > 700
                      ? width / 200
                      : width / 100,
              shrinkWrap: true,
              children: tapes())
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  List<Widget> tapes() {
    List<Widget> tapes = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _neckController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: true,
          decoration: const InputDecoration(
            labelText: 'Neck',
          ),
          onChanged: (value) {
            calcBf();
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _waistController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: true,
          decoration: const InputDecoration(
            labelText: 'Waist',
          ),
          onChanged: (value) {
            calcBf();
          },
        ),
      ),
    ];
    if (_gender == 'Female') {
      tapes.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _hipController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Hip',
            ),
            onChanged: (value) {
              calcBf();
            },
          ),
        ),
      );
    }
    tapes.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
            controller: _percentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Bodyfat Percent',
            )),
      ),
    );
    tapes.add(CheckboxListTile(
      title: const Text('Pass Bodyfat'),
      controlAffinity: ListTileControlAffinity.leading,
      value: bfPass,
      onChanged: (value) {
        setState(() {
          bfPass = value!;
        });
      },
    ));
    return tapes;
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      DocumentSnapshot doc =
          soldiers!.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
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

      if (widget.bodyfat.id == null) {
        DocumentReference docRef =
            await firestore.collection('bodyfatStats').add(saveBodyfat.toMap());

        saveBodyfat.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('bodyfatStats')
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('bodyfatStats')
          .where('users', arrayContains: userId)
          .get();
      if (apfts.docs.isNotEmpty) {
        for (var doc in apfts.docs) {
          lessSoldiers!
              .removeWhere((soldierDoc) => soldierDoc.id == doc['soldierId']);
        }
      }
    }
    if (lessSoldiers!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All Soldiers have been added')));
      }
    }

    setState(() {
      if (checked! && lessSoldiers!.isNotEmpty) {
        _soldierId = null;
        removeSoldiers = true;
      } else {
        _soldierId = null;
        removeSoldiers = false;
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    return PlatformScaffold(
        title: _title,
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onWillPop: updated
                ? () => onBackPressed(context)
                : () => Future(() => true),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width > 932 ? (width - 916) / 2 : 16),
              child: Card(
                child: Container(
                    padding: const EdgeInsets.all(16.0),
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          if (user.isAnonymous) const AnonWarningBanner(),
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
                                child: FutureBuilder(
                                    future: firestore
                                        .collection('soldiers')
                                        .where('users', arrayContains: user.uid)
                                        .get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        default:
                                          allSoldiers = snapshot.data!.docs;
                                          soldiers = removeSoldiers
                                              ? lessSoldiers
                                              : allSoldiers;
                                          soldiers!.sort((a, b) => a['lastName']
                                              .toString()
                                              .compareTo(
                                                  b['lastName'].toString()));
                                          soldiers!.sort((a, b) => a['rankSort']
                                              .toString()
                                              .compareTo(
                                                  b['rankSort'].toString()));
                                          return PlatformItemPicker(
                                            label: const Text('Soldier'),
                                            items: soldiers!
                                                .map((e) => e.id)
                                                .toList(),
                                            onChanged: (value) {
                                              int index = soldiers!.indexWhere(
                                                  (doc) => doc.id == value);
                                              if (mounted) {
                                                setState(() {
                                                  _soldierId = value;
                                                  _rank =
                                                      soldiers![index]['rank'];
                                                  _lastName = soldiers![index]
                                                      ['lastName'];
                                                  _firstName = soldiers![index]
                                                      ['firstName'];
                                                  _section = soldiers![index]
                                                      ['section'];
                                                  _rankSort = soldiers![index]
                                                          ['rankSort']
                                                      .toString();
                                                  _owner =
                                                      soldiers![index]['owner'];
                                                  _users =
                                                      soldiers![index]['users'];
                                                  updated = true;
                                                });
                                              }
                                            },
                                            value: _soldierId,
                                          );
                                      }
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 16.0, 8.0, 8.0),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: removeSoldiers,
                                  title: const Text(
                                      'Remove Soldiers already added'),
                                  onChanged: (checked) {
                                    _removeSoldiers(checked, user.uid);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _dateController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      isValidDate(value!) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickDate(context);
                                          })),
                                  onChanged: (value) {
                                    _dateTime =
                                        DateTime.tryParse(value) ?? _dateTime;
                                    updated = true;
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 150,
                                    child: RadioListTile(
                                      title: const Text('M'),
                                      value: 'Male',
                                      groupValue: _gender,
                                      onChanged: (dynamic gender) {
                                        _gender = gender;
                                        calcBmi();
                                        calcBf();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: RadioListTile(
                                      title: const Text('F'),
                                      value: 'Female',
                                      groupValue: _gender,
                                      onChanged: (dynamic gender) {
                                        _gender = gender;
                                        calcBmi();
                                        calcBf();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Age',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                    calcBmi();
                                    calcBf();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _heightController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Height',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                    height = int.tryParse(value) ?? 0;
                                    heightDouble = height.toDouble();
                                    _heightDoubleController.text =
                                        heightDouble.toString();
                                    calcBmi();
                                    calcBf();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                    calcBmi();
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
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
                          underweight
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Soldier is Under Weight',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : const SizedBox(),
                          _buildTape(width),
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
                    )),
              ),
            )));
  }
}
