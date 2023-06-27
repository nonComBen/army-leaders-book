import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/local_notification_methods.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/soldier.dart';
import '../../models/weapon.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/shared_prefs_provider.dart';
import '../../providers/soldiers_provider.dart';
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

class EditWeaponPage extends ConsumerStatefulWidget {
  const EditWeaponPage({
    Key? key,
    required this.weapon,
  }) : super(key: key);
  final Weapon weapon;

  @override
  EditWeaponPageState createState() => EditWeaponPageState();
}

class EditWeaponPageState extends ConsumerState<EditWeaponPage> {
  String _title = 'New Weapon Qual';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _hitsController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _badgeController = TextEditingController();
  String? _soldierId,
      _rank,
      _lastName,
      _firstName,
      _section,
      _rankSort,
      _qualType,
      _owner;
  List<dynamic>? _users;
  final List<String> _qualTypes = [
    'Day',
    'Night',
    'NBC',
  ];
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false, pass = true;
  DateTime? _dateTime;
  FToast toast = FToast();

  @override
  void dispose() {
    _dateController.dispose();
    _hitsController.dispose();
    _typeController.dispose();
    _maxController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.weapon.id != null) {
      _title = '${widget.weapon.rank} ${widget.weapon.name}';
    }

    _soldierId = widget.weapon.soldierId;
    _rank = widget.weapon.rank;
    _lastName = widget.weapon.name;
    _firstName = widget.weapon.firstName;
    _section = widget.weapon.section;
    _rankSort = widget.weapon.rankSort;
    _owner = widget.weapon.owner;
    _users = widget.weapon.users;

    pass = widget.weapon.pass;

    _qualType = widget.weapon.qualType;

    _dateController.text = widget.weapon.date;
    _typeController.text = widget.weapon.type;
    _hitsController.text = widget.weapon.score;
    _maxController.text = widget.weapon.max;
    _badgeController.text = widget.weapon.badge;

    removeSoldiers = false;
    updated = false;

    _dateTime = DateTime.tryParse(widget.weapon.date) ?? DateTime.now();
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
      final setting = ref.read(settingsProvider);
      List<int> notificationIds = [];
      if (!kIsWeb && _dateController.text != '' && setting!.addNotifications) {
        final notificationService = ref.read(notificationProvider);
        final prefs = ref.read(sharedPreferencesProvider);
        if (widget.weapon.notificationIds != null &&
            widget.weapon.notificationIds!.isNotEmpty) {
          notificationService
              .cancelPreviousNotifications(widget.weapon.notificationIds!);
        }
        final dueDate = getDueDate(_dateController.text, setting.weaponsMonths);
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        int id = prefs.getInt('notificationId') ?? 0;

        for (int days in setting.weaponsNotifications) {
          notificationIds.add(id);
          notificationService.scheduleNotification(
            dateTime: dueDate.subtract(Duration(days: days)),
            id: id,
            title: '$_rank $_lastName\'s Weapon Qual Due',
            body:
                '$_rank $_lastName\'s Weapon Qual Due in $days on ${formatter.format(dueDate)}',
            payload: 'Weapons',
          );
          id++;
        }
        prefs.setInt('notificationId', id);
      }

      Weapon saveWeapon = Weapon(
        id: widget.weapon.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        date: _dateController.text,
        type: _typeController.text,
        score: _hitsController.text,
        max: _maxController.text,
        badge: _badgeController.text,
        pass: pass,
        qualType: _qualType!,
      );

      // setDateNotifications(
      //   setting: ref.read(settingsProvider.notifier).settings,
      //   map: saveWeapon.toMap(),
      //   user: ref.read(userProvider).user!,
      //   topic: 'Weapons Qualification',
      // );

      if (widget.weapon.id == null) {
        firestore.collection(Weapon.collectionName).add(saveWeapon.toMap());
      } else {
        firestore
            .collection(Weapon.collectionName)
            .doc(widget.weapon.id)
            .set(saveWeapon.toMap());
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
                  onChanged: (checked) {
                    createLessSoldiers(
                      collection: Weapon.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                    label: const Text('Qualification Type'),
                    value: _qualType,
                    items: _qualTypes,
                    onChanged: (dynamic value) {
                      if (mounted) {
                        setState(() {
                          _qualType = value;
                          updated = true;
                        });
                      }
                    }),
              ),
              DateTextField(
                controller: _dateController,
                label: 'Date',
                date: _dateTime,
                minYears: 5,
                maxYears: 1,
              ),
              PaddedTextField(
                controller: _typeController,
                keyboardType: TextInputType.text,
                label: 'Weapon',
                decoration: const InputDecoration(
                  labelText: 'Weapon',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _hitsController,
                keyboardType: TextInputType.text,
                label: 'Hits',
                decoration: const InputDecoration(
                  labelText: 'Hits',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _maxController,
                keyboardType: TextInputType.text,
                label: 'Maximum',
                decoration: const InputDecoration(
                  labelText: 'Maximum',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _badgeController,
                keyboardType: TextInputType.text,
                label: 'Badge',
                decoration: const InputDecoration(
                  labelText: 'Badge',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformCheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Pass'),
                    value: pass,
                    onChanged: (value) {
                      setState(() {
                        pass = value!;
                        updated = true;
                      });
                    }),
              )
            ],
          ),
          PlatformButton(
            onPressed: () {
              submit(context);
            },
            child: Text(widget.weapon.id == null
                ? 'Add Weapons Qual'
                : 'Update Weapons Qual'),
          ),
        ],
      ),
    );
  }
}
