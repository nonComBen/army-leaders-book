import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/theme_methods.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/mil_license.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/more_tiles_header.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditMilLicPage extends ConsumerStatefulWidget {
  const EditMilLicPage({
    super.key,
    required this.milLic,
  });
  final MilLic milLic;

  @override
  EditMilLicPageState createState() => EditMilLicPageState();
}

class EditMilLicPageState extends ConsumerState<EditMilLicPage> {
  String _title = 'New Military License';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<Soldier>? allSoldiers, lessSoldiers;
  List<dynamic>? qualVehicles;
  bool removeSoldiers = false, updated = false;
  bool? abrams,
      ace,
      apc,
      bradley,
      buffalo,
      caiman,
      chenowith,
      cougar,
      fiveTon,
      fmtv,
      guardian,
      hemtt,
      hercules,
      het,
      hmar,
      hmmwv,
      landRover,
      mlrs,
      mtvr,
      navistar,
      nyala,
      oshkosh,
      patriot,
      piranha,
      pls,
      refueler,
      rg33,
      spa,
      stryker;
  DateTime? _dateTime, _expDate;
  FToast toast = FToast();

  @override
  void dispose() {
    _dateController.dispose();
    _expController.dispose();
    _licenseController.dispose();
    _restrictionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.milLic.id != null) {
      _title = '${widget.milLic.rank} ${widget.milLic.name}';
    }

    _soldierId = widget.milLic.soldierId;
    _rank = widget.milLic.rank;
    _lastName = widget.milLic.name;
    _firstName = widget.milLic.firstName;
    _section = widget.milLic.section;
    _rankSort = widget.milLic.rankSort;
    _owner = widget.milLic.owner;
    _users = widget.milLic.users;

    _dateController.text = widget.milLic.date;
    _expController.text = widget.milLic.exp;
    _licenseController.text = widget.milLic.license;
    _restrictionsController.text = widget.milLic.restrictions;

    if (widget.milLic.vehicles.isEmpty) {
      qualVehicles = [];
    } else {
      qualVehicles = widget.milLic.vehicles.toList();
    }

    _dateTime = DateTime.tryParse(widget.milLic.date);
    _expDate = DateTime.tryParse(widget.milLic.exp);
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text, _expController.text],
    )) {
      if (qualVehicles!.isNotEmpty && qualVehicles!.last == '') {
        qualVehicles!.removeLast();
      }
      MilLic saveMilLic = MilLic(
        id: widget.milLic.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        exp: _expController.text,
        license: _licenseController.text,
        restrictions: _restrictionsController.text,
        vehicles: qualVehicles!,
      );

      if (widget.milLic.id == null) {
        firestore.collection(MilLic.collectionName).add(saveMilLic.toMap());
      } else {
        firestore
            .collection(MilLic.collectionName)
            .doc(widget.milLic.id)
            .set(saveMilLic.toMap(), SetOptions(merge: true));
      }
      Navigator.of(context).pop();
    } else {
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  List<Widget> _vehicles() {
    List<Widget> vehicles = [];
    for (int index = 0; index < qualVehicles!.length; index++) {
      vehicles.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            color: getContrastingBackgroundColor(context),
            child: PlatformListTile(
              title: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(qualVehicles![index]),
              ),
              trailing: PlatformIconButton(
                icon: Icon(
                  Icons.delete,
                  color: getTextColor(context),
                ),
                onPressed: () {
                  setState(() {
                    qualVehicles!.removeAt(index);
                  });
                },
              ),
              onTap: () {
                _editVehicle(context, index);
              },
            ),
          ),
        ),
      );
    }
    return vehicles;
  }

  void _editVehicle(BuildContext context, int? index) {
    TextEditingController vehicleController = TextEditingController();
    if (index != null) vehicleController.text = qualVehicles![index];
    Widget title = Text(index != null ? 'Edit Vehicle' : 'Add Vehicle');
    Widget content = PaddedTextField(
      controller: vehicleController,
      keyboardType: TextInputType.text,
      label: 'Vehicle',
      decoration: const InputDecoration(labelText: 'Vehicle'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Vehicle' : 'Edit Vehicle',
      primary: () {
        setState(() {
          if (index != null) {
            qualVehicles![index] = vehicleController.text;
          } else {
            qualVehicles!.add(vehicleController.text);
          }
        });
      },
      secondary: () {},
    );
  }

  double childRatio(double width) {
    if (width > 900) return width / 400;
    if (width > 650) return width / 300;
    if (width > 400) return width / 200;
    return width / 100;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
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
                  onChanged: (checked) async {
                    lessSoldiers = await createLessSoldiers(
                      collection: MilLic.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              PaddedTextField(
                controller: _licenseController,
                keyboardType: TextInputType.text,
                label: 'License',
                decoration: const InputDecoration(
                  labelText: 'License Number',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _dateController,
                label: 'Issued Date',
                date: _dateTime,
                minYears: 10,
              ),
              DateTextField(
                controller: _expController,
                label: 'Expiration Date',
                date: _expDate,
                minYears: 1,
                maxYears: 10,
              ),
            ],
          ),
          Divider(
            color: getOnPrimaryColor(context),
          ),
          MoreTilesHeader(
            label: 'Qualified Vehicles',
            onPressed: () {
              _editVehicle(context, null);
            },
          ),
          if (qualVehicles!.isNotEmpty)
            FormGridView(width: width, children: _vehicles()),
          Divider(
            color: getOnPrimaryColor(context),
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            controller: _restrictionsController,
            label: 'Restrictions',
            decoration: const InputDecoration(labelText: 'Restrictions'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(widget.milLic.id == null
                ? 'Add Mil License'
                : 'Update Mil License'),
          ),
        ],
      ),
    );
  }
}
