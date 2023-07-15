import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/profile.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditTempProfilePage extends ConsumerStatefulWidget {
  const EditTempProfilePage({
    Key? key,
    required this.profile,
  }) : super(key: key);
  final TempProfile profile;

  @override
  EditTempProfilePageState createState() => EditTempProfilePageState();
}

class EditTempProfilePageState extends ConsumerState<EditTempProfilePage> {
  String _title = 'New Temp Profile';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String? _type,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic>? _users;
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime, _expDate;
  FToast toast = FToast();

  @override
  void dispose() {
    _dateController.dispose();
    _expController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    _type = widget.profile.type;

    if (widget.profile.id != null) {
      _title = '${widget.profile.rank} ${widget.profile.name}';
    }

    _soldierId = widget.profile.soldierId;
    _rank = widget.profile.rank;
    _lastName = widget.profile.name;
    _firstName = widget.profile.firstName;
    _section = widget.profile.section;
    _rankSort = widget.profile.rankSort;
    _owner = widget.profile.owner;
    _users = widget.profile.users;

    _dateController.text = widget.profile.date;
    _expController.text = widget.profile.exp;
    _commentsController.text = widget.profile.comments;

    _dateTime = DateTime.tryParse(widget.profile.date);
    _expDate = DateTime.tryParse(widget.profile.exp);
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dateController.text, _expController.text],
    )) {
      TempProfile saveProfile = TempProfile(
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
        exp: _expController.text,
        type: _type!,
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
                        profileType: 'Temporary');
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Issued Date',
                date: _dateTime,
              ),
              DateTextField(
                controller: _expController,
                label: 'Expiration Date',
                date: _expDate,
                minYears: 1,
              ),
            ],
          ),
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
