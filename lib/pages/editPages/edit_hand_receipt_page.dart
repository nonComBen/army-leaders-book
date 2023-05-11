import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants/firestore_collections.dart';
import '../../methods/create_less_soldiers.dart';
import '../../models/soldier.dart';
import '../../providers/soldiers_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/theme_methods.dart';
import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../methods/toast_messages.dart/soldier_id_is_blank.dart';
import '../../methods/validate.dart';
import '../../models/hand_receipt_item.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/form_grid_view.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_soldier_picker.dart';

class EditHandReceiptPage extends ConsumerStatefulWidget {
  const EditHandReceiptPage({
    Key? key,
    required this.item,
  }) : super(key: key);
  final HandReceiptItem item;

  @override
  EditHandReceiptPageState createState() => EditHandReceiptPageState();
}

class EditHandReceiptPageState extends ConsumerState<EditHandReceiptPage> {
  String _title = 'New Hand Receipt Item';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _nsnController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  String? _soldierId, _rank, _lastName, _firstName, _section, _rankSort, _owner;
  List<dynamic>? _users, _subComponents;
  List<Soldier>? allSoldiers, lessSoldiers;
  bool removeSoldiers = false, updated = false;
  FToast toast = FToast();

  @override
  void dispose() {
    _itemController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _nsnController.dispose();
    _locationController.dispose();
    _valueController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    allSoldiers = ref.read(soldiersProvider);

    if (widget.item.id != null) {
      _title = '${widget.item.rank} ${widget.item.name}';
    }

    _soldierId = widget.item.soldierId;
    _rank = widget.item.rank;
    _lastName = widget.item.name;
    _firstName = widget.item.firstName;
    _section = widget.item.section;
    _rankSort = widget.item.rankSort;
    _owner = widget.item.owner;
    _users = widget.item.users;

    _itemController.text = widget.item.item;
    _modelController.text = widget.item.model;
    _serialController.text = widget.item.serial;
    _nsnController.text = widget.item.nsn;
    _locationController.text = widget.item.location;
    _valueController.text = widget.item.value;
    _commentsController.text = widget.item.comments;

    _subComponents = widget.item.subComponents;

    removeSoldiers = false;
    updated = false;
  }

  void _editSubComponent(BuildContext context, int? index) {
    TextEditingController subController = TextEditingController();
    TextEditingController nsnController = TextEditingController();
    TextEditingController onHandController = TextEditingController();
    TextEditingController reqController = TextEditingController();
    if (index != null) {
      subController.text = _subComponents![index]['item'];
      nsnController.text = _subComponents![index]['nsn'];
      onHandController.text = _subComponents![index]['onHand'];
      reqController.text = _subComponents![index]['required'];
    }
    Widget title =
        Text(index != null ? 'Edit Subcompenent' : 'Add Subcompenent');
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PaddedTextField(
          controller: subController,
          keyboardType: TextInputType.text,
          label: 'Item',
          decoration: const InputDecoration(labelText: 'Item'),
        ),
        PaddedTextField(
          controller: nsnController,
          keyboardType: TextInputType.number,
          label: 'NSN #',
          decoration: const InputDecoration(labelText: 'NSN #'),
        ),
        PaddedTextField(
          controller: onHandController,
          keyboardType: TextInputType.number,
          label: 'On Hand',
          decoration: const InputDecoration(labelText: 'On Hand'),
        ),
        PaddedTextField(
          controller: reqController,
          keyboardType: TextInputType.number,
          label: 'Required',
          decoration: const InputDecoration(labelText: 'Required'),
        ),
      ],
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Subcomponent' : 'Edit Subcompenent',
      primary: () {
        setState(() {
          Map<String, dynamic> map = {
            'item': subController.text,
            'nsn': nsnController.text,
            'onHand': onHandController.text,
            'required': reqController.text
          };
          if (index != null) {
            _subComponents![index] = map;
          } else {
            _subComponents!.add(map);
          }
        });
      },
      secondary: () {},
    );
  }

  List<Widget> _subComponentWidgets() {
    List<Widget> subComponents = [];
    for (int index = 0; index < _subComponents!.length; index++) {
      subComponents.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            color: getContrastingBackgroundColor(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_subComponents![index]['item']),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                          '${_subComponents![index]['onHand']}/${_subComponents![index]['required']}'),
                    )
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('NSN: ${_subComponents![index]['nsn']}'),
                ),
                trailing: PlatformIconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _subComponents!.removeAt(index);
                    });
                  },
                ),
                onTap: () {
                  _editSubComponent(context, index);
                },
              ),
            ),
          ),
        ),
      );
    }
    return subComponents;
  }

  void submit(BuildContext context) async {
    if (_soldierId == null) {
      soldierIdIsBlankMessage(context);
      return;
    }
    if (validateAndSave(
      _formKey,
      [],
    )) {
      HandReceiptItem saveHRItem = HandReceiptItem(
        id: widget.item.id,
        soldierId: _soldierId,
        owner: _owner!,
        users: _users!,
        rank: _rank!,
        name: _lastName!,
        firstName: _firstName!,
        section: _section!,
        rankSort: _rankSort!,
        item: _itemController.text,
        model: _modelController.text,
        serial: _serialController.text,
        nsn: _nsnController.text,
        location: _locationController.text,
        value: _valueController.text,
        subComponents: _subComponents!,
        comments: _commentsController.text,
      );

      if (widget.item.id == null) {
        DocumentReference docRef = await firestore
            .collection(kHandReceiptCollection)
            .add(saveHRItem.toMap());

        saveHRItem.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection(kHandReceiptCollection)
            .doc(widget.item.id)
            .set(saveHRItem.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Hand Receipt');
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
                      collection: kHandReceiptCollection,
                      userId: user.uid,
                      allSoldiers: allSoldiers!,
                    );
                  },
                ),
              ),
              PaddedTextField(
                controller: _itemController,
                keyboardType: TextInputType.text,
                label: 'Item',
                decoration: const InputDecoration(
                  labelText: 'Item',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _modelController,
                keyboardType: TextInputType.number,
                label: 'Model #',
                decoration: const InputDecoration(
                  labelText: 'Model #',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _serialController,
                keyboardType: TextInputType.text,
                label: 'Serial #',
                decoration: const InputDecoration(
                  labelText: 'Serial #',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _nsnController,
                keyboardType: TextInputType.text,
                label: 'NSN #',
                decoration: const InputDecoration(
                  labelText: 'NSN #',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _locationController,
                keyboardType: TextInputType.text,
                label: 'Location',
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
              PaddedTextField(
                controller: _valueController,
                keyboardType: TextInputType.text,
                label: 'Value',
                decoration: const InputDecoration(
                  labelText: 'Value',
                ),
                onChanged: (value) {
                  updated = true;
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: getPrimaryColor(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HeaderText(
                      'Subcompents',
                      style: TextStyle(
                        fontSize: 16,
                        color: getOnPrimaryColor(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformIconButton(
                      icon: Icon(
                        Icons.add,
                        size: 28,
                        color: getOnPrimaryColor(context),
                      ),
                      onPressed: () {
                        _editSubComponent(context, null);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_subComponents!.isNotEmpty)
            FormGridView(width: width, children: _subComponentWidgets()),
          Divider(
            color: getOnPrimaryColor(context),
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
            child: Text(widget.item.id == null ? 'Add Item' : 'Update Item'),
          ),
        ],
      ),
    );
  }
}
