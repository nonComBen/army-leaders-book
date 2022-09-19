import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Note {
  String id;
  String owner;
  String title;
  String comments;

  Note({this.id, @required this.owner, this.title = '', this.comments = ''});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['title'] = title;
    map['comments'] = comments;

    return map;
  }

  factory Note.fromSnapshot(DocumentSnapshot doc) {
    //soldierId is null - only use for sharing
    return Note(
      id: doc.id,
      owner: doc['owner'],
      title: doc['title'],
      comments: doc['comments'],
    );
  }
}
