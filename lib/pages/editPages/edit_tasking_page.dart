import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../providers/auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/soldier.dart';
import '../../models/tasking.dart';
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

class EditTaskingPage extends ConsumerStatefulWidget {
  const EditTaskingPage({
    Key? key,
    required this.tasking,
  }) : super(key: key);
  final Tasking tasking;

  @override
  EditTaskingPageState createState() => EditTaskingPageState();
}

class EditTaskingPageState extends ConsumerState<EditTaskingPage> {
  String _title = 'New Tasking';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
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
    _typeController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.tasking.id != null) {
      _title = '${widget.tasking.rank} ${widget.tasking.name}';
    }

    _soldierId = widget.tasking.soldierId;
    _rank = widget.tasking.rank;
    _lastName = widget.tasking.name;
    _firstName = widget.tasking.firstName;
    _section = widget.tasking.section;
    _rankSort = widget.tasking.rankSort;
    _owner = widget.tasking.owner;
    _users = widget.tasking.users;

    _startController.text = widget.tasking.start;
    _endController.text = widget.tasking.end;
    _typeController.text = widget.tasking.type;
    _commentsController.text = widget.tasking.comments;
    _locController.text = widget.tasking.location;

    _start = DateTime.tryParse(widget.tasking.start);
    _end = DateTime.tryParse(widget.tasking.end);
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
      Tasking saveTasking = Tasking(
        id: widget.tasking.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        start: _startController.text,
        end: _endController.text,
        type: _typeController.text,
        comments: _commentsController.text,
        location: _locController.text,
      );
      if (widget.tasking.id == null) {
        firestore.collection(Tasking.collectionName).add(saveTasking.toMap());
      } else {
        firestore
            .collection(Tasking.collectionName)
            .doc(widget.tasking.id)
            .update(saveTasking.toMap());
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
                      collection: Tasking.collectionName,
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
                controller: _typeController,
                label: 'Tasking',
                decoration: const InputDecoration(labelText: 'Tasking'),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _locController,
                label: 'Location',
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _startController,
                label: 'Start Date',
                date: _start,
                minYears: 1,
              ),
              DateTextField(
                controller: _endController,
                label: 'End Date',
                date: _end,
                minYears: 1,
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('End Date must be after Start Date'),
                ));
              } else {
                submit(context);
              }
            },
            child: Text(
                widget.tasking.id == null ? 'Add Tasking' : 'Update Tasking'),
          ),
        ],
      ),
    );
  }
}
