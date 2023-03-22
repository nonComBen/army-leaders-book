import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_service.dart';
import 'package:leaders_book/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth_provider.dart';
import '../providers/root_provider.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({
    Key? key,
  }) : super(key: key);

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final formKey = GlobalKey<FormState>();
  String? _email, _password;
  bool tosAgree = false;
  final _passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  bool validateAndSave() {
    if (!tosAgree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'You must agree to the Terms and Conditions to create an account.')));
      return false;
    }
    final form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndCreate(AuthService auth) async {
    if (validateAndSave()) {
      try {
        User user =
            (await auth.createUserWithEmailAndPassword(_email!, _password!))!;
        final userObj = UserObj(
          userId: user.uid,
          userEmail: user.email!,
          userName: user.displayName ?? '',
          createdDate: DateTime.now(),
          lastLoginDate: DateTime.now(),
          updatedUserArray: true,
          agreeDate: DateTime.now(),
        );
        FirebaseFirestore.instance
            .doc('users/${user.uid}')
            .set(userObj.toMap());
        ref.read(rootProvider.notifier).signIn();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootService = ref.read(rootProvider.notifier);
    var auth = ref.read(authProvider);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 932 ? (width - 916) / 2 : 16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Card(
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
                        title: TextButton(
                          child: const Text(
                            'I agree to Terms and Conditions',
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                          onPressed: () => _launchURL(
                              'https://www.termsfeed.com/terms-conditions/0424a9962833498977879c797842c626'),
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
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(24.0))))),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Create Account',
                                style: TextStyle(fontSize: 20.0)),
                          ),
                          onPressed: () {
                            validateAndCreate(auth);
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24.0),
                                ),
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Have an account? Login',
                              style: TextStyle(fontSize: 20.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            // _rootBloc.onSignOut();
                            rootService.signOut();
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
