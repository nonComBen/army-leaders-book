import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String? id;
  final String soldierId;
  final List<dynamic> users;
  final List<String?> tokens;
  final String title;
  final String body;
  final String date;
  final String topic;

  Notification({
    this.id,
    required this.soldierId,
    required this.body,
    required this.date,
    required this.title,
    required this.tokens,
    required this.topic,
    required this.users,
  });

  static const String collectionName = 'notifications';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['soldierId'] = soldierId;
    map['users'] = users;
    map['tokens'] = tokens;
    map['title'] = title;
    map['body'] = body;
    map['date'] = date;
    map['topic'] = topic;

    return map;
  }

  factory Notification.fromSnapshot(DocumentSnapshot doc) {
    return Notification(
      id: doc.id,
      soldierId: doc['soldierId'],
      users: doc['users'],
      tokens: doc['tokens'],
      title: doc['title'],
      body: doc['body'],
      date: doc['date'],
      topic: doc['topic'],
    );
  }
}
