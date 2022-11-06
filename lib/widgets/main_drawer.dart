// ignore_for_file: file_names, avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:launch_review/launch_review.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:provider/provider.dart';

import '../methods/home_page_methods.dart';
import '../providers/subscription_state.dart';
import '../methods/show_snackbar.dart';
import '../pages/acftPage.dart';
import '../pages/actionsTrackerPage.dart';
import '../pages/alertRosterPage.dart';
import '../pages/apftPage.dart';
import '../pages/appointmentsPage.dart';
import '../pages/bodyfatPage.dart';
import '../pages/creedsPage.dart';
import '../pages/editPages/editUserPage.dart';
import '../pages/faqPage.dart';
import '../pages/handReceiptPage.dart';
import '../pages/hrActionsPage.dart';
import '../pages/permProfilePage.dart';
import '../pages/perstatPage.dart';
import '../pages/settingsPage.dart';
import '../pages/soldiersPage.dart';
import '../pages/tempProfilesPage.dart';
import '../pages/weaponsPage.dart';
import '../pages/flagsPage.dart';
import '../pages/ratingsPage.dart';
import '../pages/medprosPage.dart';
import '../pages/trainingPage.dart';
import '../pages/equipmentPage.dart';
import '../pages/milLicensePage.dart';
import '../pages/dutyRosterPage.dart';
import '../pages/taskingsPage.dart';
import '../pages/counselingsPage.dart';
import '../pages/workingAwardsPage.dart';
import '../pages/workingEvalsPage.dart';
import '../pages/phonePage.dart';
import '../pages/notesPage.dart';
import 'custom_drawer_header.dart';

class MainDrawer extends StatelessWidget {
  final VoidCallback subscribe;
  final VoidCallback signOutWarning;
  final VoidCallback signOut;

  const MainDrawer({
    Key key,
    this.subscribe,
    this.signOutWarning,
    this.signOut,
  }) : super(key: key);

  void subscriptionMessage(BuildContext context) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String date =
        dateFormat.format(DateTime.now().add(const Duration(days: 365)));
    String store = Platform.isAndroid ? 'Google Play Store' : 'Apple App Store';
    Text title = const Text('Premium Subscription');
    Text content = Text(
        '- \$1.99 per year*\n- Upload data via Excel file\n- Download pdf files for hard-copy leader\'s book\n- Removes ads\n* Subscription auto-renews on $date unless cancelled through $store');
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Suscribe',
      primary: () {
        subscribe();
      },
      secondary: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthProvider.of(context).auth.currentUser();
    final isSubscribedAdFree =
        Provider.of<SubscriptionState>(context).isSubscribed;
    return Drawer(
      child: ListView(
        children: <Widget>[
          const CustomDrawerHeader(),
          ListTile(
            title: const Text('Soldiers'),
            leading: const Icon(Icons.people),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SoldiersPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('PERSTAT'),
            leading: const Icon(Icons.date_range),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PerstatPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Appointments'),
            leading: const Icon(Icons.access_time),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AptsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('APFT Stats'),
            leading: const Icon(Icons.directions_run),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ApftPage()));
            },
          ),
          ListTile(
            title: const Text('ACFT Stats'),
            leading: const Icon(Icons.fitness_center),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AcftPage()));
            },
          ),
          ListTile(
            title: const Text('Temporary Profiles'),
            leading: const Icon(Icons.healing),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TempProfilesPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Permanent Profiles'),
            leading: const Icon(Icons.accessible_forward),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PermProfilesPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Body Comp'),
            leading: const Icon(Icons.accessibility),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const BodyfatPage()));
            },
          ),
          ListTile(
            title: const Text('Weapon Stats'),
            leading: const Icon(Icons.my_location),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WeaponsPage()));
            },
          ),
          ListTile(
            title: const Text('Flags'),
            leading: const Icon(Icons.assistant_photo),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FlagsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Rating Scheme'),
            leading: const Icon(Icons.star),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RatingsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('MedPros'),
            leading: const Icon(Icons.local_hospital),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MedProsPage()));
            },
          ),
          ListTile(
            title: const Text('Training'),
            leading: const Icon(Icons.school),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrainingPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Equipment'),
            leading: const Icon(Icons.important_devices),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EquipmentPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Hand Receipt'),
            leading: const Icon(Icons.request_quote),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HandReceiptPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Military License'),
            leading: const Icon(Icons.local_shipping),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MilLicPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Duty Roster'),
            leading: const Icon(Icons.sentiment_very_dissatisfied),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DutyRosterPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Taskings'),
            leading: const Icon(Icons.sentiment_dissatisfied),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TaskingsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('HR Metrics'),
            leading: const Icon(Icons.assignment),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HrActionsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Counselings'),
            leading: const Icon(Icons.folder_shared),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CounselingsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Working Awards'),
            leading: const Icon(Icons.bookmark),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkingAwardsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Working Evals'),
            leading: const Icon(Icons.star_half),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkingEvalsPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Actions Tracker'),
            leading: const Icon(Icons.article),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ActionsTrackerPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Phone Numbers'),
            leading: const Icon(Icons.phone),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhonePage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Notes'),
            leading: const Icon(Icons.note),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotesPage(
                            userId: user.uid,
                          )));
            },
          ),
          ListTile(
            title: const Text('Alert Roster'),
            leading: const Icon(Icons.device_hub),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AlertRosterPage()));
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Creeds, Etc.'),
            leading: const Icon(Icons.record_voice_over),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, CreedsPage.routeName);
            },
          ),
          ListTile(
            title: const Text('Subscribe to Premium'),
            leading: const Icon(Icons.subscriptions),
            onTap: () {
              Navigator.pop(context);
              if (!isSubscribedAdFree) {
                subscriptionMessage(context);
              } else {
                showSnackbar(context, 'You are already subscribed to Premium.');
              }
            },
          ),
          ListTile(
            title: const Text('Rate'),
            leading: const Icon(Icons.rate_review),
            onTap: kIsWeb
                ? null
                : () {
                    Navigator.pop(context);
                    LaunchReview.launch(
                        androidAppId: 'com.armynoncomtools.leadersbook',
                        iOSAppId: '1462962891');
                  },
          ),
          ListTile(
            title: const Text('FAQ'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FaqPage()));
            },
          ),
          ListTile(
            title: const Text('Contact'),
            leading: const Icon(Icons.email),
            onTap: () {
              Navigator.pop(context);
              launchURL('mailto:armynoncomtools@gmail.com');
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.info),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/privacy-policy');
            },
          ),
          ListTile(
            title: const Text('Terms and Conditions'),
            leading: const Icon(Icons.info),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/terms-of-service');
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
          ListTile(
            title: const Text('Edit Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              if (!user.isAnonymous) {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditUserPage(
                              userId: user.uid,
                            )));
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'You need to create an account before you can edit profile.')));
              }
            },
          ),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(Icons.directions_walk),
            onTap: () {
              Navigator.pop(context);
              if (user.isAnonymous) {
                signOutWarning();
              } else {
                signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
