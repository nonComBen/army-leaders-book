import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants/firestore_collections.dart';
import '../../methods/create_less_soldiers.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/rating.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
import '../../widgets/stateful_widgets/date_text_field.dart';

class EditRatingPage extends ConsumerStatefulWidget {
  const EditRatingPage({
    Key? key,
    required this.rating,
  }) : super(key: key);
  final Rating rating;

  @override
  EditRatingPageState createState() => EditRatingPageState();
}

class EditRatingPageState extends ConsumerState<EditRatingPage> {
  String _title = 'New Rating Scheme';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _nextController = TextEditingController();
  final TextEditingController _raterController = TextEditingController();
  final TextEditingController _srController = TextEditingController();
  final TextEditingController _reviewerController = TextEditingController();
  String? _type,
      _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _owner;
  List<dynamic>? _users;
  final List<String> _types = [
    '',
    'Annual',
    'Ext Annual',
    'Change of Rater',
    'Relief for Cause',
    'Complete the Record',
    '60 Day Rater Option',
    '60 Day Senior Rater Option',
    'Temporary Duty/Special Duty',
    'Change of Duty',
    'Officer Failing Promotion Selection',
  ];
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _lastDate, _nextDate;
  FToast toast = FToast();

  @override
  void dispose() {
    _lastController.dispose();
    _nextController.dispose();
    _raterController.dispose();
    _srController.dispose();
    _reviewerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.rating.id != null) {
      _title = '${widget.rating.rank} ${widget.rating.name}';
    }

    _soldierId = widget.rating.soldierId;
    _rank = widget.rating.rank;
    _lastName = widget.rating.name;
    _firstName = widget.rating.firstName;
    _section = widget.rating.section;
    _rankSort = widget.rating.rankSort;
    _type = widget.rating.nextType;
    _owner = widget.rating.owner;
    _users = widget.rating.users;

    _lastController.text = widget.rating.last;
    _nextController.text = widget.rating.next;
    _raterController.text = widget.rating.rater;
    _srController.text = widget.rating.sr;
    _reviewerController.text = widget.rating.reviewer;

    _lastDate = DateTime.tryParse(widget.rating.last) ?? DateTime.now();
    _nextDate = DateTime.tryParse(widget.rating.next) ?? DateTime.now();
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_lastController.text, _nextController.text],
    )) {
      Rating saveRating = Rating(
        id: widget.rating.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        last: _lastController.text,
        next: _nextController.text,
        nextType: _type!,
        rater: _raterController.text,
        sr: _srController.text,
        reviewer: _reviewerController.text,
      );

      if (widget.rating.id == null) {
        DocumentReference docRef = await firestore
            .collection(kRatingCollection)
            .add(saveRating.toMap());

        saveRating.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kRatingCollection)
            .doc(widget.rating.id)
            .set(saveRating.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Rating');
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
                  onChanged: (checked) {
                    createLessSoldiers(
                      collection: kRatingCollection,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                  },
                ),
              ),
              PaddedTextField(
                controller: _raterController,
                keyboardType: TextInputType.text,
                label: 'Rater',
                decoration: const InputDecoration(
                  labelText: 'Rater',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _srController,
                keyboardType: TextInputType.text,
                label: 'Senior Rater',
                decoration: const InputDecoration(
                  labelText: 'Senior Rater',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _reviewerController,
                keyboardType: TextInputType.text,
                label: 'Reviewer',
                decoration: const InputDecoration(
                  labelText: 'Reviewer',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _lastController,
                label: 'Last Eval Date',
                date: _lastDate,
              ),
              DateTextField(
                controller: _nextController,
                label: 'Next Eval Date',
                date: _nextDate,
                minYears: 1,
                maxYears: 2,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Next Type'),
                  value: _type,
                  items: _types,
                  onChanged: (dynamic value) {
                    setState(() {
                      _type = value;
                      updated = true;
                    });
                  },
                ),
              )
            ],
          ),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child:
                Text(widget.rating.id == null ? 'Add Rating' : 'Update Rating'),
          ),
        ],
      ),
    );
  }
}
