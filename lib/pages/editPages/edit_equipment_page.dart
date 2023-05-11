import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants/firestore_collections.dart';
import '../../methods/create_less_soldiers.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../auth_provider.dart';
import '../../methods/theme_methods.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages.dart/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/equipment.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';

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
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false, secondaryExpanded = false;
  FToast toast = FToast();

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

    allSoldiers = ref.read(soldiersProvider);

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

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [],
    )) {
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
        DocumentReference docRef = await firestore
            .collection(kEquipmentCollection)
            .add(saveEquipment.toMap());

        saveEquipment.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kEquipmentCollection)
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
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  Widget secondaryTextFields(double width) {
    if (secondaryExpanded) {
      return Column(
        children: <Widget>[
          FormGridView(
            width: width,
            children: <Widget>[
              PaddedTextField(
                  controller: _weapon2Controller,
                  keyboardType: TextInputType.text,
                  label: 'Secondary Weapon',
                  decoration: const InputDecoration(
                    labelText: 'Secondary Weapon',
                  )),
              PaddedTextField(
                  controller: _buttStock2Controller,
                  keyboardType: TextInputType.number,
                  label: 'Secondary Butt Stock #',
                  decoration: const InputDecoration(
                    labelText: 'Secondary Butt Stock #',
                  )),
              PaddedTextField(
                  controller: _serial2Controller,
                  keyboardType: TextInputType.text,
                  label: 'Secondary Serial #',
                  decoration: const InputDecoration(
                    labelText: 'Secondary Serial #',
                  )),
              PaddedTextField(
                  controller: _optic2Controller,
                  keyboardType: TextInputType.text,
                  label: 'Secondary Optics',
                  decoration: const InputDecoration(
                    labelText: 'Secondary Optics',
                  )),
              PaddedTextField(
                  controller: _opticSerial2Controller,
                  keyboardType: TextInputType.text,
                  label: 'Secondary Optics Serial #',
                  decoration: const InputDecoration(
                    labelText: 'Secondary Optics Serial #',
                  )),
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    toast.context = context;
    return PlatformScaffold(
      title: _title,
      body: FormFrame(
        formKey: _formKey,
        onWillPop:
            updated ? () => onBackPressed(context) : () => Future(() => true),
        children: <Widget>[
          if (user.isAnonymous) const AnonWarningBanner(),
          FormGridView(
            width: width,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformSoldierPicker(
                  label: 'Soldier',
                  soldiers: removeSoldiers ? lessSoldiers! : allSoldiers!,
                  value: _soldierId,
                  onChanged: (soldierId) {
                    final soldier =
                        allSoldiers!.firstWhere((e) => e.id == soldierId);
                    setState(() {
                      _soldierId = soldierId;
                      _rank = soldier.rank;
                      _lastName = soldier.lastName;
                      _firstName = soldier.firstName;
                      _section = soldier.section;
                      _rankSort = soldier.rankSort.toString();
                      _owner = soldier.owner;
                      _users = soldier.users;
                      updated = true;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                child: PlatformCheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: removeSoldiers,
                  title: const Text('Remove Soldiers already added'),
                  onChanged: (checked) {
                    createLessSoldiers(
                        collection: kEquipmentCollection,
                        userId: user.uid,
                        allSoldiers: allSoldiers!);
                  },
                ),
              ),
              PaddedTextField(
                controller: _weaponController,
                keyboardType: TextInputType.text,
                label: 'Weapon',
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
                label: 'Butt Stock #',
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
                label: 'Serial #',
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
                label: 'Optics',
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
                label: 'Optics Serial #',
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
          FormGridView(
            width: width,
            children: <Widget>[
              PaddedTextField(
                controller: _maskController,
                keyboardType: TextInputType.text,
                label: 'Mask',
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
                label: 'Vehicle',
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
                label: 'Bumper #',
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
                label: 'Other Item',
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
                label: 'Other Item Serial #',
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
    );
  }
}
