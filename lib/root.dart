import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_home_page.dart';

import 'pages/create_account_page.dart';
import './providers/root_provider.dart';
import 'pages/local_auth_login_page.dart';
import './pages/login.dart';
import 'pages/link_anonymous_page.dart';

class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key});

  @override
  RootPageState createState() => RootPageState();
}

class RootPageState extends ConsumerState<RootPage> {
  String? emailAddress;
  User? user;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authStatus = ref.watch(rootProvider);
        switch (authStatus) {
          case AuthStatus.notSignedIn:
            return const LoginPage();
          case AuthStatus.signedIn:
            return PlatformHomePage();
          case AuthStatus.linkAnonymous:
            return const LinkAnonymousPage();
          case AuthStatus.createAccount:
            return const CreateAccountPage();
          case AuthStatus.localAuthSignIn:
            return const LocalAuthLoginPage();
          default:
            return const LoginPage();
        }
      },
    );
  }
}
