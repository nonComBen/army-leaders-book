import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [
        'email',
      ]);
      GoogleSignInAccount googleSignInAccount = (await googleSignIn.signIn())!;
      GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: gsa.accessToken,
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
  Future<User?> signInWithEmailAndPassword(String? email, String? password) async {
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
    GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [
      'email',
    ]);
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String? email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email!);
  }

  @override
  Future<User?> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [
      'email',
    ]);
    GoogleSignInAccount googleSignInAccount = (await googleSignIn.signIn())!;
    GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gsa.accessToken,
      idToken: gsa.idToken,
    );

    var result = await _firebaseAuth.signInWithCredential(credential);

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
