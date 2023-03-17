import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/working_award.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditWorkingAwardPage extends StatefulWidget {
  const EditWorkingAwardPage({
    Key? key,
    required this.award,
  }) : super(key: key);
  final WorkingAward award;

  @override
  EditWorkingAwardPageState createState() => EditWorkingAwardPageState();
}

class EditWorkingAwardPageState extends State<EditWorkingAwardPage> {
  String _title = 'New Award';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

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
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;

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
        DocumentReference docRef =
            await firestore.collection('workingAwards').add(saveAward.toMap());

        saveAward.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('workingAwards')
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  void _removeSoldiers(bool? checked, String userId) async {
    if (lessSoldiers == null) {
      lessSoldiers = List.from(allSoldiers!, growable: true);
      QuerySnapshot apfts = await firestore
          .collection('workingAwards')
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context)!.auth!.currentUser()!;
    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onWillPop: updated
                ? () => onBackPressed(context)
                : () => Future(() => true),
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
                                        .where('owner', isEqualTo: user.uid)
                                        .get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        default:
                                          allSoldiers = snapshot.data!.docs;
                                          soldiers = removeSoldiers
                                              ? lessSoldiers
                                              : allSoldiers;
                                          soldiers!.sort((a, b) => a['lastName']
                                              .toString()
                                              .compareTo(
                                                  b['lastName'].toString()));
                                          soldiers!.sort((a, b) => a['rankSort']
                                              .toString()
                                              .compareTo(
                                                  b['rankSort'].toString()));
                                          return DropdownButtonFormField<
                                              String>(
                                            decoration: const InputDecoration(
                                                labelText: 'Soldier'),
                                            items: soldiers!.map((doc) {
                                              return DropdownMenuItem<String>(
                                                value: doc.id,
                                                child: Text(
                                                    '${doc['rank']} ${doc['lastName']}, ${doc['firstName']}'),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              int index = soldiers!.indexWhere(
                                                  (doc) => doc.id == value);
                                              if (mounted) {
                                                setState(() {
                                                  _soldierId = value;
                                                  _rank =
                                                      soldiers![index]['rank'];
                                                  _lastName = soldiers![index]
                                                      ['lastName'];
                                                  _firstName = soldiers![index]
                                                      ['firstName'];
                                                  _section = soldiers![index]
                                                      ['section'];
                                                  _rankSort = soldiers![index]
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
                                    _removeSoldiers(checked, user.uid);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Award Reason'),
                                  items: _reasons.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _ach1Controller,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Achievement',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _ach2Controller,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Achievement',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _ach3Controller,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Achievement',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _ach4Controller,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Achievement',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _citationController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Citation',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          FormattedElevatedButton(
                            onPressed: () {
                              submit(context, user.uid);
                            },
                            text: widget.award.id == null
                                ? 'Add Award'
                                : 'Update Award',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
