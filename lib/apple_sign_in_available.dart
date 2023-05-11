import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final appleSignInAvailableProvider = Provider<AppleSignInAvailable>((ref) {
  return AppleSignInAvailable();
});

class AppleSignInAvailable {
  bool _isAvailable = false;

  void check() async {
    _isAvailable = await SignInWithApple.isAvailable();
  }

  get isAvailable {
    return _isAvailable;
  }
}
