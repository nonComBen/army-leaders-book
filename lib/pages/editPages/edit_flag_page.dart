import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/flag.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditFlagPage extends ConsumerStatefulWidget {
  const EditFlagPage({
    Key? key,
    required this.flag,
  }) : super(key: key);
  final Flag flag;

  @override
  EditFlagPageState createState() => EditFlagPageState();
}

class EditFlagPageState extends ConsumerState<EditFlagPage> {
  String _title = 'New Flag';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String _type = 'Adverse Action';
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  final List<String> _types = [
    'Adverse Action',
    'Alcohol Abuse',
    'APFT Failure',
    'Commanders Investigatio',
    'Deny Automatic Promotion',
    'Drug Abuse',
    'Involuntary Separation',
    'Law Enforcement Investigation',
    'Punishment Phase',
    'Referred OER/Relief For Cause NCOER',
    'Removal From Selection List',
    'Security Violation',
    'Weight Control Program',
    'Other',
  ];

  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
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
      Flag saveFlag = Flag(
        id: widget.flag.id,
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
        type: _type,
        comments: _commentsController.text,
      );

      if (widget.flag.id == null) {
        DocumentReference docRef =
            await firestore.collection('flags').add(saveFlag.toMap());

        saveFlag.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('flags')
            .doc(widget.flag.id)
            .set(saveFlag.toMap())
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
          .collection('flags')
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
    _expController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.flag.id != null) {
      _title = '${widget.flag.rank} ${widget.flag.name}';
    }

    _soldierId = widget.flag.soldierId;
    _rank = widget.flag.rank;
    _lastName = widget.flag.name;
    _firstName = widget.flag.firstName;
    _section = widget.flag.section;
    _rankSort = widget.flag.rankSort;
    _type = widget.flag.type!;
    _owner = widget.flag.owner;
    _users = widget.flag.users;

    _dateController.text = widget.flag.date;
    _expController.text = widget.flag.exp;
    _commentsController.text = widget.flag.comments;

    _dateTime = DateTime.tryParse(widget.flag.date) ?? DateTime.now();
    _expDate = DateTime.tryParse(widget.flag.exp) ?? DateTime.now();
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
                                      _lastName = soldiers![index]['lastName'];
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
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
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
                      child: PlatformItemPicker(
                        label: const Text('Type'),
                        items: _types,
                        onChanged: (dynamic value) {
                          setState(() {
                            _type = value;
                            updated = true;
                          });
                        },
                        value: _type,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 0.0),
                      child: DateTextField(
                        controller: _dateController,
                        label: 'Date',
                        date: _dateTime,
                      ),
                    ),
                    if (_type == 'Punishment Phase')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _expController,
                          label: 'Exp Date',
                          date: _expDate,
                        ),
                      ),
                  ],
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  controller: _commentsController,
                  enabled: true,
                  decoration: const InputDecoration(labelText: 'Comments'),
                  onChanged: (value) {
                    updated = true;
                  },
                ),
                PlatformButton(
                  onPressed: () {
                    submit(context);
                  },
                  child:
                      Text(widget.flag.id == null ? 'Add Flag' : 'Update Flag'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
