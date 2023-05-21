import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:leaders_book/providers/selected_soldiers_provider.dart';

import '../models/soldier.dart';

Future<void> deleteSoldiers(BuildContext context,
    List<Soldier> selectedSoldiers, String userId, WidgetRef ref) async {
  bool superWarning = false;
  for (Soldier soldier in selectedSoldiers) {
    if (soldier.owner == userId && soldier.users.length > 1) {
      superWarning = true;
    }
  }

  Text superWarningText = const Text(
      'One or more of the Soldiers you are trying to delete are shared with other users. If you delete the Soldiers, '
      'the shared users will lose access to the records. It is best to transfer ownership of Soldier records you own (blue text). Do you still '
      'want to delete the selected Soldiers?');
  Widget title = const Text('Delete Soldiers?');
  Widget content = Container(
    padding: const EdgeInsets.all(8.0),
    child: superWarning
        ? superWarningText
        : const Text('Are you sure you want to delete the selected Soldiers?'),
  );
  await customAlertDialog(
    context: context,
    title: title,
    content: content,
    primaryText: 'Yes',
    primary: () {
      for (Soldier soldier in selectedSoldiers) {
        deleteSoldier(soldier, userId);
      }
      ref.read(selectedSoldiersProvider.notifier).clearSoldiers();
    },
    secondaryText: 'Cancel',
    secondary: () {},
  );
}

Future<void> deleteSoldier(Soldier soldier, String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  if (soldier.owner == uid) {
    db.collection('soldiers').doc(soldier.id).delete();
  } else {
    List<dynamic> users = soldier.users;
    users.remove(uid);
    DocumentReference ref =
        FirebaseFirestore.instance.collection('soldiers').doc(soldier.id);
    ref.update({'users': users});
  }
}

void deleteRecord(BuildContext context, List<DocumentSnapshot>? selectedDocs,
    String? userId, String record) {
  Widget title = Text('Delete $record?');
  Widget content = Container(
    padding: const EdgeInsets.all(8.0),
    child: Text('Are you sure you want to delete the selected $record?'),
  );
  customAlertDialog(
    context: context,
    title: title,
    content: content,
    primaryText: 'Yes',
    primary: () {
      for (DocumentSnapshot doc in selectedDocs!) {
        if (doc['owner'] == userId) {
          doc.reference.delete();
        } else {
          List<dynamic> users = doc['users'];
          users.remove(userId);
          doc.reference.update({'users': users});
        }
      }
    },
    secondary: () {},
  );
}
