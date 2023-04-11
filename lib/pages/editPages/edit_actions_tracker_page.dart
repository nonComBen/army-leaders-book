import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';
import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/action.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_text_field.dart';

class EditActionsTrackerPage extends ConsumerStatefulWidget {
  const EditActionsTrackerPage({
    Key? key,
    required this.action,
  }) : super(key: key);
  final ActionObj action;

  @override
  EditActionsTrackerPageState createState() => EditActionsTrackerPageState();
}

class EditActionsTrackerPageState
    extends ConsumerState<EditActionsTrackerPage> {
  String _title = 'New Action';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _statusDateController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime, _statusDateTime;

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
      ActionObj saveAction = ActionObj(
        id: widget.action.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        action: _actionController.text,
        dateSubmitted: _dateController.text,
        currentStatus: _statusController.text,
        statusDate: _statusDateController.text,
        remarks: _remarksController.text,
      );

      if (widget.action.id == null) {
        DocumentReference docRef =
            await firestore.collection('actions').add(saveAction.toMap());

        saveAction.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('actions')
            .doc(widget.action.id)
            .set(saveAction.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Action');
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
          .collection('actions')
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
    _actionController.dispose();
    _statusController.dispose();
    _statusDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.action.id != null) {
      _title = '${widget.action.rank} ${widget.action.name}';
    }

    _soldierId = widget.action.soldierId;
    _rank = widget.action.rank;
    _lastName = widget.action.name;
    _firstName = widget.action.firstName;
    _section = widget.action.section;
    _rankSort = widget.action.rankSort;
    _owner = widget.action.owner;
    _users = widget.action.users;

    _dateController.text = widget.action.dateSubmitted;
    _actionController.text = widget.action.action;
    _statusController.text = widget.action.currentStatus;
    _statusDateController.text = widget.action.statusDate;
    _remarksController.text = widget.action.remarks;

    _dateTime =
        DateTime.tryParse(widget.action.dateSubmitted) ?? DateTime.now();
    _statusDateTime =
        DateTime.tryParse(widget.action.statusDate) ?? DateTime.now();
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
                      padding: const EdgeInsets.all(8.0),
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
                      child: PlatformTextField(
                        autocorrect: false,
                        controller: _actionController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        enabled: true,
                        decoration: const InputDecoration(
                          labelText: 'Action',
                        ),
                        onChanged: (value) {
                          updated = true;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTextField(
                        controller: _dateController,
                        label: 'Date Submitted',
                        date: _dateTime,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PlatformTextField(
                        autocorrect: false,
                        controller: _statusController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        enabled: true,
                        decoration: const InputDecoration(
                          labelText: 'Current Status',
                        ),
                        onChanged: (value) {
                          updated = true;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTextField(
                        controller: _statusDateController,
                        label: 'Status Date',
                        date: _statusDateTime,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    controller: _remarksController,
                    enabled: true,
                    decoration: const InputDecoration(labelText: 'Remarks'),
                    onChanged: (value) {
                      updated = true;
                    },
                  ),
                ),
                PlatformButton(
                  child: Text(widget.action.id == null
                      ? 'Add Action'
                      : 'Update Action'),
                  onPressed: () => submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
