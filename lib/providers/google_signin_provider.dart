import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSigninProvider = Provider<GoogleSigninService>((ref) {
  return GoogleSigninService();
});

class GoogleSigninService {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  void init() {
    googleSignIn.initialize();
  }
}
