import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_selection_widget.dart';

import '../../methods/custom_alert_dialog.dart';
import '../../methods/theme_methods.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/padded_text_field.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/platform_widgets/platform_loading_widget.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../models/soldier.dart';
import '../widgets/upload_frame.dart';

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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userId = '', lookUpMethod = 'User ID';
  final List<String> lookUpMethods = ['User ID', 'User Email'];

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
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        title: 'Share Soldiers',
        body: UploadFrame(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformSelectionWidget(
                titles: [
                  Text(
                    'User ID',
                    style: TextStyle(
                      color: getTextColor(context),
                    ),
                  ),
                  Text(
                    'User Email',
                    style: TextStyle(
                      color: getTextColor(context),
                    ),
                  )
                ],
                values: lookUpMethods,
                groupValue: lookUpMethod,
                onChanged: (value) => setState(() {
                  lookUpMethod = value.toString();
                }),
              ),
            ),
            PaddedTextField(
              controller: controller,
              label: lookUpMethod,
              decoration: InputDecoration(
                labelText: lookUpMethod,
                hintText: lookUpMethod == 'User ID'
                    ? 'Enter the User Id'
                    : 'Enter the User Email',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformButton(
                child: const Text('Find User'),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    setState(() {
                      userId = controller.text;
                    });
                  } else {
                    FToast toast = FToast();
                    toast.context = context;
                    toast.showToast(
                      child:
                          MyToast(message: '$lookUpMethod must not be blank'),
                    );
                  }
                },
              ),
            ),
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: firestore
                    .collection('users')
                    .where(lookUpMethod == 'User ID' ? 'userId' : 'userEmail',
                        isEqualTo: userId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Card(
                      color: getContrastingBackgroundColor(context),
                      child: PlatformListTile(
                        title: const Text('No User Found'),
                      ),
                    );
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return PlatformLoadingWidget();
                    default:
                      if (snapshot.data!.docs.first.exists) {
                        return Card(
                          color: getContrastingBackgroundColor(context),
                          child: PlatformListTile(
                            title: Text(
                                '${snapshot.data!.docs.first['rank']} ${snapshot.data!.docs.first['userName']}'),
                            subtitle: Text(
                                snapshot.data!.docs.first['userEmail'] ?? ''),
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
                        return Card(
                          color: getContrastingBackgroundColor(context),
                          child: PlatformListTile(
                            title: const Text('No User Found'),
                          ),
                        );
                      }
                  }
                }),
          ],
        ));
  }
}
