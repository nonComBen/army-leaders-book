// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/working_eval.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditWorkingEvalPage extends StatefulWidget {
  const EditWorkingEvalPage({
    Key key,
    @required this.userId,
    @required this.eval,
    @required this.isSubscribed,
  }) : super(key: key);
  final String userId;
  final WorkingEval eval;
  final bool isSubscribed;

  @override
  EditWorkingEvalPageState createState() => EditWorkingEvalPageState();
}

class EditWorkingEvalPageState extends State<EditWorkingEvalPage> {
  String _title = 'New Evaluation';
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _dutyDescriptionController;
  TextEditingController _specialEmphasisController;
  TextEditingController _appointedDutiesController;
  TextEditingController _characterController;
  TextEditingController _presenceController;
  TextEditingController _intellectController;
  TextEditingController _leadsController;
  TextEditingController _developsController;
  TextEditingController _achievesController;
  TextEditingController _performanceController;
  String _soldierId, _rank, _lastName, _firstName, _section, _rankSort;
  List<DocumentSnapshot> allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers, updated;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      WorkingEval saveEval = WorkingEval(
        id: widget.eval.id,
        soldierId: _soldierId,
        owner: widget.userId,
        rank: _rank,
        name: _lastName,
        firstName: _firstName,
        section: _section,
        rankSort: _rankSort,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  void _removeSoldiers(bool checked) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('workingEvals')
          .where('owner', isEqualTo: widget.userId)
          .get();
      if (apfts.docs.isNotEmpty) {
        for (var doc in apfts.docs) {
          lessSoldiers
              .removeWhere((soldierDoc) => soldierDoc.id == doc['soldierId']);
        }
      }
    }
    if (lessSoldiers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All Soldiers have been added')));
      }
    }

    setState(() {
      if (checked && lessSoldiers.isNotEmpty) {
        _soldierId = null;
        removeSoldiers = true;
      } else {
        _soldierId = null;
        removeSoldiers = false;
      }
    });
  }

  Future<bool> _onBackPressed() {
    if (!updated) return Future.value(true);
    return onBackPressed(context);
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

    firestore = FirebaseFirestore.instance;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    if (widget.eval.id != null) {
      _title = '${widget.eval.rank} ${widget.eval.name}';
    }

    _soldierId = widget.eval.soldierId;
    _rank = widget.eval.rank;
    _lastName = widget.eval.name;
    _firstName = widget.eval.firstName;
    _section = widget.eval.section;
    _rankSort = widget.eval.rankSort;

    _dutyDescriptionController =
        TextEditingController(text: widget.eval.dutyDescription);
    _specialEmphasisController =
        TextEditingController(text: widget.eval.specialEmphasis);
    _appointedDutiesController =
        TextEditingController(text: widget.eval.appointedDuties);
    _characterController = TextEditingController(text: widget.eval.character);
    _presenceController = TextEditingController(text: widget.eval.presence);
    _intellectController = TextEditingController(text: widget.eval.intellect);
    _leadsController = TextEditingController(text: widget.eval.leads);
    _developsController = TextEditingController(text: widget.eval.develops);
    _achievesController = TextEditingController(text: widget.eval.achieves);
    _performanceController =
        TextEditingController(text: widget.eval.performance);

    removeSoldiers = false;
    updated = false;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onWillPop: _onBackPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width > 932 ? (width - 916) / 2 : 16),
              child: Card(
                child: Container(
                    padding: const EdgeInsets.all(16.0),
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      child: Column(
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
                                        .where('owner',
                                            isEqualTo: widget.userId)
                                        .get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        default:
                                          allSoldiers = snapshot.data.docs;
                                          soldiers = removeSoldiers
                                              ? lessSoldiers
                                              : allSoldiers;
                                          soldiers.sort((a, b) => a['lastName']
                                              .toString()
                                              .compareTo(
                                                  b['lastName'].toString()));
                                          soldiers.sort((a, b) => a['rankSort']
                                              .toString()
                                              .compareTo(
                                                  b['rankSort'].toString()));
                                          return DropdownButtonFormField<
                                              String>(
                                            decoration: const InputDecoration(
                                                labelText: 'Soldier'),
                                            items: soldiers.map((doc) {
                                              return DropdownMenuItem<String>(
                                                value: doc.id,
                                                child: Text(
                                                    '${doc['rank']} ${doc['lastName']}, ${doc['firstName']}'),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              int index = soldiers.indexWhere(
                                                  (doc) => doc.id == value);
                                              if (mounted) {
                                                setState(() {
                                                  _soldierId = value;
                                                  _rank =
                                                      soldiers[index]['rank'];
                                                  _lastName = soldiers[index]
                                                      ['lastName'];
                                                  _firstName = soldiers[index]
                                                      ['firstName'];
                                                  _section = soldiers[index]
                                                      ['section'];
                                                  _rankSort = soldiers[index]
                                                          ['rankSort']
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
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 16.0, 8.0, 8.0),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: removeSoldiers,
                                  title: const Text(
                                      'Remove Soldiers already added'),
                                  onChanged: (checked) {
                                    _removeSoldiers(checked);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _dutyDescriptionController,
                              enabled: true,
                              decoration: const InputDecoration(
                                  labelText: 'Daily Duties and Scope'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _specialEmphasisController,
                              enabled: true,
                              decoration: const InputDecoration(
                                  labelText: 'Areas of Special Emphasis'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _appointedDutiesController,
                              enabled: true,
                              decoration: const InputDecoration(
                                  labelText: 'Appointed Duties'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _characterController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Character'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _presenceController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Presence'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _intellectController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Intellect'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _leadsController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Leads'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _developsController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Develops'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _achievesController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Achieves'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _performanceController,
                              enabled: true,
                              decoration: const InputDecoration(
                                  labelText: 'Rater Overall Performance'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          FormattedElevatedButton(
                            onPressed: () {
                              submit(context);
                            },
                            text: widget.eval.id == null
                                ? 'Add Evaluation'
                                : 'Update Evaluation',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
