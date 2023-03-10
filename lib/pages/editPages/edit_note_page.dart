import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/note.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/formatted_elevated_button.dart';

class EditNotePage extends StatefulWidget {
  const EditNotePage({
    Key key,
    @required this.note,
  }) : super(key: key);
  final Note note;

  @override
  EditNotePageState createState() => EditNotePageState();
}

class EditNotePageState extends State<EditNotePage> {
  String _title = 'New Note';
  bool updated;
  FirebaseFirestore firestore;

  GlobalKey<FormState> _formKey;
  GlobalKey<ScaffoldState> _scaffoldState;

  TextEditingController _titleController;
  TextEditingController _commentsController;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void submit(BuildContext context, String userId) async {
    if (validateAndSave()) {
      Note saveNote = Note(
        id: widget.note.id,
        owner: userId,
        title: _titleController.text,
        comments: _commentsController.text,
      );

      if (widget.note.id == null) {
        DocumentReference docRef =
            await firestore.collection('notes').add(saveNote.toMap());

        saveNote.id = docRef.id;
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        firestore
            .collection('notes')
            .doc(widget.note.id)
            .set(saveNote.toMap())
            .then((value) {
          Navigator.pop(context);
        }).catchError((e) {
          // ignore: avoid_print
          print('Error $e thrown while updating Perstat');
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
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    firestore = FirebaseFirestore.instance;

    updated = false;

    _formKey = GlobalKey<FormState>();
    _scaffoldState = GlobalKey<ScaffoldState>();

    if (widget.note.id != null) {
      _title = 'Edit Note';
    }

    _titleController = TextEditingController(text: widget.note.title);
    _commentsController = TextEditingController(text: widget.note.comments);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width > 932 ? (width - 916) / 2 : 16),
          child: Card(
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onWillPop: _onBackPressed,
                child: Container(
                    padding: const EdgeInsets.all(16.0),
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          if (user.isAnonymous) const AnonWarningBanner(),
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
                              keyboardType: TextInputType.multiline,
                              maxLines: 20,
                              controller: _commentsController,
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: 'Comments'),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          FormattedElevatedButton(
                            onPressed: () {
                              submit(context, user.uid);
                            },
                            text: widget.note.id == null
                                ? 'Add Note'
                                : 'Update Note',
                          ),
                        ],
                      ),
                    ))),
          ),
        ));
  }
}
