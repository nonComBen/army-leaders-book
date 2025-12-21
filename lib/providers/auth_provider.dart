import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

abstract class BaseAuth {
  Future<User?> signInWithEmailAndPassword(String? email, String? password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<User?> createAnonymousUser();
  User? currentUser();
  Future<void> signOut();
  Future<void> resetPassword(String? email);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<User?> reathenticateWithCredential(String email, String password);
}

class AuthService implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      debugPrint('Google Signin is Initializing');
      await _googleSignIn.initialize(
          serverClientId:
              '590952710530-197ccbag50220tf9cs30i3qkqbdlo6b0.apps.googleusercontent.com');
      _isGoogleSignInInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
  }

  /// Always check Google sign in initialization before use
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Stream<User?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<User?> reathenticateWithCredential(
      String email, String password) async {
    AuthCredential credential;
    if (email == 'google') {
      GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      GoogleSignInAccount googleSignInAccount =
          (await googleSignIn.authenticate());
      GoogleSignInAuthentication gsa = googleSignInAccount.authentication;
      final GoogleSignInClientAuthorization? authorization =
          await googleSignInAccount.authorizationClient
              .authorizationForScopes(['email']);
      credential = GoogleAuthProvider.credential(
        accessToken: authorization!.accessToken,
        idToken: gsa.idToken,
      );
    } else if (email == 'apple') {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // 1. perform the sign-in request
      final appleCredential =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ], nonce: nonce);

      // Create an `OAuthCredential` from the credential returned by Apple.
      credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
    } else {
      return signInWithEmailAndPassword(email, password);
    }
    UserCredential userCredential =
        await currentUser()!.reauthenticateWithCredential(credential);
    return userCredential.user;
    //return currentUser().reauthenticateWithCredential(credential);
  }

  @override
  Future<User?> signInWithEmailAndPassword(
      String? email, String? password) async {
    var result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email!, password: password!);
    return result.user;
  }

  @override
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  @override
  Future<User?> createAnonymousUser() async {
    var result = await _firebaseAuth.signInAnonymously();
    return result.user;
  }

  @override
  User? currentUser() {
    return _firebaseAuth.currentUser;
  }

  bool isSignedIn() {
    final User? currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  @override
  Future<void> signOut() async {
    var user = _firebaseAuth.currentUser;
    GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.signOut();
    if (user?.isAnonymous ?? false) {
      user!.delete();
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String? email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email!);
  }

  @override
  Future<User?> signInWithGoogle() async {
    UserCredential result;
    if (kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // googleProvider
      //     .addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Once signed in, return the UserCredential
      result = await _firebaseAuth.signInWithPopup(googleProvider);
    } else {
      await _ensureGoogleSignInInitialized();
      GoogleSignInAccount account;
      try {
        // authenticate() throws exceptions instead of returning null
        account = await _googleSignIn.authenticate(
          scopeHint: ['email'], // Specify required scopes
        );
        debugPrint('Google Signin is Authenticated: ${account.displayName}');
      } on GoogleSignInException catch (e) {
        debugPrint(
            'Google Sign In error: code: ${e.code.name} description:${e.description} details:${e.details}');
        rethrow;
      } catch (error) {
        debugPrint('Unexpected Google Sign-In error: $error');
        rethrow;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = account.authentication;

      // Get authorization for Firebase scopes if needed
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      result = await FirebaseAuth.instance.signInWithCredential(credential);
    }

    return result.user;
  }

  @override
  Future<User?> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // 1. perform the sign-in request
    final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ], nonce: nonce);

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    var result = await _firebaseAuth.signInWithCredential(oauthCredential);

    return result.user;
  }

  Future<void> linkEmailAccount(
      String email, String password, User user) async {
    final AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await user.linkWithCredential(credential);
  }
}
