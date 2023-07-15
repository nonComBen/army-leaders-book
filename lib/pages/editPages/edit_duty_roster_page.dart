import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/duty.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

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
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _start, _end;
  FToast toast = FToast();

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

    allSoldiers = ref.read(soldiersProvider);

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

    _start = DateTime.tryParse(widget.duty.start);
    _end = DateTime.tryParse(widget.duty.end);
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_startController.text, _endController.text],
    )) {
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

      if (widget.duty.id == null) {
        firestore.collection(Duty.collectionName).add(saveDuty.toMap());
      } else {
        firestore
            .collection(Duty.collectionName)
            .doc(widget.duty.id)
            .update(saveDuty.toMap());
      }
      Navigator.pop(context);
    } else {
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
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
                  onChanged: (checked) async {
                    lessSoldiers = await createLessSoldiers(
                      collection: Duty.collectionName,
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
                minYears: 1,
                date: _start,
              ),
              DateTextField(
                controller: _endController,
                label: 'End Date',
                minYears: 1,
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
