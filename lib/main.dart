// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/pages/acft_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import '../apple_sign_in_available.dart';
import './auth.dart';
import './auth_provider.dart';
import '../providers/subscription_state.dart';
import 'pages/faq_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/tos_page.dart';
import './root.dart';
import 'pages/creeds_page.dart';
import './providers/root_provider.dart';
import './providers/theme_provider.dart';
import './providers/soldiers_provider.dart';
import '../providers/notifications_plugin_provider.dart';
import '../providers/shared_prefs_provider.dart';
import '../providers/tracking_provider.dart';
import '../providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppleSignInAvailable appleSignInAvailable;
  if (!kIsWeb) MobileAds.instance.initialize();

  if (!kIsWeb) {
    appleSignInAvailable = await AppleSignInAvailable.check();
  } else {
    appleSignInAvailable = AppleSignInAvailable(false);
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    name: kIsWeb
        ? null
        : Platform.isAndroid
            ? 'Army Leader\'s Book'
            : 'army-leaders-book',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: '6LcxDyQdAAAAAJN3xGUZ3M4uZIiEyFehxLcZG4QV');

  runApp(Provider<AppleSignInAvailable>(
    create: (_) => appleSignInAvailable,
    child: MyApp(
      prefs: prefs,
    ),
  ));
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  MyApp({Key key, @required this.prefs}) : super(key: key);
  final SharedPreferences prefs;

  static const int _blackPrimaryValue = 0xFF000000;

  static const MaterialColor primaryBlack =
      MaterialColor(_blackPrimaryValue, <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(0xFF000000),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  });

  final darkTheme = ThemeData(
    primarySwatch: primaryBlack,
    dialogBackgroundColor: Colors.grey[800],
    colorScheme: ColorScheme.highContrastDark(
      brightness: Brightness.dark,
      primary: Colors.black87,
      primaryContainer: Colors.black,
      secondary: Colors.grey,
      secondaryContainer: Colors.grey[900],
      background: Colors.black45,
      onPrimary: Colors.yellow,
      onSecondary: Colors.yellow,
      onError: Colors.white,
      error: Colors.red,
    ),
  );
  final lightTheme = ThemeData(
    primarySwatch: primaryBlack,
    scaffoldBackgroundColor: Colors.grey[300],
    dialogBackgroundColor: Colors.grey[300],
    colorScheme: ColorScheme.highContrastLight(
      brightness: Brightness.light,
      primary: Colors.black87,
      primaryContainer: Colors.black,
      secondary: Colors.grey,
      secondaryContainer: Colors.grey[500],
      background: Colors.black45,
      onPrimary: Colors.amber,
      onSecondary: Colors.amber,
      onError: Colors.white,
      error: Colors.red,
    ),
  );

  @override
  Widget build(BuildContext context) {
    AuthService auth = AuthService();
    return AuthProvider(
        auth: auth,
        child: StreamBuilder(
            stream: auth.onAuthStateChanged,
            builder: (BuildContext context, AsyncSnapshot<User> firebaseUser) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider<SubscriptionState>(
                    create: (ctx) => SubscriptionState(),
                  ),
                  ChangeNotifierProvider<RootProvider>(
                    create: (ctx) => RootProvider(auth: auth),
                  ),
                  ChangeNotifierProvider<ThemeProvider>(
                    create: (_) => ThemeProvider(prefs),
                  ),
                  ChangeNotifierProvider<TrackingProvider>(
                    create: (_) => TrackingProvider(prefs),
                  ),
                  ChangeNotifierProvider<SoldiersProvider>(
                    create: (_) => SoldiersProvider(),
                  ),
                  ChangeNotifierProvider<NotificationsPluginProvider>(
                    create: (_) => NotificationsPluginProvider(),
                  ),
                  ChangeNotifierProvider<SharedPreferencesProvider>(
                    create: (_) => SharedPreferencesProvider(prefs),
                  ),
                  ChangeNotifierProvider<UserProvider>(
                    create: (_) => UserProvider(),
                  ),
                ],
                child: Consumer<ThemeProvider>(
                  builder: (ctx, themeProvider, child) => MaterialApp(
                    title: 'Leader\'s Book',
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: themeProvider.currentThemeMode,
                    builder: (BuildContext context, Widget child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child,
                      );
                    },
                    debugShowCheckedModeBanner: false,
                    routes: <String, WidgetBuilder>{
                      CreedsPage.routeName: (BuildContext context) =>
                          const CreedsPage(),
                      FaqPage.routeName: (BuildContext context) =>
                          const FaqPage(),
                      PrivacyPolicyPage.routeName: (BuildContext context) =>
                          const PrivacyPolicyPage(),
                      TosPage.routeName: (BuildContext context) =>
                          const TosPage(),
                      AcftPage.routeName: (context) => const AcftPage(),
                    },
                    home: const RootPage(),
                  ),
                ),
              );
            }));
  }
}
