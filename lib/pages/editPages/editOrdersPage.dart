// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/validate.dart';
import '../../models/order.dart';
import '../../models/orders_soldier.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditOrdersPage extends StatefulWidget {
  const EditOrdersPage({
    Key key,
    @required this.userId,
    @required this.order,
    @required this.isSubscribed,
  }) : super(key: key);
  final String userId;
  final Order order;
  final bool isSubscribed;

  @override
  EditOrdersPageState createState() => EditOrdersPageState();
}

class EditOrdersPageState extends State<EditOrdersPage> {
  String _title = 'New Order';
  bool updated;
  FirebaseFirestore firestore;
  List<OrdersSoldier> soldiers;
  DateTime _dateTime;
  TimeOfDay _dueTime;
  DateFormat dateFormat;

  GlobalKey<FormState> _formKey;

  TextEditingController _titleController;
  TextEditingController _dueController;
  TextEditingController _dueTimeController;
  TextEditingController _descriptionController;

  Future<void> _pickDate(BuildContext context) async {
    var formatter = DateFormat('yyyy-MM-dd');
    if (kIsWeb || Platform.isAndroid) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _dateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2050));

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dateTime = picked;
            _dueController.text = formatter.format(picked);
            updated = true;
          });
        }
      }
    } else {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _dateTime,
                minimumDate: DateTime.now().add(const Duration(days: -365 * 5)),
                maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
                onDateTimeChanged: (value) {
                  _dateTime = value;
                  _dueController.text = formatter.format(value);
                  updated = true;
                },
              ),
            );
          });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    DateTime start = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
        _dueTime.hour, _dueTime.minute);
    var formatter = DateFormat('HHmm');
    if (kIsWeb || Platform.isAndroid) {
      final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _dueTime,
      );

      String hour = picked.hour.toString().length == 2
          ? picked.hour.toString()
          : '0${picked.hour.toString()}';
      String min = picked.minute.toString().length == 2
          ? picked.minute.toString()
          : '0${picked.minute.toString()}';

      if (picked != null) {
        if (mounted) {
          setState(() {
            _dueTime = picked;
            _dueTimeController.text = '$hour$min';
            updated = true;
          });
        }
      }
    } else {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: start,
                  onDateTimeChanged: (time) {
                    _dueTime = TimeOfDay(hour: time.hour, minute: time.minute);
                    _dueTimeController.text = formatter.format(time);
                    updated = true;
                  },
                ));
          });
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context) async {
    if (validateAndSave()) {
      Order saveOrder = Order(
        id: widget.order.id,
        owner: widget.userId,
        users: [widget.userId],
        title: _titleController.text,
        dueDate: _dateTime,
        description: _descriptionController.text,
        soldiers: soldiers.map((e) => e.toMap()).toList(),
      );

      if (widget.order.id == null) {
        DocumentReference docRef =
            await firestore.collection('orders').add(saveOrder.toMap());

        saveOrder.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('orders')
            .doc(widget.order.id)
            .set(saveOrder.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Phone');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Form is invalid - dates must be in yyyy-MM-dd format')));
    }
  }

  Future<bool> _onBackPressed() {
    if (!updated) return Future.value(true);
    return onBackPressed(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueController.dispose();
    _dueTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;

    updated = false;

    _formKey = GlobalKey<FormState>();

    if (widget.order.id != null) {
      _title = 'Edit Order';
    }

    dateFormat = DateFormat('yyyy-MM-dd HHmm');
    String dateDue = dateFormat.format(widget.order.dueDate);

    _titleController = TextEditingController(text: widget.order.title);
    _dueController = TextEditingController(text: dateDue);
    _descriptionController =
        TextEditingController(text: widget.order.description);

    initialize();
  }

  void initialize() async {
    QuerySnapshot snapshot = await firestore
        .collection('soldiers')
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: widget.userId)
        .get();

    for (DocumentSnapshot doc in snapshot.docs) {
      soldiers.add(OrdersSoldier.fromSnapshot(doc));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onWillPop: _onBackPressed,
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
                                child: TextFormField(
                                  controller: _titleController,
                                  keyboardType: TextInputType.text,
                                  enabled: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                  ),
                                  onChanged: (value) {
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _dueController,
                                  keyboardType: TextInputType.datetime,
                                  enabled: true,
                                  validator: (value) =>
                                      isValidDate(value) || value.isEmpty
                                          ? null
                                          : 'Date must be in yyyy-MM-dd format',
                                  decoration: InputDecoration(
                                      labelText: 'Due Date',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.date_range),
                                          onPressed: () {
                                            _pickDate(context);
                                          })),
                                  onChanged: (value) {
                                    _dateTime =
                                        DateTime.tryParse(value) ?? _dateTime;
                                    updated = true;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _dueTimeController,
                                  keyboardType: TextInputType.number,
                                  enabled: true,
                                  validator: (value) =>
                                      isValidTime(value) || value.isEmpty
                                          ? null
                                          : 'Time must be in hhmm format',
                                  decoration: InputDecoration(
                                      labelText: 'Due Time',
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.access_time),
                                          onPressed: () {
                                            _pickTime(context);
                                          })),
                                  onChanged: (value) {
                                    _dueTime = TimeOfDay(
                                        hour: int.tryParse(
                                                value.substring(0, 2)) ??
                                            10,
                                        minute:
                                            int.tryParse(value.substring(2)) ??
                                                0);
                                    updated = true;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              minLines: 2,
                              controller: _descriptionController,
                              enabled: true,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          FormattedElevatedButton(
                            onPressed: () {
                              submit(context);
                            },
                            text: widget.order.id == null
                                ? 'Add Order'
                                : 'Update Order',
                          ),
                        ],
                      ),
                    )),
              ),
            )));
  }
}
