import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/pages/acft_page.dart';
import 'package:leaders_book/providers/shared_prefs_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import '../apple_sign_in_available.dart';
import 'pages/faq_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/tos_page.dart';
import './root.dart';
import 'pages/creeds_page.dart';
import './providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) MobileAds.instance.initialize();

  await Firebase.initializeApp(
    name: kIsWeb
        ? null
        : Platform.isAndroid
            ? 'Army Leader\'s Book'
            : 'army-leaders-book',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: '6LcxDyQdAAAAAJN3xGUZ3M4uZIiEyFehxLcZG4QV');

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget with WidgetsBindingObserver {
  MyApp({Key? key}) : super(key: key);

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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(appleSignInAvailableProvider).check();
    return StreamBuilder(
      stream: ref.read(authProvider).onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User?> firebaseUser) {
        return Consumer(
          builder: (ctx, ref, child) => MaterialApp(
            title: 'Leader\'s Book',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ref.watch(themeProvider),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
            routes: <String, WidgetBuilder>{
              CreedsPage.routeName: (BuildContext context) =>
                  const CreedsPage(),
              FaqPage.routeName: (BuildContext context) => const FaqPage(),
              PrivacyPolicyPage.routeName: (BuildContext context) =>
                  const PrivacyPolicyPage(),
              TosPage.routeName: (BuildContext context) => const TosPage(),
              AcftPage.routeName: (context) => const AcftPage(),
            },
            home: const RootPage(),
          ),
        );
      },
    );
  }
}
