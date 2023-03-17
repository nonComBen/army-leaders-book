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
import '../../models/weapon.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditWeaponPage extends StatefulWidget {
  const EditWeaponPage({
    Key? key,
    required this.weapon,
  }) : super(key: key);
  final Weapon weapon;

  @override
  EditWeaponPageState createState() => EditWeaponPageState();
}

class EditWeaponPageState extends State<EditWeaponPage> {
  String _title = 'New Weapon Qual';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _hitsController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _badgeController = TextEditingController();
  String? _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _qualType,
      _owner;
  List<dynamic>? _users;
  final List<String> _qualTypes = [
    'Day',
    'Night',
    'NBC',
  ];
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false, pass = true;
  DateTime? _dateTime;

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateTime!,
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
      Weapon saveWeapon = Weapon(
        id: widget.weapon.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        type: _typeController.text,
        score: _hitsController.text,
        max: _maxController.text,
        badge: _badgeController.text,
        pass: pass,
        qualType: _qualType!,
      );

      if (widget.weapon.id == null) {
        DocumentReference docRef =
            await firestore.collection('weaponStats').add(saveWeapon.toMap());

        saveWeapon.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('weaponStats')
            .doc(widget.weapon.id)
            .set(saveWeapon.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Weapon');
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
          .collection('weaponStats')
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
    _hitsController.dispose();
    _typeController.dispose();
    _maxController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.weapon.id != null) {
      _title = '${widget.weapon.rank} ${widget.weapon.name}';
    }

    _soldierId = widget.weapon.soldierId;
    _rank = widget.weapon.rank;
    _lastName = widget.weapon.name;
    _firstName = widget.weapon.firstName;
    _section = widget.weapon.section;
    _rankSort = widget.weapon.rankSort;
    _owner = widget.weapon.owner;
    _users = widget.weapon.users;

    pass = widget.weapon.pass;

    _qualType = widget.weapon.qualType;

    _dateController.text = widget.weapon.date;
    _typeController.text = widget.weapon.type;
    _hitsController.text = widget.weapon.score;
    _maxController.text = widget.weapon.max;
    _badgeController.text = widget.weapon.badge;

    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(widget.weapon.date) ?? DateTime.now();
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
                          child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Qualification Type'),
                              value: _qualType,
                              items: _qualTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (dynamic value) {
                                if (mounted) {
                                  setState(() {
                                    _qualType = value;
                                    updated = true;
                                  });
                                }
                              }),
                        ),
                        Padding(
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
                                    })),
                            onChanged: (value) {
                              _dateTime = DateTime.tryParse(value) ?? _dateTime;
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _typeController,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Weapon',
                            ),
                            onChanged: (value) {
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _hitsController,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Hits',
                            ),
                            onChanged: (value) {
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _maxController,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Maximum',
                            ),
                            onChanged: (value) {
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _badgeController,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Badge',
                            ),
                            onChanged: (value) {
                              updated = true;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('Pass'),
                              value: pass,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {
                                    pass = value!;
                                    updated = true;
                                  });
                                }
                              }),
                        )
                      ],
                    ),
                    FormattedElevatedButton(
                      onPressed: () {
                        submit(context);
                      },
                      text: widget.weapon.id == null
                          ? 'Add Weapons Qual'
                          : 'Update Weapons Qual',
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
