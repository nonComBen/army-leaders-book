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
import 'package:leaders_book/widgets/platform_widgets/platform_app.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(appleSignInAvailableProvider).check();
    return StreamBuilder(
      stream: ref.read(authProvider).onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User?> firebaseUser) {
        return Consumer(
          builder: (ctx, ref, child) {
            final themeData = ref.watch(themeProvider);
            return PlatformApp(
              title: 'Leader\'s Book',
              themeData: themeData,
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
            );
          },
        );
      },
    );
  }
}
