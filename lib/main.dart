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
import 'package:leaders_book/pages/actions_tracker_page.dart';
import 'package:leaders_book/pages/alert_roster_page.dart';
import 'package:leaders_book/pages/apft_page.dart';
import 'package:leaders_book/pages/appointments_page.dart';
import 'package:leaders_book/pages/bodyfat_page.dart';
import 'package:leaders_book/pages/counselings_page.dart';
import 'package:leaders_book/pages/daily_perstat_page.dart';
import 'package:leaders_book/pages/duty_roster_page.dart';
import 'package:leaders_book/pages/equipment_page.dart';
import 'package:leaders_book/pages/flags_page.dart';
import 'package:leaders_book/pages/hand_receipt_page.dart';
import 'package:leaders_book/pages/hr_actions_page.dart';
import 'package:leaders_book/pages/medpros_page.dart';
import 'package:leaders_book/pages/mil_license_page.dart';
import 'package:leaders_book/pages/notes_page.dart';
import 'package:leaders_book/pages/perm_profile_page.dart';
import 'package:leaders_book/pages/perstat_page.dart';
import 'package:leaders_book/pages/phone_page.dart';
import 'package:leaders_book/pages/ratings_page.dart';
import 'package:leaders_book/pages/settings_page.dart';
import 'package:leaders_book/pages/taskings_page.dart';
import 'package:leaders_book/pages/temp_profiles_page.dart';
import 'package:leaders_book/pages/training_page.dart';
import 'package:leaders_book/pages/weapons_page.dart';
import 'package:leaders_book/pages/working_awards_page.dart';
import 'package:leaders_book/pages/working_evals_page.dart';
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
                ActionsTrackerPage.routeName: (context) =>
                    const ActionsTrackerPage(),
                AlertRosterPage.routeName: (context) => const AlertRosterPage(),
                ApftPage.routeName: (context) => const ApftPage(),
                AptsPage.routeName: (context) => const AptsPage(),
                BodyfatPage.routeName: (context) => const BodyfatPage(),
                CounselingsPage.routeName: (context) => const CounselingsPage(),
                DailyPerstatPage.routeName: (context) =>
                    const DailyPerstatPage(),
                DutyRosterPage.routeName: (context) => const DutyRosterPage(),
                EquipmentPage.routeName: (context) => const EquipmentPage(),
                FlagsPage.routeName: (context) => const FlagsPage(),
                HandReceiptPage.routeName: (context) => const HandReceiptPage(),
                HrActionsPage.routeName: (context) => const HrActionsPage(),
                MedProsPage.routeName: (context) => const MedProsPage(),
                MilLicPage.routeName: (context) => const MilLicPage(),
                NotesPage.routeName: (context) => const NotesPage(),
                PermProfilesPage.routeName: (context) =>
                    const PermProfilesPage(),
                PerstatPage.routeName: (context) => const PerstatPage(),
                PhonePage.routeName: (context) => const PhonePage(),
                RatingsPage.routeName: (context) => const RatingsPage(),
                SettingsPage.routeName: (context) => const SettingsPage(),
                TaskingsPage.routeName: (context) => const TaskingsPage(),
                TempProfilesPage.routeName: (context) =>
                    const TempProfilesPage(),
                TrainingPage.routeName: (context) => const TrainingPage(),
                WeaponsPage.routeName: (context) => const WeaponsPage(),
                WorkingAwardsPage.routeName: (context) =>
                    const WorkingAwardsPage(),
                WorkingEvalsPage.routeName: (context) =>
                    const WorkingEvalsPage(),
              },
              home: const RootPage(),
            );
          },
        );
      },
    );
  }
}
