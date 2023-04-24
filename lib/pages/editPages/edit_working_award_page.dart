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
import '../../methods/toast_messages.dart/soldier_id_is_blank.dart';
import '../../models/working_award.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';

class EditWorkingAwardPage extends ConsumerStatefulWidget {
  const EditWorkingAwardPage({
    Key? key,
    required this.award,
  }) : super(key: key);
  final WorkingAward award;

  @override
  EditWorkingAwardPageState createState() => EditWorkingAwardPageState();
}

class EditWorkingAwardPageState extends ConsumerState<EditWorkingAwardPage> {
  String _title = 'New Award';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _ach1Controller = TextEditingController();
  final TextEditingController _ach2Controller = TextEditingController();
  final TextEditingController _ach3Controller = TextEditingController();
  final TextEditingController _ach4Controller = TextEditingController();
  final TextEditingController _citationController = TextEditingController();
  String? _reason,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort;
  final List<String> _reasons = [
    'Achievement',
    'Service',
    'PCS',
    'ETS',
    'Retirement',
    'Heroism',
    'Valor',
  ];
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  FToast toast = FToast();

  @override
  void dispose() {
    _ach1Controller.dispose();
    _ach2Controller.dispose();
    _ach3Controller.dispose();
    _ach4Controller.dispose();
    _citationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.award.id != null) {
      _title = '${widget.award.rank} ${widget.award.name}';
    }

    _soldierId = widget.award.soldierId;
    _rank = widget.award.rank;
    _lastName = widget.award.name;
    _firstName = widget.award.firstName;
    _section = widget.award.section;
    _rankSort = widget.award.rankSort;
    _reason = widget.award.awardReason;

    _ach1Controller.text = widget.award.ach1;
    _ach2Controller.text = widget.award.ach2;
    _ach3Controller.text = widget.award.ach3;
    _ach4Controller.text = widget.award.ach4;
    _citationController.text = widget.award.citation;
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context, String userId) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave()) {
      WorkingAward saveAward = WorkingAward(
        id: widget.award.id,
        soldierId: _soldierId,
        owner: userId,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        awardReason: _reason!,
        ach1: _ach1Controller.text,
        ach2: _ach2Controller.text,
        ach3: _ach3Controller.text,
        ach4: _ach4Controller.text,
        citation: _citationController.text,
      );

      if (widget.award.id == null) {
        DocumentReference docRef = await firestore
            .collection(kWorkingAwardsCollection)
            .add(saveAward.toMap());

        saveAward.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kWorkingAwardsCollection)
            .doc(widget.award.id)
            .set(saveAward.toMap())
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
                  onChanged: (checked) {
                    createLessSoldiers(
                      collection: kWorkingAwardsCollection,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformItemPicker(
                  label: const Text('Award Reason'),
                  items: _reasons,
                  onChanged: (dynamic value) {
                    if (mounted) {
                      setState(() {
                        _reason = value;
                        updated = true;
                      });
                    }
                  },
                  value: _reason,
                ),
              ),
            ],
          ),
          PaddedTextField(
            controller: _ach1Controller,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            label: 'Achievement',
            decoration: const InputDecoration(
              labelText: 'Achievement',
            ),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            controller: _ach2Controller,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            label: 'Achievement',
            decoration: const InputDecoration(
              labelText: 'Achievement',
            ),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            controller: _ach3Controller,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            label: 'Achievement',
            decoration: const InputDecoration(
              labelText: 'Achievement',
            ),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            controller: _ach4Controller,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            label: 'Achievement',
            decoration: const InputDecoration(
              labelText: 'Achievement',
            ),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            controller: _citationController,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            label: 'Citation',
            decoration: const InputDecoration(
              labelText: 'Citation',
            ),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            onPressed: () {
              submit(context, user.uid);
            },
            child: Text(widget.award.id == null ? 'Add Award' : 'Update Award'),
          ),
        ],
      ),
    );
  }
}
