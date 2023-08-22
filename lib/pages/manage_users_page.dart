import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../methods/custom_alert_dialog.dart';
import '../../methods/custom_modal_bottom_sheet.dart';
import '../../methods/theme_methods.dart';
import '../models/leader.dart';
import '../../widgets/header_text.dart';
import '../../widgets/platform_widgets/platform_icon_button.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_loading_widget.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../models/soldier.dart';
import '../widgets/platform_widgets/platform_button.dart';

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
    var user = soldier.users.firstWhere((element) => element != widget.userId);
    var items =
        soldier.users.where((element) => element != widget.userId).toList();
    customModalBottomSheet(
      context,
      StatefulBuilder(
        builder: (context, refresh) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: HeaderText('Transfer Ownership'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Select the user you want to transfer ownership to.'),
                ),
                PlatformItemPicker(
                    value: user.toString(),
                    label: const Text('User Id'),
                    items: items.map((e) => e.toString()).toList(),
                    onChanged: (value) {
                      refresh(() {
                        user = value;
                      });
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlatformButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      PlatformButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _firestore
                              .collection(Soldier.collectionName)
                              .doc(soldier.id)
                              .update({'owner': user});
                          resetSoldiers();
                        },
                        child: const Text('Transfer'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
    _firestore
        .collection(Soldier.collectionName)
        .doc(soldier.id)
        .update({'users': users});
    resetSoldiers();
  }

  void resetSoldiers() async {
    var snapshots = await _firestore
        .collection(Soldier.collectionName)
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
      body: Center(
        heightFactor: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            primary: true,
            shrinkWrap: true,
            itemCount: _soldiers.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Card(
                    color: getContrastingBackgroundColor(context),
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
                            .collection(Leader.collectionName)
                            .doc(users[i])
                            .snapshots(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Card(
                                color: getContrastingBackgroundColor(context),
                                child: PlatformLoadingWidget(),
                              );
                            default:
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 8.0, 8.0, 8.0),
                                child: Card(
                                  color: getContrastingBackgroundColor(context),
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
      ),
    );
  }
}
