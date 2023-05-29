import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/edit_delete_list_tile.dart';
import '../../widgets/more_tiles_header.dart';
import '../../constants/firestore_collections.dart';
import '../../methods/create_less_soldiers.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/medpro.dart';
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

class EditMedprosPage extends ConsumerStatefulWidget {
  const EditMedprosPage({
    Key? key,
    required this.medpro,
  }) : super(key: key);
  final Medpro medpro;

  @override
  EditMedprosPageState createState() => EditMedprosPageState();
}

class EditMedprosPageState extends ConsumerState<EditMedprosPage> {
  String _title = 'New MedPros';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phaController = TextEditingController();
  final TextEditingController _dentalController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _hearingController = TextEditingController();
  final TextEditingController _hivController = TextEditingController();
  final TextEditingController _fluController = TextEditingController();
  final TextEditingController _mmrController = TextEditingController();
  final TextEditingController _varicellaController = TextEditingController();
  final TextEditingController _polioController = TextEditingController();
  final TextEditingController _tuberculinController = TextEditingController();
  final TextEditingController _tetanusController = TextEditingController();
  final TextEditingController _hepAController = TextEditingController();
  final TextEditingController _hepBController = TextEditingController();
  final TextEditingController _encephalitisController = TextEditingController();
  final TextEditingController _meningController = TextEditingController();
  final TextEditingController _typhoidController = TextEditingController();
  final TextEditingController _yellowController = TextEditingController();
  final TextEditingController _smallPoxController = TextEditingController();
  final TextEditingController _anthraxController = TextEditingController();

  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<Soldier>? allSoldiers, lessSoldiers;
  List<dynamic>? _otherImms;
  bool removeSoldiers = false, updated = false, expanded = false;
  DateTime? _phaDate,
      _dentalDate,
      _visionDate,
      _hearingDate,
      _hivDate,
      _fluDate,
      _mmrDate,
      _varicellaDate,
      _polioDate,
      _tuberDate,
      _tetanusDate,
      _hepADate,
      _hepBDate,
      _encephalitisDate,
      _meningDate,
      _typhoidDate,
      _yellowDate,
      _smallPoxDate,
      _anthraxDate;
  FToast toast = FToast();

  @override
  void dispose() {
    _phaController.dispose();
    _dentalController.dispose();
    _visionController.dispose();
    _hearingController.dispose();
    _hivController.dispose();
    _fluController.dispose();
    _mmrController.dispose();
    _varicellaController.dispose();
    _polioController.dispose();
    _tuberculinController.dispose();
    _tetanusController.dispose();
    _hepAController.dispose();
    _hepBController.dispose();
    _encephalitisController.dispose();
    _meningController.dispose();
    _typhoidController.dispose();
    _yellowController.dispose();
    _smallPoxController.dispose();
    _anthraxController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.medpro.id != null) {
      _title = '${widget.medpro.rank} ${widget.medpro.name}';
    }

    _soldierId = widget.medpro.soldierId;
    _rank = widget.medpro.rank;
    _lastName = widget.medpro.name;
    _firstName = widget.medpro.firstName;
    _section = widget.medpro.section;
    _rankSort = widget.medpro.rankSort;
    _owner = widget.medpro.owner;
    _users = widget.medpro.users;

    _phaController.text = widget.medpro.pha;
    _dentalController.text = widget.medpro.dental;
    _visionController.text = widget.medpro.vision;
    _hearingController.text = widget.medpro.hearing;
    _hivController.text = widget.medpro.hiv;
    _fluController.text = widget.medpro.flu;
    _mmrController.text = widget.medpro.mmr;
    _varicellaController.text = widget.medpro.varicella;
    _polioController.text = widget.medpro.polio;
    _tuberculinController.text = widget.medpro.tuberculin;
    _tetanusController.text = widget.medpro.tetanus;
    _hepAController.text = widget.medpro.hepA;
    _hepBController.text = widget.medpro.hepB;
    _encephalitisController.text = widget.medpro.encephalitis;
    _meningController.text = widget.medpro.meningococcal;
    _typhoidController.text = widget.medpro.typhoid;
    _yellowController.text = widget.medpro.yellow;
    _smallPoxController.text = widget.medpro.smallPox;
    _anthraxController.text = widget.medpro.anthrax;
    _otherImms = widget.medpro.otherImms;

    if (widget.medpro.mmr != '' ||
        widget.medpro.varicella != '' ||
        widget.medpro.polio != '' ||
        widget.medpro.tuberculin != '' ||
        widget.medpro.tetanus != '' ||
        widget.medpro.hepA != '' ||
        widget.medpro.hepB != '' ||
        widget.medpro.encephalitis != '' ||
        widget.medpro.meningococcal != '' ||
        widget.medpro.typhoid != '' ||
        widget.medpro.yellow != '' ||
        widget.medpro.smallPox != '' ||
        widget.medpro.anthrax != '') {
      expanded = true;
    } else {
      expanded = false;
    }

    _phaDate = DateTime.tryParse(widget.medpro.pha) ?? DateTime.now();
    _dentalDate = DateTime.tryParse(widget.medpro.dental) ?? DateTime.now();
    _visionDate = DateTime.tryParse(widget.medpro.vision) ?? DateTime.now();
    _hearingDate = DateTime.tryParse(widget.medpro.hearing) ?? DateTime.now();
    _hivDate = DateTime.tryParse(widget.medpro.hiv) ?? DateTime.now();
    _fluDate = DateTime.tryParse(widget.medpro.flu) ?? DateTime.now();
    _mmrDate = DateTime.tryParse(widget.medpro.mmr) ?? DateTime.now();
    _varicellaDate =
        DateTime.tryParse(widget.medpro.varicella) ?? DateTime.now();
    _polioDate = DateTime.tryParse(widget.medpro.polio) ?? DateTime.now();
    _tuberDate = DateTime.tryParse(widget.medpro.tuberculin) ?? DateTime.now();
    _tetanusDate = DateTime.tryParse(widget.medpro.tetanus) ?? DateTime.now();
    _hepADate = DateTime.tryParse(widget.medpro.hepA) ?? DateTime.now();
    _hepBDate = DateTime.tryParse(widget.medpro.hepB) ?? DateTime.now();
    _encephalitisDate =
        DateTime.tryParse(widget.medpro.encephalitis) ?? DateTime.now();
    _meningDate =
        DateTime.tryParse(widget.medpro.meningococcal) ?? DateTime.now();
    _typhoidDate = DateTime.tryParse(widget.medpro.typhoid) ?? DateTime.now();
    _yellowDate = DateTime.tryParse(widget.medpro.yellow) ?? DateTime.now();
    _smallPoxDate = DateTime.tryParse(widget.medpro.smallPox) ?? DateTime.now();
    _anthraxDate = DateTime.tryParse(widget.medpro.anthrax) ?? DateTime.now();
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [
        _phaController.text,
        _dentalController.text,
        _visionController.text,
        _hearingController.text,
        _hivController.text,
        _fluController.text,
        _mmrController.text,
        _varicellaController.text,
        _polioController.text,
        _tuberculinController.text,
        _tetanusController.text,
        _hepAController.text,
        _hepBController.text,
        _encephalitisController.text,
        _meningController.text,
        _typhoidController.text,
        _yellowController.text,
        _smallPoxController.text,
        _anthraxController.text,
      ],
    )) {
      Medpro saveMedpros = Medpro(
        id: widget.medpro.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        pha: _phaController.text,
        dental: _dentalController.text,
        vision: _visionController.text,
        hearing: _hearingController.text,
        hiv: _hivController.text,
        flu: _fluController.text,
        anthrax: _anthraxController.text,
        encephalitis: _encephalitisController.text,
        hepA: _hepAController.text,
        hepB: _hepBController.text,
        meningococcal: _meningController.text,
        mmr: _mmrController.text,
        polio: _polioController.text,
        smallPox: _smallPoxController.text,
        tetanus: _tetanusController.text,
        tuberculin: _tuberculinController.text,
        typhoid: _typhoidController.text,
        varicella: _varicellaController.text,
        yellow: _yellowController.text,
        otherImms: _otherImms,
      );

      if (widget.medpro.id == null) {
        DocumentReference docRef = await firestore
            .collection(kMedprosCollection)
            .add(saveMedpros.toMap());

        saveMedpros.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kMedprosCollection)
            .doc(widget.medpro.id)
            .set(saveMedpros.toMap())
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

  Widget moreImmunizations(double width) {
    if (expanded) {
      return Column(
        children: [
          FormGridView(
            width: width,
            children: <Widget>[
              DateTextField(
                controller: _mmrController,
                label: 'MMR Date',
                date: _mmrDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _varicellaController,
                label: 'Varicella Date',
                date: _varicellaDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _polioController,
                label: 'Polio Date',
                date: _polioDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _tuberculinController,
                label: 'Tuberculin Date',
                date: _tuberDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _tetanusController,
                label: 'Tetanus Date',
                date: _tetanusDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _hepAController,
                label: 'Hepatitis A Date',
                date: _hepADate,
                minYears: 30,
              ),
              DateTextField(
                controller: _hepBController,
                label: 'Hepatitis B Date',
                date: _hepBDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _encephalitisController,
                label: 'Encephalitis Date',
                date: _encephalitisDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _meningController,
                label: 'Meningococcal Date',
                date: _meningDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _typhoidController,
                label: 'Typhoid Date',
                date: _typhoidDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _yellowController,
                label: 'Yellow Fever Date',
                date: _yellowDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _smallPoxController,
                label: 'Small Pox Date',
                date: _smallPoxDate,
                minYears: 30,
              ),
              DateTextField(
                controller: _anthraxController,
                label: 'Anthrax Date',
                date: _anthraxDate,
                minYears: 30,
              ),
            ],
          ),
          const Divider(),
          MoreTilesHeader(
            label: 'Other Immunizations',
            onPressed: () => _editImm(context, null),
          ),
          if (_otherImms!.isNotEmpty)
            FormGridView(
              width: width,
              children: _otherImms!
                  .map(
                    (imm) => EditDeleteListTile(
                      title: imm['title'],
                      subTitle: imm['date'],
                      onIconPressed: () =>
                          deleteImm(context, _otherImms!.indexOf(imm)),
                      onTap: () => _editImm(context, _otherImms!.indexOf(imm)),
                    ),
                  )
                  .toList(),
            ),
        ],
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  void deleteImm(BuildContext context, int index) {
    Widget title = const Text('Delete POV?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Are you sure you want to delete this POV?'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        setState(() {
          _otherImms!.removeAt(index);
        });
      },
      secondary: () {},
    );
  }

  void _editImm(BuildContext context, int? index) {
    TextEditingController titleController = TextEditingController();
    if (index != null) titleController.text = _otherImms![index]['title'];
    TextEditingController dateController = TextEditingController();
    if (index != null) dateController.text = _otherImms![index]['date'];
    Widget title =
        Text(index != null ? 'Edit Immunization' : 'Add Immunization');
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PaddedTextField(
          controller: titleController,
          keyboardType: TextInputType.text,
          label: 'Immunization',
          decoration: const InputDecoration(labelText: 'Immunization'),
        ),
        PaddedTextField(
          controller: dateController,
          keyboardType: TextInputType.text,
          label: 'Date',
          decoration: const InputDecoration(labelText: 'Date'),
        ),
      ],
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Immunization' : 'Edit Immunization',
      primary: () {
        saveImms(index, titleController.text, dateController.text);
      },
      secondary: () {},
    );
  }

  void saveImms(int? index, String title, String date) {
    setState(() {
      if (index != null) {
        _otherImms![index]['title'] = title;
        _otherImms![index]['date'] = date;
      } else {
        _otherImms!.add(
          {'title': title, 'date': date},
        );
      }
    });
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
                      collection: kMedprosCollection,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                  },
                ),
              ),
              DateTextField(
                controller: _phaController,
                label: 'PHA Date',
                date: _phaDate,
                minYears: 2,
                maxYears: 1,
              ),
              DateTextField(
                controller: _dentalController,
                label: 'Dental Date',
                date: _dentalDate,
              ),
              DateTextField(
                controller: _visionController,
                label: 'Vision Date',
                date: _visionDate,
              ),
              DateTextField(
                controller: _hearingController,
                label: 'Hearing Date',
                date: _hearingDate,
              ),
              DateTextField(
                controller: _hivController,
                label: 'HIV Date',
                date: _hivDate,
              ),
              DateTextField(
                controller: _fluController,
                label: 'Influenza Date',
                date: _fluDate,
              ),
            ],
          ),
          PlatformButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: expanded
                ? const Text('Less Immunizations')
                : const Text('More Immunizations'),
          ),
          moreImmunizations(width),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(
                widget.medpro.id == null ? 'Add MedPros' : 'Update MedPros'),
          ),
        ],
      ),
    );
  }
}
