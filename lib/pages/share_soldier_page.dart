import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';

import '../../models/soldier.dart';
import '../../widgets/formatted_elevated_button.dart';

class ShareSoldierPage extends StatefulWidget {
  const ShareSoldierPage({
    Key? key,
    required this.userId,
    required this.soldiers,
  }) : super(key: key);
  final String userId;
  final List<Soldier> soldiers;

  static const routeName = '/share-soldiers-page';

  @override
  ShareSoldierPageState createState() => ShareSoldierPageState();
}

class ShareSoldierPageState extends State<ShareSoldierPage> {
  TextEditingController controller = TextEditingController();

  List<DocumentSnapshot>? allSnapshots;
  late FirebaseFirestore firestore;
  String userId = '';
  bool lookupUserId = true, lookupUserEmail = false;

  void _makeSure(
      BuildContext context, String? userId, String? rank, String? name) {
    String soldierList = '';
    for (Soldier soldier in widget.soldiers) {
      soldierList = '$soldierList\n - ${soldier.rank} ${soldier.lastName}';
    }

    Widget title = const Text('Share Soldier?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
          'Are you sure you want to share these Soldiers with $rank $name? $soldierList'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        _shareSoldier(context, userId);
      },
      secondary: () {},
    );
  }

  void _shareSoldier(BuildContext context, String? userId) {
    for (Soldier soldier in widget.soldiers) {
      List<dynamic> users = soldier.users;
      users.add(userId);
      DocumentReference soldierRef =
          firestore.collection('soldiers').doc(soldier.id);
      soldierRef.update({'users': users});
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Share Soldiers'),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: ToggleButtons(
                          isSelected: [lookupUserId, lookupUserEmail],
                          fillColor: Theme.of(context).primaryColor,
                          selectedColor: Colors.white,
                          onPressed: ((value) {
                            setState(() {
                              switch (value) {
                                case 0:
                                  lookupUserId = true;
                                  lookupUserEmail = false;
                                  break;
                                case 1:
                                  lookupUserId = false;
                                  lookupUserEmail = true;
                                  break;
                              }
                            });
                          }),
                          children: [
                            SizedBox(
                              width: width > 500 ? 200 : 100,
                              child: const Center(child: Text('User Id')),
                            ),
                            SizedBox(
                              width: width > 500 ? 200 : 100,
                              child: const Center(child: Text('User Email')),
                            )
                          ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          labelText: lookupUserId ? 'User Id' : 'User Email',
                          hintText: lookupUserId
                              ? 'Enter the User Id'
                              : 'Enter the User Email',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormattedElevatedButton(
                      text: 'Find User',
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          setState(() {
                            userId = controller.text;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  '${lookupUserId ? 'User Id' : 'User Email'} must not be blank')));
                        }
                      },
                    ),
                  ),
                  FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: firestore
                          .collection('users')
                          .where(lookupUserId ? 'userId' : 'userEmail',
                              isEqualTo: userId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
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
                            if (snapshot.data!.docs.first.exists) {
                              return Card(
                                child: ListTile(
                                  title: Text(
                                      '${snapshot.data!.docs.first['rank']} ${snapshot.data!.docs.first['userName']}'),
                                  subtitle: Text(
                                      snapshot.data!.docs.first['userEmail'] ??
                                          ''),
                                  onTap: () {
                                    _makeSure(
                                        context,
                                        snapshot.data!.docs.first['userId'],
                                        snapshot.data!.docs.first['rank'],
                                        snapshot.data!.docs.first['userName']);
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
            ),
          ),
        ));
  }
}
