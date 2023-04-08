import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/auth_provider.dart';

import '../widgets/anon_warning_banner.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class FaqPage extends ConsumerStatefulWidget {
  const FaqPage({
    Key? key,
  }) : super(key: key);

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
        'How do I go to the year I want in the Calendars (Android) without having to click back through every month?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
            'Once the calendar pops up, click on the year in the upper left corner.  A separate scroll selector will pop up '
            'allowing you to select the year you want.',
            textAlign: TextAlign.start,
          ),
        )),
    Faq(
        false,
        'Why are there empty fields on the Soldier PDF that don\'t have input fields in the app?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
            'Due to their sensitive nature, certain fields (DOB, DOD ID, Address, etc.) are omitted from the the '
            'Soldier Input Form to keep them from being stored in the database. However, that information is '
            'important to have in a more secure, hardcopy leader\'s book. The intent is that you will write '
            '(or type if you have Adobe Pro) that information in after creating the PDF.',
            textAlign: TextAlign.start,
          ),
        )),
    Faq(
        false,
        'Where is the data stored?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
            'Army Leader\'s Book uses a cloud database from Google called Firestore, which is highly trusted and secure.  Firestore has end-to-end '
            'encryption, which means data is encrypted en route to the server, and server-side encryption, which means it is encrypted in the '
            'cloud. I have also set up strong security rules that allows you to read data associated with your user ID. All admin accounts to the '
            'database have two-factor authentication as well.',
            textAlign: TextAlign.start,
          ),
        )),
    Faq(
        false,
        'Why isn\'t the Alert Roster working?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
            'In order for the Alert Roster to build, you have to set the supervisor for each Soldier. When you long-press on one of the cards, a popup appears '
            'that allows you to set the supervisor from a dropdown of the Soldiers associated with your account. The first thing you need to do is to establish '
            'the top of the hierarchy (whether that is yourself or someone in your supervisory chain). Next, select the rest of the cards and set their supervisor. '
            'Everything will be saved when you push the back arrow so you don\'t have to reset it every time, but make sure you don\'t close the app before '
            'clicking out of the Alert Roster.',
            textAlign: TextAlign.start,
          ),
        )),
    Faq(
        false,
        'Can I share my data with another user?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
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
          ),
        )),
    Faq(
        false,
        'Can I upload my data from an Excel file?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
            'Yes, you can upload any data via a Excel file.  However, it is only available for users subscribed to the premium version. Start by downloading a '
            'blank Excel file with the headers by selecting the Download icon on the menu bar (or Download Data from the Overflow icon), starting with Soldiers. '
            'Save that file to a cloud folder (Google Drive, iCloud, etc) and open it on your computer to fill in the data and save back in the cloud folder. '
            'Then, in the app, go to the appropriate summary page and select the Upload icon (or Upload Data from the Overflow icon), select the file, choose '
            'the headers that are associated with each field and click Upload. For sub-records of a Soldier, you will need the soldierId, which you can get by '
            're-downloading the Excel file on the Soldiers page.',
            textAlign: TextAlign.start,
          ),
        )),
    Faq(
        false,
        'Is there a web version?',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const SelectableText(
            'There is a web version at https://www.armyleadersbook.app.',
            textAlign: TextAlign.start,
          ),
        )),
  ];

  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();

    myBanner = BannerAd(
      adUnitId: kIsWeb
          ? ''
          : Platform.isAndroid
              ? 'ca-app-pub-2431077176117105/1369522276'
              : 'ca-app-pub-2431077176117105/9894231072',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).currentUser()!;
    double width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Frequently Asked Questions',
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 932 ? (width - 916) / 2 : 16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            children: <Widget>[
              if (user.isAnonymous) const AnonWarningBanner(),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    for (int i = 0; i < faqs.length; i++) {
                      if (i == index) {
                        faqs[index].isExpanded = !faqs[index].isExpanded;
                      } else {
                        faqs[i].isExpanded = false;
                      }
                    }
                  });
                },
                children: faqs.map((Faq faq) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: SelectableText(
                          faq.header,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                    isExpanded: faq.isExpanded,
                    body: faq.body,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
