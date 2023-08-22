import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/models/reminder.dart';
import 'package:leaders_book/widgets/more_tiles_header.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_selection_widget.dart';

import '../../providers/auth_provider.dart';
import '../../methods/create_less_soldiers.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/custom_modal_bottom_sheet.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/appointment.dart';
import '../../models/soldier.dart';
import '../../providers/notification_provider.dart';
import '../../providers/shared_prefs_provider.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/edit_delete_list_tile.dart';
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
import '../../widgets/stateful_widgets/time_text_field.dart';

class EditAppointmentPage extends ConsumerStatefulWidget {
  const EditAppointmentPage({
    Key? key,
    required this.apt,
  }) : super(key: key);
  final Appointment apt;

  @override
  EditAppointmentPageState createState() => EditAppointmentPageState();
}

class EditAppointmentPageState extends ConsumerState<EditAppointmentPage> {
  String _title = 'New Appointment';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String _status = 'Scheduled';
  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users;
  final List<String> _statuses = [
    'Scheduled',
    'Rescheduled',
    'Kept',
    'Cancelled',
    'Missed',
  ];
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  DateTime? _dateTime;
  TimeOfDay? _startTime, _endTime;
  FToast toast = FToast();
  late List<Reminder> _reminders;
  List<int> notificationIdsToCancel = [];

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _commentsController.dispose();
    _locController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.apt.id != null) {
      _title = '${widget.apt.rank} ${widget.apt.name}';
    }

    _soldierId = widget.apt.soldierId;
    _rank = widget.apt.rank;
    _lastName = widget.apt.name;
    _firstName = widget.apt.firstName;
    _section = widget.apt.section;
    _rankSort = widget.apt.rankSort;
    _status = widget.apt.status;
    _owner = widget.apt.owner;
    _users = widget.apt.users;
    _reminders = widget.apt.reminders
        .map((e) => Reminder.fromMap(e as Map<String, dynamic>))
        .toList();

    _startController.text = widget.apt.start;
    _endController.text = widget.apt.end;
    _titleController.text = widget.apt.aptTitle;
    _dateController.text = widget.apt.date;
    _commentsController.text = widget.apt.comments;
    _locController.text = widget.apt.location;

    _dateTime = DateTime.tryParse(_dateController.text);
    if (widget.apt.start.length == 4) {
      _startTime = TimeOfDay(
          hour: int.tryParse(widget.apt.start.substring(0, 2)) ?? 9,
          minute: int.tryParse(widget.apt.start.substring(2)) ?? 0);
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
    }
    if (widget.apt.end.length == 4) {
      _endTime = TimeOfDay(
          hour: int.tryParse(widget.apt.end.substring(0, 2)) ?? 10,
          minute: int.tryParse(widget.apt.end.substring(2)) ?? 0);
    } else {
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
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
      final notificationService = ref.read(notificationProvider);
      notificationService.cancelPreviousNotifications(notificationIdsToCancel);
      if (!kIsWeb &&
          _dateController.text != '' &&
          _startController.text != '') {
        DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm');
        DateTime aptDate =
            DateTime.tryParse(_dateController.text) ?? DateTime.now();
        int hour = int.tryParse(_startController.text.substring(0, 2)) ?? 0;
        int minute = int.tryParse(_startController.text.substring(2)) ?? 0;
        aptDate =
            DateTime(aptDate.year, aptDate.month, aptDate.day, hour, minute);
        debugPrint('Appointment Date Time: $aptDate');
        for (Reminder reminder in _reminders) {
          notificationService.scheduleNotification(
            dateTime: aptDate.subtract(Duration(minutes: reminder.minutes)),
            id: reminder.id!,
            title: '$_rank $_lastName\'s Appointment',
            body:
                '$_rank $_lastName has an appointment in ${(reminder.minutes / getConversionRate(reminder.unitOfMeasure)).floor()} ${reminder.unitOfMeasure} at ${formatter.format(aptDate)}',
            payload: 'Appointment',
          );
        }
      }

      Appointment saveApt = Appointment(
        id: widget.apt.id,
        users: _users!,
        soldierId: _soldierId,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        aptTitle: _titleController.text,
        date: _dateController.text,
        start: _startController.text,
        end: _endController.text,
        status: _status,
        comments: _commentsController.text,
        owner: _owner!,
        location: _locController.text,
        reminders: _reminders.map((e) => e.toMap()).toList(),
      );

      if (widget.apt.id == null) {
        firestore.collection(Appointment.collectionName).add(saveApt.toMap());
      } else {
        firestore
            .collection(Appointment.collectionName)
            .doc(widget.apt.id)
            .set(saveApt.toMap(), SetOptions(merge: true));
      }
      Navigator.pop(context);
    } else {
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  void editReminder(
      {required BuildContext context, required Reminder reminder, int? index}) {
    String unit = reminder.unitOfMeasure;
    TextEditingController minutes = TextEditingController(
        text: (reminder.minutes / getConversionRate(reminder.unitOfMeasure))
            .floor()
            .toString());
    final prefs = ref.read(sharedPreferencesProvider);
    int id = prefs.getInt('notificationId') ?? 0;
    customModalBottomSheet(
      context,
      StatefulBuilder(builder: (context, refresh) {
        return ListView(
          children: [
            HeaderText(
              index == null ? 'Add Reminder' : 'Edit Reminder',
            ),
            PlatformSelectionWidget(
              titles: const [Text('Minutes'), Text('Hours'), Text('Days')],
              values: const ['Minutes', 'Hours', 'Days'],
              onChanged: (value) => refresh(() {
                unit = value.toString();
              }),
            ),
            PaddedTextField(
              controller: minutes,
              keyboardType: TextInputType.number,
              enabled: true,
              decoration: InputDecoration(
                labelText: unit,
              ),
              label: unit,
            ),
            PlatformButton(
              onPressed: () {
                if (reminder.id != null) {
                  notificationIdsToCancel.add(reminder.id!);
                }
                Reminder saveReminder = Reminder(
                  id: id,
                  minutes: (int.tryParse(minutes.text) ?? 0) *
                      getConversionRate(unit),
                  unitOfMeasure: unit,
                );
                setState(() {
                  debugPrint('Minutes: ${saveReminder.minutes}');
                  debugPrint('Unit: ${saveReminder.unitOfMeasure}');
                  if (index != null) {
                    _reminders[index] = saveReminder;
                  } else {
                    _reminders.add(saveReminder);
                  }
                });
                prefs.setInt('notificationId', id + 1);
                Navigator.of(context).pop();
              },
              child: Text(index == null ? 'Add Reminder' : 'Edit Reminder'),
            )
          ],
        );
      }),
    );
  }

  void deleteReminder(BuildContext context, int index) {
    Widget title = const Text('Delete Reminder?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Are you sure you want to delete this reminder?'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        setState(() {
          notificationIdsToCancel.add(_reminders[index].id!);
          _reminders.removeAt(index);
        });
      },
      secondary: () {},
    );
  }

  int getConversionRate(String unit) {
    switch (unit) {
      case 'Hours':
        return 60;
      case 'Days':
        return 1440;
      default:
        return 1;
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
                      collection: Appointment.collectionName,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                    setState(() {
                      removeSoldiers = checked!;
                    });
                  },
                ),
              ),
              PaddedTextField(
                controller: _titleController,
                keyboardType: TextInputType.text,
                label: 'Apt Title',
                decoration: const InputDecoration(
                  labelText: 'Apt Title',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              DateTextField(
                controller: _dateController,
                label: 'Apt Date',
                minYears: 1,
                date: _dateTime,
              ),
              TimeTextField(
                controller: _startController,
                label: 'Start Time',
                time: _startTime,
              ),
              TimeTextField(
                controller: _endController,
                label: 'End Time',
                time: _endTime,
              ),
              PaddedTextField(
                controller: _locController,
                keyboardType: TextInputType.text,
                label: 'Location',
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 8.0, 8.0, width <= 700 ? 0.0 : 8.0),
                child: PlatformItemPicker(
                  label: const Text('Status'),
                  items: _statuses,
                  onChanged: (dynamic value) {
                    if (mounted) {
                      setState(() {
                        _status = value;
                        updated = true;
                      });
                    }
                  },
                  value: _status,
                ),
              ),
            ],
          ),
          if (!kIsWeb)
            MoreTilesHeader(
                label: 'Reminders',
                onPressed: () {
                  editReminder(context: context, reminder: Reminder());
                }),
          if (!kIsWeb)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FormGridView(
                width: width,
                children: _reminders
                    .map((reminder) => EditDeleteListTile(
                          title:
                              '${(reminder.minutes / getConversionRate(reminder.unitOfMeasure)).floor()} ${reminder.unitOfMeasure} Prior',
                          onIconPressed: () {
                            deleteReminder(
                              context,
                              _reminders.indexOf(reminder),
                            );
                          },
                          onTap: () {
                            editReminder(
                              context: context,
                              reminder: reminder,
                              index: _reminders.indexOf(reminder),
                            );
                          },
                        ))
                    .toList(),
              ),
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
            child: Text(widget.apt.id == null
                ? 'Add Appointment'
                : 'Update Appointment'),
            onPressed: () {
              if (_endController.text != '' &&
                  (_endTime!.hour < _startTime!.hour ||
                      (_endTime!.hour == _startTime!.hour &&
                          _endTime!.minute < _startTime!.minute))) {
                toast.showToast(
                  child: const MyToast(
                    message: 'Start Time must be before End Time',
                  ),
                );
              } else {
                submit(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
