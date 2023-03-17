import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../calculators/twomr_calculator.dart';
import '../../calculators/plk_calculator.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/validate.dart';
import '../../models/acft.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';
import '../../calculators/hrp_calculator.dart';
import '../../calculators/mdl_calculator.dart';
import '../../calculators/sdc_calculator.dart';
import '../../calculators/spt_calculator.dart';

class EditAcftPage extends StatefulWidget {
  const EditAcftPage({
    Key? key,
    required this.acft,
  }) : super(key: key);
  final Acft acft;

  @override
  EditAcftPageState createState() => EditAcftPageState();
}

class EditAcftPageState extends State<EditAcftPage> {
  String _title = 'New ACFT';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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
  String? _ageGroup,
      _gender,
      _runType,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
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

  List<String?> ageGroups = [
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

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _dateTime!,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
      );

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dateTime = picked;
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
        ageGroup: _ageGroup!,
        gender: _gender!,
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
        altEvent: _runType!,
        pass: pass,
      );

      if (widget.acft.id == null) {
        await firestore.collection('acftStats').add(saveAcft.toMap());

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('acftStats')
            .doc(widget.acft.id)
            .set(saveAcft.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating ACFT');
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
          .collection('acftStats')
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
    _sptRaw = int.tryParse(widget.acft.powerThrowRaw) as double? ?? 0;
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context)!.auth!.currentUser()!;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onWillPop:
            updated ? () => onBackPressed(context) : () => Future(() => true),
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
                                        child: CircularProgressIndicator());
                                  default:
                                    allSoldiers = snapshot.data!.docs;
                                    soldiers = removeSoldiers
                                        ? lessSoldiers
                                        : allSoldiers;
                                    soldiers!.sort((a, b) => a['lastName']
                                        .toString()
                                        .compareTo(b['lastName'].toString()));
                                    soldiers!.sort((a, b) => a['rankSort']
                                        .toString()
                                        .compareTo(b['rankSort'].toString()));
                                    return DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                          labelText: 'Soldier'),
                                      items: soldiers!.map((doc) {
                                        return DropdownMenuItem<String>(
                                          value: doc.id,
                                          child: Text(
                                              '${doc['rank']} ${doc['lastName']}, ${doc['firstName']}'),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        int index = soldiers!.indexWhere(
                                            (doc) => doc.id == value);
                                        if (mounted) {
                                          setState(() {
                                            _soldierId = value;
                                            _rank = soldiers![index]['rank'];
                                            _lastName =
                                                soldiers![index]['lastName'];
                                            _firstName =
                                                soldiers![index]['firstName'];
                                            _section =
                                                soldiers![index]['section'];
                                            _rankSort = soldiers![index]
                                                    ['rankSort']
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
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: removeSoldiers,
                            title: const Text('Remove Soldiers already added'),
                            onChanged: (checked) {
                              _removeSoldiers(checked, user.uid);
                            },
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 0.0),
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
                                },
                              ),
                            ),
                            onChanged: (value) {
                              _dateTime = DateTime.tryParse(value) ?? _dateTime;
                              updated = true;
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: RadioListTile(
                                title: const Text('M'),
                                value: 'Male',
                                groupValue: _gender,
                                activeColor: Theme.of(context).primaryColor,
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
                            Flexible(
                              flex: 1,
                              child: RadioListTile(
                                title: const Text('F'),
                                value: 'Female',
                                groupValue: _gender,
                                activeColor: Theme.of(context).primaryColor,
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
                                    calcRunScore();
                                    calcTotal();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField(
                            value: _ageGroup,
                            decoration:
                                const InputDecoration(labelText: 'Age Group'),
                            items: ageGroups.map((age) {
                              return DropdownMenuItem(
                                value: age,
                                child: Text(age!),
                              );
                            }).toList(),
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
                      childAspectRatio: width > 900 ? 900 / 300 : width / 300.0,
                      shrinkWrap: true,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                            child: Text(
                              'MDL',
                              style: TextStyle(fontSize: 18),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _deadliftRawController,
                            keyboardType: TextInputType.number,
                            enabled: true,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _deadliftController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                            child: Text(
                              'SPT',
                              style: TextStyle(fontSize: 18),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _powerThrowRawController,
                            keyboardType: TextInputType.text,
                            enabled: true,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _powerThrowController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                          child: Text(
                            'HRP',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
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
                                _hrpRaw = int.tryParse(value) ?? 0;
                                calcHrp();
                                calcTotal();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _puController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                            child: Text(
                              'SDC',
                              style: TextStyle(fontSize: 18),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _dragRawController,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Raw',
                            ),
                            onChanged: (value) {
                              String mins = value.contains(':')
                                  ? value.substring(0, value.indexOf(':'))
                                  : '5';
                              _sdcMins = int.tryParse(mins) ?? 5;
                              String secs =
                                  value.substring(value.indexOf(':') + 1);
                              _sdcSecs = int.tryParse(secs) ?? 0;
                              setState(() {
                                updated = true;
                                calcSdc();
                                calcTotal();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _dragController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                          child: Text(
                            'PLK',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _plankRawController,
                            keyboardType: TextInputType.text,
                            enabled: true,
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
                                String secs =
                                    value.substring(value.indexOf(':') + 1);
                                _plkSecs = int.tryParse(secs) ?? 0;
                                calcPlk();
                                calcTotal();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _plankController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                            ),
                          ),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 0.0),
                            child: Text(
                              _runType!,
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
                                String mins = value.contains(':')
                                    ? value.substring(0, value.indexOf(':'))
                                    : '30';
                                _runMins = int.tryParse(mins) ?? 30;
                                String secs =
                                    value.substring(value.indexOf(':') + 1);
                                _runSecs = int.tryParse(secs) ?? 0;
                                calcRunScore();
                                calcTotal();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _runController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 0.0),
                            child: Text(
                              'Total',
                              style: TextStyle(fontSize: 18),
                            )),
                        const Padding(
                            padding: EdgeInsets.all(8.0), child: SizedBox()),
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
                        )
                      ],
                    ),
                    GridView.count(
                      primary: false,
                      crossAxisCount: width > 500 ? 3 : 2,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 300
                          : width > 500
                              ? width / 300
                              : width / 200,
                      shrinkWrap: true,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CheckboxListTile(
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
                    FormattedElevatedButton(
                      text: widget.acft.id == null ? 'Add ACFT' : 'Update ACFT',
                      onPressed: () => submit(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
