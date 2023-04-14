import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/phone_number.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditPhonePage extends ConsumerStatefulWidget {
  const EditPhonePage({
    Key? key,
    required this.phone,
  }) : super(key: key);
  final Phone phone;

  @override
  EditPhonePageState createState() => EditPhonePageState();
}

class EditPhonePageState extends ConsumerState<EditPhonePage> {
  String _title = 'New Phone';
  bool updated = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context, String userId) async {
    if (validateAndSave()) {
      Phone savePhone = Phone(
        id: widget.phone.id,
        owner: userId,
        title: _titleController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        location: _locationController.text,
      );

      if (widget.phone.id == null) {
        DocumentReference docRef =
            await firestore.collection('phoneNumbers').add(savePhone.toMap());

        savePhone.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('phoneNumbers')
            .doc(widget.phone.id)
            .set(savePhone.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Phone');
        });
      }
    } else {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'Form is invalid - dates must be in yyyy-MM-dd format',
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.phone.id != null) {
      _title = 'Edit Phone';
    }

    _titleController.text = widget.phone.title;
    _nameController.text = widget.phone.name;
    _phoneController.text = widget.phone.phone;
    _locationController.text = widget.phone.location;
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
                    PaddedTextField(
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
                    PaddedTextField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'POC',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                    PaddedTextField(
                      controller: _locationController,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                      ),
                      onChanged: (value) {
                        updated = true;
                      },
                    ),
                  ],
                ),
                PlatformButton(
                  onPressed: () {
                    submit(context, user.uid);
                  },
                  child: Text(
                      widget.phone.id == null ? 'Add Phone' : 'Update Phone'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
