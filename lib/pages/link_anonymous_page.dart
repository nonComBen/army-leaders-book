import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/theme_methods.dart';
import '../providers/root_provider.dart';
import '../auth_provider.dart';
import '../../models/user.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class LinkAnonymousPage extends ConsumerStatefulWidget {
  const LinkAnonymousPage({
    Key? key,
  }) : super(key: key);

  @override
  LinkAnonymousPageState createState() => LinkAnonymousPageState();
}

class LinkAnonymousPageState extends ConsumerState<LinkAnonymousPage> {
  final formKey = GlobalKey<FormState>();
  String? _email, _password;
  bool tosAgree = false;
  final _passwordController = TextEditingController();
  final _rankController = TextEditingController();
  final _nameController = TextEditingController();
  User? user;

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  bool validateAndSave() {
    if (!tosAgree) {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message:
              'You must agree to the Terms and Conditions to create an account.',
        ),
      );

      return false;
    }
    final form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndLink() async {
    final auth = ref.read(authProvider);
    if (validateAndSave()) {
      try {
        await auth.linkEmailAccount(_email!, _password!, user!);
        UserObj userObj = UserObj(
          userId: user!.uid,
          userRank: _rankController.text,
          userName: _nameController.text,
          userEmail: _email!,
          tosAgree: true,
          createdDate: DateTime.now(),
          lastLoginDate: DateTime.now(),
          agreeDate: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set(userObj.toMap(), SetOptions(merge: true));
        ref.read(rootProvider.notifier).signIn();
      } catch (e) {
        FToast toast = FToast();
        toast.context = context;
        toast.showToast(
          child: MyToast(message: e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootService = ref.read(rootProvider.notifier);
    var auth = ref.read(authProvider);
    user = auth.currentUser();
    return PlatformScaffold(
      title: 'Create Account',
      body: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Card(
                color: getContrastingBackgroundColor(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(height: 32.0),
                      Hero(
                        tag: 'hero',
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 96.0,
                          child: Image.asset('assets/icon-512.png'),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Rank (Optional)',
                        ),
                        keyboardType: TextInputType.text,
                        controller: _rankController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name (Optional)',
                        ),
                        keyboardType: TextInputType.text,
                        controller: _nameController,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Email', icon: Icon(Icons.mail)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Email can\'t be empty' : null,
                        onSaved: (value) => _email = value!.trim(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Password', icon: Icon(Icons.lock)),
                        controller: _passwordController,
                        validator: (value) =>
                            value!.isEmpty ? 'Password can\'t be empty' : null,
                        onSaved: (value) => _password = value,
                        obscureText: true,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            icon: Icon(Icons.lock)),
                        validator: (value) => value != _passwordController.text
                            ? 'Password fields must match'
                            : null,
                        obscureText: true,
                      ),
                      CheckboxListTile(
                          title: Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: TextButton(
                              child: const Text(
                                'I agree toTerms and Conditions',
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                              onPressed: () => _launchURL(
                                  'https://www.termsfeed.com/terms-conditions/0424a9962833498977879c797842c626'),
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: tosAgree,
                          onChanged: (value) {
                            setState(() {
                              tosAgree = value!;
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                        const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(24.0))))),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Create Account',
                                  style: TextStyle(fontSize: 18.0)),
                            ),
                            onPressed: () {
                              validateAndLink();
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                        const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(24.0))))),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Return Without Creating Account',
                                style: TextStyle(fontSize: 18.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            onPressed: () {
                              rootService.signIn();
                            }),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
