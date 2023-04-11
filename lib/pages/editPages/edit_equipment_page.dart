import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_provider.dart';
import '../../methods/theme_methods.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/equipment.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditEquipmentPage extends ConsumerStatefulWidget {
  const EditEquipmentPage({
    Key? key,
    required this.equipment,
  }) : super(key: key);
  final Equipment equipment;

  @override
  EditEquipmentPageState createState() => EditEquipmentPageState();
}

class EditEquipmentPageState extends ConsumerState<EditEquipmentPage> {
  String _title = 'New Equipment';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _weaponController = TextEditingController();
  final TextEditingController _buttStockController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _opticController = TextEditingController();
  final TextEditingController _opticSerialController = TextEditingController();
  final TextEditingController _weapon2Controller = TextEditingController();
  final TextEditingController _buttStock2Controller = TextEditingController();
  final TextEditingController _serial2Controller = TextEditingController();
  final TextEditingController _optic2Controller = TextEditingController();
  final TextEditingController _opticSerial2Controller = TextEditingController();
  final TextEditingController _maskController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _bumperController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _otherSerialController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false, secondaryExpanded = false;

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
      Equipment saveEquipment = Equipment(
        id: widget.equipment.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        weapon: _weaponController.text,
        buttStock: _buttStockController.text,
        serial: _serialController.text,
        weapon2: _weapon2Controller.text,
        buttStock2: _buttStock2Controller.text,
        serial2: _serial2Controller.text,
        optic: _opticController.text,
        opticSerial: _opticSerialController.text,
        optic2: _optic2Controller.text,
        opticSerial2: _opticSerial2Controller.text,
        mask: _maskController.text,
        veh: _bumperController.text,
        vehType: _vehicleController.text,
        license: _licenseController.text,
        other: _otherController.text,
        otherSerial: _otherSerialController.text,
      );

      if (widget.equipment.id == null) {
        DocumentReference docRef =
            await firestore.collection('equipment').add(saveEquipment.toMap());

        saveEquipment.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('equipment')
            .doc(widget.equipment.id)
            .set(saveEquipment.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Bodyfat');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  Widget secondaryTextFields(double width) {
    if (secondaryExpanded) {
      return Column(
        children: <Widget>[
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
                child: PaddedTextField(
                    controller: _weapon2Controller,
                    keyboardType: TextInputType.text,
                    enabled: true,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Weapon',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PaddedTextField(
                    controller: _buttStock2Controller,
                    keyboardType: TextInputType.number,
                    enabled: true,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Butt Stock #',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PaddedTextField(
                    controller: _serial2Controller,
                    keyboardType: TextInputType.text,
                    enabled: true,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Serial #',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PaddedTextField(
                    controller: _optic2Controller,
                    keyboardType: TextInputType.text,
                    enabled: true,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Optics',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PaddedTextField(
                    controller: _opticSerial2Controller,
                    keyboardType: TextInputType.text,
                    enabled: true,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Optics Serial #',
                    )),
              ),
            ],
          )
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('equipment')
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
    _weaponController.dispose();
    _buttStockController.dispose();
    _serialController.dispose();
    _opticController.dispose();
    _opticSerialController.dispose();
    _weapon2Controller.dispose();
    _buttStock2Controller.dispose();
    _serial2Controller.dispose();
    _optic2Controller.dispose();
    _opticSerial2Controller.dispose();
    _maskController.dispose();
    _vehicleController.dispose();
    _bumperController.dispose();
    _licenseController.dispose();
    _otherController.dispose();
    _otherSerialController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.equipment.id != null) {
      _title = '${widget.equipment.rank} ${widget.equipment.name}';
    }

    _soldierId = widget.equipment.soldierId;
    _rank = widget.equipment.rank;
    _lastName = widget.equipment.name;
    _firstName = widget.equipment.firstName;
    _section = widget.equipment.section;
    _rankSort = widget.equipment.rankSort;
    _owner = widget.equipment.owner;
    _users = widget.equipment.users;

    _weaponController.text = widget.equipment.weapon;
    _buttStockController.text = widget.equipment.buttStock;
    _serialController.text = widget.equipment.serial;
    _opticController.text = widget.equipment.optic;
    _opticSerialController.text = widget.equipment.opticSerial;
    _weapon2Controller.text = widget.equipment.weapon2;
    _buttStock2Controller.text = widget.equipment.buttStock2;
    _serial2Controller.text = widget.equipment.serial2;
    _optic2Controller.text = widget.equipment.optic2;
    _opticSerial2Controller.text = widget.equipment.opticSerial2;
    _maskController.text = widget.equipment.mask;
    _vehicleController.text = widget.equipment.vehType;
    _bumperController.text = widget.equipment.veh;
    _licenseController.text = widget.equipment.license;
    _otherController.text = widget.equipment.other;
    _otherSerialController.text = widget.equipment.otherSerial;

    if (_weapon2Controller.text != '' || _optic2Controller.text != '') {
      secondaryExpanded = true;
    }
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
                    PaddedTextField(
                      controller: _weaponController,
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
                      controller: _buttStockController,
                      keyboardType: TextInputType.number,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Butt Stock #',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _serialController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Serial #',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _opticController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Optics',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _opticSerialController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Optics Serial #',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                  ],
                ),
                secondaryTextFields(width),
                if (!secondaryExpanded)
                  PlatformButton(
                      child: const Text('Add Secondary Weapon'),
                      onPressed: () {
                        setState(() {
                          secondaryExpanded = true;
                        });
                      }),
                Divider(
                  color: getOnPrimaryColor(context),
                ),
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
                    PaddedTextField(
                      controller: _maskController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Mask',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _vehicleController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _bumperController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Bumper #',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _otherController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Other Item',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _otherSerialController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Other Item Serial #',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                  ],
                ),
                PlatformButton(
                  onPressed: () {
                    submit(context);
                  },
                  child: Text(widget.equipment.id == null
                      ? 'Add Equipment'
                      : 'Update Equipment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
