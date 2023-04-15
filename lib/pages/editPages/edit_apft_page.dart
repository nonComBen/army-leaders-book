import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../methods/theme_methods.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_selection_widget.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';
import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/apft.dart';
import '../../calculators/pu_calculator.dart';
import '../../calculators/su_calculator.dart';
import '../../calculators/run_calculator.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditApftPage extends ConsumerStatefulWidget {
  const EditApftPage({
    Key? key,
    required this.apft,
  }) : super(key: key);
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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
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
    final form = _formKey.currentState!;
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
    if (validateAndSave()) {
      DocumentSnapshot doc =
          soldiers!.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
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
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('apftStats')
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
        toast.showToast(
          child: const MyToast(
            message: 'All Soldiers have been added',
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    toast.context = context;
    return PlatformScaffold(
      title: _title,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onWillPop:
            updated ? () => onBackPressed(context) : () => Future(() => true),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width > 932 ? (width - 916) / 2 : 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                if (user.isAnonymous) const AnonWarningBanner(),
                GridView.count(
                  padding: const EdgeInsets.all(0),
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
                                    child: CircularProgressIndicator());
                              default:
                                allSoldiers = snapshot.data!.docs;
                                soldiers =
                                    removeSoldiers ? lessSoldiers : allSoldiers;
                                soldiers!.sort((a, b) => a['lastName']
                                    .toString()
                                    .compareTo(b['lastName'].toString()));
                                soldiers!.sort((a, b) => a['rankSort']
                                    .toString()
                                    .compareTo(b['rankSort'].toString()));
                                return PlatformItemPicker(
                                  label: Text(
                                    'Soldier',
                                    style:
                                        TextStyle(color: getTextColor(context)),
                                  ),
                                  items: soldiers!.map((e) => e.id).toList(),
                                  onChanged: (value) {
                                    int index = soldiers!
                                        .indexWhere((doc) => doc.id == value);
                                    if (mounted) {
                                      setState(() {
                                        _soldierId = value;
                                        _rank = soldiers![index]['rank'];
                                        _lastName =
                                            soldiers![index]['lastName'];
                                        _firstName =
                                            soldiers![index]['firstName'];
                                        _section = soldiers![index]['section'];
                                        _rankSort = soldiers![index]['rankSort']
                                            .toString();
                                        _owner = soldiers![index]['owner'];
                                        _users = soldiers![index]['users'];
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
                      child: PlatformCheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: removeSoldiers,
                        title: const Text('Remove Soldiers already added'),
                        onChanged: (checked) {
                          _removeSoldiers(checked, user.uid);
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
                      padding: const EdgeInsets.all(8.0),
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
                        subtitle:
                            const Text('Type "00" in PU/SU Raw if Profile'),
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
                    Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                        child: HeaderText(
                          'Pushup',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: getTextColor(context),
                          ),
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
                    Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                        child: HeaderText(
                          'Situp',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: getTextColor(context),
                          ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(context),
                        ),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
                      child: HeaderText(
                        'Total',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: getTextColor(context),
                        ),
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.all(8.0), child: SizedBox()),
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
                  child:
                      Text(widget.apft.id == null ? 'Add APFT' : 'Update APFT'),
                  onPressed: () => submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
