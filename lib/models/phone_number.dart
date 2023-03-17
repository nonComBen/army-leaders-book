import 'package:cloud_firestore/cloud_firestore.dart';

class Phone {
  String? id;
  String owner;
  String title;
  String name;
  String phone;
  String location;

  Phone({
    this.id,
    required this.owner,
    this.title = '',
    this.name = '',
    this.phone = '',
    this.location = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['title'] = title;
    map['name'] = name;
    map['phone'] = phone;
    map['location'] = location;

    return map;
  }

  factory Phone.fromSnapshot(DocumentSnapshot doc) {
    return Phone(
      id: doc.id,
      owner: doc['owner'],
      title: doc['title'],
      name: doc['name'],
      phone: doc['phone'],
      location: doc['location'],
    );
  }
}
