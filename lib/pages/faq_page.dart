import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/auth_provider.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_expansion_list_tile.dart';

import '../widgets/anon_warning_banner.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class FaqPage extends ConsumerStatefulWidget {
  const FaqPage({
    super.key,
  });

  static const routeName = '/faq-page';

  @override
  FaqPageState createState() => FaqPageState();
}

class Faq {
  bool isExpanded;
  final String header;
  final Widget body;
  Faq(this.isExpanded, this.header, this.body);
}

class FaqPageState extends ConsumerState<FaqPage> {
  List<Faq> faqs = [
    Faq(
      false,
      'Why are there empty fields on the Soldier PDF that don\'t have input fields in the app?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Due to their sensitive nature, certain fields (DOB, DOD ID, Address, etc.) are omitted from the the '
          'Soldier Input Form to keep them from being stored in the database. However, that information is '
          'important to have in a more secure, hardcopy leader\'s book. The intent is that you will write '
          '(or type if you have Adobe Pro) that information in after creating the PDF.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
    Faq(
      false,
      'Where is the data stored?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Army Leader\'s Book uses a cloud database from Google called Firestore, which is highly trusted and secure.  Firestore has end-to-end '
          'encryption, which means data is encrypted en route to the server, and server-side encryption, which means it is encrypted in the '
          'cloud. I have also set up strong security rules that allows you to read data associated with your user ID. All admin accounts to the '
          'database have two-factor authentication as well.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
    Faq(
      false,
      'Why isn\'t the Alert Roster working?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'In order for the Alert Roster to build, you have to set the supervisor for each Soldier. When you long-press on one of the cards, a popup appears '
          'that allows you to set the supervisor from a dropdown of the Soldiers associated with your account. The first thing you need to do is to establish '
          'the top of the hierarchy (whether that is yourself or someone in your supervisory chain). Next, select the rest of the cards and set their supervisor. '
          'Everything will be saved when you push the back arrow so you don\'t have to reset it every time, but make sure you don\'t close the app before '
          'clicking out of the Alert Roster.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
    Faq(
      false,
      'Can I share my data with another user?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Yes, as of 25 August 2020, any user can share Soldiers that are associated with their account with any other user.  You will need to get the user Id '
          'of the user you would like to share with.  They can find their user ID in their Edit User page.  Once you have their user ID, select the Soldiers '
          'you wish to share with that user and select Share Record(s) from the overflow button on the menu, enter the user ID in the text field and click '
          'Find User. When the user shows up in a card below the button, click on the card and confirm that you wish to share the Soldiers with that user. '
          'If no user is found, there is no user with the user ID entered (copy and paste is your friend as the ID is long, case sensitive and complicated). '
          'Also make sure there is no extra space at the end.'
          '\n\nOnce shared, the user will have access to read and update the Soldier and all sub-records (except for Counselings, Working Awards, and Working Evals) '
          'and any updates will be seen by all users who have access to the record. '
          'However, only the owner of the record can delete it, other users can only remove themselves from the access to it. That being said, if the owner '
          'deletes the record, it deletes for everyone. You can also transfer ownership of a record in a similar way as sharing a record.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
    Faq(
      false,
      'Can I upload my data from an Excel file?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Yes, you can upload any data via a Excel file.  However, it is only available for users subscribed to the premium version. Start by downloading a '
          'blank Excel file with the headers by selecting the Download icon on the menu bar (or Download Data from the Overflow icon), starting with Soldiers. '
          'Save that file to a cloud folder (Google Drive, iCloud, etc) and open it on your computer to fill in the data and save back in the cloud folder. '
          'Then, in the app, go to the appropriate summary page and select the Upload icon (or Upload Data from the Overflow icon), select the file, choose '
          'the headers that are associated with each field and click Upload. For sub-records of a Soldier, you will need the soldierId, which you can get by '
          're-downloading the Excel file on the Soldiers page.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
    Faq(
      false,
      'Is there a web version?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'There is a web version at https://www.armyleadersbook.app.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
    Faq(
      false,
      'How do I get notified when my Soldier is due?',
      Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text(
          'Notifications are available for ACFT, Body Composition, Weapons, Medpros, HR Metrics, '
          'and Appointments. Notifications are scheduled for your device when you add/update a record '
          'based on when the metric is due and when you want to be notified. You can adjust when the '
          'metric is due and when you want to be notified in the Settings page. Appointment reminder '
          'details are added when adding/updating the appointment. To add notifications to metrics that were '
          'added before version 4.3.4, just view and update each record. Since the notifications are '
          'stored in the app\'s memory on your device, if you uninstall and reinstall the app or want '
          'notifications on another device, you will have to update the records again to get the notifications.',
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).currentUser()!;
    return PlatformScaffold(
      title: 'Frequently Asked Questions',
      body: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            children: <Widget>[
              if (user.isAnonymous) const AnonWarningBanner(),
              ...faqs.map(
                (faq) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformExpansionTile(
                    title: Text(
                      faq.header,
                      style: TextStyle(
                        color: getPrimaryColor(context),
                        fontSize: 20,
                      ),
                      softWrap: true,
                    ),
                    trailing: kIsWeb || Platform.isAndroid
                        ? Icon(
                            Icons.arrow_drop_down,
                            color: getPrimaryColor(context),
                          )
                        : Icon(
                            CupertinoIcons.chevron_down,
                            color: getPrimaryColor(context),
                          ),
                    collapsedBackgroundColor: getOnPrimaryColor(context),
                    collapsedTextColor: getPrimaryColor(context),
                    collapsedIconColor: getPrimaryColor(context),
                    textColor: getPrimaryColor(context),
                    children: [faq.body],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
