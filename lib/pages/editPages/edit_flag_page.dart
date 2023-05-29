import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants/firestore_collections.dart';
import '../../methods/create_less_soldiers.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/flag.dart';
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
  String? _type;
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  FToast toast = FToast();
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

  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime, _expDate;

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

    allSoldiers = ref.read(soldiersProvider);

    if (widget.flag.id != null) {
      _title = '${widget.flag.rank} ${widget.flag.name}';
    }

    _soldierId = widget.flag.soldierId;
    _rank = widget.flag.rank;
    _lastName = widget.flag.name;
    _firstName = widget.flag.firstName;
    _section = widget.flag.section;
    _rankSort = widget.flag.rankSort;
    _type = widget.flag.type;
    _owner = widget.flag.owner;
    _users = widget.flag.users;

    _dateController.text = widget.flag.date;
    _expController.text = widget.flag.exp;
    _commentsController.text = widget.flag.comments;

    _dateTime = DateTime.tryParse(widget.flag.date) ?? DateTime.now();
    _expDate = DateTime.tryParse(widget.flag.exp) ?? DateTime.now();
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text, _expController.text],
    )) {
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
            await firestore.collection(kFlagCollection).add(saveFlag.toMap());

        saveFlag.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kFlagCollection)
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
                  onChanged: (checked) {
                    createLessSoldiers(
                      collection: kFlagCollection,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
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
                    setState(() {
                      _type = value;
                      updated = true;
                    });
                  },
                  value: _type,
                ),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Date',
                minYears: 10,
                date: _dateTime,
              ),
              if (_type == 'Punishment Phase')
                DateTextField(
                  controller: _expController,
                  label: 'Exp Date',
                  date: _expDate,
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
              submit(context);
            },
            child: Text(widget.flag.id == null ? 'Add Flag' : 'Update Flag'),
          ),
        ],
      ),
    );
  }
}
