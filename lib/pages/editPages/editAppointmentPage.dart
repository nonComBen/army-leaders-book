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
import '../../models/appointment.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditAppointmentPage extends StatefulWidget {
  const EditAppointmentPage({
    Key key,
    @required this.userId,
    @required this.apt,
    @required this.isSubscribed,
  }) : super(key: key);
  final String userId;
  final Appointment apt;
  final bool isSubscribed;

  @override
  EditAppointmentPageState createState() => EditAppointmentPageState();
}

class EditAppointmentPageState extends State<EditAppointmentPage> {
  String _title = 'New Appointment';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _startController;
  TextEditingController _endController;
  TextEditingController _titleController;
  TextEditingController _dateController;
  TextEditingController _locController;
  TextEditingController _commentsController;
  String _status,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic> _users;
  List<String> _statuses;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers, updated, saveToCalendar, updateCalendar;
  DateTime _dateTime;
  TimeOfDay _startTime, _endTime;
  RegExp regExp, timeRegExp;

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _dateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        var formatter = DateFormat('yyyy-MM-dd');
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

  Future<void> _pickStart(BuildContext context) async {
    DateTime start = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
        _startTime.hour, _startTime.minute);
    var formatter = DateFormat('HHmm');
    if (kIsWeb || Platform.isAndroid) {
      final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _startTime,
      );

      String hour = picked.hour.toString().length == 2
          ? picked.hour.toString()
          : '0${picked.hour.toString()}';
      String min = picked.minute.toString().length == 2
          ? picked.minute.toString()
          : '0${picked.minute.toString()}';

      if (picked != null) {
        if (mounted) {
          setState(() {
            _startTime = picked;
            _startController.text = '$hour$min';
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
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: start,
                  onDateTimeChanged: (time) {
                    _startTime =
                        TimeOfDay(hour: time.hour, minute: time.minute);
                    _startController.text = formatter.format(time);
                    updated = true;
                  },
                ));
          });
    }
  }

  Future<void> _pickEnd(BuildContext context) async {
    DateTime end = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
        _endTime.hour, _endTime.minute);
    var formatter = DateFormat('HHmm');
    if (kIsWeb || Platform.isAndroid) {
      final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _endTime,
      );

      String hour = picked.hour.toString().length == 2
          ? picked.hour.toString()
          : '0${picked.hour.toString()}';
      String min = picked.minute.toString().length == 2
          ? picked.minute.toString()
          : '0${picked.minute.toString()}';

      if (picked != null) {
        if (mounted) {
          setState(() {
            _endTime = picked;
            _endController.text = '$hour$min';
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
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: end,
                  onDateTimeChanged: (time) {
                    _endTime = TimeOfDay(hour: time.hour, minute: time.minute);
                    _endController.text = formatter.format(time);
                    updated = true;
                  },
                ));
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
      Appointment saveApt = Appointment(
        id: widget.apt.id,
        users: _users,
        soldierId: _soldierId,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        aptTitle: _titleController.text,
        date: _dateController.text,
        start: _startController.text,
        end: _endController.text,
        status: _status,
        comments: _commentsController.text,
        owner: _owner,
        location: _locController.text,
      );

      DocumentReference docRef;
      if (widget.apt.id == null) {
        docRef =
            await firestore.collection('appointments').add(saveApt.toMap());
      } else {
        docRef = firestore.collection('appointments').doc(widget.apt.id);
        docRef.set(saveApt.toMap());
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
          .collection('appointments')
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
    _titleController.dispose();
    _dateController.dispose();
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

    _statuses = [];
    _statuses.add('Scheduled');
    _statuses.add('Rescheduled');
    _statuses.add('Kept');
    _statuses.add('Cancelled');
    _statuses.add('Missed');

    if (widget.apt.id != null) {
      _title = '${widget.apt.rank} ${widget.apt.name}';
    }

    _soldierId = widget.apt.soldierId;
    _rank = widget.apt.rank;
    _lastName = widget.apt.name;
    _firstName = widget.apt.firstName;
    _section = widget.apt.section;
    _rankSort = widget.apt.rankSort;
    _status = widget.apt.status;
    _owner = widget.apt.owner;
    _users = widget.apt.users;

    _startController = TextEditingController(text: widget.apt.start);
    _endController = TextEditingController(text: widget.apt.end);
    _titleController = TextEditingController(text: widget.apt.aptTitle);
    _dateController = TextEditingController(text: widget.apt.date);
    _commentsController = TextEditingController(text: widget.apt.comments);
    _locController = TextEditingController(text: widget.apt.location ?? '');

    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    if (widget.apt.start.length == 4) {
      _startTime = TimeOfDay(
          hour: int.tryParse(widget.apt.start.substring(0, 2)) ?? 9,
          minute: int.tryParse(widget.apt.start.substring(2)) ?? 0);
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
    }
    if (widget.apt.end.length == 4) {
      _endTime = TimeOfDay(
          hour: int.tryParse(widget.apt.end.substring(0, 2)) ?? 10,
          minute: int.tryParse(widget.apt.end.substring(2)) ?? 0);
    } else {
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
    regExp = RegExp(r'^\d{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$');
    timeRegExp = RegExp(r'^(0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$');
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
                                child: TextFormField(
                                  controller: _titleController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Apt Title',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
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
                                      labelText: 'Apt Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickDate(context);
                                          })),
                                  onChanged: (value) {
                                    if (regExp.hasMatch(value)) {
                                      _dateTime = DateTime.tryParse(value) ??
                                          DateTime.now();
                                    }
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _startController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                  validator: (value) =>
                                      timeRegExp.hasMatch(value) ||
                                              value.isEmpty
                                          ? null
                                          : 'Time must be in hhmm format',
                                  decoration: InputDecoration(
                                      labelText: 'Start Time',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.access_time),
                                          onPressed: () {
                                            _pickStart(context);
                                          })),
                                  onChanged: (value) {
                                    if (timeRegExp.hasMatch(value)) {
                                      _startTime = TimeOfDay(
                                          hour: int.tryParse(
                                                  value.substring(0, 2)) ??
                                              9,
                                          minute: int.tryParse(
                                                  value.substring(2)) ??
                                              0);
                                    }
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _endController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                  validator: (value) =>
                                      timeRegExp.hasMatch(value) ||
                                              value.isEmpty
                                          ? null
                                          : 'Time must be in hhmm format',
                                  decoration: InputDecoration(
                                      labelText: 'End Time',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.access_time),
                                          onPressed: () {
                                            _pickEnd(context);
                                          })),
                                  onChanged: (value) {
                                    if (timeRegExp.hasMatch(value)) {
                                      _endTime = TimeOfDay(
                                          hour: int.tryParse(
                                                  value.substring(0, 2)) ??
                                              10,
                                          minute: int.tryParse(
                                                  value.substring(2)) ??
                                              0);
                                    }
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 15.0, 8.0, 0.0),
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
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Status'),
                                  items: _statuses.map((status) {
                                    return DropdownMenuItem(
                                        value: status, child: Text(status));
                                  }).toList(),
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        _status = value;
                                        updated = true;
                                      });
                                    }
                                  },
                                  value: _status,
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
                            text: widget.apt.id == null
                                ? 'Add Appointment'
                                : 'Update Appointment',
                            onPressed: () {
                              if (_endController.text != '' &&
                                  (_endTime.hour < _startTime.hour ||
                                      (_endTime.hour == _startTime.hour &&
                                          _endTime.minute <
                                              _startTime.minute))) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Start Time must be before End Time'),
                                ));
                              } else {
                                submit(context);
                              }
                            },
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
