import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/providers/auth_provider.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/providers/tracking_provider.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_expansion_list_tile.dart';

import '../providers/subscription_state.dart';
import '../widgets/anon_warning_banner.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class CreedsPage extends ConsumerStatefulWidget {
  const CreedsPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/creeds-page';

  @override
  CreedsPageState createState() => CreedsPageState();
}

class Creed {
  bool isExpanded;
  final String header;
  final Widget body;
  Creed(this.isExpanded, this.header, this.body);
}

class CreedsPageState extends ConsumerState<CreedsPage> {
  bool isSubscribed = false;
  final List<Creed> _creeds = <Creed>[
    Creed(
        false,
        'Soldier\'s Creed',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'I am an American Soldier.\nI am a warrior and a member of a team.\nI serve the people of the United States, and live the Army Values.'
            '\n\nI will always place the mission first.\nI will never accept defeat.\nI will never quit.\nI will never leave a fallen comrade.'
            '\n\nI am disciplined, physically and mentally tough, trained and proficient in my warrior tasks and drills.'
            '\nI always maintain my arms, my equipment and myself.\nI am an expert and I am a professional.'
            '\nI stand ready to deploy, engage, and destroy, the enemies of the United States of America in close combat.'
            '\nI am a guardian of freedom and the American way of life.\nI am an American Soldier.',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'Creed of the NonCommissioned Officer',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'No one is more professional than I. I am a NonCommissioned Officer, a leader of Soldiers. As a NonCommissioned '
            'Officer, I realize that I am a member of a time honored corps, which is known as "The Backbone of the Army". '
            'I am proud of the Corps of NonCommissioned Officers and will at all times conduct myself so as to bring credit '
            'upon the Corps, the military service and my country regardless of the situation in which I find myself. I '
            'will not use my grade or position to attain pleasure, profit, or personal safety.'
            '\n\nCompetence is my watchword. My two basic responsibilities will always be uppermost in my mind—'
            'accomplishment of my mission and the welfare of my Soldiers. I will strive to remain technically and '
            'tactically proficient. I am aware of my role as a NonCommissioned Officer. I will fulfill my responsibilities '
            'inherent in that role. All Soldiers are entitled to outstanding leadership; I will provide that leadership. '
            'I know my Soldiers and I will always place their needs above my own. I will communicate consistently with my '
            'Soldiers and never leave them uninformed. I will be fair and impartial when recommending both rewards and punishment.'
            '\n\nOfficers of my unit will have maximum time to accomplish their duties; they will not have to accomplish '
            'mine. I will earn their respect and confidence as well as that of my Soldiers. I will be loyal to those with whom '
            'I serve; seniors, peers, and subordinates alike. I will exercise initiative by taking appropriate action in the '
            'absence of orders. I will not compromise my integrity, nor my moral courage. I will not forget, nor will I allow '
            'my comrades to forget that we are professionals, NonCommissioned Officers, leaders!',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'NCO Charge',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'I will discharge carefully and diligently the duties of the grade to which I have been promoted and uphold the traditions '
            'and standards of the Army.'
            '\n\nI understand that Soldiers of lesser rank are required to obey my lawful orders. Accordingly, I accept responsibility '
            'for their actions. As a NonCommissioned officer, I accept the charge to observe and follow the orders and directions '
            'given by supervisors acting according to the laws, articles and rules governing the discipline of the Army, I will '
            'correct conditions detrimental to the readiness thereof. In so doing, I will fulfill my greatest obligation as a leader '
            'and thereby confirm my status as a NonCommissioned officer.',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'NCO Vision',
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'An NCO Corps, grounded in heritage, values and tradition, that embodies the warrior ethos; values perpetual learning; '
            'and is capable of leading, training and motivating Soldiers.'
            '\n\nWe must always be an NCO Corps that'
            '\n\n - Leads by Example'
            '\n - Trains from Experience'
            '\n - Maintains and Enforces Discipline'
            '\n - Takes care of Soldiers'
            '\n - Adapts to a Changing World'
            '\n\nEffectively Counsels and Mentors Subordinates'
            '\nMaintains an Outstanding Personal Appearance'
            '\nDisciplined Leaders Produce Disciplined Soldiers',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'Army Song',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'March along, sing our song, with the Army of the free.\n'
            'Count the brave, count the true, who have fought to victory.\n'
            'We\'re the Army and proud of our name!\n'
            'We\'re the Army and proudly proclaim:\n\n'
            'First to fight for the right,\n'
            'And to build the Nation\'s might,\n'
            'And the Army goes rolling along.\n'
            'Proud of all we have done,\n'
            'Fighting till the battle\'s won,\n'
            'And the Army goes rolling along.\n\n'
            'Then it\'s hi! hi! hey!\n'
            'The Army\'s on its way.\n'
            'Count off the cadence loud and strong;\n'
            'For where\'er we go,\n'
            'You will always know\n'
            'That the Army goes rolling along.',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'Army Values',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'LOYALTY\n'
            'Bear true faith and allegiance to the U.S. Constitution, the Army, your unit and other Soldiers. Bearing '
            'true faith and allegiance is a matter of believing in and devoting yourself to something or someone. A loyal '
            'Soldier is one who supports the leadership and stands up for fellow Soldiers. By wearing the uniform of the '
            'U.S. Army you are expressing your loyalty. And by doing your share, you show your loyalty to your unit.\n\n'
            'DUTY\n'
            'Fulfill your obligations. Doing your duty means more than carrying out your assigned tasks. Duty means being '
            'able to accomplish tasks as part of a team. The work of the U.S. Army is a complex combination of missions, '
            'tasks and responsibilities — all in constant motion. Our work entails building one assignment onto another. '
            'You fulfill your obligations as a part of your unit every time you resist the temptation to take “shortcuts” '
            'that might undermine the integrity of the final product.\n\n'
            'RESPECT\n'
            'Treat people as they should be treated. In the Soldier\'s Code, we pledge to “treat others with dignity and '
            'respect while expecting others to do the same.” Respect is what allows us to appreciate the best in other '
            'people. Respect is trusting that all people have done their jobs and fulfilled their duty. And self-respect '
            'is a vital ingredient with the Army value of respect, which results from knowing you have put forth your best '
            'effort. The Army is one team and each of us has something to contribute.\n\n'
            'SELFLESS SERVICE\n'
            'Put the welfare of the nation, the Army and your subordinates before your own. Selfless service is larger than '
            'just one person. In serving your country, you are doing your duty loyally without thought of recognition or '
            'gain. The basic building block of selfless service is the commitment of each team member to go a little further, '
            'endure a little longer, and look a little closer to see how he or she can add to the effort.\n\n'
            'HONOR\n'
            'Live up to Army values. The nation\'s highest military award is The Medal of Honor. This award goes to Soldiers '
            'who make honor a matter of daily living — Soldiers who develop the habit of being honorable, and solidify that '
            'habit with every value choice they make. Honor is a matter of carrying out, acting, and living the values of '
            'respect, duty, loyalty, selfless service, integrity and personal courage in everything you do.\n\n'
            'INTEGRITY\n'
            'Do what\'s right, legally and morally. Integrity is a quality you develop by adhering to moral principles. It '
            'requires that you do and say nothing that deceives others. As your integrity grows, so does the trust others '
            'place in you. The more choices you make based on integrity, the more this highly prized value will affect your '
            'relationships with family and friends, and, finally, the fundamental acceptance of yourself.\n\n'
            'PERSONAL COURAGE\n'
            'Face fear, danger or adversity (physical or moral). Personal courage has long been associated with our Army. '
            'With physical courage, it is a matter of enduring physical duress and at times risking personal safety. Facing '
            'moral fear or adversity may be a long, slow process of continuing forward on the right path, especially if '
            'taking those actions is not popular with others. You can build your personal courage by daily standing up for '
            'and acting upon the things that you know are honorable.',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'Code of Conduct',
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Article I: I am an American, fighting in the forces which guard my country and our way of life. I am prepared to give my life in '
            'their defense.\n\n'
            'Article II:  I will never surrender of my own free will. If in command, I will never surrender the members of my command while '
            'they still have the means to resist.\n\n'
            'Article III:  If I am captured I will continue to resist by all means available. I will make every effort to escape and aid others '
            'to escape. I will accept neither parole nor special favors from the enemy.\n\n'
            'Article IV:  If I become a prisoner of war, I will keep faith with my fellow prisoners. I will give no information or take part '
            'in any action which might be harmful to my comrades. If I am senior, I will take command. If not, I will obey the lawful orders '
            'of those appointed over me and will back them up in every way.\n\n'
            'Article V:  When questioned, should I become a prisoner of war, I am required to give name, rank, service number and date of birth. '
            'I will evade answering further questions to the utmost of my ability. I will make no oral or written statements disloyal to my '
            'country and its allies or harmful to their cause.\n\n'
            'Article VI:  I will never forget that I am an American, fighting for freedom, responsible for my actions, and dedicated to the '
            'principles which made my country free. I will trust in my God and in the United States of America.',
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'Oath of Enlistment',
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'I, _____, do solemnly swear (or affirm) that I will support and defend the Constitution of the United States against '
            'all enemies, foreign and domestic; that I will bear true faith and allegiance to the same; and that I will obey '
            'the orders of the President of the United States and the orders of the officers appointed over me, according to '
            'regulations and the Uniform Code of Military Justice. *So help me God.\n\n'
            '*Optional',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'Jr Promotion Verbiage',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'To all who shall see these presents, greeting:\n\n'
            'Know ye, that reposing special trust and confidence in the fidelity and the abilities of\n\n'
            '[Full Name]\n\n'
            'I do promote [him/her] to [const rank] in the United States Army\n\n'
            'to ranks as such from the [day] day of [month] two thousand and [year].\n\n'
            'You charged to discharge carefully and diligently the duties of the grade to which promoted and uphold the traditions '
            'and standards of the Army.\n\n'
            'Effective with this promotion you are charged to execute diligently your special skills with a high degree of technical '
            'proficiency and to maintain standards of performance, moral courage and dedication to the Army which will serve as '
            'outstanding examples to your fellow Soldiers. You are charged to observe and follow the orders and directions given by '
            'superiors acting accordingly to the law, articles and rules governing the discipline of the Army. Your unfailing trust '
            'in superiors and loyalty to your peers will signifcantly contribute to the readiness and honor of the United States Army.\n\n'
            'Signed\n'
            '[Full Name]\n'
            '[Rank]/[Branch]\n'
            'Commanding',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
    Creed(
        false,
        'NCO Promotion Verbiage',
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'To all who shall see these presents, greeting:\n\n'
            'Know ye, that reposing special trust and confidence in the fidelity and the abilities of\n\n'
            '[Full Name]\n\n'
            'I do promote [him/her] to [const rank] in the United States Army\n\n'
            'to ranks as such from the [day] day of [month] two thousand and [year].\n\n'
            'You will discharge carefully and diligently the duties of the grade to which promoted and uphold the traditions and '
            'standards of the Army.\n\n'
            'Soldiers of lesser grade are required to obey your lawful orders. Accordingly you accept responsibility for their '
            'actions. As a noncomissioned officer you are charged to observe and follow the orders and directions given by '
            'superiors activing according to the laws, articles and rules governing the discipline of the Army, and to correct '
            'conditions detrimental to the readiness thereof. In so doing, you fulfill your greatest obligation as a leader and '
            'theryby confirm your status as a Noncommissioned Officer in the United States Army.\n\n'
            'Signed\n'
            '[Full Name]\n'
            '[Rank]/[Branch]\n'
            'Commanding',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18),
          ),
        )),
  ];
  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();

    isSubscribed = ref.read(subscriptionStateProvider);
    bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

    myBanner = BannerAd(
      adUnitId: kIsWeb
          ? ''
          : Platform.isAndroid
              ? 'ca-app-pub-2431077176117105/3345783071'
              : 'ca-app-pub-2431077176117105/4531945950',
      size: AdSize.banner,
      request: AdRequest(nonPersonalizedAds: !trackingAllowed),
      listener: const BannerAdListener(),
    );

    if (!kIsWeb) {
      myBanner.load();
    }
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).currentUser()!;
    return PlatformScaffold(
      title: 'Creeds, Etc.',
      body: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(
            16.0,
          ),
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    if (user.isAnonymous) const AnonWarningBanner(),
                    ..._creeds
                        .map(
                          (creed) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PlatformExpansionTile(
                              title: Text(
                                creed.header,
                                style: TextStyle(
                                  color: getOnPrimaryColor(context),
                                  fontSize: 20,
                                ),
                              ),
                              trailing: kIsWeb || Platform.isAndroid
                                  ? Icon(
                                      Icons.arrow_drop_down,
                                      color: getOnPrimaryColor(context),
                                    )
                                  : Icon(
                                      CupertinoIcons.chevron_down,
                                      color: getOnPrimaryColor(context),
                                    ),
                              collapsedBackgroundColor:
                                  getPrimaryColor(context),
                              collapsedTextColor: getOnPrimaryColor(context),
                              collapsedIconColor: getOnPrimaryColor(context),
                              textColor: getOnPrimaryColor(context),
                              children: [creed.body],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
              if (!isSubscribed && !kIsWeb)
                Container(
                  alignment: Alignment.center,
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                  constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                  child: AdWidget(
                    ad: myBanner,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
