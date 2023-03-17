import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';

import '../../models/soldier.dart';

class TransferSoldierPage extends StatefulWidget {
  const TransferSoldierPage({
    Key? key,
    required this.userId,
    required this.soldiers,
  }) : super(key: key);
  final String userId;
  final List<Soldier> soldiers;

  static const routeName = '/transfer-soldiers-page';

  @override
  TransferSoldierPageState createState() => TransferSoldierPageState();
}

class TransferSoldierPageState extends State<TransferSoldierPage> {
  TextEditingController controller = TextEditingController();

  List<DocumentSnapshot>? allSnapshots;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId = '';
  List<dynamic> userIds = [];
  bool? typeInUserId = false, retainAccess = true;

  void _makeSure(
      BuildContext context, String? userId, String? rank, String? name) {
    String soldierList = '';
    for (Soldier soldier in widget.soldiers) {
      soldierList = '$soldierList\n - ${soldier.rank} ${soldier.lastName}';
    }

    Widget title = const Text('Transfer Soldier?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
          'Are you sure you want to transfer ownership of these Soldiers to $rank $name? $soldierList'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        _transferSoldier(context, userId, retainAccess);
      },
      secondary: () {},
    );
  }

  void _transferSoldier(
      BuildContext context, String? userId, bool? remainMember) async {
    for (Soldier soldier in widget.soldiers) {
      List<dynamic> users = soldier.users;
      if (!users.contains(userId)) {
        users.add(userId);
      }
      if (!remainMember!) {
        users.remove(widget.userId);
      }
      DocumentReference soldierRef =
          firestore.collection('soldiers').doc(soldier.id);
      await soldierRef.update({'users': users, 'owner': userId});
    }
  }

  @override
  void initState() {
    super.initState();

    List<dynamic> ids = [];
    for (Soldier soldier in widget.soldiers) {
      ids.addAll(soldier.users);
    }
    for (dynamic id in ids) {
      if (!userIds.contains(id)) {
        userIds.add(id);
      }
    }
    userId = userIds.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Transfer Soldiers'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwitchListTile(
                  title: typeInUserId!
                      ? const Text('Type In User Id')
                      : const Text('Select User Id From Dropdown'),
                  value: typeInUserId!,
                  onChanged: (value) {
                    setState(() {
                      typeInUserId = value;
                      if (!typeInUserId!) {
                        userId = userIds.first;
                      }
                    });
                  },
                ),
              ),
              typeInUserId!
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            labelText: 'User Id',
                            hintText: 'Enter the User Id',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                            )),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                        items: userIds
                            .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        value: userId,
                        onChanged: (dynamic value) {
                          setState(() {
                            userId = value;
                          });
                        },
                      ),
                    ),
              typeInUserId!
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).primaryColor),
                        ),
                        child: const Text(
                          'Find User',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            setState(() {
                              userId = controller.text;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('User Id must not be blank')));
                          }
                        },
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CheckboxListTile(
                  value: retainAccess,
                  title: const Text('Retain Read/Update Access'),
                  onChanged: (value) {
                    setState(() {
                      retainAccess = value;
                    });
                  },
                ),
              ),
              FutureBuilder<DocumentSnapshot>(
                  future: firestore.collection('users').doc(userId).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Card(
                        child: ListTile(
                          title: Text('No User Found'),
                        ),
                      );
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      default:
                        if (snapshot.data!.exists) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${snapshot.data!['rank'] ?? ''} ${snapshot.data!['userName'] ?? ''}'),
                              subtitle: Text(snapshot.data!['userEmail'] ?? ''),
                              onTap: () {
                                _makeSure(
                                    context,
                                    snapshot.data!['userId'],
                                    snapshot.data!['rank'],
                                    snapshot.data!['userName']);
                              },
                            ),
                          );
                        } else {
                          return const Card(
                            child: ListTile(
                              title: Text('No User Found'),
                            ),
                          );
                        }
                    }
                  }),
            ],
          ),
        ));
  }
}
