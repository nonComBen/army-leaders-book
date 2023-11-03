import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../providers/settings_provider.dart';
import '../../providers/soldiers_provider.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../providers/auth_provider.dart';
import '../providers/root_provider.dart';
import '../providers/leader_provider.dart';
import '../widgets/platform_widgets/platform_text_button.dart';

class LocalAuthLoginPage extends ConsumerStatefulWidget {
  const LocalAuthLoginPage({super.key});

  @override
  LocalAuthLoginPageState createState() => LocalAuthLoginPageState();
}

class LocalAuthLoginPageState extends ConsumerState<LocalAuthLoginPage> {
  AuthService? _auth;

  void onUnlockApp(BuildContext context) async {
    final rootService = ref.read(rootProvider.notifier);
    final soldiersService = ref.read(soldiersProvider.notifier);
    final settingsService = ref.read(settingsProvider.notifier);
    final LocalAuthentication localAuth = LocalAuthentication();

    bool authenticated = await localAuth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(stickyAuth: true));

    if (authenticated) {
      soldiersService.loadSoldiers(_auth!.currentUser()!.uid);
      settingsService.init(_auth!.currentUser()!.uid);
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
    ref.read(leaderProvider).init(_auth!.currentUser()!.uid);
    return PlatformScaffold(
      title: 'Lock Screen',
      body: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: <Widget>[
                const LogoWidget(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformButton(
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
                  child: PlatformTextButton(
                    onPressed: () => onSignOut(context),
                    child: const Text(
                      'Back to Login Page',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.blue,
                      ),
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
