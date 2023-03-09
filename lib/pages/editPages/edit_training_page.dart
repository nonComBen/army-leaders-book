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
import '../../models/training.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditTrainingPage extends StatefulWidget {
  const EditTrainingPage({
    Key key,
    @required this.training,
  }) : super(key: key);
  final Training training;

  @override
  EditTrainingPageState createState() => EditTrainingPageState();
}

class EditTrainingPageState extends State<EditTrainingPage> {
  String _title = 'New Training';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _cyberController;
  TextEditingController _opsecController;
  TextEditingController _antiTerrorController;
  TextEditingController _lawController;
  TextEditingController _persRecController;
  TextEditingController _infoSecController;
  TextEditingController _ctipController;
  TextEditingController _gatController;
  TextEditingController _sereController;
  TextEditingController _tarpController;
  TextEditingController _eoController;
  TextEditingController _asapController;
  TextEditingController _suicideController;
  TextEditingController _sharpController;
  TextEditingController _add1Controller;
  TextEditingController _add1DateController;
  TextEditingController _add2Controller;
  TextEditingController _add2DateController;
  TextEditingController _add3Controller;
  TextEditingController _add3DateController;
  TextEditingController _add4Controller;
  TextEditingController _add4DateController;
  TextEditingController _add5Controller;
  TextEditingController _add5DateController;
  String _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic> _users;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers, updated;
  bool addMore;
  String addMoreLess;

  DateTime _cyberDate,
      _opsecDate,
      _antiTerrorDate,
      _lawDate,
      _persRecDate,
      _infoSecDate,
      _ctipDate,
      _gatDate,
      _sereDate,
      _tarpDate,
      _eoDate,
      _asapDate,
      _suicideDate,
      _sharpDate,
      _add1Date,
      _add2Date,
      _add3Date,
      _add4Date,
      _add5Date;
  RegExp regExp;

  Future<void> _pickCyber(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _cyberDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _cyberDate = picked;
            _cyberController.text = formatter.format(picked);
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
                initialDateTime: _cyberDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _cyberDate = value;
                  _cyberController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickOpsec(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _opsecDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _opsecDate = picked;
            _opsecController.text = formatter.format(picked);
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
                initialDateTime: _opsecDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _opsecDate = value;
                  _opsecController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAntiTerror(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _antiTerrorDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _antiTerrorDate = picked;
            _antiTerrorController.text = formatter.format(picked);
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
                initialDateTime: _antiTerrorDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _antiTerrorDate = value;
                  _antiTerrorController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickLaw(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _lawDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _lawDate = picked;
            _lawController.text = formatter.format(picked);
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
                initialDateTime: _lawDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _lawDate = value;
                  _lawController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickPersRec(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _persRecDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _persRecDate = picked;
            _persRecController.text = formatter.format(picked);
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
                initialDateTime: _persRecDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _persRecDate = value;
                  _persRecController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickInfoSec(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _infoSecDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _infoSecDate = picked;
            _infoSecController.text = formatter.format(picked);
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
                initialDateTime: _infoSecDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _infoSecDate = value;
                  _infoSecController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickCtip(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _ctipDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _ctipDate = picked;
            _ctipController.text = formatter.format(picked);
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
                initialDateTime: _ctipDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _ctipDate = value;
                  _ctipController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickGat(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _gatDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _gatDate = picked;
            _gatController.text = formatter.format(picked);
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
                initialDateTime: _gatDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _gatDate = value;
                  _gatController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickSere(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _sereDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _sereDate = picked;
            _sereController.text = formatter.format(picked);
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
                initialDateTime: _sereDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _sereDate = value;
                  _sereController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickTarp(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _tarpDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _tarpDate = picked;
            _tarpController.text = formatter.format(picked);
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
                initialDateTime: _tarpDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _tarpDate = value;
                  _tarpController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickEo(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _eoDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _eoDate = picked;
            _eoController.text = formatter.format(picked);
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
                initialDateTime: _eoDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _eoDate = value;
                  _eoController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAsap(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _asapDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _asapDate = picked;
            _asapController.text = formatter.format(picked);
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
                initialDateTime: _asapDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _asapDate = value;
                  _asapController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickSuicide(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _suicideDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _suicideDate = picked;
            _suicideController.text = formatter.format(picked);
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
                initialDateTime: _suicideDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _suicideDate = value;
                  _suicideController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickSharp(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _sharpDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _sharpDate = picked;
            _sharpController.text = formatter.format(picked);
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
                initialDateTime: _sharpDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _sharpDate = value;
                  _sharpController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAdd1(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _add1Date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _add1Date = picked;
            _add1DateController.text = formatter.format(picked);
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
                initialDateTime: _add1Date,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _add1Date = value;
                  _add1DateController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAdd2(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _add2Date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _add2Date = picked;
            _add2DateController.text = formatter.format(picked);
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
                initialDateTime: _add2Date,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _add2Date = value;
                  _add2DateController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAdd3(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _add3Date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _add3Date = picked;
            _add3DateController.text = formatter.format(picked);
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
                initialDateTime: _add3Date,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _add3Date = value;
                  _add3DateController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAdd4(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _add4Date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _add4Date = picked;
            _add4DateController.text = formatter.format(picked);
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
                initialDateTime: _add4Date,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _add4Date = value;
                  _add4DateController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAdd5(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _add5Date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _add5Date = picked;
            _add5DateController.text = formatter.format(picked);
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
                initialDateTime: _add5Date,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _add5Date = value;
                  _add5DateController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
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
      Training saveTraining = Training(
        id: widget.training.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        cyber: _cyberController.text,
        opsec: _opsecController.text,
        antiTerror: _antiTerrorController.text,
        lawOfWar: _lawController.text,
        persRec: _persRecController.text,
        infoSec: _infoSecController.text,
        ctip: _ctipController.text,
        gat: _gatController.text,
        sere: _sereController.text,
        tarp: _tarpController.text,
        eo: _eoController.text,
        asap: _asapController.text,
        suicide: _suicideController.text,
        sharp: _sharpController.text,
        add1: _add1Controller.text,
        add1Date: _add1DateController.text,
        add2: _add2Controller.text,
        add2Date: _add2DateController.text,
        add3: _add3Controller.text,
        add3Date: _add3DateController.text,
        add4: _add4Controller.text,
        add4Date: _add4DateController.text,
        add5: _add5Controller.text,
        add5Date: _add5DateController.text,
      );

      if (widget.training.id == null) {
        DocumentReference docRef =
            await firestore.collection('training').add(saveTraining.toMap());

        saveTraining.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('training')
            .doc(widget.training.id)
            .set(saveTraining.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Perstat');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  Widget addMoreTraining(double width) {
    if (addMore) {
      return GridView.count(
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
            child: TextFormField(
                controller: _add1Controller,
                keyboardType: TextInputType.text,
                enabled: true,
                decoration: const InputDecoration(
                  labelText: 'Additional Training 1',
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add1DateController,
                keyboardType: TextInputType.datetime,
                enabled: true,
                validator: (value) => regExp.hasMatch(value) || value.isEmpty
                    ? null
                    : 'Date must be in yyyy-MM-dd format',
                decoration: InputDecoration(
                    labelText: 'Additional Training 1 Date',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () {
                          _pickAdd1(context);
                        }))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add2Controller,
                keyboardType: TextInputType.text,
                enabled: true,
                decoration: const InputDecoration(
                  labelText: 'Additional Training 2',
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add2DateController,
                keyboardType: TextInputType.datetime,
                enabled: true,
                validator: (value) => regExp.hasMatch(value) || value.isEmpty
                    ? null
                    : 'Date must be in yyyy-MM-dd format',
                decoration: InputDecoration(
                    labelText: 'Additional Training 2 Date',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () {
                          _pickAdd2(context);
                        }))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add3Controller,
                keyboardType: TextInputType.text,
                enabled: true,
                decoration: const InputDecoration(
                  labelText: 'Additional Training 3',
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add3DateController,
                keyboardType: TextInputType.datetime,
                enabled: true,
                validator: (value) => regExp.hasMatch(value) || value.isEmpty
                    ? null
                    : 'Date must be in yyyy-MM-dd format',
                decoration: InputDecoration(
                    labelText: 'Additional Training 3 Date',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () {
                          _pickAdd3(context);
                        }))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add4Controller,
                keyboardType: TextInputType.text,
                enabled: true,
                decoration: const InputDecoration(
                  labelText: 'Additional Training 4',
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add4DateController,
                keyboardType: TextInputType.datetime,
                enabled: true,
                validator: (value) => regExp.hasMatch(value) || value.isEmpty
                    ? null
                    : 'Date must be in yyyy-MM-dd format',
                decoration: InputDecoration(
                    labelText: 'Additional Training 4 Date',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () {
                          _pickAdd4(context);
                        }))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add5Controller,
                keyboardType: TextInputType.text,
                enabled: true,
                decoration: const InputDecoration(
                  labelText: 'Additional Training 5',
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                controller: _add5DateController,
                keyboardType: TextInputType.datetime,
                enabled: true,
                validator: (value) => regExp.hasMatch(value) || value.isEmpty
                    ? null
                    : 'Date must be in yyyy-MM-dd format',
                decoration: InputDecoration(
                    labelText: 'Additional Training 5 Date',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () {
                          _pickAdd5(context);
                        }))),
          ),
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  void _removeSoldiers(bool checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('training')
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
    _cyberController.dispose();
    _opsecController.dispose();
    _antiTerrorController.dispose();
    _lawController.dispose();
    _persRecController.dispose();
    _infoSecController.dispose();
    _ctipController.dispose();
    _gatController.dispose();
    _sereController.dispose();
    _tarpController.dispose();
    _eoController.dispose();
    _asapController.dispose();
    _suicideController.dispose();
    _sharpController.dispose();
    _add1Controller.dispose();
    _add1DateController.dispose();
    _add2Controller.dispose();
    _add2DateController.dispose();
    _add3Controller.dispose();
    _add3DateController.dispose();
    _add4Controller.dispose();
    _add4DateController.dispose();
    _add5Controller.dispose();
    _add5DateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    if (widget.training.id != null) {
      _title = '${widget.training.rank} ${widget.training.name}';
    }

    _soldierId = widget.training.soldierId;
    _rank = widget.training.rank;
    _lastName = widget.training.name;
    _firstName = widget.training.firstName;
    _section = widget.training.section;
    _rankSort = widget.training.rankSort;
    _owner = widget.training.owner;
    _users = widget.training.users;

    _cyberController = TextEditingController(text: widget.training.cyber);
    _opsecController = TextEditingController(text: widget.training.opsec);
    _antiTerrorController =
        TextEditingController(text: widget.training.antiTerror);
    _lawController = TextEditingController(text: widget.training.lawOfWar);
    _persRecController = TextEditingController(text: widget.training.persRec);
    _infoSecController = TextEditingController(text: widget.training.infoSec);
    _ctipController = TextEditingController(text: widget.training.ctip);
    _gatController = TextEditingController(text: widget.training.gat);
    _sereController = TextEditingController(text: widget.training.sere);
    _tarpController = TextEditingController(text: widget.training.tarp);
    _eoController = TextEditingController(text: widget.training.eo);
    _asapController = TextEditingController(text: widget.training.asap);
    _suicideController = TextEditingController(text: widget.training.suicide);
    _sharpController = TextEditingController(text: widget.training.sharp);
    _add1Controller = TextEditingController(text: widget.training.add1);
    _add1DateController = TextEditingController(text: widget.training.add1Date);
    _add2Controller = TextEditingController(text: widget.training.add2);
    _add2DateController = TextEditingController(text: widget.training.add2Date);
    _add3Controller = TextEditingController(text: widget.training.add3);
    _add3DateController = TextEditingController(text: widget.training.add3Date);
    _add4Controller = TextEditingController(text: widget.training.add4);
    _add4DateController = TextEditingController(text: widget.training.add4Date);
    _add5Controller = TextEditingController(text: widget.training.add5);
    _add5DateController = TextEditingController(text: widget.training.add5Date);

    removeSoldiers = false;
    addMore = false;
    updated = false;

    if (_add1DateController.text != '' ||
        _add2DateController.text != '' ||
        _add3DateController.text != '' ||
        _add4DateController.text != '' ||
        _add5DateController.text != '') {
      addMore = true;
    }
    if (addMore) {
      addMoreLess = 'Less Training';
    } else {
      addMoreLess = 'More Training';
    }

    _cyberDate = DateTime.tryParse(widget.training.cyber) ?? DateTime.now();
    _opsecDate = DateTime.tryParse(widget.training.opsec) ?? DateTime.now();
    _antiTerrorDate =
        DateTime.tryParse(widget.training.antiTerror) ?? DateTime.now();
    _lawDate = DateTime.tryParse(widget.training.lawOfWar) ?? DateTime.now();
    _persRecDate = DateTime.tryParse(widget.training.persRec) ?? DateTime.now();
    _infoSecDate = DateTime.tryParse(widget.training.infoSec) ?? DateTime.now();
    _ctipDate = DateTime.tryParse(widget.training.ctip) ?? DateTime.now();
    _gatDate = DateTime.tryParse(widget.training.gat) ?? DateTime.now();
    _sereDate = DateTime.tryParse(widget.training.sere) ?? DateTime.now();
    _tarpDate = DateTime.tryParse(widget.training.tarp) ?? DateTime.now();
    _eoDate = DateTime.tryParse(widget.training.eo) ?? DateTime.now();
    _asapDate = DateTime.tryParse(widget.training.asap) ?? DateTime.now();
    _sharpDate = DateTime.tryParse(widget.training.sharp) ?? DateTime.now();
    _suicideDate = DateTime.tryParse(widget.training.suicide) ?? DateTime.now();
    _add1Date = DateTime.tryParse(widget.training.add1Date) ?? DateTime.now();
    _add2Date = DateTime.tryParse(widget.training.add2Date) ?? DateTime.now();
    _add3Date = DateTime.tryParse(widget.training.add3Date) ?? DateTime.now();
    _add4Date = DateTime.tryParse(widget.training.add4Date) ?? DateTime.now();
    _add5Date = DateTime.tryParse(widget.training.add5Date) ?? DateTime.now();

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
                                  controller: _cyberController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Cyber Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickCyber(context);
                                          })),
                                  onChanged: (value) {
                                    _cyberDate =
                                        DateTime.tryParse(value) ?? _cyberDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _opsecController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'OPSEC Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickOpsec(context);
                                          })),
                                  onChanged: (value) {
                                    _opsecDate =
                                        DateTime.tryParse(value) ?? _opsecDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _antiTerrorController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Anti-Terror Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickAntiTerror(context);
                                          })),
                                  onChanged: (value) {
                                    _antiTerrorDate =
                                        DateTime.tryParse(value) ??
                                            _antiTerrorDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _lawController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Law of War Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickLaw(context);
                                          })),
                                  onChanged: (value) {
                                    _lawDate =
                                        DateTime.tryParse(value) ?? _lawDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _persRecController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Personnel Recovery Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickPersRec(context);
                                          })),
                                  onChanged: (value) {
                                    _persRecDate = DateTime.tryParse(value) ??
                                        _persRecDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _infoSecController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Info Security Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickInfoSec(context);
                                          })),
                                  onChanged: (value) {
                                    _infoSecDate = DateTime.tryParse(value) ??
                                        _infoSecDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _ctipController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'CTIP Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickCtip(context);
                                          })),
                                  onChanged: (value) {
                                    _ctipDate =
                                        DateTime.tryParse(value) ?? _ctipDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _gatController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'GAT Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickGat(context);
                                          })),
                                  onChanged: (value) {
                                    _gatDate =
                                        DateTime.tryParse(value) ?? _gatDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _sereController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'SERE Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickSere(context);
                                          })),
                                  onChanged: (value) {
                                    _sereDate =
                                        DateTime.tryParse(value) ?? _sereDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _tarpController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'TARP Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickTarp(context);
                                          })),
                                  onChanged: (value) {
                                    _tarpDate =
                                        DateTime.tryParse(value) ?? _tarpDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _eoController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'EO Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickEo(context);
                                          })),
                                  onChanged: (value) {
                                    _eoDate =
                                        DateTime.tryParse(value) ?? _eoDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _asapController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'ASAP Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickAsap(context);
                                          })),
                                  onChanged: (value) {
                                    _asapDate =
                                        DateTime.tryParse(value) ?? _asapDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _suicideController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Suicide Prev Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickSuicide(context);
                                          })),
                                  onChanged: (value) {
                                    _suicideDate = DateTime.tryParse(value) ??
                                        _suicideDate;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _sharpController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'SHARP Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickSharp(context);
                                          })),
                                  onChanged: (value) {
                                    _sharpDate =
                                        DateTime.tryParse(value) ?? _sharpDate;
                                    updated = true;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FormattedElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    addMore = !addMore;
                                    if (addMore) {
                                      addMoreLess = 'Less Training';
                                    } else {
                                      addMoreLess = 'More Training';
                                    }
                                  });
                                }
                              },
                              text: addMoreLess,
                            ),
                          ),
                          addMoreTraining(width),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FormattedElevatedButton(
                              onPressed: () {
                                submit(context);
                              },
                              text: widget.training.id == null
                                  ? 'Add Training'
                                  : 'Update Training',
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
