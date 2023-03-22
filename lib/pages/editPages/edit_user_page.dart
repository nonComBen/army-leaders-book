import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_service.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../methods/on_back_pressed.dart';
import '../../models/user.dart';
import '../../widgets/formatted_elevated_button.dart';
import '../../auth_provider.dart';
import '../../methods/show_snackbar.dart';
import '../../providers/root_provider.dart';
import '../../widgets/formatted_text_button.dart';

class EditUserPage extends ConsumerStatefulWidget {
  const EditUserPage({
    Key? key,
    this.userId,
  }) : super(key: key);
  final String? userId;

  @override
  EditUserPageState createState() => EditUserPageState();
}

class EditUserPageState extends ConsumerState<EditUserPage> {
  bool updated = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late UserObj user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> deleteAccount(BuildContext context) async {
    // var rootBloc = BlocProvider.of<RootBloc>(context);
    final rootService = ref.read(rootProvider.notifier);
    var auth = ref.read(authProvider);
    User user = auth.currentUser()!;
    try {
      user.delete();
      showSnackbar(context, 'Your account and data has been deleted.');
      // rootBloc.onSignOut();
      rootService.signOut();
    } on Exception catch (e) {
      if (e is FirebaseAuthException) {
        reauthenticate(context, auth, rootService);
      }
    }
  }

  void reauthenticate(
      BuildContext context, AuthService auth, RootService rootProvider) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    User? user;
    Widget title = const Text('Verify Authentication');
    Widget content = SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Please verify your authentication in order to delete your account.',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Email', icon: Icon(Icons.mail)),
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value!.isEmpty ? 'Email can\'t be empty' : null,
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
                labelText: 'Password', icon: Icon(Icons.lock)),
            validator: (value) =>
                value!.isEmpty ? 'Password can\'t be empty' : null,
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(4.0)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24.0))))),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  user = await auth.reathenticateWithCredential('google', '');
                  if (!mounted) return;
                  if (user != null) {
                    user!.delete();
                    showSnackbar(
                        context, 'Your account and data has been deleted.');
                    rootProvider.signOut();
                  } else {
                    showSnackbar(context,
                        'Failed to reauthenticate account. Account could not be deleted.');
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SignInWithAppleButton(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              iconAlignment: IconAlignment.center,
              onPressed: () async {
                Navigator.pop(context);
                user = await auth.reathenticateWithCredential('apple', '');
                if (!mounted) return;
                if (user != null) {
                  user!.delete();
                  showSnackbar(
                      context, 'Your account and data has been deleted.');
                  rootProvider.signOut();
                } else {
                  showSnackbar(context,
                      'Failed to reauthenticate account. Account could not be deleted.');
                }
              },
            ),
          )
        ],
      ),
    );
    if (kIsWeb || Platform.isAndroid) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: title,
              content: content,
              actions: <Widget>[
                FormattedTextButton(
                  label: 'Cancel',
                  onPressed: () {
                    Navigator.of(context).pop();
                    showSnackbar(context, 'Account was not deleted.');
                  },
                ),
                FormattedTextButton(
                  label: 'Continue',
                  onPressed: () async {
                    Navigator.of(context).pop();
                    user = await auth.reathenticateWithCredential(
                        emailController.text, passwordController.text);
                    if (!mounted) return;
                    if (user != null) {
                      user!.delete();
                      showSnackbar(
                          context, 'Your account and data has been deleted.');
                      rootProvider.signOut();
                    } else {
                      showSnackbar(context,
                          'Failed to reauthenticate account. Account could not be deleted.');
                    }
                  },
                )
              ],
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: title,
                content: content,
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showSnackbar(context, 'Account was not deleted.');
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('Continue'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('Continue'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      user = await auth.reathenticateWithCredential(
                          emailController.text, passwordController.text);
                      if (!mounted) return;
                      if (user != null) {
                        user!.delete();
                        showSnackbar(
                            context, 'Your account and data has been deleted.');
                        rootProvider.signOut();
                      } else {
                        showSnackbar(context,
                            'Failed to reauthenticate account. Account could not be deleted.');
                      }
                    },
                  )
                ],
              ));
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  submit(BuildContext context) {
    if (validateAndSave()) {
      UserObj saveUser = UserObj(
        userId: widget.userId,
        userRank: _rankController.text,
        userName: _nameController.text,
        userUnit: _unitController.text,
        userEmail: _emailController.text,
        subToken: user.subToken,
        tosAgree: user.tosAgree,
        agreeDate: user.agreeDate,
      );

      firestore
          .collection('users')
          .doc(widget.userId)
          .set(saveUser.toMap(), SetOptions(merge: true));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Form is invalid - name must not be empty')));
    }
  }

  void confirmDeleteAccount() {
    Widget title = const Text('Delete Account');
    Widget content = SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: const Text(
          'Are you sure you want to delete this account? All data associated with this account will also be deleted.',
        ),
      ),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Continue',
      primary: () {
        deleteAccount(context);
      },
      secondary: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    DocumentSnapshot doc = await firestore.doc('users/${widget.userId}').get();
    user = UserObj.fromSnapshot(doc);
    _rankController.text = user.userRank;
    _nameController.text = user.userName;
    _unitController.text = user.userUnit;
    _emailController.text = user.userEmail;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Edit User'),
        actions: [
          Tooltip(
            message: 'Delete Account',
            child: IconButton(
                onPressed: confirmDeleteAccount,
                icon: const Icon(Icons.delete)),
          )
        ],
      ),
      body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onWillPop:
              updated ? () => onBackPressed(context) : () => Future(() => true),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width > 932 ? (width - 916) / 2 : 16),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                constraints: const BoxConstraints(maxWidth: 900),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      GridView.count(
                        primary: false,
                        crossAxisCount: width > 700 ? 2 : 1,
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 1.0,
                        childAspectRatio: width > 900
                            ? 900 / 230
                            : width > 700
                                ? width / 230
                                : width / 115,
                        shrinkWrap: true,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: widget.userId,
                              enabled: true,
                              decoration: InputDecoration(
                                  labelText: 'User Id',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.content_copy),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: widget.userId));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content:
                                            Text('User ID copied to clipboard'),
                                      ));
                                    },
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _rankController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Rank',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) => value!.isEmpty
                                  ? 'Name can\'t be empty'
                                  : null,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _unitController,
                              keyboardType: TextInputType.text,
                              enabled: true,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                              onChanged: (value) {
                                updated = true;
                              },
                            ),
                          ),
                          if (_emailController.text == 'applesignin@apple.com')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: true,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                                onChanged: (value) {
                                  updated = true;
                                },
                              ),
                            ),
                        ],
                      ),
                      FormattedElevatedButton(
                        onPressed: () {
                          submit(context);
                        },
                        text: 'Update Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
