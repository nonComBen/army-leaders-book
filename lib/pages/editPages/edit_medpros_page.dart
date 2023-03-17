import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/validate.dart';
import '../../models/medpro.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';
import '../../widgets/platform_widgets/platform_text_field.dart';

class EditMedprosPage extends StatefulWidget {
  const EditMedprosPage({
    Key? key,
    required this.medpro,
  }) : super(key: key);
  final Medpro medpro;

  @override
  EditMedprosPageState createState() => EditMedprosPageState();
}

class EditMedprosPageState extends State<EditMedprosPage> {
  String _title = 'New MedPros';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  final TextEditingController _phaController = TextEditingController();
  final TextEditingController _dentalController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _hearingController = TextEditingController();
  final TextEditingController _hivController = TextEditingController();
  final TextEditingController _fluController = TextEditingController();
  final TextEditingController _mmrController = TextEditingController();
  final TextEditingController _varicellaController = TextEditingController();
  final TextEditingController _polioController = TextEditingController();
  final TextEditingController _tuberculinController = TextEditingController();
  final TextEditingController _tetanusController = TextEditingController();
  final TextEditingController _hepAController = TextEditingController();
  final TextEditingController _hepBController = TextEditingController();
  final TextEditingController _encephalitisController = TextEditingController();
  final TextEditingController _meningController = TextEditingController();
  final TextEditingController _typhoidController = TextEditingController();
  final TextEditingController _yellowController = TextEditingController();
  final TextEditingController _smallPoxController = TextEditingController();
  final TextEditingController _anthraxController = TextEditingController();

  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  List<dynamic>? _otherImms;
  bool removeSoldiers = false, updated = false, expanded = false;
  DateTime? _phaDate,
      _dentalDate,
      _visionDate,
      _hearingDate,
      _hivDate,
      _fluDate,
      _mmrDate,
      _varicellaDate,
      _polioDate,
      _tuberDate,
      _tetanusDate,
      _hepADate,
      _hepBDate,
      _encephalitisDate,
      _meningDate,
      _typhoidDate,
      _yellowDate,
      _smallPoxDate,
      _anthraxDate;

  Future<void> _pickPha(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _phaDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _phaDate = picked;
            _phaController.text = formatter.format(picked);
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
                initialDateTime: _phaDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _phaDate = value;
                  _phaController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickDental(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dentalDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dentalDate = picked;
            _dentalController.text = formatter.format(picked);
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
                initialDateTime: _dentalDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _dentalDate = value;
                  _dentalController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickHearing(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _hearingDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        var formatter = DateFormat('yyyy-MM-dd');
        if (mounted) {
          setState(() {
            _hearingDate = picked;
            _hearingController.text = formatter.format(picked);
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
                initialDateTime: _hearingDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _hearingDate = value;
                  _hearingController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickHiv(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _hivDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _hivDate = picked;
            _hivController.text = formatter.format(picked);
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
                initialDateTime: _hivDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _hivDate = value;
                  _hivController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickVision(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _visionDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _visionDate = picked;
            _visionController.text = formatter.format(picked);
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
                initialDateTime: _visionDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _visionDate = value;
                  _visionController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickFlu(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _fluDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _fluDate = picked;
            _fluController.text = formatter.format(picked);
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
                initialDateTime: _fluDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _fluDate = value;
                  _fluController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickMmr(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _mmrDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _mmrDate = picked;
            _mmrController.text = formatter.format(picked);
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
                initialDateTime: _mmrDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _mmrDate = value;
                  _mmrController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickVaricella(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _varicellaDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _varicellaDate = picked;
            _varicellaController.text = formatter.format(picked);
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
                initialDateTime: _varicellaDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _varicellaDate = value;
                  _varicellaController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickPolio(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _polioDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _polioDate = picked;
            _polioController.text = formatter.format(picked);
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
                initialDateTime: _polioDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _polioDate = value;
                  _polioController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickTuberculin(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _tuberDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _tuberDate = picked;
            _tuberculinController.text = formatter.format(picked);
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
                initialDateTime: _tuberDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _tuberDate = value;
                  _tuberculinController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickTetanus(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _tetanusDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _tetanusDate = picked;
            _tetanusController.text = formatter.format(picked);
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
                initialDateTime: _tetanusDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _tetanusDate = value;
                  _tetanusController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickHepA(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _hepADate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _hepADate = picked;
            _hepAController.text = formatter.format(picked);
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
                initialDateTime: _hepADate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _hepADate = value;
                  _hepAController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickHepB(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _hepBDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _hepBDate = picked;
            _hepBController.text = formatter.format(picked);
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
                initialDateTime: _hepBDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _hepBDate = value;
                  _hepBController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickEncephalitis(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _encephalitisDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _encephalitisDate = picked;
            _encephalitisController.text = formatter.format(picked);
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
                initialDateTime: _encephalitisDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _encephalitisDate = value;
                  _encephalitisController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickMening(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _meningDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _meningDate = picked;
            _meningController.text = formatter.format(picked);
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
                initialDateTime: _meningDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _meningDate = value;
                  _meningController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickTyphoid(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _typhoidDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _typhoidDate = picked;
            _typhoidController.text = formatter.format(picked);
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
                initialDateTime: _typhoidDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _typhoidDate = value;
                  _typhoidController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickYellow(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _yellowDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _yellowDate = picked;
            _yellowController.text = formatter.format(picked);
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
                initialDateTime: _yellowDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _yellowDate = value;
                  _yellowController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickSmallPox(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _smallPoxDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _smallPoxDate = picked;
            _smallPoxController.text = formatter.format(picked);
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
                initialDateTime: _smallPoxDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _smallPoxDate = value;
                  _smallPoxController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickAnthrax(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _anthraxDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _anthraxDate = picked;
            _anthraxController.text = formatter.format(picked);
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
                initialDateTime: _anthraxDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _anthraxDate = value;
                  _anthraxController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
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
      Medpro saveMedpros = Medpro(
        id: widget.medpro.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        pha: _phaController.text,
        dental: _dentalController.text,
        vision: _visionController.text,
        hearing: _hearingController.text,
        hiv: _hivController.text,
        flu: _fluController.text,
        anthrax: _anthraxController.text,
        encephalitis: _encephalitisController.text,
        hepA: _hepAController.text,
        hepB: _hepBController.text,
        meningococcal: _meningController.text,
        mmr: _mmrController.text,
        polio: _polioController.text,
        smallPox: _smallPoxController.text,
        tetanus: _tetanusController.text,
        tuberculin: _tuberculinController.text,
        typhoid: _typhoidController.text,
        varicella: _varicellaController.text,
        yellow: _yellowController.text,
        otherImms: _otherImms,
      );

      if (widget.medpro.id == null) {
        DocumentReference docRef =
            await firestore.collection('medpros').add(saveMedpros.toMap());

        saveMedpros.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('medpros')
            .doc(widget.medpro.id)
            .set(saveMedpros.toMap())
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

  Widget moreImmunizations(double width) {
    if (expanded) {
      return Column(children: [
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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _mmrController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'MMR Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _mmrController.text == 'Exempt'
                                  ? _mmrController.text = ''
                                  : _mmrController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickMmr(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _varicellaController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Varicella Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _varicellaController.text == 'Exempt'
                                  ? _varicellaController.text = ''
                                  : _varicellaController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickVaricella(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _polioController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Polio Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _polioController.text == 'Exempt'
                                  ? _polioController.text = ''
                                  : _polioController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickPolio(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _tuberculinController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Tuberculin Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _tuberculinController.text == 'Exempt'
                                  ? _tuberculinController.text = ''
                                  : _tuberculinController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickTuberculin(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _tetanusController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Tetanus Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _tetanusController.text == 'Exempt'
                                  ? _tetanusController.text = ''
                                  : _tetanusController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickTetanus(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _hepAController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Hepatitis A Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _hepAController.text == 'Exempt'
                                  ? _hepAController.text = ''
                                  : _hepAController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickHepA(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _hepBController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Hepatitis B Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _hepBController.text == 'Exempt'
                                  ? _hepBController.text = ''
                                  : _hepBController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickHepB(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _encephalitisController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Encephalitis Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _encephalitisController.text == 'Exempt'
                                  ? _encephalitisController.text = ''
                                  : _encephalitisController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickEncephalitis(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _meningController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Meningococcal Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _meningController.text == 'Exempt'
                                  ? _meningController.text = ''
                                  : _meningController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickMening(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _typhoidController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Typhoid Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _typhoidController.text == 'Exempt'
                                  ? _typhoidController.text = ''
                                  : _typhoidController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickTyphoid(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _yellowController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Yellow Fever Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _yellowController.text == 'Exempt'
                                  ? _yellowController.text = ''
                                  : _yellowController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickYellow(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _smallPoxController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Small Pox Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _smallPoxController.text == 'Exempt'
                                  ? _smallPoxController.text = ''
                                  : _smallPoxController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickSmallPox(context);
                          }))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _anthraxController,
                  keyboardType: TextInputType.datetime,
                  enabled: true,
                  validator: (value) =>
                      isValidDate(value!) || value.isEmpty || value == 'Exempt'
                          ? null
                          : 'Date must be in yyyy-MM-dd format',
                  decoration: InputDecoration(
                      labelText: 'Anthrax Date',
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _anthraxController.text == 'Exempt'
                                  ? _anthraxController.text = ''
                                  : _anthraxController.text = 'Exempt';
                            });
                          }),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            _pickAnthrax(context);
                          }))),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Other Immunizations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _editImm(context, null);
                },
              ),
            )
          ],
        ),
        if (_otherImms!.isNotEmpty)
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
            children: _otherImms!
                .map((imm) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      child: ListTile(
                        title: Text(imm['title']),
                        subtitle: Text(imm['date']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _otherImms!.removeAt(_otherImms!.indexOf(imm));
                            });
                          },
                        ),
                        onTap: () {
                          _editImm(context, _otherImms!.indexOf(imm));
                        },
                      ),
                    )))
                .toList(),
          ),
      ]);
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  void _editImm(BuildContext context, int? index) {
    TextEditingController titleController = TextEditingController();
    if (index != null) titleController.text = _otherImms![index]['title'];
    TextEditingController dateController = TextEditingController();
    if (index != null) dateController.text = _otherImms![index]['date'];
    Widget title =
        Text(index != null ? 'Edit Immunization' : 'Add Immunization');
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PlatformTextField(
            controller: titleController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Immunization'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PlatformTextField(
            controller: dateController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Date'),
          ),
        ),
      ],
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Immunization' : 'Edit Immunization',
      primary: () {
        saveImms(index, titleController.text, dateController.text);
      },
      secondary: () {},
    );
  }

  void saveImms(int? index, String title, String date) {
    setState(() {
      if (index != null) {
        _otherImms![index]['title'] = title;
        _otherImms![index]['date'] = date;
      } else {
        _otherImms!.add(
          {'title': title, 'date': date},
        );
      }
    });
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('medpros')
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
    _phaController.dispose();
    _dentalController.dispose();
    _visionController.dispose();
    _hearingController.dispose();
    _hivController.dispose();
    _fluController.dispose();
    _mmrController.dispose();
    _varicellaController.dispose();
    _polioController.dispose();
    _tuberculinController.dispose();
    _tetanusController.dispose();
    _hepAController.dispose();
    _hepBController.dispose();
    _encephalitisController.dispose();
    _meningController.dispose();
    _typhoidController.dispose();
    _yellowController.dispose();
    _smallPoxController.dispose();
    _anthraxController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.medpro.id != null) {
      _title = '${widget.medpro.rank} ${widget.medpro.name}';
    }

    _soldierId = widget.medpro.soldierId;
    _rank = widget.medpro.rank;
    _lastName = widget.medpro.name;
    _firstName = widget.medpro.firstName;
    _section = widget.medpro.section;
    _rankSort = widget.medpro.rankSort;
    _owner = widget.medpro.owner;
    _users = widget.medpro.users;

    _phaController.text = widget.medpro.pha;
    _dentalController.text = widget.medpro.dental;
    _visionController.text = widget.medpro.vision;
    _hearingController.text = widget.medpro.hearing;
    _hivController.text = widget.medpro.hiv;
    _fluController.text = widget.medpro.flu;
    _mmrController.text = widget.medpro.mmr;
    _varicellaController.text = widget.medpro.varicella;
    _polioController.text = widget.medpro.polio;
    _tuberculinController.text = widget.medpro.tuberculin;
    _tetanusController.text = widget.medpro.tetanus;
    _hepAController.text = widget.medpro.hepA;
    _hepBController.text = widget.medpro.hepB;
    _encephalitisController.text = widget.medpro.encephalitis;
    _meningController.text = widget.medpro.meningococcal;
    _typhoidController.text = widget.medpro.typhoid;
    _yellowController.text = widget.medpro.yellow;
    _smallPoxController.text = widget.medpro.smallPox;
    _anthraxController.text = widget.medpro.anthrax;
    _otherImms = widget.medpro.otherImms;

    if (widget.medpro.mmr != '' ||
        widget.medpro.varicella != '' ||
        widget.medpro.polio != '' ||
        widget.medpro.tuberculin != '' ||
        widget.medpro.tetanus != '' ||
        widget.medpro.hepA != '' ||
        widget.medpro.hepB != '' ||
        widget.medpro.encephalitis != '' ||
        widget.medpro.meningococcal != '' ||
        widget.medpro.typhoid != '' ||
        widget.medpro.yellow != '' ||
        widget.medpro.smallPox != '' ||
        widget.medpro.anthrax != '') {
      expanded = true;
    } else {
      expanded = false;
    }

    _phaDate = DateTime.tryParse(widget.medpro.pha) ?? DateTime.now();
    _dentalDate = DateTime.tryParse(widget.medpro.dental) ?? DateTime.now();
    _visionDate = DateTime.tryParse(widget.medpro.vision) ?? DateTime.now();
    _hearingDate = DateTime.tryParse(widget.medpro.hearing) ?? DateTime.now();
    _hivDate = DateTime.tryParse(widget.medpro.hiv) ?? DateTime.now();
    _fluDate = DateTime.tryParse(widget.medpro.flu) ?? DateTime.now();
    _mmrDate = DateTime.tryParse(widget.medpro.mmr) ?? DateTime.now();
    _varicellaDate =
        DateTime.tryParse(widget.medpro.varicella) ?? DateTime.now();
    _polioDate = DateTime.tryParse(widget.medpro.polio) ?? DateTime.now();
    _tuberDate = DateTime.tryParse(widget.medpro.tuberculin) ?? DateTime.now();
    _tetanusDate = DateTime.tryParse(widget.medpro.tetanus) ?? DateTime.now();
    _hepADate = DateTime.tryParse(widget.medpro.hepA) ?? DateTime.now();
    _hepBDate = DateTime.tryParse(widget.medpro.hepB) ?? DateTime.now();
    _encephalitisDate =
        DateTime.tryParse(widget.medpro.encephalitis) ?? DateTime.now();
    _meningDate =
        DateTime.tryParse(widget.medpro.meningococcal) ?? DateTime.now();
    _typhoidDate = DateTime.tryParse(widget.medpro.typhoid) ?? DateTime.now();
    _yellowDate = DateTime.tryParse(widget.medpro.yellow) ?? DateTime.now();
    _smallPoxDate = DateTime.tryParse(widget.medpro.smallPox) ?? DateTime.now();
    _anthraxDate = DateTime.tryParse(widget.medpro.anthrax) ?? DateTime.now();
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
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                            child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              value: removeSoldiers,
                              title:
                                  const Text('Remove Soldiers already added'),
                              onChanged: (checked) {
                                _removeSoldiers(checked, user.uid);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _phaController,
                              keyboardType: TextInputType.datetime,
                              enabled: true,
                              validator: (value) =>
                                  isValidDate(value!) || value.isEmpty
                                      ? null
                                      : 'Date must be in yyyy-MM-dd format',
                              decoration: InputDecoration(
                                  labelText: 'PHA Date',
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.date_range),
                                      onPressed: () {
                                        _pickPha(context);
                                      })),
                              onChanged: (value) {
                                _phaDate = DateTime.tryParse(value) ?? _phaDate;
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _dentalController,
                              keyboardType: TextInputType.datetime,
                              enabled: true,
                              validator: (value) =>
                                  isValidDate(value!) || value.isEmpty
                                      ? null
                                      : 'Date must be in yyyy-MM-dd format',
                              decoration: InputDecoration(
                                  labelText: 'Dental Date',
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.date_range),
                                      onPressed: () {
                                        _pickDental(context);
                                      })),
                              onChanged: (value) {
                                _dentalDate =
                                    DateTime.tryParse(value) ?? _dentalDate;
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _visionController,
                              keyboardType: TextInputType.datetime,
                              enabled: true,
                              validator: (value) =>
                                  isValidDate(value!) || value.isEmpty
                                      ? null
                                      : 'Date must be in yyyy-MM-dd format',
                              decoration: InputDecoration(
                                  labelText: 'Vision Date',
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.date_range),
                                      onPressed: () {
                                        _pickVision(context);
                                      })),
                              onChanged: (value) {
                                _visionDate =
                                    DateTime.tryParse(value) ?? _visionDate;
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _hearingController,
                              keyboardType: TextInputType.datetime,
                              enabled: true,
                              validator: (value) =>
                                  isValidDate(value!) || value.isEmpty
                                      ? null
                                      : 'Date must be in yyyy-MM-dd format',
                              decoration: InputDecoration(
                                  labelText: 'Hearing Date',
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.date_range),
                                      onPressed: () {
                                        _pickHearing(context);
                                      })),
                              onChanged: (value) {
                                _hearingDate =
                                    DateTime.tryParse(value) ?? _hearingDate;
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _hivController,
                              keyboardType: TextInputType.datetime,
                              enabled: true,
                              validator: (value) =>
                                  isValidDate(value!) || value.isEmpty
                                      ? null
                                      : 'Date must be in yyyy-MM-dd format',
                              decoration: InputDecoration(
                                  labelText: 'HIV Date',
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.date_range),
                                      onPressed: () {
                                        _pickHiv(context);
                                      })),
                              onChanged: (value) {
                                _hivDate = DateTime.tryParse(value) ?? _hivDate;
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _fluController,
                              keyboardType: TextInputType.datetime,
                              enabled: true,
                              validator: (value) => isValidDate(value!) ||
                                      value.isEmpty ||
                                      value == 'Exempt'
                                  ? null
                                  : 'Date must be in yyyy-MM-dd format',
                              decoration: InputDecoration(
                                  labelText: 'Influenza Date',
                                  prefixIcon: IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        if (mounted) {
                                          setState(() {
                                            _fluController.text == 'Exempt'
                                                ? _fluController.text = ''
                                                : _fluController.text =
                                                    'Exempt';
                                          });
                                        }
                                      }),
                                  suffixIcon: IconButton(
                                      icon: const Icon(Icons.date_range),
                                      onPressed: () {
                                        _pickFlu(context);
                                      })),
                              onChanged: (value) {
                                _fluDate = DateTime.tryParse(value) ?? _fluDate;
                                updated = true;
                              },
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                expanded = !expanded;
                              });
                            }
                          },
                          child: expanded
                              ? const Text('Less Immunizations')
                              : const Text('More Immunizations'),
                        ),
                      ),
                      moreImmunizations(width),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormattedElevatedButton(
                          onPressed: () {
                            submit(context);
                          },
                          text: widget.medpro.id == null
                              ? 'Add MedPros'
                              : 'Update MedPros',
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
