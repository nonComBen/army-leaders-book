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
import '../../models/perstat.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditPerstatPage extends StatefulWidget {
  const EditPerstatPage({
    Key key,
    @required this.userId,
    @required this.perstat,
    @required this.isSubscribed,
  }) : super(key: key);
  final String userId;
  final Perstat perstat;
  final bool isSubscribed;

  @override
  EditPerstatPageState createState() => EditPerstatPageState();
}

class EditPerstatPageState extends State<EditPerstatPage> {
  String _title = 'New Perstat';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _startController;
  TextEditingController _endController;
  TextEditingController _typeController;
  TextEditingController _commentsController;
  TextEditingController _locController;
  String _type,
      _otherType,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic> _users;
  List<String> _types;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers, updated, saveToCalendar, updateCalendar;
  DateTime _start, _end;
  RegExp regExp;

  Future<void> _pickStart(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _start,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _start = picked;
            _startController.text = formatter.format(picked);
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
                initialDateTime: _start,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _start = value;
                  _startController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickEnd(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _end,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _end = picked;
            _endController.text = formatter.format(picked);
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
                initialDateTime: _end,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _end = value;
                  _endController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Widget otherType() {
    if (_type == 'Other') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 0.0),
        child: TextFormField(
          controller: _typeController,
          keyboardType: TextInputType.text,
          enabled: true,
          decoration: const InputDecoration(
            labelText: 'Type',
          ),
          onChanged: (value) {
            setState(() {
              updated = true;
            });
          },
        ),
      );
    } else {
      return const SizedBox(
        height: 0,
      );
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
      String type;
      if (_type == 'Other' && _typeController.text != '') {
        type = _typeController.text;
      } else {
        type = _type;
      }
      DocumentSnapshot doc =
          soldiers.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      Perstat savePerstat = Perstat(
        id: widget.perstat.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        start: _startController.text,
        end: _endController.text,
        type: type,
        comments: _commentsController.text,
        location: _locController.text,
      );
      DocumentReference docRef;
      if (widget.perstat.id == null) {
        docRef = await firestore.collection('perstat').add(savePerstat.toMap());
      } else {
        docRef = firestore.collection('perstat').doc(widget.perstat.id);
        docRef.update(savePerstat.toMap());
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  void _removeSoldiers(bool checked) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('perstat')
          .where('users', arrayContains: widget.userId)
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
    _startController.dispose();
    _endController.dispose();
    _typeController.dispose();
    _commentsController.dispose();
    _locController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    _types = [];
    _types.add('Leave');
    _types.add('Pass');
    _types.add('TDY');
    _types.add('Duty');
    _types.add('Comp Day');
    _types.add('Hospital');
    _types.add('AWOL');
    _types.add('Confinement');
    _types.add('SUTA');
    _types.add('ADOS');
    _types.add('Other');
    int matches = 0;
    for (var type in _types) {
      if (type == widget.perstat.type) {
        matches++;
      }
    }
    if (matches == 0) {
      _otherType = widget.perstat.type;
      _type = 'Other';
    } else {
      _otherType = '';
      _type = widget.perstat.type;
    }

    if (widget.perstat.id != null) {
      _title = '${widget.perstat.rank} ${widget.perstat.name}';
    }

    _soldierId = widget.perstat.soldierId;
    _rank = widget.perstat.rank;
    _lastName = widget.perstat.name;
    _firstName = widget.perstat.firstName;
    _section = widget.perstat.section;
    _rankSort = widget.perstat.rankSort;
    _owner = widget.perstat.owner;
    _users = widget.perstat.users;

    _startController = TextEditingController(text: widget.perstat.start);
    _endController = TextEditingController(text: widget.perstat.end);
    _typeController = TextEditingController(text: _otherType);
    _commentsController = TextEditingController(text: widget.perstat.comments);
    _locController = TextEditingController(text: widget.perstat.location ?? '');

    removeSoldiers = false;
    updated = false;

    _start = DateTime.tryParse(_startController.text) ?? DateTime.now();
    _end = DateTime.tryParse(_endController.text) ?? DateTime.now();
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
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: FutureBuilder(
                                    future: firestore
                                        .collection('soldiers')
                                        .where('users',
                                            arrayContains: widget.userId)
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
                                    _removeSoldiers(checked);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButtonFormField(
                                  decoration:
                                      const InputDecoration(labelText: 'Type'),
                                  hint: const Text('Type'),
                                  items: _types.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        _type = value;
                                        updated = true;
                                      });
                                    }
                                  },
                                  value: _type,
                                ),
                              ),
                              if (_type == 'Other')
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 15.0, 8.0, 0.0),
                                  child: TextFormField(
                                    controller: _typeController,
                                    keyboardType: TextInputType.text,
                                    enabled: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Type',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        updated = true;
                                      });
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _locController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Location',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _startController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Start Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickStart(context);
                                          })),
                                  onChanged: (value) {
                                    if (regExp.hasMatch(value)) {
                                      _start =
                                          DateTime.tryParse(value) ?? _start;
                                    }
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _endController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'End Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickEnd(context);
                                          })),
                                  onChanged: (value) {
                                    if (regExp.hasMatch(value)) {
                                      _end = DateTime.tryParse(value) ?? _end;
                                    }
                                    updated = true;
                                  },
                                ),
                              ),
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
                              if (_endController.text != '' &&
                                  _end.isBefore(_start)) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text('End Date must be after Start Date'),
                                ));
                              } else {
                                submit(context);
                              }
                            },
                            text: widget.perstat.id == null
                                ? 'Add Perstat'
                                : 'Update Perstat',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
