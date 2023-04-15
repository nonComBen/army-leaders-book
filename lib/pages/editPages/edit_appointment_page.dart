import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/toast_messages.dart/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';
import '../../widgets/stateful_widgets/time_text_field.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/appointment.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditAppointmentPage extends ConsumerStatefulWidget {
  const EditAppointmentPage({
    Key? key,
    required this.apt,
  }) : super(key: key);
  final Appointment apt;

  @override
  EditAppointmentPageState createState() => EditAppointmentPageState();
}

class EditAppointmentPageState extends ConsumerState<EditAppointmentPage> {
  String _title = 'New Appointment';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String _status = 'Scheduled';
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  final List<String> _statuses = [
    'Scheduled',
    'Rescheduled',
    'Kept',
    'Cancelled',
    'Missed',
  ];
  List<DocumentSnapshot> allSoldiers = [], lessSoldiers = [], soldiers = [];
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime;
  TimeOfDay? _startTime, _endTime;
  FToast toast = FToast();

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text],
    )) {
      DocumentSnapshot doc =
          soldiers.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      Appointment saveApt = Appointment(
        id: widget.apt.id,
        users: _users!,
        soldierId: _soldierId,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        aptTitle: _titleController.text,
        date: _dateController.text,
        start: _startController.text,
        end: _endController.text,
        status: _status,
        comments: _commentsController.text,
        owner: _owner!,
        location: _locController.text,
      );

      DocumentReference docRef;
      if (widget.apt.id == null) {
        docRef =
            await firestore.collection('appointments').add(saveApt.toMap());
      } else {
        docRef = firestore.collection('appointments').doc(widget.apt.id);
        docRef.set(saveApt.toMap());
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
    lessSoldiers = List.from(allSoldiers, growable: true);
    QuerySnapshot apfts = await firestore
        .collection('appointments')
        .where('users', arrayContains: userId)
        .get();
    if (apfts.docs.isNotEmpty) {
      for (var doc in apfts.docs) {
        lessSoldiers
            .removeWhere((soldierDoc) => soldierDoc.id == doc['soldierId']);
      }
    }

    if (lessSoldiers.isEmpty) {
      if (mounted) {
        toast.showToast(
          child: const MyToast(
            message: 'All Soldiers have been added',
          ),
        );
      }
    }

    setState(() {
      if (checked! && lessSoldiers.isNotEmpty) {
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
    _titleController.dispose();
    _dateController.dispose();
    _commentsController.dispose();
    _locController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.apt.id != null) {
      _title = '${widget.apt.rank} ${widget.apt.name}';
    }

    _soldierId = widget.apt.soldierId;
    _rank = widget.apt.rank;
    _lastName = widget.apt.name;
    _firstName = widget.apt.firstName;
    _section = widget.apt.section;
    _rankSort = widget.apt.rankSort;
    _status = widget.apt.status;
    _owner = widget.apt.owner;
    _users = widget.apt.users;

    _startController.text = widget.apt.start;
    _endController.text = widget.apt.end;
    _titleController.text = widget.apt.aptTitle;
    _dateController.text = widget.apt.date;
    _commentsController.text = widget.apt.comments;
    _locController.text = widget.apt.location;

    _dateTime = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    if (widget.apt.start.length == 4) {
      _startTime = TimeOfDay(
          hour: int.tryParse(widget.apt.start.substring(0, 2)) ?? 9,
          minute: int.tryParse(widget.apt.start.substring(2)) ?? 0);
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
    }
    if (widget.apt.end.length == 4) {
      _endTime = TimeOfDay(
          hour: int.tryParse(widget.apt.end.substring(0, 2)) ?? 10,
          minute: int.tryParse(widget.apt.end.substring(2)) ?? 0);
    } else {
      _endTime = const TimeOfDay(hour: 10, minute: 0);
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
          GridView.count(
            padding: const EdgeInsets.all(0.0),
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
                          soldiers.sort((a, b) => a['lastName']
                              .toString()
                              .compareTo(b['lastName'].toString()));
                          soldiers.sort((a, b) => a['rankSort']
                              .toString()
                              .compareTo(b['rankSort'].toString()));
                          return PlatformItemPicker(
                            label: const Text('Soldier'),
                            items: soldiers.map((e) => e.id).toList(),
                            onChanged: (value) {
                              int index =
                                  soldiers.indexWhere((doc) => doc.id == value);
                              if (mounted) {
                                setState(() {
                                  _soldierId = value;
                                  _rank = soldiers[index]['rank'];
                                  _lastName = soldiers[index]['lastName'];
                                  _firstName = soldiers[index]['firstName'];
                                  _section = soldiers[index]['section'];
                                  _rankSort =
                                      soldiers[index]['rankSort'].toString();
                                  _owner = soldiers[index]['owner'];
                                  _users = soldiers[index]['users'];
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
                controller: _titleController,
                keyboardType: TextInputType.text,
                label: 'Apt Title',
                decoration: const InputDecoration(
                  labelText: 'Apt Title',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _dateController,
                label: 'Apt Date',
                date: _dateTime,
              ),
              TimeTextField(
                controller: _startController,
                label: 'Start Time',
                time: _startTime,
              ),
              TimeTextField(
                controller: _endController,
                label: 'End Time',
                time: _endTime,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformItemPicker(
                  label: const Text('Status'),
                  items: _statuses,
                  onChanged: (dynamic value) {
                    if (mounted) {
                      setState(() {
                        _status = value;
                        updated = true;
                      });
                    }
                  },
                  value: _status,
                ),
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
            child: Text(widget.apt.id == null
                ? 'Add Appointment'
                : 'Update Appointment'),
            onPressed: () {
              if (_endController.text != '' &&
                  (_endTime!.hour < _startTime!.hour ||
                      (_endTime!.hour == _startTime!.hour &&
                          _endTime!.minute < _startTime!.minute))) {
                toast.showToast(
                  child: const MyToast(
                    message: 'Start Time must be before End Time',
                  ),
                );
              } else {
                submit(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
