import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../methods/theme_methods.dart';
import '../../auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/medpro.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
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

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      DocumentSnapshot doc =
          soldiers!.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
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
        DocumentReference docRef =
            await firestore.collection('medpros').add(saveMedpros.toMap());

        saveMedpros.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('medpros')
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
          GridView.count(
            primary: false,
            crossAxisCount: width > 700 ? 2 : 1,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            childAspectRatio: width > 900
                ? 900 / 200
                : width > 700
                    ? width / 200
                    : width / 100,
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _mmrController,
                  label: 'MMR Date',
                  date: _mmrDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _varicellaController,
                  label: 'Varicella Date',
                  date: _varicellaDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _polioController,
                  label: 'Polio Date',
                  date: _polioDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _tuberculinController,
                  label: 'Tuberculin Date',
                  date: _tuberDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _tetanusController,
                  label: 'Tetanus Date',
                  date: _tetanusDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _hepAController,
                  label: 'Hepatitis A Date',
                  date: _hepADate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _hepBController,
                  label: 'Hepatitis B Date',
                  date: _hepBDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _encephalitisController,
                  label: 'Encephalitis Date',
                  date: _encephalitisDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _meningController,
                  label: 'Meningococcal Date',
                  date: _meningDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _typhoidController,
                  label: 'Typhoid Date',
                  date: _typhoidDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _yellowController,
                  label: 'Yellow Fever Date',
                  date: _yellowDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _smallPoxController,
                  label: 'Small Pox Date',
                  date: _smallPoxDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTextField(
                  controller: _anthraxController,
                  label: 'Anthrax Date',
                  date: _anthraxDate,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: HeaderText(
                  'Other Immunizations',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformIconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _editImm(context, null);
                  },
                ),
              )
            ],
          ),
          if (_otherImms!.isNotEmpty)
            GridView.count(
              primary: false,
              crossAxisCount: width > 700 ? 2 : 1,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              childAspectRatio: width > 900
                  ? 900 / 200
                  : width > 700
                      ? width / 200
                      : width / 100,
              shrinkWrap: true,
              children: _otherImms!
                  .map(
                    (imm) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        color: getContrastingBackgroundColor(context),
                        child: PlatformListTile(
                          title: Text(imm['title']),
                          subtitle: Text(imm['date']),
                          trailing: PlatformIconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _otherImms!.removeAt(_otherImms!.indexOf(imm));
                              });
                            },
                          ),
                          onTap: () {
                            _editImm(context, _otherImms!.indexOf(imm));
                          },
                        ),
                      ),
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
          decoration: const InputDecoration(labelText: 'Immunization'),
        ),
        PaddedTextField(
          controller: dateController,
          keyboardType: TextInputType.text,
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

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('medpros')
          .where('users', arrayContains: userId)
          .get();
      if (apfts.docs.isNotEmpty) {
        for (var doc in apfts.docs) {
          lessSoldiers!
              .removeWhere((soldierDoc) => soldierDoc.id == doc['soldierId']);
        }
      }
    }
    if (lessSoldiers!.isEmpty) {
      if (mounted) {
        toast.showToast(
          child: const MyToast(
            message: 'All Soldiers have been added',
          ),
        );
      }
    }

    setState(() {
      if (checked! && lessSoldiers!.isNotEmpty) {
        _soldierId = null;
        removeSoldiers = true;
      } else {
        _soldierId = null;
        removeSoldiers = false;
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    toast.context = context;
    return PlatformScaffold(
      title: _title,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onWillPop:
            updated ? () => onBackPressed(context) : () => Future(() => true),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width > 932 ? (width - 916) / 2 : 16),
          child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
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
                        child: FutureBuilder(
                            future: firestore
                                .collection('soldiers')
                                .where('users', arrayContains: user.uid)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return const Center(
                                      child: CircularProgressIndicator());
                                default:
                                  allSoldiers = snapshot.data!.docs;
                                  soldiers = removeSoldiers
                                      ? lessSoldiers
                                      : allSoldiers;
                                  soldiers!.sort((a, b) => a['lastName']
                                      .toString()
                                      .compareTo(b['lastName'].toString()));
                                  soldiers!.sort((a, b) => a['rankSort']
                                      .toString()
                                      .compareTo(b['rankSort'].toString()));
                                  return PlatformItemPicker(
                                    label: const Text('Soldier'),
                                    items: soldiers!.map((e) => e.id).toList(),
                                    onChanged: (value) {
                                      int index = soldiers!
                                          .indexWhere((doc) => doc.id == value);
                                      if (mounted) {
                                        setState(() {
                                          _soldierId = value;
                                          _rank = soldiers![index]['rank'];
                                          _lastName =
                                              soldiers![index]['lastName'];
                                          _firstName =
                                              soldiers![index]['firstName'];
                                          _section =
                                              soldiers![index]['section'];
                                          _rankSort = soldiers![index]
                                                  ['rankSort']
                                              .toString();
                                          _owner = soldiers![index]['owner'];
                                          _users = soldiers![index]['users'];
                                          updated = true;
                                        });
                                      }
                                    },
                                    value: _soldierId,
                                  );
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                        child: PlatformCheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: removeSoldiers,
                          title: const Text('Remove Soldiers already added'),
                          onChanged: (checked) {
                            _removeSoldiers(checked, user.uid);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _phaController,
                          label: 'PHA Date',
                          date: _phaDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _dentalController,
                          label: 'Dental Date',
                          date: _dentalDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _visionController,
                          label: 'Vision Date',
                          date: _visionDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _hearingController,
                          label: 'Hearing Date',
                          date: _hearingDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _hivController,
                          label: 'HIV Date',
                          date: _hivDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DateTextField(
                          controller: _fluController,
                          label: 'Influenza Date',
                          date: _fluDate,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformButton(
                      onPressed: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                      child: expanded
                          ? const Text('Less Immunizations')
                          : const Text('More Immunizations'),
                    ),
                  ),
                  moreImmunizations(width),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformButton(
                      onPressed: () {
                        submit(context);
                      },
                      child: Text(widget.medpro.id == null
                          ? 'Add MedPros'
                          : 'Update MedPros'),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
