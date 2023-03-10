import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/bodyfat.dart';
import '../../calculators/bf_calculator.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditBodyfatPage extends StatefulWidget {
  const EditBodyfatPage({
    Key key,
    @required this.bodyfat,
  }) : super(key: key);
  final Bodyfat bodyfat;

  @override
  EditBodyfatPageState createState() => EditBodyfatPageState();
}

class EditBodyfatPageState extends State<EditBodyfatPage> {
  String _title = 'New Body Composition';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _dateController;
  TextEditingController _heightController;
  TextEditingController _weightController;
  TextEditingController _neckController;
  TextEditingController _waistController;
  TextEditingController _hipController;
  TextEditingController _percentController;
  TextEditingController _ageController;
  TextEditingController _heightDoubleController;
  bool bmiPass, bfPass, removeSoldiers, updated, underweight;
  String _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _gender,
      _owner;
  List<dynamic> _users;
  int height;
  double heightDouble;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  DateTime _dateTime;
  RegExp regExp;
  BfCalculator bfCalculator = BfCalculator();

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _dateTime,
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
    List<int> benchmarks =
        bfCalculator.setBenchmarks(_gender == 'Male', ageGroupIndex(), height);

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

  calcBf() {
    int maxPercent = bfCalculator.percentTable[
        _gender == 'Male' ? ageGroupIndex() : ageGroupIndex() + 4];
    double neck = double.tryParse(_neckController.text) ?? 0;
    double waist = double.tryParse(_waistController.text) ?? 0;
    double hip = double.tryParse(_hipController.text) ?? 0;
    double cirValue = _gender == 'Male' ? waist - neck : hip + waist - neck;

    int bfPercent =
        bfCalculator.getBfPercent(_gender == 'Male', heightDouble, cirValue);
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
                  child: FormattedElevatedButton(
                    onPressed: () {
                      if (!(heightDouble == (height.toDouble() - 0.5))) {
                        setState(() {
                          heightDouble = heightDouble - 0.5;
                          _heightDoubleController.text =
                              heightDouble.toString();
                        });
                        calcBf();
                      }
                    },
                    text: '- 0.5',
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
                  child: FormattedElevatedButton(
                    text: '+ 0.5',
                    onPressed: () {
                      if (!(heightDouble == (height.toDouble() + 0.5))) {
                        setState(() {
                          heightDouble = heightDouble + 0.5;
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
          bfPass = value;
        });
      },
    ));
    return tapes;
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      DocumentSnapshot doc =
          soldiers.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      Bodyfat saveBodyfat = Bodyfat(
        id: widget.bodyfat.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        age: int.tryParse(_ageController.text ?? 0),
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

  void _removeSoldiers(bool checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('bodyfatStats')
          .where('users', arrayContains: userId)
          .get();
      if (apfts.docs.isNotEmpty) {
        for (var doc in apfts.docs) {
          lessSoldiers
              .removeWhere((soldierDoc) => soldierDoc.id == doc['soldierId']);
        }
      }
    }
    if (lessSoldiers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All Soldiers have been added')));
      }
    }

    setState(() {
      if (checked && lessSoldiers.isNotEmpty) {
        _soldierId = null;
        removeSoldiers = true;
      } else {
        _soldierId = null;
        removeSoldiers = false;
      }
    });
  }

  Future<bool> _onBackPressed() {
    if (!updated) return Future.value(true);
    return onBackPressed(context);
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

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    if (widget.bodyfat.id != null) {
      _title = '${widget.bodyfat.rank} ${widget.bodyfat.name}';
    }

    _soldierId = widget.bodyfat.soldierId;
    _rank = widget.bodyfat.rank;
    _lastName = widget.bodyfat.name;
    _firstName = widget.bodyfat.firstName;
    _section = widget.bodyfat.section;
    _rankSort = widget.bodyfat.rankSort;
    _gender = widget.bodyfat.gender ?? 'Male';
    _owner = widget.bodyfat.owner;
    _users = widget.bodyfat.users;

    height = int.tryParse(widget.bodyfat.height) ?? 0;
    if (widget.bodyfat.heightDouble == null ||
        widget.bodyfat.heightDouble == '') {
      heightDouble = height.toDouble();
    } else {
      heightDouble = double.tryParse(widget.bodyfat.heightDouble);
    }

    bmiPass = widget.bodyfat.passBmi;
    bfPass = widget.bodyfat.passBf;
    underweight = false;

    _dateController = TextEditingController(text: widget.bodyfat.date);
    _heightController = TextEditingController(text: widget.bodyfat.height);
    _weightController = TextEditingController(text: widget.bodyfat.weight);
    _neckController = TextEditingController(text: widget.bodyfat.neck);
    _waistController = TextEditingController(text: widget.bodyfat.waist);
    _hipController = TextEditingController(text: widget.bodyfat.hip);
    _percentController = TextEditingController(text: widget.bodyfat.percent);
    _ageController = TextEditingController(text: widget.bodyfat.age.toString());
    _heightDoubleController =
        TextEditingController(text: heightDouble.toString());

    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(widget.bodyfat.date) ?? DateTime.now();
    regExp = RegExp(r'^\d{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onWillPop: _onBackPressed,
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
                                          allSoldiers = snapshot.data.docs;
                                          soldiers = removeSoldiers
                                              ? lessSoldiers
                                              : allSoldiers;
                                          soldiers.sort((a, b) => a['lastName']
                                              .toString()
                                              .compareTo(
                                                  b['lastName'].toString()));
                                          soldiers.sort((a, b) => a['rankSort']
                                              .toString()
                                              .compareTo(
                                                  b['rankSort'].toString()));
                                          return DropdownButtonFormField<
                                              String>(
                                            decoration: const InputDecoration(
                                                labelText: 'Soldier'),
                                            items: soldiers.map((doc) {
                                              return DropdownMenuItem<String>(
                                                value: doc.id,
                                                child: Text(
                                                    '${doc['rank']} ${doc['lastName']}, ${doc['firstName']}'),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              int index = soldiers.indexWhere(
                                                  (doc) => doc.id == value);
                                              if (mounted) {
                                                setState(() {
                                                  _soldierId = value;
                                                  _rank =
                                                      soldiers[index]['rank'];
                                                  _lastName = soldiers[index]
                                                      ['lastName'];
                                                  _firstName = soldiers[index]
                                                      ['firstName'];
                                                  _section = soldiers[index]
                                                      ['section'];
                                                  _rankSort = soldiers[index]
                                                          ['rankSort']
                                                      .toString();
                                                  _owner =
                                                      soldiers[index]['owner'];
                                                  _users =
                                                      soldiers[index]['users'];
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
                                      regExp.hasMatch(value) || value.isEmpty
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
                                      onChanged: (gender) {
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
                                      onChanged: (gender) {
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
                                      bmiPass = value;
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
                          FormattedElevatedButton(
                            onPressed: () {
                              submit(context);
                            },
                            text: widget.bodyfat.id == null
                                ? 'Add Body Comp'
                                : 'Update Body Comp',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
