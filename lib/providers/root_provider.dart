import 'package:flutter/material.dart';
import 'package:leaders_book/auth.dart';

enum AuthStatus {
  notSignedIn,
  signedIn,
  linkAnonymous,
  createAccount,
  localAuthSignIn
}

class RootProvider with ChangeNotifier {
  final AuthService auth;
  AuthStatus _currentAuthStatus;
  RootProvider({
    this.auth,
  }) {
    _currentAuthStatus =
        auth.isSignedIn() ? AuthStatus.localAuthSignIn : AuthStatus.notSignedIn;
  }

  AuthStatus get authStatus {
    return _currentAuthStatus;
  }

  void signOut() {
    _currentAuthStatus = AuthStatus.notSignedIn;
    notifyListeners();
  }

  void localSignOut() {
    _currentAuthStatus = AuthStatus.localAuthSignIn;
    notifyListeners();
  }

  void signIn() {
    _currentAuthStatus = AuthStatus.signedIn;
    notifyListeners();
  }

  void linkAnonymous() {
    _currentAuthStatus = AuthStatus.linkAnonymous;
    notifyListeners();
  }

  void createAccout() {
    _currentAuthStatus = AuthStatus.createAccount;
    notifyListeners();
  }
}
