import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

// class AuthProvider extends InheritedWidget {
//   const AuthProvider({Key? key, required Widget child, this.auth})
//       : super(key: key, child: child);
//   final BaseAuth? auth;

//   @override
//   bool updateShouldNotify(InheritedWidget oldWidget) => true;

//   static AuthProvider? of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
//   }
// }

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});
