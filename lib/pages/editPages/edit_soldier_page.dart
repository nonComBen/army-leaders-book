import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/custom_modal_bottom_sheet.dart';

import '../../methods/validate.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../auth_provider.dart';
import '../../methods/theme_methods.dart';
import '../../widgets/edit_delete_list_tile.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/award.dart';
import '../../models/pov.dart';
import '../../models/soldier.dart';
import '../../methods/rank_sort.dart';
import '../../widgets/anon_warning_banner.dart';

class EditSoldierPage extends ConsumerStatefulWidget {
  const EditSoldierPage({
    Key? key,
    required this.soldier,
  }) : super(key: key);
  final Soldier soldier;

  @override
  EditSoldierPageState createState() => EditSoldierPageState();
}

class EditSoldierPageState extends ConsumerState<EditSoldierPage> {
  String _title = 'New Soldier';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _miController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _dodIdController = TextEditingController();
  final TextEditingController _dorController = TextEditingController();
  final TextEditingController _mosController = TextEditingController();
  final TextEditingController _paraLnController = TextEditingController();
  final TextEditingController _reqMosController = TextEditingController();
  final TextEditingController _dutyController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _gainController = TextEditingController();
  final TextEditingController _etsController = TextEditingController();
  final TextEditingController _basdController = TextEditingController();
  final TextEditingController _pebdController = TextEditingController();
  final TextEditingController _nbcSuitController = TextEditingController();
  final TextEditingController _nbcMaskController = TextEditingController();
  final TextEditingController _nbcBootController = TextEditingController();
  final TextEditingController _nbcGloveController = TextEditingController();
  final TextEditingController _hatController = TextEditingController();
  final TextEditingController _bootController = TextEditingController();
  final TextEditingController _acuTopController = TextEditingController();
  final TextEditingController _acuTrouserController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _workPhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();
  final TextEditingController _nokController = TextEditingController();
  final TextEditingController _nokPhoneController = TextEditingController();
  final TextEditingController _maritalStatusController =
      TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  bool _promotable = false, updated = false, _assigned = true;
  String _civEd = '', _milEd = '';
  List<POV> _povs = [];
  List<Award> _awards = [];
  final List<String> _civEds = [
    '',
    'GED',
    'HS Diploma',
    '30 Semester Hour',
    '60 Semester Hours',
    '90 Semester Hours',
    'Associates',
    'Bachelors',
    'Masters',
    'Doctorate',
  ];
  final List<String> _milEds = [
    '',
    'None',
    'DLC1',
    'BLC',
    'DLC2',
    'ALC',
    'DLC3',
    'SLC',
    'DLC4',
    'MLC',
    'DLC5',
    'SMA',
  ];
  DateTime? _dorDate, _lossDate, _etsDate, _basdDate, _pebdDate, _gainDate;
  DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();

    if (widget.soldier.id != null) {
      _title = '${widget.soldier.rank} ${widget.soldier.lastName}';
    }
    _rankController.text = widget.soldier.rank;
    _lastNameController.text = widget.soldier.lastName;
    _firstNameController.text = widget.soldier.firstName;
    _miController.text = widget.soldier.mi;
    _assigned = widget.soldier.assigned;
    _supervisorController.text = widget.soldier.supervisor;
    _sectionController.text = widget.soldier.section;
    _dodIdController.text = widget.soldier.dodId;
    _mosController.text = widget.soldier.mos;
    _dutyController.text = widget.soldier.duty;
    _paraLnController.text = widget.soldier.paraLn;
    _reqMosController.text = widget.soldier.reqMos;
    _dorController.text = widget.soldier.dor;
    _lossController.text = widget.soldier.lossDate;
    _etsController.text = widget.soldier.ets;
    _gainController.text = widget.soldier.gainDate;
    _basdController.text = widget.soldier.basd;
    _pebdController.text = widget.soldier.pebd;
    _nbcSuitController.text = widget.soldier.nbcSuitSize;
    _nbcMaskController.text = widget.soldier.nbcMaskSize;
    _nbcBootController.text = widget.soldier.nbcBootSize;
    _nbcGloveController.text = widget.soldier.nbcGloveSize;
    _hatController.text = widget.soldier.hatSize;
    _bootController.text = widget.soldier.bootSize;
    _acuTopController.text = widget.soldier.acuTopSize;
    _acuTrouserController.text = widget.soldier.acuTrouserSize;
    _addressController.text = widget.soldier.address;
    _cityController.text = widget.soldier.city;
    _stateController.text = widget.soldier.state;
    _zipController.text = widget.soldier.zip;
    _phoneController.text = widget.soldier.phone;
    _workEmailController.text = widget.soldier.workEmail;
    _workPhoneController.text = widget.soldier.workPhone;
    _emailController.text = widget.soldier.email;
    _nokController.text = widget.soldier.nok;
    _maritalStatusController.text = widget.soldier.maritalStatus;
    _nokPhoneController.text = widget.soldier.nokPhone;
    _commentsController.text = widget.soldier.comments;

    _promotable = widget.soldier.promotable == '(P)';

    _civEd = widget.soldier.civEd;
    _milEd = widget.soldier.milEd;

    _povs = widget.soldier.povs.map((e) => POV.fromMap(e)).toList();
    _awards = widget.soldier.awards.map((e) => Award.fromMap(e)).toList();

    _dorDate = DateTime.tryParse(widget.soldier.dor) ?? DateTime.now();
    _lossDate = DateTime.tryParse(widget.soldier.lossDate) ?? DateTime.now();
    _etsDate = DateTime.tryParse(widget.soldier.ets) ?? DateTime.now();
    _gainDate = DateTime.tryParse(widget.soldier.gainDate) ?? DateTime.now();
    _basdDate = DateTime.tryParse(widget.soldier.basd) ?? DateTime.now();
    _pebdDate = DateTime.tryParse(widget.soldier.pebd) ?? DateTime.now();
  }

  @override
  void dispose() {
    _rankController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _miController.dispose();
    _supervisorController.dispose();
    _sectionController.dispose();
    _dodIdController.dispose();
    _mosController.dispose();
    _dorController.dispose();
    _dutyController.dispose();
    _paraLnController.dispose();
    _reqMosController.dispose();
    _lossController.dispose();
    _etsController.dispose();
    _basdController.dispose();
    _pebdController.dispose();
    _nbcSuitController.dispose();
    _nbcMaskController.dispose();
    _nbcBootController.dispose();
    _nbcGloveController.dispose();
    _hatController.dispose();
    _bootController.dispose();
    _acuTopController.dispose();
    _acuTrouserController.dispose();
    _gainController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _workPhoneController.dispose();
    _emailController.dispose();
    _workEmailController.dispose();
    _nokPhoneController.dispose();
    _nokController.dispose();
    _maritalStatusController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void deletePov(BuildContext context, int index) {
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
          _povs.removeAt(index);
        });
      },
      secondary: () {},
    );
  }

  void deleteAward(BuildContext context, int index) {
    Widget title = const Text('Delete Award?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Are you sure you want to delete this award?'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        setState(() {
          _awards.removeAt(index);
        });
      },
      secondary: () {},
    );
  }

  void editAward(
      {required BuildContext context, required Award award, int? index}) {
    TextEditingController name = TextEditingController(text: award.name);
    TextEditingController number = TextEditingController(text: award.number);
    customModalBottomSheet(
      context,
      ListView(
        children: [
          HeaderText(
            index == null ? 'Add Award' : 'Edit Award',
          ),
          PaddedTextField(
            controller: name,
            keyboardType: TextInputType.text,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Award Name',
            ),
            label: 'Award Name',
          ),
          PaddedTextField(
            controller: number,
            keyboardType: TextInputType.number,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Number of Awards',
            ),
            label: 'Number of Awards',
          ),
          PlatformButton(
            onPressed: () {
              Award saveAward = Award(
                  id: award.id,
                  owner: award.owner,
                  users: award.users,
                  soldierId: award.soldierId,
                  name: name.text,
                  number: number.text);
              setState(() {
                if (index != null) {
                  _awards[index] = saveAward;
                } else {
                  _awards.add(saveAward);
                }
              });
              Navigator.of(context).pop();
            },
            child: Text(index == null ? 'Add Award' : 'Edit Award'),
          )
        ],
      ),
    );
  }

  void editPov({required BuildContext context, required POV pov, int? index}) {
    TextEditingController year = TextEditingController(text: pov.year);
    TextEditingController make = TextEditingController(text: pov.make);
    TextEditingController model = TextEditingController(text: pov.model);
    TextEditingController plate = TextEditingController(text: pov.plate);
    TextEditingController state = TextEditingController(text: pov.state);
    TextEditingController regExp = TextEditingController(text: pov.regExp);
    TextEditingController ins = TextEditingController(text: pov.ins);
    TextEditingController insExp = TextEditingController(text: pov.insExp);

    customModalBottomSheet(
      context,
      ListView(
        children: [
          HeaderText(index == null ? 'Add POV' : 'Edit POV'),
          PaddedTextField(
            controller: year,
            keyboardType: TextInputType.number,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Year',
            ),
            label: 'Year',
          ),
          PaddedTextField(
            controller: make,
            keyboardType: TextInputType.text,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Make',
            ),
            label: 'Make',
          ),
          PaddedTextField(
            controller: model,
            keyboardType: TextInputType.text,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Model',
            ),
            label: 'Model',
          ),
          PaddedTextField(
            controller: plate,
            keyboardType: TextInputType.text,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Plates',
            ),
            label: 'Plates',
          ),
          PaddedTextField(
            controller: state,
            keyboardType: TextInputType.text,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'State',
            ),
            label: 'State',
          ),
          PaddedTextField(
            controller: regExp,
            keyboardType: TextInputType.datetime,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Registration Exp',
            ),
            label: 'Registration Exp',
          ),
          PaddedTextField(
            controller: ins,
            keyboardType: TextInputType.text,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Insurance',
            ),
            label: 'Insurance',
          ),
          PaddedTextField(
            controller: insExp,
            keyboardType: TextInputType.datetime,
            enabled: true,
            decoration: const InputDecoration(
              labelText: 'Insurance Exp',
            ),
            label: 'Insurance Exp',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformButton(
              onPressed: () {
                POV savePov = POV(
                  id: pov.id,
                  owner: pov.owner,
                  users: pov.users,
                  soldierId: pov.soldierId,
                  year: year.text,
                  make: make.text,
                  model: model.text,
                  plate: plate.text,
                  state: state.text,
                  regExp: regExp.text,
                  ins: ins.text,
                  insExp: insExp.text,
                );
                setState(() {
                  if (index == null) {
                    _povs.add(savePov);
                  } else {
                    _povs[index] = savePov;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(index == null ? 'Add POV' : 'Edit POV'),
            ),
          )
        ],
      ),
    );
  }

  void submit(BuildContext context) async {
    if (validateAndSave(
      _formKey,
      [
        _dorController.text,
        _lossController.text,
        _gainController.text,
        _etsController.text,
        _basdController.text,
        _pebdController.text,
      ],
    )) {
      Soldier saveSoldier = Soldier(
        id: widget.soldier.id,
        owner: widget.soldier.owner,
        users: widget.soldier.users,
        rank: _rankController.text,
        rankSort: getRankSort(_rankController.text),
        promotable: _promotable ? '(P)' : '',
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        mi: _miController.text,
        assigned: _assigned,
        supervisor: _supervisorController.text,
        section: _sectionController.text,
        dodId: _dodIdController.text,
        dor: _dorController.text,
        mos: _mosController.text,
        duty: _dutyController.text,
        paraLn: _paraLnController.text,
        reqMos: _reqMosController.text,
        lossDate: _lossController.text,
        ets: _etsController.text,
        basd: _basdController.text,
        pebd: _pebdController.text,
        gainDate: _gainController.text,
        civEd: _civEd,
        milEd: _milEd,
        nbcSuitSize: _nbcSuitController.text,
        nbcMaskSize: _nbcMaskController.text,
        nbcBootSize: _nbcBootController.text,
        nbcGloveSize: _nbcGloveController.text,
        hatSize: _hatController.text,
        bootSize: _bootController.text,
        acuTopSize: _acuTopController.text,
        acuTrouserSize: _acuTrouserController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zip: _zipController.text,
        phone: _phoneController.text,
        workPhone: _workPhoneController.text,
        email: _emailController.text,
        workEmail: _workEmailController.text,
        nok: _nokController.text,
        nokPhone: _nokPhoneController.text,
        maritalStatus: _maritalStatusController.text,
        comments: _commentsController.text,
        povs: _povs.map((e) => e.toMap()).toList(),
        awards: _awards.map((e) => e.toMap()).toList(),
      );

      if (widget.soldier.id == null) {
        firestore
            .collection('soldiers')
            .add(saveSoldier.toMap())
            .then((docRef) {
          saveSoldier.id = docRef.id;
          Navigator.pop(context);
        });
      } else {
        firestore
            .collection('soldiers')
            .doc(widget.soldier.id)
            .set(saveSoldier.toMap())
            .then((value) => Navigator.of(context).pop());
      }
    } else {
      MyToast myToast = const MyToast(
        message:
            'Form is invalid - rank and last name must not be blank and dates must be in yyyy-MM-dd format',
      );
      FToast toast = FToast();
      toast.showToast(child: myToast);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
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
              PaddedTextField(
                controller: _rankController,
                enabled: true,
                textCapitalization: TextCapitalization.characters,
                validator: (value) =>
                    value!.isEmpty ? 'Rank can\'t be empty' : null,
                decoration: const InputDecoration(
                  labelText: 'Rank',
                ),
                label: 'Rank',
                onChanged: (value) {
                  updated = true;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                  title: const Text('Promotable'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _promotable,
                  onChanged: (checked) {
                    setState(() {
                      _promotable = checked!;
                      updated = true;
                    });
                  },
                ),
              ),
              PaddedTextField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                enabled: true,
                validator: (value) =>
                    value!.isEmpty ? 'Last Name can\'t be empty' : null,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
                label: 'Last Name',
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                label: 'First Name',
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
                controller: _firstNameController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                controller: _miController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Middle Initial'),
                label: 'Middle Initial',
                onChanged: (value) {
                  updated = true;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                    title: Text(_assigned ? 'Assigned' : 'Attached'),
                    value: _assigned,
                    onChanged: (value) {
                      setState(() {
                        _assigned = value!;
                      });
                    }),
              ),
              PaddedTextField(
                label: 'Supervisor',
                decoration: const InputDecoration(
                  labelText: 'Supervisor',
                ),
                controller: _supervisorController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Section',
                decoration: const InputDecoration(
                  labelText: 'Section',
                ),
                controller: _sectionController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'DoD ID',
                decoration: const InputDecoration(
                  labelText: 'DoD ID',
                ),
                controller: _dodIdController,
                keyboardType: TextInputType.number,
                onChanged: (_) => updated = true,
              ),
              DateTextField(
                  label: 'Date of Rank',
                  date: _dorDate,
                  controller: _dorController),
              PaddedTextField(
                label: 'MOS',
                decoration: const InputDecoration(
                  labelText: 'MOS',
                ),
                controller: _mosController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Duty Position',
                decoration: const InputDecoration(
                  labelText: 'Duty Position',
                ),
                controller: _dutyController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Paragraph/Line',
                decoration: const InputDecoration(
                  labelText: 'Paragraph/Line',
                ),
                controller: _paraLnController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Duty MOS',
                decoration: const InputDecoration(
                  labelText: 'Duty MOS',
                ),
                controller: _reqMosController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              DateTextField(
                  label: 'Loss Date',
                  date: _lossDate,
                  controller: _lossController),
              DateTextField(
                  label: 'ETS Date',
                  date: _etsDate,
                  controller: _etsController),
              DateTextField(
                  label: 'BASD', date: _basdDate, controller: _basdController),
              DateTextField(
                  label: 'PEBD', date: _pebdDate, controller: _pebdController),
              DateTextField(
                  label: 'Gain Date',
                  date: _gainDate,
                  controller: _gainController),
            ],
          ),
          Divider(
            color: getOnPrimaryColor(context),
          ),
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
              PaddedTextField(
                label: 'CBRN Suit Size',
                decoration: const InputDecoration(
                  labelText: 'CBRN Suit Size',
                ),
                controller: _nbcSuitController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'CBRN Mask Size',
                decoration: const InputDecoration(
                  labelText: 'CBRN Mask Size',
                ),
                controller: _nbcMaskController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'CBRN Boot Size',
                decoration: const InputDecoration(
                  labelText: 'CBRN Boot Size',
                ),
                controller: _nbcBootController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'CBRN Glove Size',
                decoration: const InputDecoration(
                  labelText: 'CBRN Glove Size',
                ),
                controller: _nbcGloveController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Hat Size',
                decoration: const InputDecoration(
                  labelText: 'Hit Size',
                ),
                controller: _hatController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Boot Size',
                decoration: const InputDecoration(
                  labelText: 'Boot Size',
                ),
                controller: _bootController,
                keyboardType: TextInputType.number,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'OCP Top Size',
                decoration: const InputDecoration(
                  labelText: 'OCP Top Size',
                ),
                controller: _acuTopController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'OCP Trouser Size',
                decoration: const InputDecoration(
                  labelText: 'OCP Trouser Size',
                ),
                controller: _acuTrouserController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
            ],
          ),
          Divider(
            color: getOnPrimaryColor(context),
          ),
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
                child: PlatformItemPicker(
                  label: const Text('Civilian Education'),
                  items: _civEds,
                  onChanged: (dynamic value) {
                    setState(() {
                      _civEd = value;
                      updated = true;
                    });
                  },
                  value: _civEd,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformItemPicker(
                  label: const Text('Military Education'),
                  items: _milEds,
                  onChanged: (dynamic value) {
                    setState(() {
                      _milEd = value;
                      updated = true;
                    });
                  },
                  value: _milEd,
                ),
              ),
              PaddedTextField(
                label: 'Address',
                decoration: const InputDecoration(
                  labelText: 'Address',
                ),
                controller: _addressController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'City',
                decoration: const InputDecoration(
                  labelText: 'Cty',
                ),
                controller: _cityController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'State',
                decoration: const InputDecoration(
                  labelText: 'State',
                ),
                controller: _stateController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Zip Code',
                decoration: const InputDecoration(
                  labelText: 'Zip Code',
                ),
                controller: _zipController,
                keyboardType: TextInputType.number,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Personal Phone',
                decoration: const InputDecoration(
                  labelText: 'Personal Phone',
                ),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Work Phone',
                decoration: const InputDecoration(
                  labelText: 'Work Phone',
                ),
                controller: _workPhoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Email',
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Work Email',
                decoration: const InputDecoration(
                  labelText: 'Work Email',
                ),
                controller: _workEmailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Next of Kin',
                decoration: const InputDecoration(
                  labelText: 'Next of Kin',
                ),
                controller: _nokController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'NOK Phone',
                decoration: const InputDecoration(
                  labelText: 'NOK Phone',
                ),
                controller: _nokPhoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => updated = true,
              ),
              PaddedTextField(
                label: 'Marital Status',
                decoration: const InputDecoration(
                  labelText: 'Marital Status',
                ),
                controller: _maritalStatusController,
                keyboardType: TextInputType.text,
                onChanged: (_) => updated = true,
              ),
            ],
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            controller: _commentsController,
            enabled: true,
            label: 'Comments',
            decoration: const InputDecoration(labelText: 'Comments'),
            onChanged: (value) {
              updated = true;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformListTile(
              title: Text(
                'POVs',
                style: TextStyle(color: getOnPrimaryColor(context)),
              ),
              color: getPrimaryColor(context),
              trailing: PlatformIconButton(
                icon: Icon(
                  Icons.add,
                  color: getOnPrimaryColor(context),
                ),
                onPressed: () => editPov(
                  context: context,
                  pov: POV(
                    owner: user.uid,
                    users: [user.uid],
                    soldierId: widget.soldier.id!,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              padding: const EdgeInsets.all(0.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width > 700 ? 2 : 1,
                  childAspectRatio: width > 900
                      ? 900 / 150
                      : width > 700
                          ? width / 150
                          : width / 75),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _povs.length,
              itemBuilder: (ibContext, position) {
                return EditDeleteListTile(
                  title:
                      '${_povs[position].year} ${_povs[position].make} ${_povs[position].model}',
                  subTitle: Text(
                      'Reg Exp: ${_povs[position].regExp}, Ins Exp: ${_povs[position].insExp}'),
                  onIconPressed: () {
                    deletePov(context, position);
                  },
                  onTap: () {
                    editPov(
                      context: context,
                      pov: _povs[position],
                      index: position,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformListTile(
              title: Text(
                'Awards',
                style: TextStyle(color: getOnPrimaryColor(context)),
              ),
              color: getPrimaryColor(context),
              trailing: PlatformIconButton(
                icon: Icon(
                  Icons.add,
                  color: getOnPrimaryColor(context),
                ),
                onPressed: () => editAward(
                  context: context,
                  award: Award(
                    owner: user.uid,
                    users: [user.uid],
                    soldierId: widget.soldier.id!,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              padding: const EdgeInsets.all(0.0),
              primary: false,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width > 700 ? 2 : 1,
                childAspectRatio: width > 900
                    ? 900 / 150
                    : width > 700
                        ? width / 150
                        : width / 75,
              ),
              shrinkWrap: true,
              itemCount: _awards.length,
              itemBuilder: (ctx, position) {
                return EditDeleteListTile(
                  title:
                      '${_awards[position].name}: ${_awards[position].number}',
                  onIconPressed: () {
                    deleteAward(
                      context,
                      position,
                    );
                  },
                  onTap: () {
                    editAward(
                        context: context,
                        award: _awards[position],
                        index: position);
                  },
                );
              },
            ),
          ),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(
                widget.soldier.id == null ? 'Add Soldier' : 'Update Soldier'),
          ),
        ],
      ),
    );
  }
}
