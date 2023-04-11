import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/counseling.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime;

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context, String userId) async {
    if (validateAndSave()) {
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
        DocumentReference docRef = await firestore
            .collection('counselings')
            .add(saveCounseling.toMap());

        saveCounseling.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('counselings')
            .doc(widget.counseling.id)
            .set(saveCounseling.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Perstat');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('counselings')
          .where('owner', isEqualTo: userId)
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All Soldiers have been added')));
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

    _dateTime = DateTime.tryParse(widget.counseling.date) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
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
                                soldiers =
                                    removeSoldiers ? lessSoldiers : allSoldiers;
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
                                        _section = soldiers![index]['section'];
                                        _rankSort = soldiers![index]['rankSort']
                                            .toString();
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
                        controller: _dateController,
                        label: 'Date',
                        date: _dateTime,
                      ),
                    ),
                  ],
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  controller: _purposeController,
                  enabled: true,
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
                  enabled: true,
                  decoration: const InputDecoration(
                      labelText: 'Key Points of Discussion'),
                  onChanged: (value) {
                    updated = true;
                  },
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  controller: _planOfActionController,
                  enabled: true,
                  decoration:
                      const InputDecoration(labelText: 'Plan of Action'),
                  onChanged: (value) {
                    updated = true;
                  },
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  controller: _indivRemarksController,
                  enabled: true,
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
                  enabled: true,
                  decoration: const InputDecoration(
                      labelText: 'Leader Responsibilities'),
                  onChanged: (value) {
                    updated = true;
                  },
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  controller: _assessmentController,
                  enabled: true,
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
          ),
        ),
      ),
    );
  }
}
