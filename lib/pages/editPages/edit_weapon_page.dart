import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/weapon.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditWeaponPage extends ConsumerStatefulWidget {
  const EditWeaponPage({
    Key? key,
    required this.weapon,
  }) : super(key: key);
  final Weapon weapon;

  @override
  EditWeaponPageState createState() => EditWeaponPageState();
}

class EditWeaponPageState extends ConsumerState<EditWeaponPage> {
  String _title = 'New Weapon Qual';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
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
                                soldiers =
                                    removeSoldiers ? lessSoldiers : allSoldiers;
                                soldiers!.sort((a, b) => a['lastName']
                                    .toString()
                                    .compareTo(b['lastName'].toString()));
                                soldiers!.sort((a, b) => a['rankSort']
                                    .toString()
                                    .compareTo(b['rankSort'].toString()));
                                return PlatformItemPicker(
                                  label: const Text('Soldier'),
                                  items: soldiers!.map((e) => e.id).toList(),
                                  onChanged: (value) {
                                    int index = soldiers!
                                        .indexWhere((doc) => doc.id == value);
                                    if (mounted) {
                                      setState(() {
                                        _soldierId = value;
                                        _rank = soldiers![index]['rank'];
                                        _lastName =
                                            soldiers![index]['lastName'];
                                        _firstName =
                                            soldiers![index]['firstName'];
                                        _section = soldiers![index]['section'];
                                        _rankSort = soldiers![index]['rankSort']
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
                      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                      child: PlatformCheckboxListTile(
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
                      child: PlatformItemPicker(
                          label: const Text('Qualification Type'),
                          value: _qualType,
                          items: _qualTypes,
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
                      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 0.0),
                      child: DateTextField(
                        controller: _dateController,
                        label: 'Date',
                        date: _dateTime,
                      ),
                    ),
                    PaddedTextField(
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
                    PaddedTextField(
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
                    PaddedTextField(
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
                    PaddedTextField(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PlatformCheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Pass'),
                          value: pass,
                          onChanged: (value) {
                            setState(() {
                              pass = value!;
                              updated = true;
                            });
                          }),
                    )
                  ],
                ),
                PlatformButton(
                  onPressed: () {
                    submit(context);
                  },
                  child: Text(widget.weapon.id == null
                      ? 'Add Weapons Qual'
                      : 'Update Weapons Qual'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
