import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_provider.dart';
import '../../methods/on_back_pressed.dart';
import '../../models/note.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';

class EditNotePage extends ConsumerStatefulWidget {
  const EditNotePage({
    Key? key,
    required this.note,
  }) : super(key: key);
  final Note note;

  @override
  EditNotePageState createState() => EditNotePageState();
}

class EditNotePageState extends ConsumerState<EditNotePage> {
  String _title = 'New Note';
  bool updated = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

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
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.note.id != null) {
      _title = 'Edit Note';
    }

    _titleController.text = widget.note.title;
    _commentsController.text = widget.note.comments;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    return PlatformScaffold(
      title: _title,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 932 ? (width - 916) / 2 : 16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onWillPop:
              updated ? () => onBackPressed(context) : () => Future(() => true),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: <Widget>[
                if (user.isAnonymous) const AnonWarningBanner(),
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
                  keyboardType: TextInputType.multiline,
                  maxLines: 20,
                  controller: _commentsController,
                  enabled: true,
                  decoration: const InputDecoration(labelText: 'Comments'),
                  onChanged: (value) {
                    updated = true;
                  },
                ),
                PlatformButton(
                  onPressed: () {
                    submit(context, user.uid);
                  },
                  child:
                      Text(widget.note.id == null ? 'Add Note' : 'Update Note'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
