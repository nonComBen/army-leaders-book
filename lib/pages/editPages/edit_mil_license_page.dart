import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/mil_license.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditMilLicPage extends StatefulWidget {
  const EditMilLicPage({
    Key key,
    @required this.milLic,
  }) : super(key: key);
  final MilLic milLic;

  @override
  EditMilLicPageState createState() => EditMilLicPageState();
}

class EditMilLicPageState extends State<EditMilLicPage> {
  String _title = 'New Military License';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _dateController;
  TextEditingController _expController;
  TextEditingController _licenseController;
  TextEditingController _restrictionsController;
  String _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic> _users;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  List<dynamic> qualVehicles;
  bool removeSoldiers, updated;
  bool abrams,
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
  DateTime _dateTime, _expDate;
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

  Future<void> _pickExp(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _expDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _expDate = picked;
            _expController.text = formatter.format(picked);
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
                initialDateTime: _expDate,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _expDate = value;
                  _expController.text = formatter.format(value);
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
      if (qualVehicles.last == '') qualVehicles.removeLast();
      MilLic saveMilLic = MilLic(
        id: widget.milLic.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        date: _dateController.text,
        exp: _expController.text,
        license: _licenseController.text,
        restrictions: _restrictionsController.text,
        vehicles: qualVehicles,
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

  void _removeSoldiers(bool checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('milLic')
          .where('users', arrayContains: userId)
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

  List<Widget> _vehicles() {
    List<Widget> vehicles = [];
    for (int index = 0; index < qualVehicles.length; index++) {
      vehicles.add(Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: ListTile(
              title: Text(qualVehicles[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    qualVehicles.removeAt(index);
                  });
                },
              ),
              onTap: () {
                _editVehicle(context, index);
              },
            ),
          )));
    }
    return vehicles;
  }

  void _editVehicle(BuildContext context, int index) {
    TextEditingController vehicleController = TextEditingController();
    if (index != null) vehicleController.text = qualVehicles[index];
    Widget title = Text(index != null ? 'Edit Vehicle' : 'Add Vehicle');
    Widget content = Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: vehicleController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(labelText: 'Vehicle'),
      ),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Vehicle' : 'Edit Vehicle',
      primary: () {
        setState(() {
          if (index != null) {
            qualVehicles[index] = vehicleController.text;
          } else {
            qualVehicles.add(vehicleController.text);
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

  Future<bool> _onBackPressed() {
    if (!updated) return Future.value(true);
    return onBackPressed(context);
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

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

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

    _dateController = TextEditingController(text: widget.milLic.date);
    _expController = TextEditingController(text: widget.milLic.exp);
    _licenseController = TextEditingController(text: widget.milLic.license);
    _restrictionsController =
        TextEditingController(text: widget.milLic.restrictions);

    if (widget.milLic.vehicles == null) {
      qualVehicles = [];
    } else {
      qualVehicles = widget.milLic.vehicles.toList();
    }

    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(widget.milLic.date) ?? DateTime.now();
    _expDate = DateTime.tryParse(widget.milLic.exp) ?? DateTime.now();
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
                                      labelText: 'Issued Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickDate(context);
                                          })),
                                  onChanged: (value) {
                                    _dateTime =
                                        DateTime.tryParse(value) ?? _dateTime;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _expController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      regExp.hasMatch(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Expiration Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickExp(context);
                                          })),
                                  onChanged: (value) {
                                    _expDate =
                                        DateTime.tryParse(value) ?? _expDate;
                                    updated = true;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Qualified Vehicles',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _editVehicle(context, null);
                                  },
                                ),
                              )
                            ],
                          ),
                          qualVehicles.isEmpty
                              ? const SizedBox()
                              : GridView.count(
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
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                              controller: _restrictionsController,
                              enabled: true,
                              decoration: const InputDecoration(
                                  labelText: 'Restrictions'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          FormattedElevatedButton(
                            onPressed: () {
                              submit(context);
                            },
                            text: widget.milLic.id == null
                                ? 'Add Mil License'
                                : 'Update Mil License',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
