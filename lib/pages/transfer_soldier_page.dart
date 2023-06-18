import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../methods/custom_alert_dialog.dart';
import '../../methods/theme_methods.dart';
import '../../models/soldier.dart';
import '../../models/user.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../../widgets/platform_widgets/platform_item_picker.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_loading_widget.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/platform_widgets/platform_selection_widget.dart';
import '../../widgets/standard_text.dart';
import '../widgets/upload_frame.dart';

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
  String? userId = '', method = 'UserId';
  List<String> userIds = [];
  final List<String> methods = ['UserId', 'DropDown'];
  bool retainAccess = true;

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
      List<String> users = soldier.users as List<String>;
      if (!users.contains(userId)) {
        users.add(userId!);
      }
      if (!remainMember!) {
        users.remove(widget.userId);
      }
      DocumentReference soldierRef =
          firestore.collection(Soldier.collectionName).doc(soldier.id);
      await soldierRef.update({'users': users, 'owner': userId});
    }
  }

  @override
  void initState() {
    super.initState();

    for (Soldier soldier in widget.soldiers) {
      userIds.addAll(soldier.users.map((e) => e.toString()).toList());
    }
    userIds = userIds.toSet().toList();
    userId = userIds.first;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      title: 'Transfer Soldiers',
      body: UploadFrame(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformSelectionWidget(
              titles: const [
                StandardText('Type In User Id'),
                StandardText('Select User Id From Dropdown')
              ],
              values: methods,
              groupValue: method,
              onChanged: (value) {
                setState(() {
                  method = value.toString();
                  userId = userIds.first;
                });
              },
            ),
          ),
          method == 'UserId'
              ? PaddedTextField(
                  controller: controller,
                  label: 'User ID',
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter the User ID',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformItemPicker(
                    label: const StandardText('User'),
                    items: userIds,
                    value: userId!,
                    onChanged: (value) {
                      setState(
                        () {
                          userId = value.toString();
                        },
                      );
                    },
                  ),
                ),
          method == 'UserId'
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformButton(
                    child: const HeaderText(
                      'Find User',
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          userId = controller.text;
                        });
                      } else {
                        FToast toast = FToast();
                        toast.context = context;
                        toast.showToast(
                          child: const MyToast(
                              message: 'User Id must not be blank'),
                        );
                      }
                    },
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformCheckboxListTile(
              value: retainAccess,
              title: const StandardText('Retain Read/Update Access'),
              onChanged: (value) {
                setState(() {
                  retainAccess = value!;
                });
              },
            ),
          ),
          FutureBuilder<DocumentSnapshot>(
            future:
                firestore.collection(UserObj.collectionName).doc(userId).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Card(
                  color: getContrastingBackgroundColor(context),
                  child: PlatformListTile(
                    title: const StandardText(
                      'No User Found',
                    ),
                  ),
                );
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return PlatformLoadingWidget();
                default:
                  if (snapshot.data!.exists) {
                    return Card(
                      color: getContrastingBackgroundColor(context),
                      child: PlatformListTile(
                        title: StandardText(
                            '${snapshot.data!['rank'] ?? ''} ${snapshot.data!['userName'] ?? ''}'),
                        subtitle:
                            StandardText(snapshot.data!['userEmail'] ?? ''),
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
                    return Card(
                      color: getContrastingBackgroundColor(context),
                      child: PlatformListTile(
                        title: const StandardText('No User Found'),
                      ),
                    );
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
