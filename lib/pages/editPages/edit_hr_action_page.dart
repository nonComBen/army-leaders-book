import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/local_notification_methods.dart';

import '../../auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/hr_action.dart';
import '../../models/setting.dart';
import '../../models/soldier.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/shared_prefs_provider.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';
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
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dd93Date, _sglvDate, _prrDate;
  FToast toast = FToast();
  Setting? setting;

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

    allSoldiers = ref.read(soldiersProvider);

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

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [_dd93Controller.text, _sglvController.text, _prrController.text],
    )) {
      setting = ref.read(settingsProvider);
      List<int> notificationIds = [];
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      if (!kIsWeb && setting!.addNotifications) {
        final notificationService = ref.read(notificationProvider);
        final prefs = ref.read(sharedPreferencesProvider);
        int id = prefs.getInt('notificationId') ?? 0;

        if (widget.hrAction.notificationIds.isNotEmpty) {
          notificationService
              .cancelPreviousNotifications(widget.hrAction.notificationIds);
        }

        List<String> topics = ['DD93', 'SGLV', 'PRR'];
        for (String topic in topics) {
          final date = getDate(topic);
          if (date != '') {
            DateTime dueDate = getDueDate(date, setting!.hrActionMonths);

            for (int days in setting!.hrActionNotifications) {
              notificationIds.add(id);
              notificationService.scheduleNotification(
                dateTime: dueDate.subtract(Duration(days: days)),
                id: id,
                title: '$_rank $_lastName\'s $topic Due',
                body:
                    '$_rank $_lastName\'s $topic Due in $days on ${formatter.format(dueDate)}',
                payload: NotificationService.hrMetricsPayload,
              );
              id++;
            }
          }
        }
        prefs.setInt('notificationId', id);
      }

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
        notificationIds: notificationIds,
      );

      if (widget.hrAction.id == null) {
        firestore.collection(HrAction.collectionName).add(saveHrAction.toMap());
      } else {
        firestore
            .collection(HrAction.collectionName)
            .doc(widget.hrAction.id)
            .set(saveHrAction.toMap());
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

  String getDate(String topic) {
    switch (topic) {
      case 'DD93':
        return _dd93Controller.text;
      case 'SGLV':
        return _sglvController.text;
      default:
        return _prrController.text;
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
                      collection: HrAction.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
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
