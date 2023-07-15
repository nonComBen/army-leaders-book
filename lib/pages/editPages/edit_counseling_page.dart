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
import '../../models/counseling.dart';
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

class EditCounselingPage extends ConsumerStatefulWidget {
  const EditCounselingPage({
    Key? key,
    required this.counseling,
  }) : super(key: key);
  final Counseling counseling;

  @override
  EditCounselingPageState createState() => EditCounselingPageState();
}

class EditCounselingPageState extends ConsumerState<EditCounselingPage> {
  String _title = 'New Counseling';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _indivRemarksController = TextEditingController();
  final TextEditingController _keyPointsController = TextEditingController();
  final TextEditingController _leaderRespController = TextEditingController();
  final TextEditingController _planOfActionController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort;
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime;
  FToast toast = FToast();

  @override
  void dispose() {
    _dateController.dispose();
    _assessmentController.dispose();
    _keyPointsController.dispose();
    _indivRemarksController.dispose();
    _leaderRespController.dispose();
    _planOfActionController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.counseling.id != null) {
      _title = '${widget.counseling.rank} ${widget.counseling.name}';
    }

    _soldierId = widget.counseling.soldierId;
    _rank = widget.counseling.rank;
    _lastName = widget.counseling.name;
    _firstName = widget.counseling.firstName;
    _section = widget.counseling.section;
    _rankSort = widget.counseling.rankSort;

    _dateController.text = widget.counseling.date;
    _assessmentController.text = widget.counseling.assessment;
    _indivRemarksController.text = widget.counseling.indivRemarks;
    _leaderRespController.text = widget.counseling.leaderResp;
    _planOfActionController.text = widget.counseling.planOfAction;
    _purposeController.text = widget.counseling.purpose;
    _keyPointsController.text = widget.counseling.keyPoints;

    _dateTime = DateTime.tryParse(widget.counseling.date);
  }

  void submit(BuildContext context, String userId) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text],
    )) {
      Counseling saveCounseling = Counseling(
        id: widget.counseling.id,
        soldierId: _soldierId,
        owner: userId,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        assessment: _assessmentController.text,
        indivRemarks: _indivRemarksController.text,
        keyPoints: _keyPointsController.text,
        leaderResp: _leaderRespController.text,
        planOfAction: _planOfActionController.text,
        purpose: _purposeController.text,
      );

      if (widget.counseling.id == null) {
        firestore
            .collection(Counseling.collectionName)
            .add(saveCounseling.toMap());
      } else {
        firestore
            .collection(Counseling.collectionName)
            .doc(widget.counseling.id)
            .set(saveCounseling.toMap());
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
                      collection: Counseling.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Date',
                minYears: 1,
                date: _dateTime,
              ),
            ],
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _purposeController,
            enabled: true,
            label: 'Purpose of Counseling',
            decoration:
                const InputDecoration(labelText: 'Purpose of Counseling'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _keyPointsController,
            label: 'Key Points of Discussion',
            decoration:
                const InputDecoration(labelText: 'Key Points of Discussion'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _planOfActionController,
            label: 'Plan of Action',
            decoration: const InputDecoration(labelText: 'Plan of Action'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _indivRemarksController,
            label: 'Individual Counseled Remarks',
            decoration: const InputDecoration(
                labelText: 'Individual Counseled Remarks'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _leaderRespController,
            label: 'Leader Responsibilities',
            decoration:
                const InputDecoration(labelText: 'Leader Responsibilities'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            controller: _assessmentController,
            label: 'Assessment',
            decoration: const InputDecoration(labelText: 'Assessment'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            onPressed: () {
              submit(context, user.uid);
            },
            child: Text(widget.counseling.id == null
                ? 'Add Counseling'
                : 'Update Counseling'),
          ),
        ],
      ),
    );
  }
}
