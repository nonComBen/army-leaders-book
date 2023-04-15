import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages.dart/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/hr_action.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditHrActionPage extends ConsumerStatefulWidget {
  const EditHrActionPage({
    Key? key,
    required this.hrAction,
  }) : super(key: key);
  final HrAction hrAction;

  @override
  EditHrActionPageState createState() => EditHrActionPageState();
}

class EditHrActionPageState extends ConsumerState<EditHrActionPage> {
  String _title = 'New HR Metrics';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dd93Controller = TextEditingController();
  final TextEditingController _sglvController = TextEditingController();
  final TextEditingController _prrController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dd93Date, _sglvDate, _prrDate;
  FToast toast = FToast();

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dd93Controller.text, _sglvController.text, _prrController.text],
    )) {
      DocumentSnapshot doc =
          soldiers!.firstWhere((element) => element.id == _soldierId);
      _users = doc['users'];
      HrAction saveHrAction = HrAction(
        id: widget.hrAction.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        dd93: _dd93Controller.text,
        sglv: _sglvController.text,
        prr: _prrController.text,
      );

      if (widget.hrAction.id == null) {
        DocumentReference docRef =
            await firestore.collection('hrActions').add(saveHrAction.toMap());

        saveHrAction.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('hrActions')
            .doc(widget.hrAction.id)
            .set(saveHrAction.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Hr Metrics');
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
          .collection('hrActions')
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
    _dd93Controller.dispose();
    _sglvController.dispose();
    _prrController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.hrAction.id != null) {
      _title = '${widget.hrAction.rank} ${widget.hrAction.name}';
    }

    _soldierId = widget.hrAction.soldierId;
    _rank = widget.hrAction.rank;
    _lastName = widget.hrAction.name;
    _firstName = widget.hrAction.firstName;
    _section = widget.hrAction.section;
    _rankSort = widget.hrAction.rankSort;
    _owner = widget.hrAction.owner;
    _users = widget.hrAction.users;

    _dd93Controller.text = widget.hrAction.dd93;
    _sglvController.text = widget.hrAction.sglv;
    _prrController.text = widget.hrAction.prr;

    removeSoldiers = false;
    updated = false;

    _dd93Date = DateTime.tryParse(widget.hrAction.dd93) ?? DateTime.now();
    _sglvDate = DateTime.tryParse(widget.hrAction.sglv) ?? DateTime.now();
    _prrDate = DateTime.tryParse(widget.hrAction.prr) ?? DateTime.now();
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
                                  _lastName = soldiers![index]['lastName'];
                                  _firstName = soldiers![index]['firstName'];
                                  _section = soldiers![index]['section'];
                                  _rankSort =
                                      soldiers![index]['rankSort'].toString();
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
              DateTextField(
                controller: _dd93Controller,
                label: 'DD93 Date',
                date: _dd93Date,
              ),
              DateTextField(
                controller: _sglvController,
                label: 'SGLV Date',
                date: _sglvDate,
              ),
              DateTextField(
                controller: _prrController,
                label: 'Record Review Date',
                date: _prrDate,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformButton(
              onPressed: () {
                submit(context);
              },
              child: Text(widget.hrAction.id == null
                  ? 'Add HR Metrics'
                  : 'Update HR Metrics'),
            ),
          ),
        ],
      ),
    );
  }
}
