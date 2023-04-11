import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_provider.dart';
import '../../methods/theme_methods.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/mil_license.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/header_text.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditMilLicPage extends ConsumerStatefulWidget {
  const EditMilLicPage({
    Key? key,
    required this.milLic,
  }) : super(key: key);
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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
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
      if (qualVehicles!.last == '') qualVehicles!.removeLast();
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
        DocumentReference docRef =
            await firestore.collection('milLic').add(saveMilLic.toMap());

        saveMilLic.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('milLic')
            .doc(widget.milLic.id)
            .set(saveMilLic.toMap())
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

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('milLic')
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

  List<Widget> _vehicles() {
    List<Widget> vehicles = [];
    for (int index = 0; index < qualVehicles!.length; index++) {
      vehicles.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            color: getContrastingBackgroundColor(context),
            child: PlatformListTile(
              title: Text(qualVehicles![index]),
              trailing: PlatformIconButton(
                icon: const Icon(Icons.delete),
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

    _dateTime = DateTime.tryParse(widget.milLic.date) ?? DateTime.now();
    _expDate = DateTime.tryParse(widget.milLic.exp) ?? DateTime.now();
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
                      controller: _licenseController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'License',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTextField(
                        controller: _dateController,
                        label: 'Issued Date',
                        date: _dateTime,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTextField(
                        controller: _expController,
                        label: 'Expiration Date',
                        date: _expDate,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: getOnPrimaryColor(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Qualified Vehicles',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PlatformIconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          _editVehicle(context, null);
                        },
                      ),
                    )
                  ],
                ),
                if (qualVehicles!.isNotEmpty)
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
                      children: _vehicles()),
                Divider(
                  color: getOnPrimaryColor(context),
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  controller: _restrictionsController,
                  enabled: true,
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
          ),
        ),
      ),
    );
  }
}
