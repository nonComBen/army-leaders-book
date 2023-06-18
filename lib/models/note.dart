import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String? id;
  String owner;
  String title;
  String comments;

  Note({
    this.id,
    required this.owner,
    this.title = '',
    this.comments = '',
  });

  static const String collectionName = 'notes';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['title'] = title;
    map['comments'] = comments;

    return map;
  }

  factory Note.fromSnapshot(DocumentSnapshot doc) {
    return Note(
      id: doc.id,
      owner: doc['owner'],
      title: doc['title'],
      comments: doc['comments'],
    );
  }
}
