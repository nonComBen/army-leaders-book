import 'package:flutter/material.dart';
import 'package:leaders_book/providers/soldiers_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../auth_provider.dart';
import '../providers/root_provider.dart';
import '../providers/user_provider.dart';

class LocalAuthLoginPage extends StatefulWidget {
  const LocalAuthLoginPage({Key key}) : super(key: key);

  @override
  LocalAuthLoginPageState createState() => LocalAuthLoginPageState();
}

class LocalAuthLoginPageState extends State<LocalAuthLoginPage> {
  AuthService _auth;

  void onUnlockApp(BuildContext context) async {
    final rootProvider = Provider.of<RootProvider>(context, listen: false);
    final soldiersProvider =
        Provider.of<SoldiersProvider>(context, listen: false);
    final LocalAuthentication auth = LocalAuthentication();

    bool authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(stickyAuth: true));

    if (authenticated) {
      soldiersProvider.loadSoldiers(_auth.currentUser().uid);
      rootProvider.signIn();
    }
  }

  void onSignOut(BuildContext context) {
    final rootProvider = Provider.of<RootProvider>(context, listen: false);
    _auth.signOut();
    rootProvider.signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _auth = AuthProvider.of(context).auth;
    Provider.of<UserProvider>(context, listen: false)
        .loadUser(_auth.currentUser().uid);
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
                    onPressed: () =>
                        throw Exception('test crash'), // onUnlockApp(context),
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
