// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/hand_receipt_item.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditHandReceiptPage extends StatefulWidget {
  const EditHandReceiptPage({
    Key key,
    @required this.userId,
    @required this.item,
    @required this.isSubscribed,
  }) : super(key: key);
  final String userId;
  final HandReceiptItem item;
  final bool isSubscribed;

  @override
  EditHandReceiptPageState createState() => EditHandReceiptPageState();
}

class EditHandReceiptPageState extends State<EditHandReceiptPage> {
  String _title = 'New Hand Receipt Item';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _itemController;
  TextEditingController _modelController;
  TextEditingController _serialController;
  TextEditingController _nsnController;
  TextEditingController _locationController;
  TextEditingController _valueController;
  TextEditingController _commentsController;

  String _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic> _users, _subComponents;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers, updated;

  void _editSubComponent(BuildContext context, int index) {
    TextEditingController subController = TextEditingController();
    TextEditingController nsnController = TextEditingController();
    TextEditingController onHandController = TextEditingController();
    TextEditingController reqController = TextEditingController();
    if (index != null) {
      subController.text = _subComponents[index]['item'];
      nsnController.text = _subComponents[index]['nsn'];
      onHandController.text = _subComponents[index]['onHand'];
      reqController.text = _subComponents[index]['required'];
    }
    Widget title =
        Text(index != null ? 'Edit Subcompenent' : 'Add Subcompenent');
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: subController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Item'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: nsnController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'NSN #'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: onHandController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'On Hand'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: reqController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Required'),
          ),
        ),
      ],
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Subcomponent' : 'Edit Subcompenent',
      primary: () {
        setState(() {
          Map<String, dynamic> map = {
            'item': subController.text,
            'nsn': nsnController.text,
            'onHand': onHandController.text,
            'required': reqController.text
          };
          if (index != null) {
            _subComponents[index] = map;
          } else {
            _subComponents.add(map);
          }
        });
      },
      secondary: () {},
    );
  }

  List<Widget> _subComponentWidgets() {
    List<Widget> vehicles = [];
    for (int index = 0; index < _subComponents.length; index++) {
      vehicles.add(Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_subComponents[index]['item']),
                  Text(
                      '${_subComponents[index]['onHand']}/${_subComponents[index]['required']}')
                ],
              ),
              subtitle: Text('NSN: ${_subComponents[index]['nsn']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _subComponents.removeAt(index);
                  });
                },
              ),
              onTap: () {
                _editSubComponent(context, index);
              },
            ),
          )));
    }
    return vehicles;
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
      HandReceiptItem saveHRItem = HandReceiptItem(
        id: widget.item.id,
        soldierId: _soldierId,
        owner: _owner,
        users: _users,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
        item: _itemController.text,
        model: _modelController.text,
        serial: _serialController.text,
        nsn: _nsnController.text,
        location: _locationController.text,
        value: _valueController.text,
        subComponents: _subComponents,
        comments: _commentsController.text,
      );

      if (widget.item.id == null) {
        DocumentReference docRef =
            await firestore.collection('handReceipt').add(saveHRItem.toMap());

        saveHRItem.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('handReceipt')
            .doc(widget.item.id)
            .set(saveHRItem.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Hand Receipt');
        });
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
          .collection('equipment')
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
    _itemController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _nsnController.dispose();
    _locationController.dispose();
    _valueController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    if (widget.item.id != null) {
      _title = '${widget.item.rank} ${widget.item.name}';
    }

    _soldierId = widget.item.soldierId;
    _rank = widget.item.rank;
    _lastName = widget.item.name;
    _firstName = widget.item.firstName;
    _section = widget.item.section;
    _rankSort = widget.item.rankSort;
    _owner = widget.item.owner;
    _users = widget.item.users;

    _itemController = TextEditingController(text: widget.item.item);
    _modelController = TextEditingController(text: widget.item.model);
    _serialController = TextEditingController(text: widget.item.serial);
    _nsnController = TextEditingController(text: widget.item.nsn);
    _locationController = TextEditingController(text: widget.item.location);
    _valueController = TextEditingController(text: widget.item.value);
    _commentsController = TextEditingController(text: widget.item.comments);

    _subComponents = widget.item.subComponents;

    removeSoldiers = false;
    updated = false;
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
                                                labelText: 'Soldier Signed'),
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
                                  controller: _itemController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Item',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _modelController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Model #',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _nsnController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'NSN #',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _locationController,
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
                                  controller: _valueController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Value',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Subcompents',
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
                                    _editSubComponent(context, null);
                                  },
                                ),
                              )
                            ],
                          ),
                          _subComponents.isEmpty
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
                                  children: _subComponentWidgets()),
                          const Divider(),
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
                            onPressed: () {
                              submit(context);
                            },
                            text: widget.item.id == null
                                ? 'Add Item'
                                : 'Update Item',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
