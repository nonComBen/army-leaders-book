import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/profile.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditPermProfilePage extends StatefulWidget {
  const EditPermProfilePage({
    Key key,
    @required this.profile,
  }) : super(key: key);
  final PermProfile profile;

  @override
  EditPermProfilePageState createState() => EditPermProfilePageState();
}

class EditPermProfilePageState extends State<EditPermProfilePage> {
  String _title = 'New Permanent Profile';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _dateController;
  TextEditingController _commentsController;
  String _event,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic> _users;
  List<String> _events;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers, updated;
  bool shaving, pu, su, run;
  DateTime _dateTime;
  RegExp regExp;

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
      PermProfile saveProfile = PermProfile(
        id: widget.profile.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        date: _dateController.text,
        shaving: shaving,
        pu: pu,
        su: su,
        run: run,
        altEvent: _event,
        comments: _commentsController.text,
      );

      if (widget.profile.id == null) {
        DocumentReference docRef =
            await firestore.collection('profiles').add(saveProfile.toMap());

        saveProfile.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('profiles')
            .doc(widget.profile.id)
            .set(saveProfile.toMap())
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

  double childRatio(double width) {
    if (width > 900) return 900 / 400;
    if (width > 650) return width / 300;
    if (width > 400) return width / 200;
    return width / 100;
  }

  Widget checkBoxes(double width) {
    return GridView.count(
      primary: false,
      crossAxisCount: width > 900
          ? 4
          : width > 650
              ? 3
              : width > 400
                  ? 2
                  : 1,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: childRatio(width),
      shrinkWrap: true,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Pushup'),
              value: pu,
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    pu = value;
                    updated = true;
                  });
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Situp'),
              value: su,
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    su = value;
                    updated = true;
                  });
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Run'),
              value: run,
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    run = value;
                    if (value) _event = '';
                    updated = true;
                  });
                }
              }),
        ),
        altEvent()
      ],
    );
  }

  Widget altEvent() {
    if (!run) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Alternative Event'),
            items: _events.map((event) {
              return DropdownMenuItem(value: event, child: Text(event));
            }).toList(),
            value: _event,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _event = value;
                });
              }
            }),
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
          .collection('profiles')
          .where('users', arrayContains: userId)
          .where('type', isEqualTo: 'Permanent')
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
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    _events = [];
    _events.add('');
    _events.add('Walk');
    _events.add('Bike');
    _events.add('Swim');

    if (widget.profile.id != null) {
      _title = '${widget.profile.rank} ${widget.profile.name}';
    }

    _soldierId = widget.profile.soldierId;
    _rank = widget.profile.rank;
    _lastName = widget.profile.name;
    _firstName = widget.profile.firstName;
    _section = widget.profile.section;
    _rankSort = widget.profile.rankSort;
    _event = widget.profile.altEvent;
    _owner = widget.profile.owner;
    _users = widget.profile.users;

    _dateController = TextEditingController(text: widget.profile.date);
    _commentsController = TextEditingController(text: widget.profile.comments);

    shaving = widget.profile.shaving;
    pu = widget.profile.pu;
    su = widget.profile.su;
    run = widget.profile.run;
    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(widget.profile.date) ?? DateTime.now();
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
                                      labelText: 'Start Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickDate(context);
                                          })),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 16.0, 8.0, 0.0),
                                  child: CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: const Text(
                                        'Shaving',
                                      ),
                                      value: shaving,
                                      onChanged: (value) {
                                        if (mounted) {
                                          setState(() {
                                            shaving = value;
                                            updated = true;
                                          });
                                        }
                                      })),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            'APFT Events',
                            style: TextStyle(fontSize: 18),
                          ),
                          const Text('Select events the Soldier can take.'),
                          checkBoxes(width),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
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
                            text: widget.profile.id == null
                                ? 'Add Profile'
                                : 'Update Profile',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
