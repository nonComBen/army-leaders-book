import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_scaffold.dart';

import '../../methods/custom_alert_dialog.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_loading_widget.dart';
import '../models/soldier.dart';
import '../widgets/formatted_text_button.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage(
      {Key? key, required this.userId, required this.soldiers})
      : super(key: key);

  final String userId;
  final List<Soldier> soldiers;

  static const routeName = '/manage-users-page';

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<Soldier> _soldiers = [];
  final _firestore = FirebaseFirestore.instance;

  void _transferOwnership(Soldier soldier) {
    var title = const Text('Transfer Ownership');
    var user = soldier.users.firstWhere((element) => element != widget.userId);
    var items =
        soldier.users.where((element) => element != widget.userId).toList();
    if (kIsWeb || Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context2) {
            return StatefulBuilder(
              builder: ((context, refresh) {
                return AlertDialog(
                  title: title,
                  content: Column(
                    children: [
                      const Text(
                          'Select the user you want to transfer ownership to.'),
                      DropdownButtonFormField(
                          decoration:
                              const InputDecoration(labelText: 'User Id'),
                          isExpanded: true,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.black),
                          value: user,
                          items: items
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (dynamic value) {
                            refresh(() {
                              user = value;
                            });
                          })
                    ],
                  ),
                  actions: [
                    FormattedTextButton(
                      onPressed: () => Navigator.pop(context2),
                      label: 'Cancel',
                    ),
                    FormattedTextButton(
                      onPressed: () {
                        Navigator.pop(context2);
                        _firestore
                            .collection('soldiers')
                            .doc(soldier.id)
                            .update({'owner': user});
                        resetSoldiers();
                      },
                      label: 'Transfer',
                    )
                  ],
                );
              }),
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context2) {
            return StatefulBuilder(
              builder: ((context, refresh) {
                return CupertinoAlertDialog(
                  title: title,
                  content: Column(
                    children: [
                      const Text(
                          'Select the user you want to transfer ownership to.'),
                      DropdownButtonFormField(
                          isExpanded: true,
                          decoration:
                              const InputDecoration(label: Text('User Id')),
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.black),
                          value: user,
                          items: items
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (dynamic value) {
                            refresh(() {
                              user = value;
                            });
                          })
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context2),
                    ),
                    CupertinoDialogAction(
                      child: const Text('Transfer'),
                      onPressed: () {
                        Navigator.pop(context2);
                        _firestore
                            .collection('soldiers')
                            .doc(soldier.id)
                            .update({'owner': user});
                        resetSoldiers();
                      },
                    )
                  ],
                );
              }),
            );
          });
    }
  }

  void confirmDelete(Soldier soldier, String? userId) {
    var title = const Text('Remove Permissions');
    var content = const Text(
        'Are you sure you want to remove this user\'s access to this Soldier\'s records?');
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        deleteUser(soldier, userId);
      },
      secondary: () {},
    );
  }

  void deleteUser(Soldier soldier, String? userId) {
    var users = soldier.users;
    users.removeWhere((element) => element == userId);
    _firestore.collection('soldiers').doc(soldier.id).update({'users': users});
    resetSoldiers();
  }

  void resetSoldiers() async {
    var snapshots = await _firestore
        .collection('soldiers')
        .where('owner', isEqualTo: widget.userId)
        .get();
    setState(() {
      _soldiers = snapshots.docs.map((e) => Soldier.fromSnapshot(e)).toList();
    });
  }

  @override
  void initState() {
    _soldiers = widget.soldiers
        .where((element) => element.owner == widget.userId)
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      title: 'Manage Users',
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          primary: true,
          shrinkWrap: true,
          itemCount: _soldiers.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Card(
                  color: getBackgroundColor(context),
                  child: PlatformListTile(
                      trailing: _soldiers[index].users.length > 1
                          ? Tooltip(
                              message: 'Transfer Ownership',
                              child: PlatformIconButton(
                                icon: const Icon(
                                    Icons.arrow_circle_right_outlined),
                                onPressed: () {
                                  _transferOwnership(_soldiers[index]);
                                },
                              ),
                            )
                          : null,
                      title: Text(
                          '${_soldiers[index].rank} ${_soldiers[index].lastName}, ${_soldiers[index].firstName}')),
                ),
                ListView.builder(
                  itemCount: _soldiers[index]
                      .users
                      .where((element) => element != widget.userId)
                      .length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    var users = _soldiers[index]
                        .users
                        .where((element) => element != widget.userId)
                        .toList();
                    return StreamBuilder<DocumentSnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(users[i])
                          .snapshots(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Card(
                              color: getBackgroundColor(context),
                              child: PlatformLoadingWidget(),
                            );
                          default:
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 8.0, 8.0),
                              child: Card(
                                color: getBackgroundColor(context),
                                child: PlatformListTile(
                                  title: Text(
                                      '${snapshot.data!['rank']} ${snapshot.data!['userName']}'),
                                  subtitle: Text(users[i]),
                                  trailing: Tooltip(
                                    message: 'Remove Permissions',
                                    child: PlatformIconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        confirmDelete(
                                            _soldiers[index], users[i]);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                        }
                      },
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
