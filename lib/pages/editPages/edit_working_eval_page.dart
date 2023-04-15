import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/theme_methods.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/working_eval.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditWorkingEvalPage extends ConsumerStatefulWidget {
  const EditWorkingEvalPage({
    Key? key,
    required this.eval,
  }) : super(key: key);
  final WorkingEval eval;

  @override
  EditWorkingEvalPageState createState() => EditWorkingEvalPageState();
}

class EditWorkingEvalPageState extends ConsumerState<EditWorkingEvalPage> {
  String _title = 'New Evaluation';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dutyDescriptionController =
      TextEditingController();
  final TextEditingController _specialEmphasisController =
      TextEditingController();
  final TextEditingController _appointedDutiesController =
      TextEditingController();
  final TextEditingController _characterController = TextEditingController();
  final TextEditingController _presenceController = TextEditingController();
  final TextEditingController _intellectController = TextEditingController();
  final TextEditingController _leadsController = TextEditingController();
  final TextEditingController _developsController = TextEditingController();
  final TextEditingController _achievesController = TextEditingController();
  final TextEditingController _performanceController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  FToast toast = FToast();

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
      WorkingEval saveEval = WorkingEval(
        id: widget.eval.id,
        soldierId: _soldierId,
        owner: userId,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        dutyDescription: _dutyDescriptionController.text,
        appointedDuties: _appointedDutiesController.text,
        specialEmphasis: _specialEmphasisController.text,
        character: _characterController.text,
        presence: _presenceController.text,
        intellect: _intellectController.text,
        leads: _leadsController.text,
        develops: _developsController.text,
        achieves: _achievesController.text,
        performance: _performanceController.text,
      );

      if (widget.eval.id == null) {
        DocumentReference docRef =
            await firestore.collection('workingEvals').add(saveEval.toMap());

        saveEval.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('workingEvals')
            .doc(widget.eval.id)
            .set(saveEval.toMap())
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

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('workingEvals')
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
    _dutyDescriptionController.dispose();
    _specialEmphasisController.dispose();
    _appointedDutiesController.dispose();
    _characterController.dispose();
    _presenceController.dispose();
    _intellectController.dispose();
    _leadsController.dispose();
    _developsController.dispose();
    _achievesController.dispose();
    _performanceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.eval.id != null) {
      _title = '${widget.eval.rank} ${widget.eval.name}';
    }

    _soldierId = widget.eval.soldierId;
    _rank = widget.eval.rank;
    _lastName = widget.eval.name;
    _firstName = widget.eval.firstName;
    _section = widget.eval.section;
    _rankSort = widget.eval.rankSort;

    _dutyDescriptionController.text = widget.eval.dutyDescription;
    _specialEmphasisController.text = widget.eval.specialEmphasis;
    _appointedDutiesController.text = widget.eval.appointedDuties;
    _characterController.text = widget.eval.character;
    _presenceController.text = widget.eval.presence;
    _intellectController.text = widget.eval.intellect;
    _leadsController.text = widget.eval.leads;
    _developsController.text = widget.eval.develops;
    _achievesController.text = widget.eval.achieves;
    _performanceController.text = widget.eval.performance;
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
                child: FutureBuilder(
                    future: firestore
                        .collection('soldiers')
                        .where('owner', isEqualTo: user.uid)
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
                                  _lastName = soldiers![index]['lastName'];
                                  _firstName = soldiers![index]['firstName'];
                                  _section = soldiers![index]['section'];
                                  _rankSort =
                                      soldiers![index]['rankSort'].toString();
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
            ],
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _dutyDescriptionController,
            label: 'Daily Duties and Scope',
            decoration:
                const InputDecoration(labelText: 'Daily Duties and Scope'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _specialEmphasisController,
            label: 'Areas of Special Emphasis',
            decoration:
                const InputDecoration(labelText: 'Areas of Special Emphasis'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _appointedDutiesController,
            label: 'Appointed Duties',
            decoration: const InputDecoration(labelText: 'Appointed Duties'),
            onChanged: (value) {
              updated = true;
            },
          ),
          Divider(
            color: getOnPrimaryColor(context),
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _characterController,
            label: 'Character',
            decoration: const InputDecoration(labelText: 'Character'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _presenceController,
            label: 'Presence',
            decoration: const InputDecoration(labelText: 'Presence'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _intellectController,
            label: 'Intellect',
            decoration: const InputDecoration(labelText: 'Intellect'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _leadsController,
            label: 'Leads',
            decoration: const InputDecoration(labelText: 'Leads'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _developsController,
            label: 'Develops',
            decoration: const InputDecoration(labelText: 'Develops'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _achievesController,
            label: 'Achieves',
            decoration: const InputDecoration(labelText: 'Achieves'),
            onChanged: (value) {
              updated = true;
            },
          ),
          Divider(
            color: getOnPrimaryColor(context),
          ),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: _performanceController,
            label: 'Rater Overall Performance',
            decoration:
                const InputDecoration(labelText: 'Rater Overall Performance'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            onPressed: () {
              submit(context, user.uid);
            },
            child: Text(widget.eval.id == null
                ? 'Add Evaluation'
                : 'Update Evaluation'),
          ),
        ],
      ),
    );
  }
}
