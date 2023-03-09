// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/apft.dart';
import '../../calculators/pu_calculator.dart';
import '../../calculators/su_calculator.dart';
import '../../calculators/run_calculator.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditApftPage extends StatefulWidget {
  const EditApftPage({
    Key key,
    @required this.apft,
  }) : super(key: key);
  final Apft apft;

  @override
  EditApftPageState createState() => EditApftPageState();
}

class EditApftPageState extends State<EditApftPage> {
  String _title = 'New APFT';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _dateController;
  TextEditingController _puController;
  TextEditingController _suController;
  TextEditingController _runController;
  TextEditingController _puRawController;
  TextEditingController _suRawController;
  TextEditingController _runRawController;
  TextEditingController _ageController;
  String _runType,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _gender,
      _owner;
  List<dynamic> _users;
  int _total, _puScore, _suScore, _runScore;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool pass, removeSoldiers, updated, forProPoints, puPass, suPass, runPass;
  List<String> _runTypes;
  DateTime _dateTime;
  RegExp regExp;

  PuCalculator puCalculator = PuCalculator();
  SuCalculator suCalculator = SuCalculator();
  RunCalculator runCalculator = RunCalculator();

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

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
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
      _puScore =
          puCalculator.getPuScore(_gender == 'Male', ageGroupIndex(), puRaw);
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
      _suScore = suCalculator.getSuScore(ageGroupIndex(), suRaw);
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
            _gender == 'Male', ageGroupIndex(), runRaw, _runType)) {
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
      _runScore =
          runCalculator.getRunScore(_gender == 'Male', ageGroupIndex(), runRaw);
      if (_runScore < 60) {
        runPass = false;
      } else {
        runPass = true;
      }
    }
    _runController.text = _runScore.toString();
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      DocumentSnapshot doc =
          soldiers.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      int age = int.tryParse(_ageController.text.trim() ?? 0);
      Apft saveApft = Apft(
        id: widget.apft.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
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
        DocumentReference docRef =
            await firestore.collection('apftStats').add(saveApft.toMap());

        saveApft.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('apftStats')
            .doc(widget.apft.id)
            .set(saveApft.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating APFT');
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
          .collection('apftStats')
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

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    _runTypes = [];
    _runTypes.add('Run');
    _runTypes.add('Walk');
    _runTypes.add('Bike');
    _runTypes.add('Swim');

    _runType = widget.apft.altEvent;

    if (widget.apft.id != null) {
      _title = '${widget.apft.rank} ${widget.apft.name}';
    }

    _gender = widget.apft.gender ?? 'Male';

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

    _dateController = TextEditingController(text: widget.apft.date);
    _puController = TextEditingController(text: _puScore.toString());
    _suController = TextEditingController(text: _suScore.toString());
    _runController = TextEditingController(text: _runScore.toString());
    _puRawController = TextEditingController(text: widget.apft.puRaw);
    _suRawController = TextEditingController(text: widget.apft.suRaw);
    _runRawController = TextEditingController(text: widget.apft.runRaw);
    _ageController = TextEditingController(text: widget.apft.age.toString());

    pass = widget.apft.pass;
    puPass = true;
    suPass = true;
    runPass = true;
    removeSoldiers = false;
    updated = false;
    forProPoints = false;

    _dateTime = DateTime.tryParse(widget.apft.date) ?? DateTime.now();
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
                    constraints: const BoxConstraints(maxWidth: 900),
                    padding: const EdgeInsets.all(16.0),
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
                                padding: const EdgeInsets.all(8.0),
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
                              Container(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(
                                    width: 150,
                                    child: RadioListTile(
                                      title: const Text('M'),
                                      value: 'Male',
                                      groupValue: _gender,
                                      onChanged: (gender) {
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
                                  SizedBox(
                                    width: 150,
                                    child: RadioListTile(
                                      title: const Text('F'),
                                      value: 'Female',
                                      groupValue: _gender,
                                      onChanged: (gender) {
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
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 15.0, 8.0, 0.0),
                                child: TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Aerobic Event'),
                                  items: _runTypes.map((type) {
                                    return DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(fontSize: 18),
                                        ));
                                  }).toList(),
                                  onChanged: (value) {
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
                                child: CheckboxListTile(
                                  value: forProPoints,
                                  title: const Text('For Promotion Points'),
                                  subtitle: const Text(
                                      'Type "00" in PU/SU Raw if Profile'),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (forPoints) {
                                    setState(() {
                                      updated = true;
                                      forProPoints = forPoints;
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
                            childAspectRatio:
                                width > 900 ? 900 / 300 : width / 300.0,
                            shrinkWrap: true,
                            children: <Widget>[
                              const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                                  child: Text(
                                    'Pushup',
                                    style: TextStyle(fontSize: 18),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _puRawController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _puController,
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Score',
                                  ),
                                ),
                              ),
                              const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                                  child: Text(
                                    'Situp',
                                    style: TextStyle(fontSize: 18),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _suRawController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _suController,
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Score',
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 24.0, 8.0, 0.0),
                                  child: Text(
                                    _runType,
                                    style: const TextStyle(fontSize: 18),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _runRawController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _runController,
                                  keyboardType: TextInputType.number,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Score',
                                  ),
                                ),
                              ),
                              const Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
                                  child: Text(
                                    'Total',
                                    style: TextStyle(fontSize: 18),
                                  )),
                              const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox()),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 2.0,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0))),
                                  child: Center(
                                    child: Text(
                                      _total.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CheckboxListTile(
                                title: const Text('Pass'),
                                value: pass,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  setState(() {
                                    updated = true;
                                    pass = value;
                                  });
                                },
                              )),
                          FormattedElevatedButton(
                            text: widget.apft.id == null
                                ? 'Add APFT'
                                : 'Update APFT',
                            onPressed: () => submit(context),
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
