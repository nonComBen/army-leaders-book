import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/create_account_page.dart';
import 'pages/home_page.dart';
import './providers/root_provider.dart';
import 'pages/local_auth_login_page.dart';
import './pages/login.dart';
import 'pages/link_anonymous_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  RootPageState createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  String? emailAddress;
  User? user;
  late RootProvider _rootProvider;

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
          default:
            return LoginPage(
              onSignedIn: _rootProvider.signIn,
            );
        }
      },
    );
  }
}
