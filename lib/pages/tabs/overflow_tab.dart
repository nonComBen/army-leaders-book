import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:launch_review/launch_review.dart';

import '../../methods/toast_messages/show_toast.dart';
import '../../pages/premium_page.dart';
import '../../providers/user_provider.dart';
import '../../auth_provider.dart';
import '../../auth_service.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/theme_methods.dart';
import '../../pages/privacy_policy_page.dart';
import '../../pages/tos_page.dart';
import '../../providers/root_provider.dart';
import '../../methods/home_page_methods.dart';
import '../../providers/subscription_state.dart';
import '../../pages/acft_page.dart';
import '../../pages/actions_tracker_page.dart';
import '../../pages/alert_roster_page.dart';
import '../../pages/apft_page.dart';
import '../../pages/appointments_page.dart';
import '../../pages/bodyfat_page.dart';
import '../../pages/creeds_page.dart';
import '../../pages/editPages/edit_user_page.dart';
import '../../pages/faq_page.dart';
import '../../pages/hand_receipt_page.dart';
import '../../pages/hr_actions_page.dart';
import '../../pages/perm_profile_page.dart';
import '../../pages/perstat_page.dart';
import '../../pages/settings_page.dart';
import '../../pages/temp_profiles_page.dart';
import '../../pages/weapons_page.dart';
import '../../pages/flags_page.dart';
import '../../pages/ratings_page.dart';
import '../../pages/medpros_page.dart';
import '../../pages/training_page.dart';
import '../../pages/equipment_page.dart';
import '../../pages/mil_license_page.dart';
import '../../pages/duty_roster_page.dart';
import '../../pages/taskings_page.dart';
import '../../pages/counselings_page.dart';
import '../../pages/working_awards_page.dart';
import '../../pages/working_evals_page.dart';
import '../../pages/phone_page.dart';
import '../../pages/notes_page.dart';
import '../../widgets/custom_drawer_header.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/platform_widgets/platform_list_tile.dart';
import '../../widgets/upload_frame.dart';

class OverflowTab extends ConsumerWidget {
  const OverflowTab({
    Key? key,
  }) : super(key: key);

  static const String title = 'Overflow page';

  void signOut({required AuthService auth, required RootService root}) {
    try {
      root.signOut();
      auth.signOut();
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Sign Out Error');
    }
  }

  void signOutWarning({
    required BuildContext context,
    required AuthService auth,
    required RootService root,
    required WidgetRef ref,
  }) {
    // ignore: close_sinks
    Widget title = const Text('Sign Out?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text(
          'Are you sure you want to sign out? Any data you saved will be lost unless you create an account.'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        signOut(auth: auth, root: root);
        ref.read(userProvider).nullUser();
      },
      secondaryText: 'Create Account',
      secondary: () {
        root.linkAnonymous();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).currentUser();
    final isSubscribedAdFree = ref.read(subscriptionStateProvider);
    final auth = ref.read(authProvider);
    final root = ref.read(rootProvider.notifier);
    // final sp = ref.read(subscriptionPurchasesProvider);
    return UploadFrame(
      children: <Widget>[
        const CustomDrawerHeader(),
        PlatformListTile(
          title: const Text('PERSTAT'),
          leading: const Icon(Icons.date_range),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(PerstatPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Appointments'),
          leading: const Icon(Icons.access_time),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(AptsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('APFT Stats'),
          leading: const Icon(Icons.directions_run),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(ApftPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('ACFT Stats'),
          leading: const Icon(Icons.fitness_center),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(AcftPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Temporary Profiles'),
          leading: const Icon(Icons.healing),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(TempProfilesPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Permanent Profiles'),
          leading: const Icon(Icons.accessible_forward),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(PermProfilesPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Body Comp'),
          leading: const Icon(Icons.accessibility),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(BodyfatPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Weapon Stats'),
          leading: const Icon(Icons.my_location),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(WeaponsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Flags'),
          leading: const Icon(Icons.assistant_photo),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(FlagsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Rating Scheme'),
          leading: const Icon(Icons.star),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(RatingsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('MedPros'),
          leading: const Icon(Icons.local_hospital),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(MedProsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Training'),
          leading: const Icon(Icons.school),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(TrainingPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Equipment'),
          leading: const Icon(Icons.important_devices),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(EquipmentPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Hand Receipt'),
          leading: const Icon(Icons.request_quote),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(HandReceiptPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Military License'),
          leading: const Icon(Icons.local_shipping),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(MilLicPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Duty Roster'),
          leading: const Icon(Icons.sentiment_very_dissatisfied),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(DutyRosterPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Taskings'),
          leading: const Icon(Icons.sentiment_dissatisfied),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(TaskingsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('HR Metrics'),
          leading: const Icon(Icons.assignment),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(HrActionsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Counselings'),
          leading: const Icon(Icons.folder_shared),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(CounselingsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Working Awards'),
          leading: const Icon(Icons.bookmark),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(WorkingAwardsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Working Evals'),
          leading: const Icon(Icons.star_half),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(WorkingEvalsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Actions Tracker'),
          leading: const Icon(Icons.article),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(ActionsTrackerPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Phone Numbers'),
          leading: const Icon(Icons.phone),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(PhonePage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Notes'),
          leading: const Icon(Icons.note),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(NotesPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Alert Roster'),
          leading: const Icon(Icons.device_hub),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(AlertRosterPage.routeName);
          },
        ),
        Divider(
          color: getOnPrimaryColor(context),
        ),
        PlatformListTile(
          title: const Text('Creeds, Etc.'),
          leading: const Icon(Icons.record_voice_over),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(CreedsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Subscription'),
          leading: const Icon(Icons.subscriptions),
          onTap: () {
            if (!isSubscribedAdFree) {
              if (!kIsWeb) {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(PremiumPage.routeName);
              } else {
                showToast(context,
                    'Subscriptions can onlyl be purchased from the Google Play Store or Apple App Store.');
              }
            } else {
              showToast(context, 'You are already subscribed to Premium.');
            }
          },
        ),
        PlatformListTile(
          title: const Text('Rate'),
          leading: const Icon(Icons.rate_review),
          onTap: kIsWeb
              ? null
              : () {
                  LaunchReview.launch(
                      androidAppId: 'com.armynoncomtools.leadersbook',
                      iOSAppId: '1462962891');
                },
        ),
        PlatformListTile(
          title: const Text('FAQ'),
          leading: const Icon(Icons.info_outline),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(FaqPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Contact'),
          leading: const Icon(Icons.email),
          onTap: () {
            launchURL('armynoncomtools@gmail.com');
          },
        ),
        PlatformListTile(
          title: const Text('Privacy Policy'),
          leading: const Icon(Icons.info),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(PrivacyPolicyPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Terms and Conditions'),
          leading: const Icon(Icons.info),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(TosPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          onTap: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(SettingsPage.routeName);
          },
        ),
        PlatformListTile(
          title: const Text('Edit Profile'),
          leading: const Icon(Icons.person),
          onTap: () {
            if (!user!.isAnonymous) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditUserPage(
                    userId: user.uid,
                  ),
                ),
              );
            } else {
              FToast toast = FToast();
              toast.context = context;
              toast.showToast(
                child: const MyToast(
                  message:
                      'You need to create an account before you can edit profile.',
                ),
              );
            }
          },
        ),
        PlatformListTile(
          title: const Text('Sign Out'),
          leading: const Icon(Icons.directions_walk),
          onTap: () {
            if (user!.isAnonymous) {
              signOutWarning(
                context: context,
                auth: auth,
                root: root,
                ref: ref,
              );
            } else {
              signOut(auth: auth, root: root);
              ref.read(userProvider).nullUser();
            }
          },
        ),
      ],
    );
  }
}
