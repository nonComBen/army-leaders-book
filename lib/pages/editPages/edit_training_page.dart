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
import '../../methods/validate.dart';
import '../../models/training.dart';
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

class EditTrainingPage extends ConsumerStatefulWidget {
  const EditTrainingPage({
    Key? key,
    required this.training,
  }) : super(key: key);
  final Training training;

  @override
  EditTrainingPageState createState() => EditTrainingPageState();
}

class EditTrainingPageState extends ConsumerState<EditTrainingPage> {
  String _title = 'New Training';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _cyberController = TextEditingController();
  final TextEditingController _opsecController = TextEditingController();
  final TextEditingController _antiTerrorController = TextEditingController();
  final TextEditingController _lawController = TextEditingController();
  final TextEditingController _persRecController = TextEditingController();
  final TextEditingController _infoSecController = TextEditingController();
  final TextEditingController _ctipController = TextEditingController();
  final TextEditingController _gatController = TextEditingController();
  final TextEditingController _sereController = TextEditingController();
  final TextEditingController _tarpController = TextEditingController();
  final TextEditingController _eoController = TextEditingController();
  final TextEditingController _asapController = TextEditingController();
  final TextEditingController _suicideController = TextEditingController();
  final TextEditingController _sharpController = TextEditingController();
  final TextEditingController _add1Controller = TextEditingController();
  final TextEditingController _add1DateController = TextEditingController();
  final TextEditingController _add2Controller = TextEditingController();
  final TextEditingController _add2DateController = TextEditingController();
  final TextEditingController _add3Controller = TextEditingController();
  final TextEditingController _add3DateController = TextEditingController();
  final TextEditingController _add4Controller = TextEditingController();
  final TextEditingController _add4DateController = TextEditingController();
  final TextEditingController _add5Controller = TextEditingController();
  final TextEditingController _add5DateController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false, addMore = false;
  String? addMoreLess;
  FToast toast = FToast();

  DateTime? _cyberDate,
      _opsecDate,
      _antiTerrorDate,
      _lawDate,
      _persRecDate,
      _infoSecDate,
      _ctipDate,
      _gatDate,
      _sereDate,
      _tarpDate,
      _eoDate,
      _asapDate,
      _suicideDate,
      _sharpDate,
      _add1Date,
      _add2Date,
      _add3Date,
      _add4Date,
      _add5Date;

  @override
  void dispose() {
    _cyberController.dispose();
    _opsecController.dispose();
    _antiTerrorController.dispose();
    _lawController.dispose();
    _persRecController.dispose();
    _infoSecController.dispose();
    _ctipController.dispose();
    _gatController.dispose();
    _sereController.dispose();
    _tarpController.dispose();
    _eoController.dispose();
    _asapController.dispose();
    _suicideController.dispose();
    _sharpController.dispose();
    _add1Controller.dispose();
    _add1DateController.dispose();
    _add2Controller.dispose();
    _add2DateController.dispose();
    _add3Controller.dispose();
    _add3DateController.dispose();
    _add4Controller.dispose();
    _add4DateController.dispose();
    _add5Controller.dispose();
    _add5DateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.training.id != null) {
      _title = '${widget.training.rank} ${widget.training.name}';
    }

    _soldierId = widget.training.soldierId;
    _rank = widget.training.rank;
    _lastName = widget.training.name;
    _firstName = widget.training.firstName;
    _section = widget.training.section;
    _rankSort = widget.training.rankSort;
    _owner = widget.training.owner;
    _users = widget.training.users;

    _cyberController.text = widget.training.cyber;
    _opsecController.text = widget.training.opsec;
    _antiTerrorController.text = widget.training.antiTerror;
    _lawController.text = widget.training.lawOfWar;
    _persRecController.text = widget.training.persRec;
    _infoSecController.text = widget.training.infoSec;
    _ctipController.text = widget.training.ctip;
    _gatController.text = widget.training.gat;
    _sereController.text = widget.training.sere;
    _tarpController.text = widget.training.tarp;
    _eoController.text = widget.training.eo;
    _asapController.text = widget.training.asap;
    _suicideController.text = widget.training.suicide;
    _sharpController.text = widget.training.sharp;
    _add1Controller.text = widget.training.add1;
    _add1DateController.text = widget.training.add1Date;
    _add2Controller.text = widget.training.add2;
    _add2DateController.text = widget.training.add2Date;
    _add3Controller.text = widget.training.add3;
    _add3DateController.text = widget.training.add3Date;
    _add4Controller.text = widget.training.add4;
    _add4DateController.text = widget.training.add4Date;
    _add5Controller.text = widget.training.add5;
    _add5DateController.text = widget.training.add5Date;

    if (_add1DateController.text != '' ||
        _add2DateController.text != '' ||
        _add3DateController.text != '' ||
        _add4DateController.text != '' ||
        _add5DateController.text != '') {
      addMore = true;
    }
    if (addMore) {
      addMoreLess = 'Less Training';
    } else {
      addMoreLess = 'More Training';
    }

    _cyberDate = DateTime.tryParse(widget.training.cyber) ?? DateTime.now();
    _opsecDate = DateTime.tryParse(widget.training.opsec) ?? DateTime.now();
    _antiTerrorDate =
        DateTime.tryParse(widget.training.antiTerror) ?? DateTime.now();
    _lawDate = DateTime.tryParse(widget.training.lawOfWar) ?? DateTime.now();
    _persRecDate = DateTime.tryParse(widget.training.persRec) ?? DateTime.now();
    _infoSecDate = DateTime.tryParse(widget.training.infoSec) ?? DateTime.now();
    _ctipDate = DateTime.tryParse(widget.training.ctip) ?? DateTime.now();
    _gatDate = DateTime.tryParse(widget.training.gat) ?? DateTime.now();
    _sereDate = DateTime.tryParse(widget.training.sere) ?? DateTime.now();
    _tarpDate = DateTime.tryParse(widget.training.tarp) ?? DateTime.now();
    _eoDate = DateTime.tryParse(widget.training.eo) ?? DateTime.now();
    _asapDate = DateTime.tryParse(widget.training.asap) ?? DateTime.now();
    _sharpDate = DateTime.tryParse(widget.training.sharp) ?? DateTime.now();
    _suicideDate = DateTime.tryParse(widget.training.suicide) ?? DateTime.now();
    _add1Date = DateTime.tryParse(widget.training.add1Date) ?? DateTime.now();
    _add2Date = DateTime.tryParse(widget.training.add2Date) ?? DateTime.now();
    _add3Date = DateTime.tryParse(widget.training.add3Date) ?? DateTime.now();
    _add4Date = DateTime.tryParse(widget.training.add4Date) ?? DateTime.now();
    _add5Date = DateTime.tryParse(widget.training.add5Date) ?? DateTime.now();
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [
        _cyberController.text,
        _opsecController.text,
        _antiTerrorController.text,
        _lawController.text,
        _persRecController.text,
        _infoSecController.text,
        _ctipController.text,
        _gatController.text,
        _sereController.text,
        _tarpController.text,
        _eoController.text,
        _asapController.text,
        _suicideController.text,
        _sharpController.text,
        _add1DateController.text,
        _add2DateController.text,
        _add3DateController.text,
        _add4DateController.text,
        _add5DateController.text,
      ],
    )) {
      Training saveTraining = Training(
        id: widget.training.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        cyber: _cyberController.text,
        opsec: _opsecController.text,
        antiTerror: _antiTerrorController.text,
        lawOfWar: _lawController.text,
        persRec: _persRecController.text,
        infoSec: _infoSecController.text,
        ctip: _ctipController.text,
        gat: _gatController.text,
        sere: _sereController.text,
        tarp: _tarpController.text,
        eo: _eoController.text,
        asap: _asapController.text,
        suicide: _suicideController.text,
        sharp: _sharpController.text,
        add1: _add1Controller.text,
        add1Date: _add1DateController.text,
        add2: _add2Controller.text,
        add2Date: _add2DateController.text,
        add3: _add3Controller.text,
        add3Date: _add3DateController.text,
        add4: _add4Controller.text,
        add4Date: _add4DateController.text,
        add5: _add5Controller.text,
        add5Date: _add5DateController.text,
      );

      if (widget.training.id == null) {
        DocumentReference docRef = await firestore
            .collection(kTrainingCollection)
            .add(saveTraining.toMap());

        saveTraining.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kTrainingCollection)
            .doc(widget.training.id)
            .set(saveTraining.toMap())
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

  Widget addMoreTraining(double width) {
    return FormGridView(
      width: width,
      children: <Widget>[
        PaddedTextField(
          controller: _add1Controller,
          keyboardType: TextInputType.text,
          label: 'Additional Training 1',
          decoration: const InputDecoration(
            labelText: 'Additional Training 1',
          ),
        ),
        DateTextField(
          controller: _add1DateController,
          label: 'Additional Training 1 Date',
          date: _add1Date,
        ),
        PaddedTextField(
          controller: _add2Controller,
          keyboardType: TextInputType.text,
          label: 'Additional Training 2',
          decoration: const InputDecoration(
            labelText: 'Additional Training 2',
          ),
        ),
        DateTextField(
          controller: _add2DateController,
          label: 'Additional Training 2 Date',
          date: _add2Date,
        ),
        PaddedTextField(
          controller: _add3Controller,
          keyboardType: TextInputType.text,
          label: 'Additional Training 3',
          decoration: const InputDecoration(
            labelText: 'Additional Training 3',
          ),
        ),
        DateTextField(
          controller: _add3DateController,
          label: 'Additional Training 3 Date',
          date: _add3Date,
        ),
        PaddedTextField(
          controller: _add4Controller,
          keyboardType: TextInputType.text,
          label: 'Additional Training 4',
          decoration: const InputDecoration(
            labelText: 'Additional Training 4',
          ),
        ),
        DateTextField(
          controller: _add4DateController,
          label: 'Additional Training 4 Date',
          date: _add4Date,
        ),
        PaddedTextField(
          controller: _add5Controller,
          keyboardType: TextInputType.text,
          label: 'Additional Training 5',
          decoration: const InputDecoration(
            labelText: 'Additional Training 5',
          ),
        ),
        DateTextField(
          controller: _add5DateController,
          label: 'Additional Training 5 Date',
          date: _add5Date,
        ),
      ],
    );
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
                      collection: kTrainingCollection,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                  },
                ),
              ),
              DateTextField(
                controller: _cyberController,
                label: 'Cyber Date',
                date: _cyberDate,
              ),
              DateTextField(
                controller: _opsecController,
                label: 'OPSEC Date',
                date: _opsecDate,
              ),
              DateTextField(
                controller: _antiTerrorController,
                label: 'Anti-Terror Date',
                date: _antiTerrorDate,
              ),
              DateTextField(
                controller: _lawController,
                label: 'Law of War Date',
                date: _lawDate,
              ),
              DateTextField(
                controller: _persRecController,
                label: 'Personnel Recover Date',
                date: _persRecDate,
              ),
              DateTextField(
                controller: _infoSecController,
                label: 'Info Security Date',
                date: _infoSecDate,
              ),
              DateTextField(
                controller: _ctipController,
                label: 'CTIP Date',
                date: _ctipDate,
              ),
              DateTextField(
                controller: _gatController,
                label: 'GAT Date',
                date: _gatDate,
              ),
              DateTextField(
                controller: _sereController,
                label: 'SERE Date',
                date: _sereDate,
              ),
              DateTextField(
                controller: _tarpController,
                label: 'TARP Date',
                date: _tarpDate,
              ),
              DateTextField(
                controller: _eoController,
                label: 'EO Date',
                date: _eoDate,
              ),
              DateTextField(
                controller: _asapController,
                label: 'ASAP Date',
                date: _asapDate,
              ),
              DateTextField(
                controller: _suicideController,
                label: 'Suicide Prev Date',
                date: _suicideDate,
              ),
              DateTextField(
                controller: _sharpController,
                label: 'SHARP Date',
                date: _sharpDate,
              ),
            ],
          ),
          PlatformButton(
            onPressed: () {
              setState(() {
                addMore = !addMore;
                if (addMore) {
                  addMoreLess = 'Less Training';
                } else {
                  addMoreLess = 'More Training';
                }
              });
            },
            child: Text(addMoreLess!),
          ),
          if (addMore) addMoreTraining(width),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(widget.training.id == null
                ? 'Add Training'
                : 'Update Training'),
          ),
        ],
      ),
    );
  }
}
