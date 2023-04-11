import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/tasking.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditTaskingPage extends ConsumerStatefulWidget {
  const EditTaskingPage({
    Key? key,
    required this.tasking,
  }) : super(key: key);
  final Tasking tasking;

  @override
  EditTaskingPageState createState() => EditTaskingPageState();
}

class EditTaskingPageState extends ConsumerState<EditTaskingPage> {
  String _title = 'New Tasking';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  List<DocumentSnapshot>? allSoldiers, lessSoldiers, soldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _start, _end;

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
      Tasking saveTasking = Tasking(
        id: widget.tasking.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        start: _startController.text,
        end: _endController.text,
        type: _typeController.text,
        comments: _commentsController.text,
        location: _locController.text,
      );
      DocumentReference docRef;
      if (widget.tasking.id == null) {
        docRef =
            await firestore.collection('taskings').add(saveTasking.toMap());
      } else {
        docRef = firestore.collection('taskings').doc(widget.tasking.id);
        docRef.update(saveTasking.toMap());
      }
      if (mounted) {
        Navigator.pop(context);
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
          .collection('taskings')
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
    _startController.dispose();
    _endController.dispose();
    _typeController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.tasking.id != null) {
      _title = '${widget.tasking.rank} ${widget.tasking.name}';
    }

    _soldierId = widget.tasking.soldierId;
    _rank = widget.tasking.rank;
    _lastName = widget.tasking.name;
    _firstName = widget.tasking.firstName;
    _section = widget.tasking.section;
    _rankSort = widget.tasking.rankSort;
    _owner = widget.tasking.owner;
    _users = widget.tasking.users;

    _startController.text = widget.tasking.start;
    _endController.text = widget.tasking.end;
    _typeController.text = widget.tasking.type;
    _commentsController.text = widget.tasking.comments;
    _locController.text = widget.tasking.location;

    _start = DateTime.tryParse(widget.tasking.start) ?? DateTime.now();
    _end = DateTime.tryParse(widget.tasking.end) ?? DateTime.now();
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
                    PaddedTextField(
                      controller: _typeController,
                      enabled: true,
                      decoration: const InputDecoration(labelText: 'Tasking'),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _locController,
                      enabled: true,
                      decoration: const InputDecoration(labelText: 'Location'),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTextField(
                        controller: _startController,
                        label: 'Start Date',
                        date: _start,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DateTextField(
                        controller: _endController,
                        label: 'End Date',
                        date: _end,
                      ),
                    ),
                  ],
                ),
                PaddedTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  controller: _commentsController,
                  enabled: true,
                  decoration: const InputDecoration(labelText: 'Comments'),
                  onChanged: (value) {
                    updated = true;
                  },
                ),
                PlatformButton(
                  onPressed: () {
                    if (_endController.text != '' && _end!.isBefore(_start!)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('End Date must be after Start Date'),
                      ));
                    } else {
                      submit(context);
                    }
                  },
                  child: Text(widget.tasking.id == null
                      ? 'Add Tasking'
                      : 'Update Tasking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
