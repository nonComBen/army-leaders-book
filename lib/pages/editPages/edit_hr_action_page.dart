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
import '../../models/hr_action.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditHrActionPage extends ConsumerStatefulWidget {
  const EditHrActionPage({
    Key? key,
    required this.hrAction,
  }) : super(key: key);
  final HrAction hrAction;

  @override
  EditHrActionPageState createState() => EditHrActionPageState();
}

class EditHrActionPageState extends ConsumerState<EditHrActionPage> {
  String _title = 'New HR Metrics';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dd93Controller = TextEditingController();
  final TextEditingController _sglvController = TextEditingController();
  final TextEditingController _prrController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dd93Date, _sglvDate, _prrDate;

  Future<void> _pickDd93(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dd93Date!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dd93Controller.text = formatter.format(picked);
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
                initialDateTime: _dd93Date,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _dd93Date = value;
                  _dd93Controller.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickSglv(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _sglvDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _sglvDate = picked;
            _sglvController.text = formatter.format(picked);
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
                initialDateTime: _sglvDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _sglvDate = value;
                  _sglvController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickPrr(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _prrDate!,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _prrDate = picked;
            _prrController.text = formatter.format(picked);
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
                initialDateTime: _prrDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _prrDate = value;
                  _prrController.text = formatter.format(value);
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
      HrAction saveHrAction = HrAction(
        id: widget.hrAction.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        dd93: _dd93Controller.text,
        sglv: _sglvController.text,
        prr: _prrController.text,
      );

      if (widget.hrAction.id == null) {
        DocumentReference docRef =
            await firestore.collection('hrActions').add(saveHrAction.toMap());

        saveHrAction.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('hrActions')
            .doc(widget.hrAction.id)
            .set(saveHrAction.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Hr Metrics');
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
          .collection('hrActions')
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
    _dd93Controller.dispose();
    _sglvController.dispose();
    _prrController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.hrAction.id != null) {
      _title = '${widget.hrAction.rank} ${widget.hrAction.name}';
    }

    _soldierId = widget.hrAction.soldierId;
    _rank = widget.hrAction.rank;
    _lastName = widget.hrAction.name;
    _firstName = widget.hrAction.firstName;
    _section = widget.hrAction.section;
    _rankSort = widget.hrAction.rankSort;
    _owner = widget.hrAction.owner;
    _users = widget.hrAction.users;

    _dd93Controller.text = widget.hrAction.dd93;
    _sglvController.text = widget.hrAction.sglv;
    _prrController.text = widget.hrAction.prr;

    removeSoldiers = false;
    updated = false;

    _dd93Date = DateTime.tryParse(widget.hrAction.dd93) ?? DateTime.now();
    _sglvDate = DateTime.tryParse(widget.hrAction.sglv) ?? DateTime.now();
    _prrDate = DateTime.tryParse(widget.hrAction.prr) ?? DateTime.now();
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
                                    return PlatformItemPicker(
                                      label: const Text('Soldier'),
                                      items:
                                          soldiers!.map((e) => e.id).toList(),
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
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: removeSoldiers,
                            title: const Text('Remove Soldiers already added'),
                            onChanged: (checked) {
                              _removeSoldiers(checked, user.uid);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _dd93Controller,
                            keyboardType: TextInputType.datetime,
                            enabled: true,
                            validator: (value) =>
                                isValidDate(value!) || value.isEmpty
                                    ? null
                                    : 'Date must be in yyyy-MM-dd format',
                            decoration: InputDecoration(
                                labelText: 'DD93 Date',
                                suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () {
                                      _pickDd93(context);
                                    })),
                            onChanged: (value) {
                              _dd93Date = DateTime.tryParse(value) ?? _dd93Date;
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _sglvController,
                            keyboardType: TextInputType.datetime,
                            enabled: true,
                            validator: (value) =>
                                isValidDate(value!) || value.isEmpty
                                    ? null
                                    : 'Date must be in yyyy-MM-dd format',
                            decoration: InputDecoration(
                                labelText: 'SGLV Date',
                                suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () {
                                      _pickSglv(context);
                                    })),
                            onChanged: (value) {
                              _sglvDate = DateTime.tryParse(value) ?? _sglvDate;
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _prrController,
                            keyboardType: TextInputType.datetime,
                            enabled: true,
                            validator: (value) =>
                                isValidDate(value!) || value.isEmpty
                                    ? null
                                    : 'Date must be in yyyy-MM-dd format',
                            decoration: InputDecoration(
                                labelText: 'Record Review Date',
                                suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () {
                                      _pickPrr(context);
                                    })),
                            onChanged: (value) {
                              _prrDate = DateTime.tryParse(value) ?? _prrDate;
                              updated = true;
                            },
                          ),
                        ),
                      ],
                    ),
                    PlatformButton(
                      onPressed: () {
                        submit(context);
                      },
                      child: Text(widget.hrAction.id == null
                          ? 'Add HR Metrics'
                          : 'Update HR Metrics'),
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
