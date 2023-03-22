import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_service.dart';
import 'package:leaders_book/providers/soldiers_provider.dart';
import 'package:local_auth/local_auth.dart';

import '../auth_provider.dart';
import '../providers/root_provider.dart';
import '../providers/user_provider.dart';

class LocalAuthLoginPage extends ConsumerStatefulWidget {
  const LocalAuthLoginPage({Key? key}) : super(key: key);

  @override
  LocalAuthLoginPageState createState() => LocalAuthLoginPageState();
}

class LocalAuthLoginPageState extends ConsumerState<LocalAuthLoginPage> {
  AuthService? _auth;

  void onUnlockApp(BuildContext context) async {
    final rootService = ref.read(rootProvider.notifier);
    final soldiersService = ref.read(soldiersProvider.notifier);
    final LocalAuthentication localAuth = LocalAuthentication();

    bool authenticated = await localAuth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(stickyAuth: true));

    if (authenticated) {
      soldiersService.loadSoldiers(_auth!.currentUser()!.uid);
      rootService.signIn();
    }
  }

  void onSignOut(BuildContext context) {
    final rootService = ref.read(rootProvider.notifier);
    _auth!.signOut();
    rootService.signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _auth = ref.read(authProvider);
    ref.read(userProvider).loadUser(_auth!.currentUser()!.uid);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 932 ? (width - 916) / 2 : 16),
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Hero(
                    tag: 'hero',
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 96.0,
                      child: Image.asset('assets/icon-512.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24.0))))),
                    onPressed: () => onUnlockApp(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Unlock App',
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => onSignOut(context),
                    child: const Text(
                      'Back to Login Page',
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
