import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Order {
  String id;
  String owner;
  List<dynamic> users;
  String title;
  DateTime dueDate;
  String description;
  List<dynamic> soldiers;

  Order({
    this.id,
    @required this.owner,
    @required this.users,
    this.title = '',
    this.dueDate,
    this.description = '',
    @required this.soldiers,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['users'] = users;
    map['title'] = title;
    map['dueDate'] = dueDate;
    map['description'] = description;
    map['soldiers'] = soldiers;

    return map;
  }

  factory Order.fromSnapshot(DocumentSnapshot doc) {
    return Order(
      id: doc.id,
      owner: doc['owner'],
      users: doc['users'],
      title: doc['title'],
      dueDate: doc['dueDate'],
      description: doc['description'],
      soldiers: doc['soldiers'],
    );
  }
}
