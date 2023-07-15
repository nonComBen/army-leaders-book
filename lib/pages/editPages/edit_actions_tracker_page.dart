import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/validate.dart';
import '../../models/action.dart';
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

class EditActionsTrackerPage extends ConsumerStatefulWidget {
  const EditActionsTrackerPage({
    Key? key,
    required this.action,
  }) : super(key: key);
  final ActionObj action;

  @override
  EditActionsTrackerPageState createState() => EditActionsTrackerPageState();
}

class EditActionsTrackerPageState
    extends ConsumerState<EditActionsTrackerPage> {
  String _title = 'New Action';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _statusDateController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime, _statusDateTime;
  FToast toast = FToast();

  @override
  void dispose() {
    _dateController.dispose();
    _actionController.dispose();
    _statusController.dispose();
    _statusDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.action.id != null) {
      _title = '${widget.action.rank} ${widget.action.name}';
    }

    _soldierId = widget.action.soldierId;
    _rank = widget.action.rank;
    _lastName = widget.action.name;
    _firstName = widget.action.firstName;
    _section = widget.action.section;
    _rankSort = widget.action.rankSort;
    _owner = widget.action.owner;
    _users = widget.action.users;

    _dateController.text = widget.action.dateSubmitted;
    _actionController.text = widget.action.action;
    _statusController.text = widget.action.currentStatus;
    _statusDateController.text = widget.action.statusDate;
    _remarksController.text = widget.action.remarks;

    _dateTime = DateTime.tryParse(widget.action.dateSubmitted);
    _statusDateTime = DateTime.tryParse(widget.action.statusDate);
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      toast.showToast(
        child: const MyToast(
          message: 'Please Select a Soldier',
        ),
      );
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text, _statusDateController.text],
    )) {
      ActionObj saveAction = ActionObj(
        id: widget.action.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        action: _actionController.text,
        dateSubmitted: _dateController.text,
        currentStatus: _statusController.text,
        statusDate: _statusDateController.text,
        remarks: _remarksController.text,
      );

      if (widget.action.id == null) {
        firestore.collection(ActionObj.collectionName).add(saveAction.toMap());
      } else {
        try {
          firestore
              .collection(ActionObj.collectionName)
              .doc(widget.action.id)
              .set(saveAction.toMap());
        } on Exception catch (e) {
          debugPrint('Error updating Actions Tracker: $e');
        }
      }
      Navigator.of(context).pop();
    } else {
      toast.showToast(
        toastDuration: const Duration(seconds: 5),
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
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: removeSoldiers,
                  title: const Text('Remove Soldiers already added'),
                  onChanged: (checked) async {
                    lessSoldiers = await createLessSoldiers(
                      collection: ActionObj.collectionName,
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
                autocorrect: false,
                controller: _actionController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                label: 'Action',
                decoration: const InputDecoration(
                  labelText: 'Action',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _dateController,
                label: 'Date Submitted',
                date: _dateTime,
              ),
              PaddedTextField(
                autocorrect: false,
                controller: _statusController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                label: 'Current Status',
                decoration: const InputDecoration(
                  labelText: 'Current Status',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _statusDateController,
                label: 'Status Date',
                minYears: 1,
                date: _statusDateTime,
              ),
            ],
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            controller: _remarksController,
            label: 'Remarks',
            decoration: const InputDecoration(labelText: 'Remarks'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            child:
                Text(widget.action.id == null ? 'Add Action' : 'Update Action'),
            onPressed: () => submit(context),
          ),
        ],
      ),
    );
  }
}
