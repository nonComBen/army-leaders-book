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
import '../../models/perstat.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditPerstatPage extends ConsumerStatefulWidget {
  const EditPerstatPage({
    Key? key,
    required this.perstat,
  }) : super(key: key);
  final Perstat perstat;

  @override
  EditPerstatPageState createState() => EditPerstatPageState();
}

class EditPerstatPageState extends ConsumerState<EditPerstatPage> {
  String _title = 'New Perstat';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  String? _type,
      _otherType,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic>? _users;
  final List<String> _types = [
    'Leave',
    'Pass',
    'TDY',
    'Duty',
    'Comp Day',
    'Hospital',
    'AWOL',
    'Confinement',
    'SUTA',
    'ADOS',
    'Other',
  ];
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
    _locController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    int matches = 0;
    for (var type in _types) {
      if (type == widget.perstat.type) {
        matches++;
      }
    }
    if (matches == 0) {
      _otherType = widget.perstat.type;
      _type = 'Other';
    } else {
      _otherType = '';
      _type = widget.perstat.type;
    }

    if (widget.perstat.id != null) {
      _title = '${widget.perstat.rank} ${widget.perstat.name}';
    }

    _soldierId = widget.perstat.soldierId;
    _rank = widget.perstat.rank;
    _lastName = widget.perstat.name;
    _firstName = widget.perstat.firstName;
    _section = widget.perstat.section;
    _rankSort = widget.perstat.rankSort;
    _owner = widget.perstat.owner;
    _users = widget.perstat.users;

    _startController.text = widget.perstat.start;
    _endController.text = widget.perstat.end;
    _typeController.text = _otherType!;
    _commentsController.text = widget.perstat.comments;
    _locController.text = widget.perstat.location;

    _start = DateTime.tryParse(_startController.text);
    _end = DateTime.tryParse(_endController.text);
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
      String? type;
      if (_type == 'Other' && _typeController.text != '') {
        type = _typeController.text;
      } else {
        type = _type;
      }
      Perstat savePerstat = Perstat(
        id: widget.perstat.id,
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
        type: type!,
        comments: _commentsController.text,
        location: _locController.text,
      );

      if (widget.perstat.id == null) {
        firestore.collection(Perstat.collectionName).add(savePerstat.toMap());
      } else {
        firestore
            .collection(Perstat.collectionName)
            .doc(widget.perstat.id)
            .update(savePerstat.toMap());
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
                      collection: Perstat.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Type'),
                  items: _types,
                  onChanged: (dynamic value) {
                    if (mounted) {
                      setState(() {
                        _type = value;
                        updated = true;
                      });
                    }
                  },
                  value: _type,
                ),
              ),
              if (_type == 'Other')
                PaddedTextField(
                  controller: _typeController,
                  keyboardType: TextInputType.text,
                  label: 'Type',
                  decoration: const InputDecoration(
                    labelText: 'Type',
                  ),
                  onChanged: (value) {
                    setState(() {
                      updated = true;
                    });
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
                minYears: 1,
                maxYears: 2,
              ),
              DateTextField(
                controller: _endController,
                label: 'End Date',
                date: _end,
                minYears: 1,
                maxYears: 2,
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
              if (_end != null && _end!.isBefore(_start!)) {
                toast.showToast(
                  child: const MyToast(
                    message: 'End Date must be after Start Date',
                  ),
                );
              } else {
                submit(context);
              }
            },
            child: Text(
                widget.perstat.id == null ? 'Add Perstat' : 'Update Perstat'),
          ),
        ],
      ),
    );
  }
}
