import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_provider.dart';
import '../auth_service.dart';

enum AuthStatus {
  notSignedIn,
  signedIn,
  linkAnonymous,
  createAccount,
  localAuthSignIn
}

final rootProvider = StateNotifierProvider<RootService, AuthStatus>((ref) {
  return RootService(auth: ref.read(authProvider));
});

class RootService extends StateNotifier<AuthStatus> {
  RootService({required this.auth})
      : super(auth.isSignedIn()
            ? AuthStatus.localAuthSignIn
            : AuthStatus.notSignedIn);
  final AuthService auth;

  AuthStatus? get authStatus {
    return state;
  }

  void signOut() {
    state = AuthStatus.notSignedIn;
  }

  void localSignOut() {
    state = AuthStatus.localAuthSignIn;
  }

  void signIn() {
    state = AuthStatus.signedIn;
  }

  void linkAnonymous() {
    state = AuthStatus.linkAnonymous;
  }

  void createAccout() {
    state = AuthStatus.createAccount;
  }
}
