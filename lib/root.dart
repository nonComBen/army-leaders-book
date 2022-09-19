import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/createAccountPage.dart';
import './pages/homePage.dart';
import './providers/root_provider.dart';
import './pages/localAuthLoginPage.dart';
import './pages/login.dart';
import './pages/linkAnonymousPage.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key key}) : super(key: key);

  @override
  RootPageState createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  String emailAddress;
  User user;
  RootProvider _rootProvider;

  // void _signedIn(UserObj userObj) {
  //   setState(() {
  //     _userObj = userObj;
  //     _soldiersProvider.loadSoldiers(userObj.userId);
  //     _rootProvider.signIn();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<RootProvider>(
      builder: (context, rootProvider, child) {
        _rootProvider = rootProvider;
        switch (rootProvider.authStatus) {
          case AuthStatus.notSignedIn:
            return LoginPage(
              onSignedIn: _rootProvider.signIn,
            );
          case AuthStatus.signedIn:
            return const HomePage();
          case AuthStatus.linkAnonymous:
            return LinkAnonymousPage(
              onAccountLinked: _rootProvider.signIn,
            );
          case AuthStatus.createAccount:
            return CreateAccountPage(
              onAccountCreated: _rootProvider.signIn,
            );
          case AuthStatus.localAuthSignIn:
            return const LocalAuthLoginPage();
        }
        return null;
      },
    );
  }
}
