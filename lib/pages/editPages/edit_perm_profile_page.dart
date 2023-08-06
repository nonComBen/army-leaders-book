import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../methods/create_less_soldiers.dart';
import '../../providers/soldiers_provider.dart';
import '../../providers/auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/profile.dart';
import '../../models/soldier.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditPermProfilePage extends ConsumerStatefulWidget {
  const EditPermProfilePage({
    Key? key,
    required this.profile,
  }) : super(key: key);
  final PermProfile profile;

  @override
  EditPermProfilePageState createState() => EditPermProfilePageState();
}

class EditPermProfilePageState extends ConsumerState<EditPermProfilePage> {
  String _title = 'New Permanent Profile';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FToast toast = FToast();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String? _event,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic>? _users;
  final List<String> _events = [
    '',
    'Walk',
    'Bike',
    'Swim',
  ];
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false,
      updated = false,
      shaving = false,
      pu = false,
      su = false,
      run = false;
  DateTime? _dateTime;

  @override
  void dispose() {
    _dateController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    allSoldiers = ref.read(soldiersProvider);

    if (widget.profile.id != null) {
      _title = '${widget.profile.rank} ${widget.profile.name}';
    }

    _soldierId = widget.profile.soldierId;
    _rank = widget.profile.rank;
    _lastName = widget.profile.name;
    _firstName = widget.profile.firstName;
    _section = widget.profile.section;
    _rankSort = widget.profile.rankSort;
    _event = widget.profile.altEvent;
    _owner = widget.profile.owner;
    _users = widget.profile.users;

    _dateController.text = widget.profile.date;
    _commentsController.text = widget.profile.comments;

    shaving = widget.profile.shaving;
    pu = widget.profile.pu;
    su = widget.profile.su;
    run = widget.profile.run;

    _dateTime = DateTime.tryParse(widget.profile.date);
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text],
    )) {
      PermProfile saveProfile = PermProfile(
        id: widget.profile.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        shaving: shaving,
        pu: pu,
        su: su,
        run: run,
        altEvent: _event!,
        comments: _commentsController.text,
      );

      if (widget.profile.id == null) {
        firestore
            .collection(TempProfile.collectionName)
            .add(saveProfile.toMap());
      } else {
        firestore
            .collection(TempProfile.collectionName)
            .doc(widget.profile.id)
            .set(saveProfile.toMap());
      }
      Navigator.of(context).pop();
    } else {
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  double childRatio(double width) {
    if (width > 900) return 900 / 425;
    if (width > 650) return width / 325;
    if (width > 400) return width / 225;
    return width / 100;
  }

  Widget checkBoxes(double width) {
    return GridView.count(
      primary: false,
      crossAxisCount: width > 900
          ? 4
          : width > 650
              ? 3
              : width > 400
                  ? 2
                  : 1,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: childRatio(width),
      shrinkWrap: true,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: PlatformCheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Pushup'),
            value: pu,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  pu = value!;
                  updated = true;
                });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: PlatformCheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Situp'),
            value: su,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  su = value!;
                  updated = true;
                });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
          child: PlatformCheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Run'),
            value: run,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  run = value!;
                  if (value) _event = '';
                  updated = true;
                });
              }
            },
          ),
        ),
        if (!run)
          Padding(
            padding:
                EdgeInsets.fromLTRB(8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
            child: PlatformItemPicker(
              label: const Text('Alternative Event'),
              items: _events,
              value: _event,
              onChanged: (dynamic value) {
                if (mounted) {
                  setState(() {
                    _event = value;
                  });
                }
              },
            ),
          )
      ],
    );
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
                  onChanged: (checked) async {
                    lessSoldiers = await createLessSoldiers(
                      collection: TempProfile.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                      profileType: 'Permanent',
                    );
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Start Date',
                date: _dateTime,
                minYears: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
                child: PlatformCheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Shaving',
                  ),
                  value: shaving,
                  onChanged: (value) {
                    setState(() {
                      shaving = value!;
                      updated = true;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          const HeaderText(
            'APFT Events',
          ),
          const Text('Select events the Soldier can take.'),
          checkBoxes(width),
          PaddedTextField(
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            controller: _commentsController,
            label: 'Comments',
            decoration: const InputDecoration(labelText: 'Comments'),
            onChanged: (value) {
              updated = true;
            },
          ),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(
                widget.profile.id == null ? 'Add Profile' : 'Update Profile'),
          ),
        ],
      ),
    );
  }
}
