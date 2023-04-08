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
import '../../models/perstat.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditPerstatPage extends ConsumerStatefulWidget {
  const EditPerstatPage({
    Key? key,
    required this.perstat,
  }) : super(key: key);
  final Perstat perstat;

  @override
  EditPerstatPageState createState() => EditPerstatPageState();
}

class EditPerstatPageState extends ConsumerState<EditPerstatPage> {
  String _title = 'New Perstat';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  String? _type,
      _otherType,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic>? _users;
  final List<String> _types = [
    'Leave',
    'Pass',
    'TDY',
    'Duty',
    'Comp Day',
    'Hospital',
    'AWOL',
    'Confinement',
    'SUTA',
    'ADOS',
    'Other',
  ];
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _start, _end;

  Future<void> _pickStart(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _start!,
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
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _end!,
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
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      String? type;
      if (_type == 'Other' && _typeController.text != '') {
        type = _typeController.text;
      } else {
        type = _type;
      }
      DocumentSnapshot doc =
          soldiers!.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      Perstat savePerstat = Perstat(
        id: widget.perstat.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        start: _startController.text,
        end: _endController.text,
        type: type!,
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

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('perstat')
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

    _startController.text = widget.perstat.start;
    _endController.text = widget.perstat.end;
    _typeController.text = _otherType!;
    _commentsController.text = widget.perstat.comments;
    _locController.text = widget.perstat.location;

    _start = DateTime.tryParse(_startController.text) ?? DateTime.now();
    _end = DateTime.tryParse(_endController.text) ?? DateTime.now();
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
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 0.0),
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
                                          allSoldiers = snapshot.data!.docs;
                                          soldiers = removeSoldiers
                                              ? lessSoldiers
                                              : allSoldiers;
                                          soldiers!.sort((a, b) => a['lastName']
                                              .toString()
                                              .compareTo(
                                                  b['lastName'].toString()));
                                          soldiers!.sort((a, b) => a['rankSort']
                                              .toString()
                                              .compareTo(
                                                  b['rankSort'].toString()));
                                          return DropdownButtonFormField<
                                              String>(
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
                                                  _rank =
                                                      soldiers![index]['rank'];
                                                  _lastName = soldiers![index]
                                                      ['lastName'];
                                                  _firstName = soldiers![index]
                                                      ['firstName'];
                                                  _section = soldiers![index]
                                                      ['section'];
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
                                  onChanged: (dynamic value) {
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
                                      isValidDate(value!) || value.isEmpty
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
                                    if (isValidDate(value)) {
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
                                      isValidDate(value!) || value.isEmpty
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
                                    if (isValidDate(value)) {
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
                          PlatformButton(
                            onPressed: () {
                              if (_endController.text != '' &&
                                  _end!.isBefore(_start!)) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text('End Date must be after Start Date'),
                                ));
                              } else {
                                submit(context);
                              }
                            },
                            child: Text(widget.perstat.id == null
                                ? 'Add Perstat'
                                : 'Update Perstat'),
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
