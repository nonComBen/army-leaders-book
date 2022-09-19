// ignore_for_file: file_names, avoid_print

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';

import '../models/soldier.dart';

void deleteSoldiers(
    BuildContext context, List<Soldier> selectedSoldiers, String userId) {
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
  customAlertDialog(
    context: context,
    title: title,
    content: content,
    primaryText: 'Yes',
    primary: () {
      for (Soldier soldier in selectedSoldiers) {
        deleteSoldier(soldier, userId);
      }
    },
    secondaryText: 'Cancel',
    secondary: () {},
  );
}

Future<void> deleteSoldier(Soldier soldier, String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  if (soldier.owner == uid) {
    db.collection('soldiers').doc(soldier.id).delete().then((v) {
      print('Soldier ${soldier.id} deleted successfully');
    }).catchError((e) {
      print('Error $e thrown while deleting Soldier ${soldier.id}');
    });
  } else {
    List<dynamic> users = soldier.users;
    users.remove(uid);
    DocumentReference ref =
        FirebaseFirestore.instance.collection('soldiers').doc(soldier.id);
    ref.update({'users': users});
  }
}

void deleteRecord(BuildContext context, List<DocumentSnapshot> selectedDocs,
    String userId, String record) {
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
    secondaryText: 'Cancel',
    primary: () {
      for (DocumentSnapshot doc in selectedDocs) {
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
