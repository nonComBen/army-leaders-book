import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/root_provider.dart';
import '../../auth.dart';
import '../auth_provider.dart';
import '../../models/user.dart';

class LinkAnonymousPage extends StatefulWidget {
  const LinkAnonymousPage({
    Key key,
    this.onAccountLinked,
  }) : super(key: key);
  final Function onAccountLinked;

  @override
  LinkAnonymousPageState createState() => LinkAnonymousPageState();
}

class LinkAnonymousPageState extends State<LinkAnonymousPage> {
  final formKey = GlobalKey<FormState>();
  String _email, _password;
  bool tosAgree = false;
  final _passwordController = TextEditingController();
  final _rankController = TextEditingController();
  final _nameController = TextEditingController();
  User user;

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
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndLink(AuthService auth) async {
    if (validateAndSave()) {
      try {
        await auth.linkEmailAccount(_email, _password, user);
        UserObj userObj = UserObj(
            userId: user.uid,
            userRank: _rankController.text,
            userName: _nameController.text,
            userEmail: _email,
            tosAgree: true,
            agreeDate: DateTime.now());
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userObj.toMap(), SetOptions(merge: true));
        widget.onAccountLinked(userObj);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootProvider = Provider.of<RootProvider>(context);
    var auth = AuthProvider.of(context).auth;
    user = auth.currentUser();
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width > 932 ? (width - 916) / 2 : 16),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
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
                              value.isEmpty ? 'Email can\'t be empty' : null,
                          onSaved: (value) => _email = value.trim(),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Password', icon: Icon(Icons.lock)),
                          controller: _passwordController,
                          validator: (value) =>
                              value.isEmpty ? 'Password can\'t be empty' : null,
                          onSaved: (value) => _password = value,
                          obscureText: true,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              icon: Icon(Icons.lock)),
                          validator: (value) =>
                              value != _passwordController.text
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
                                tosAgree = value;
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
                                validateAndLink(auth);
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
                                // widget.rootBloc.onSignIn();
                                rootProvider.signIn();
                              }),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
