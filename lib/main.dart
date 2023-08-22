import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/providers/notification_provider.dart';

import '../../pages/premium_page.dart';
import 'providers/auth_provider.dart';
import '../../pages/acft_page.dart';
import '../../pages/actions_tracker_page.dart';
import '../../pages/alert_roster_page.dart';
import '../../pages/apft_page.dart';
import '../../pages/appointments_page.dart';
import '../../pages/bodyfat_page.dart';
import '../../pages/counselings_page.dart';
import '../../pages/daily_perstat_page.dart';
import '../../pages/duty_roster_page.dart';
import '../../pages/equipment_page.dart';
import '../../pages/flags_page.dart';
import '../../pages/hand_receipt_page.dart';
import '../../pages/hr_actions_page.dart';
import '../../pages/medpros_page.dart';
import '../../pages/mil_license_page.dart';
import '../../pages/notes_page.dart';
import '../../pages/perm_profile_page.dart';
import '../../pages/perstat_page.dart';
import '../../pages/phone_page.dart';
import '../../pages/ratings_page.dart';
import '../../pages/settings_page.dart';
import '../../pages/taskings_page.dart';
import '../../pages/temp_profiles_page.dart';
import '../../pages/training_page.dart';
import '../../pages/weapons_page.dart';
import '../../pages/working_awards_page.dart';
import '../../pages/working_evals_page.dart';
import '../../providers/shared_prefs_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../../widgets/platform_widgets/platform_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import '../apple_sign_in_available.dart';
import 'methods/notifications_initializations.dart';
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
    webRecaptchaSiteKey: '6LcxDyQdAAAAAJN3xGUZ3M4uZIiEyFehxLcZG4QV',
    appleProvider: AppleProvider.appAttest,
    androidProvider: AndroidProvider.playIntegrity,
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  final launchDetails = await initializeLocalNotifications();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(
        launchDetails: launchDetails,
      ),
    ),
  );
}

class MyApp extends ConsumerWidget with WidgetsBindingObserver {
  MyApp({Key? key, this.launchDetails}) : super(key: key);
  final NotificationAppLaunchDetails? launchDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(appleSignInAvailableProvider).check();
    ref.read(notificationProvider).setLaunchDetails(launchDetails);
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
                PremiumPage.routeName: (context) => const PremiumPage(),
              },
              home: const RootPage(),
            );
          },
        );
      },
    );
  }
}
