import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/validate.dart';
import '../../models/soldier.dart';
import '../../methods/rank_sort.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditSoldierPage extends StatefulWidget {
  const EditSoldierPage({
    Key? key,
    required this.soldier,
  }) : super(key: key);
  final Soldier soldier;

  @override
  EditSoldierPageState createState() => EditSoldierPageState();
}

class EditSoldierPageState extends State<EditSoldierPage> {
  String _title = 'New Soldier';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _miController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _dodIdController = TextEditingController();
  final TextEditingController _dorController = TextEditingController();
  final TextEditingController _mosController = TextEditingController();
  final TextEditingController _paraLnController = TextEditingController();
  final TextEditingController _reqMosController = TextEditingController();
  final TextEditingController _dutyController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _gainController = TextEditingController();
  final TextEditingController _etsController = TextEditingController();
  final TextEditingController _basdController = TextEditingController();
  final TextEditingController _pebdController = TextEditingController();
  final TextEditingController _nbcSuitController = TextEditingController();
  final TextEditingController _nbcMaskController = TextEditingController();
  final TextEditingController _nbcBootController = TextEditingController();
  final TextEditingController _nbcGloveController = TextEditingController();
  final TextEditingController _hatController = TextEditingController();
  final TextEditingController _bootController = TextEditingController();
  final TextEditingController _acuTopController = TextEditingController();
  final TextEditingController _acuTrouserController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _workPhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();
  final TextEditingController _nokController = TextEditingController();
  final TextEditingController _nokPhoneController = TextEditingController();
  final TextEditingController _maritalStatusController =
      TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  bool _promotable = false, updated = false, _assigned = true;
  String _civEd = '', _milEd = '';
  final List<String> _civEds = [
    '',
    'GED',
    'HS Diploma',
    '30 Semester Hour',
    '60 Semester Hours',
    '90 Semester Hours',
    'Associates',
    'Bachelors',
    'Masters',
    'Doctorate',
  ];
  final List<String> _milEds = [
    '',
    'None',
    'DLC1',
    'BLC',
    'DLC2',
    'ALC',
    'DLC3',
    'SLC',
    'DLC4',
    'MLC',
    'DLC5',
    'SMA',
  ];
  DateTime? _dorDate, _lossDate, _etsDate, _basdDate, _pebdDate, _gainDate;

  Widget createField(
      {String? label,
      TextEditingController? controller,
      TextInputType? inputType}) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          enabled: true,
          keyboardType: inputType,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: label,
          ),
          onChanged: (value) {
            updated = true;
          },
        ));
  }

  Future<void> _pickDor(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dorDate!,
          firstDate: DateTime(1950),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dorDate = picked;
            _dorController.text = formatter.format(picked);
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
                initialDateTime: _dorDate,
                minimumDate:
                    DateTime.now().add(const Duration(days: -365 * 10)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 1)),
                onDateTimeChanged: (value) {
                  _dorDate = value;
                  _dorController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickLoss(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _lossDate!,
          firstDate: DateTime(1950),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _lossDate = picked;
            _lossController.text = formatter.format(picked);
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
                initialDateTime: _lossDate,
                minimumDate:
                    DateTime.now().add(const Duration(days: -365 * 10)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 10)),
                onDateTimeChanged: (value) {
                  _lossDate = value;
                  _lossController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickEts(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _etsDate!,
          firstDate: DateTime(1950),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _etsDate = picked;
            _etsController.text = formatter.format(picked);
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
                initialDateTime: _etsDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 10)),
                onDateTimeChanged: (value) {
                  _etsDate = value;
                  _etsController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickBasd(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _basdDate!,
          firstDate: DateTime(1950),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _basdDate = picked;
            _basdController.text = formatter.format(picked);
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
                initialDateTime: _basdDate,
                minimumDate:
                    DateTime.now().add(const Duration(days: -365 * 40)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 1)),
                onDateTimeChanged: (value) {
                  _basdDate = value;
                  _basdController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickPebd(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _pebdDate!,
          firstDate: DateTime(1950),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _pebdDate = picked;
            _pebdController.text = formatter.format(picked);
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
                initialDateTime: _pebdDate,
                minimumDate:
                    DateTime.now().add(const Duration(days: -365 * 40)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 1)),
                onDateTimeChanged: (value) {
                  _pebdDate = value;
                  _pebdController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickGain(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _gainDate!,
          firstDate: DateTime(1950),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _gainDate = picked;
            _gainController.text = formatter.format(picked);
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
                initialDateTime: _gainDate,
                minimumDate:
                    DateTime.now().add(const Duration(days: -365 * 20)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _gainDate = value;
                  _gainController.text = formatter.format(value);
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
      Soldier saveSoldier = Soldier(
        id: widget.soldier.id,
        owner: widget.soldier.owner,
        users: widget.soldier.users,
        rank: _rankController.text,
        rankSort: getRankSort(_rankController.text),
        promotable: _promotable ? '(P)' : '',
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        mi: _miController.text,
        assigned: _assigned,
        supervisor: _supervisorController.text,
        section: _sectionController.text,
        dodId: _dodIdController.text,
        dor: _dorController.text,
        mos: _mosController.text,
        duty: _dutyController.text,
        paraLn: _paraLnController.text,
        reqMos: _reqMosController.text,
        lossDate: _lossController.text,
        ets: _etsController.text,
        basd: _basdController.text,
        pebd: _pebdController.text,
        gainDate: _gainController.text,
        civEd: _civEd,
        milEd: _milEd,
        nbcSuitSize: _nbcSuitController.text,
        nbcMaskSize: _nbcMaskController.text,
        nbcBootSize: _nbcBootController.text,
        nbcGloveSize: _nbcGloveController.text,
        hatSize: _hatController.text,
        bootSize: _bootController.text,
        acuTopSize: _acuTopController.text,
        acuTrouserSize: _acuTrouserController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zip: _zipController.text,
        phone: _phoneController.text,
        workPhone: _workPhoneController.text,
        email: _emailController.text,
        workEmail: _workEmailController.text,
        nok: _nokController.text,
        nokPhone: _nokPhoneController.text,
        maritalStatus: _maritalStatusController.text,
        comments: _commentsController.text,
      );

      if (widget.soldier.id == null) {
        DocumentReference docRef =
            await firestore.collection('soldiers').add(saveSoldier.toMap());

        saveSoldier.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        await firestore
            .collection('soldiers')
            .doc(widget.soldier.id)
            .set(saveSoldier.toMap());
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Form is invalid - rank and last name must not be blank and dates must be in yyyy-MM-dd format')));
    }
  }

  @override
  void dispose() {
    _rankController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _miController.dispose();
    _supervisorController.dispose();
    _sectionController.dispose();
    _dodIdController.dispose();
    _mosController.dispose();
    _dorController.dispose();
    _dutyController.dispose();
    _paraLnController.dispose();
    _reqMosController.dispose();
    _lossController.dispose();
    _etsController.dispose();
    _basdController.dispose();
    _pebdController.dispose();
    _nbcSuitController.dispose();
    _nbcMaskController.dispose();
    _nbcBootController.dispose();
    _nbcGloveController.dispose();
    _hatController.dispose();
    _bootController.dispose();
    _acuTopController.dispose();
    _acuTrouserController.dispose();
    _gainController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _workPhoneController.dispose();
    _emailController.dispose();
    _workEmailController.dispose();
    _nokPhoneController.dispose();
    _nokController.dispose();
    _maritalStatusController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.soldier.id != null) {
      _title = '${widget.soldier.rank} ${widget.soldier.lastName}';
    }
    _rankController.text = widget.soldier.rank;
    _lastNameController.text = widget.soldier.lastName;
    _firstNameController.text = widget.soldier.firstName;
    _miController.text = widget.soldier.mi;
    _assigned = widget.soldier.assigned;
    _supervisorController.text = widget.soldier.supervisor;
    _sectionController.text = widget.soldier.section;
    _dodIdController.text = widget.soldier.dodId;
    _mosController.text = widget.soldier.mos;
    _dutyController.text = widget.soldier.duty;
    _paraLnController.text = widget.soldier.paraLn;
    _reqMosController.text = widget.soldier.reqMos;
    _dorController.text = widget.soldier.dor;
    _lossController.text = widget.soldier.lossDate;
    _etsController.text = widget.soldier.ets;
    _gainController.text = widget.soldier.gainDate;
    _basdController.text = widget.soldier.basd;
    _pebdController.text = widget.soldier.pebd;
    _nbcSuitController.text = widget.soldier.nbcSuitSize;
    _nbcMaskController.text = widget.soldier.nbcMaskSize;
    _nbcBootController.text = widget.soldier.nbcBootSize;
    _nbcGloveController.text = widget.soldier.nbcGloveSize;
    _hatController.text = widget.soldier.hatSize;
    _bootController.text = widget.soldier.bootSize;
    _acuTopController.text = widget.soldier.acuTopSize;
    _acuTrouserController.text = widget.soldier.acuTrouserSize;
    _addressController.text = widget.soldier.address;
    _cityController.text = widget.soldier.city;
    _stateController.text = widget.soldier.state;
    _zipController.text = widget.soldier.zip;
    _phoneController.text = widget.soldier.phone;
    _workEmailController.text = widget.soldier.workEmail;
    _workPhoneController.text = widget.soldier.workPhone;
    _emailController.text = widget.soldier.email;
    _nokController.text = widget.soldier.nok;
    _maritalStatusController.text = widget.soldier.maritalStatus;
    _nokPhoneController.text = widget.soldier.nokPhone;
    _commentsController.text = widget.soldier.comments;

    _promotable = widget.soldier.promotable == '(P)';

    _civEd = widget.soldier.civEd;
    _milEd = widget.soldier.milEd;

    _dorDate = DateTime.tryParse(widget.soldier.dor) ?? DateTime.now();
    _lossDate = DateTime.tryParse(widget.soldier.lossDate) ?? DateTime.now();
    _etsDate = DateTime.tryParse(widget.soldier.ets) ?? DateTime.now();
    _gainDate = DateTime.tryParse(widget.soldier.gainDate) ?? DateTime.now();
    _basdDate = DateTime.tryParse(widget.soldier.basd) ?? DateTime.now();
    _pebdDate = DateTime.tryParse(widget.soldier.pebd) ?? DateTime.now();
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
                                child: TextFormField(
                                  controller: _rankController,
                                  enabled: true,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: (value) => value!.isEmpty
                                      ? 'Rank can\'t be empty'
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Rank',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CheckboxListTile(
                                title: const Text('Promotable'),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: _promotable,
                                onChanged: (checked) {
                                  setState(() {
                                    _promotable = checked!;
                                  });
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _lastNameController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  enabled: true,
                                  validator: (value) => value!.isEmpty
                                      ? 'Last Name can\'t be empty'
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                )),
                            createField(
                                label: 'First Name',
                                controller: _firstNameController,
                                inputType: TextInputType.text),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _miController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                enabled: true,
                                decoration: const InputDecoration(
                                    labelText: 'Middle Initial'),
                                onChanged: (value) {
                                  updated = true;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SwitchListTile(
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  title:
                                      Text(_assigned ? 'Assigned' : 'Attached'),
                                  value: _assigned,
                                  onChanged: (value) {
                                    setState(() {
                                      _assigned = value;
                                    });
                                  }),
                            ),
                            createField(
                                label: 'Supervisor',
                                controller: _supervisorController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Section',
                                controller: _sectionController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'DoD ID',
                                controller: _dodIdController,
                                inputType: TextInputType.number),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _dorController,
                                keyboardType: TextInputType.datetime,
                                enabled: true,
                                validator: (value) =>
                                    isValidDate(value!) || value.isEmpty
                                        ? null
                                        : 'Date must be in yyyy-MM-dd format',
                                decoration: InputDecoration(
                                  labelText: 'Date of Rank',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () {
                                      _pickDor(context);
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  _dorDate =
                                      DateTime.tryParse(value) ?? _dorDate;
                                  updated = true;
                                },
                              ),
                            ),
                            createField(
                                label: 'MOS',
                                controller: _mosController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Duty Position',
                                controller: _dutyController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Paragraph/Line',
                                controller: _paraLnController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Duty MOS',
                                controller: _reqMosController,
                                inputType: TextInputType.text),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _lossController,
                                keyboardType: TextInputType.datetime,
                                enabled: true,
                                validator: (value) =>
                                    isValidDate(value!) || value.isEmpty
                                        ? null
                                        : 'Date must be in yyyy-MM-dd format',
                                decoration: InputDecoration(
                                  labelText: 'Loss Date',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () {
                                      _pickLoss(context);
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  _lossDate =
                                      DateTime.tryParse(value) ?? _lossDate;
                                  updated = true;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _etsController,
                                keyboardType: TextInputType.datetime,
                                enabled: true,
                                validator: (value) =>
                                    isValidDate(value!) || value.isEmpty
                                        ? null
                                        : 'Date must be in yyyy-MM-dd format',
                                decoration: InputDecoration(
                                    labelText: 'ETS',
                                    suffixIcon: IconButton(
                                        icon: const Icon(Icons.date_range),
                                        onPressed: () {
                                          _pickEts(context);
                                        })),
                                onChanged: (value) {
                                  _etsDate =
                                      DateTime.tryParse(value) ?? _etsDate;
                                  updated = true;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _basdController,
                                keyboardType: TextInputType.datetime,
                                enabled: true,
                                validator: (value) =>
                                    isValidDate(value!) || value.isEmpty
                                        ? null
                                        : 'Date must be in yyyy-MM-dd format',
                                decoration: InputDecoration(
                                    labelText: 'BASD',
                                    suffixIcon: IconButton(
                                        icon: const Icon(Icons.date_range),
                                        onPressed: () {
                                          _pickBasd(context);
                                        })),
                                onChanged: (value) {
                                  _basdDate =
                                      DateTime.tryParse(value) ?? _basdDate;
                                  updated = true;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _pebdController,
                                keyboardType: TextInputType.datetime,
                                enabled: true,
                                validator: (value) =>
                                    isValidDate(value!) || value.isEmpty
                                        ? null
                                        : 'Date must be in yyyy-MM-dd format',
                                decoration: InputDecoration(
                                  labelText: 'PEBD',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () {
                                      _pickPebd(context);
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  _pebdDate =
                                      DateTime.tryParse(value) ?? _pebdDate;
                                  updated = true;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _gainController,
                                keyboardType: TextInputType.datetime,
                                enabled: true,
                                validator: (value) =>
                                    isValidDate(value!) || value.isEmpty
                                        ? null
                                        : 'Date must be in yyyy-MM-dd format',
                                decoration: InputDecoration(
                                    labelText: 'Gain Date',
                                    suffixIcon: IconButton(
                                        icon: const Icon(Icons.date_range),
                                        onPressed: () {
                                          _pickGain(context);
                                        })),
                                onChanged: (value) {
                                  _gainDate =
                                      DateTime.tryParse(value) ?? _gainDate;
                                  updated = true;
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
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
                            createField(
                                label: 'CBRN Suit Size',
                                controller: _nbcSuitController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'CBRN Mask Size',
                                controller: _nbcMaskController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'CBRN Boot Size',
                                controller: _nbcBootController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'CBRN Glove Size',
                                controller: _nbcGloveController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Hat Size',
                                controller: _hatController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Boot Size',
                                controller: _bootController,
                                inputType: TextInputType.number),
                            createField(
                                label: 'OCP Top Size',
                                controller: _acuTopController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'OCP Trouser Size',
                                controller: _acuTrouserController,
                                inputType: TextInputType.text),
                          ],
                        ),
                        const Divider(),
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
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Civilian Education'),
                                items: _civEds.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (dynamic value) {
                                  if (mounted) {
                                    setState(() {
                                      _civEd = value;
                                      updated = true;
                                    });
                                  }
                                },
                                value: _civEd,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Military Education'),
                                items: _milEds.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (dynamic value) {
                                  if (mounted) {
                                    setState(() {
                                      _milEd = value;
                                      updated = true;
                                    });
                                  }
                                },
                                value: _milEd,
                              ),
                            ),
                            createField(
                                label: 'Address',
                                controller: _addressController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'City',
                                controller: _cityController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'State',
                                controller: _stateController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'Zip Code',
                                controller: _zipController,
                                inputType: TextInputType.number),
                            createField(
                                label: 'Personal Phone',
                                controller: _phoneController,
                                inputType: TextInputType.phone),
                            createField(
                                label: 'Work Phone',
                                controller: _workPhoneController,
                                inputType: TextInputType.phone),
                            createField(
                                label: 'Email',
                                controller: _emailController,
                                inputType: TextInputType.emailAddress),
                            createField(
                                label: 'Work Email',
                                controller: _workEmailController,
                                inputType: TextInputType.emailAddress),
                            createField(
                                label: 'Next of Kin',
                                controller: _nokController,
                                inputType: TextInputType.text),
                            createField(
                                label: 'NOK Phone',
                                controller: _nokPhoneController,
                                inputType: TextInputType.phone),
                            createField(
                                label: 'Marital Status',
                                controller: _maritalStatusController,
                                inputType: TextInputType.text),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 2,
                            controller: _commentsController,
                            enabled: true,
                            decoration:
                                const InputDecoration(labelText: 'Comments'),
                            onChanged: (value) {
                              updated = true;
                            },
                          ),
                        ),
                        FormattedElevatedButton(
                          onPressed: () {
                            submit(context);
                          },
                          text: widget.soldier.id == null
                              ? 'Add Soldier'
                              : 'Update Soldier',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
