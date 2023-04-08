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
import '../../models/profile.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditTempProfilePage extends ConsumerStatefulWidget {
  const EditTempProfilePage({
    Key? key,
    required this.profile,
  }) : super(key: key);
  final TempProfile profile;

  @override
  EditTempProfilePageState createState() => EditTempProfilePageState();
}

class EditTempProfilePageState extends ConsumerState<EditTempProfilePage> {
  String _title = 'New Temp Profile';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String? _type,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime, _expDate;

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateTime!,
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
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _expDate!,
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
      TempProfile saveProfile = TempProfile(
        id: widget.profile.id,
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
        type: _type!,
        comments: _commentsController.text,
      );

      DocumentReference docRef;
      if (widget.profile.id == null) {
        docRef =
            await firestore.collection('profiles').add(saveProfile.toMap());

        //saveProfile.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        docRef = firestore.collection('profiles').doc(widget.profile.id);
        docRef.set(saveProfile.toMap());
        if (mounted) {
          Navigator.pop(context);
        }
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
          .collection('profiles')
          .where('users', arrayContains: userId)
          .where('type', isEqualTo: 'Temporary')
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
    _expController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _type = widget.profile.type;

    if (widget.profile.id != null) {
      _title = '${widget.profile.rank} ${widget.profile.name}';
    }

    _soldierId = widget.profile.soldierId;
    _rank = widget.profile.rank;
    _lastName = widget.profile.name;
    _firstName = widget.profile.firstName;
    _section = widget.profile.section;
    _rankSort = widget.profile.rankSort;
    _owner = widget.profile.owner;
    _users = widget.profile.users;

    _dateController.text = widget.profile.date;
    _expController.text = widget.profile.exp;
    _commentsController.text = widget.profile.comments;

    _dateTime = DateTime.tryParse(widget.profile.date) ?? DateTime.now();
    _expDate = DateTime.tryParse(widget.profile.exp) ?? DateTime.now();
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
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                            child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              value: removeSoldiers,
                              title:
                                  const Text('Remove Soldiers already added'),
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
                                  isValidDate(value!) || value.isEmpty
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
                                  isValidDate(value!) || value.isEmpty
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
                                _expDate = DateTime.tryParse(value) ?? _expDate;
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
                          submit(context);
                        },
                        child: Text(widget.profile.id == null
                            ? 'Add Profile'
                            : 'Update Profile'),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
