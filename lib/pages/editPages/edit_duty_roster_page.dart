import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leaders_book/widgets/form_frame.dart';

import '../../methods/toast_messages.dart/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';
import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/duty.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditDutyRosterPage extends ConsumerStatefulWidget {
  const EditDutyRosterPage({
    Key? key,
    required this.duty,
  }) : super(key: key);
  final Duty duty;

  @override
  EditDutyRosterPageState createState() => EditDutyRosterPageState();
}

class EditDutyRosterPageState extends ConsumerState<EditDutyRosterPage> {
  String _title = 'New Duty';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _dutyController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _start, _end;
  FToast toast = FToast();

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_startController.text, _endController.text],
    )) {
      DocumentSnapshot doc =
          soldiers!.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      Duty saveDuty = Duty(
        id: widget.duty.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        duty: _dutyController.text,
        start: _startController.text,
        end: _endController.text,
        comments: _commentsController.text,
        location: _locController.text,
      );

      DocumentReference docRef;
      if (widget.duty.id == null) {
        docRef = await firestore.collection('dutyRoster').add(saveDuty.toMap());
      } else {
        docRef = firestore.collection('dutyRoster').doc(widget.duty.id);
        docRef.update(saveDuty.toMap());
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('dutyRoster')
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
        toast.showToast(
          child: const MyToast(
            message: 'All Soldiers have been added',
          ),
        );
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
    _startController.dispose();
    _endController.dispose();
    _dutyController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.duty.id != null) {
      _title = '${widget.duty.rank} ${widget.duty.name}';
    }

    _soldierId = widget.duty.soldierId;
    _rank = widget.duty.rank;
    _lastName = widget.duty.name;
    _firstName = widget.duty.firstName;
    _section = widget.duty.section;
    _rankSort = widget.duty.rankSort;
    _owner = widget.duty.owner;
    _users = widget.duty.users;

    _startController.text = widget.duty.start;
    _endController.text = widget.duty.end;
    _dutyController.text = widget.duty.duty;
    _commentsController.text = widget.duty.comments;
    _locController.text = widget.duty.location;

    _start = DateTime.tryParse(widget.duty.start) ?? DateTime.now();
    _end = DateTime.tryParse(widget.duty.end) ?? DateTime.now();
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
                                  _firstName = soldiers![index]['firstName'];
                                  _section = soldiers![index]['section'];
                                  _rankSort =
                                      soldiers![index]['rankSort'].toString();
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
                controller: _dutyController,
                keyboardType: TextInputType.text,
                label: 'Duty Title',
                decoration: const InputDecoration(
                  labelText: 'Duty Title',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _locController,
                keyboardType: TextInputType.text,
                label: 'Location',
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _startController,
                label: 'Start Date',
                date: _start,
              ),
              DateTextField(
                controller: _endController,
                label: 'End Date',
                date: _end,
              ),
            ],
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            controller: _commentsController,
            label: 'Comments',
            decoration: const InputDecoration(labelText: 'Comments'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            onPressed: () {
              if (_endController.text != '' && _end!.isBefore(_start!)) {
                toast.showToast(
                  child: const MyToast(
                    message: 'End Date must be after Start Date',
                  ),
                );
              } else {
                submit(context);
              }
            },
            child: Text(widget.duty.id == null ? 'Add Duty' : 'Update Duty'),
          ),
        ],
      ),
    );
  }
}
