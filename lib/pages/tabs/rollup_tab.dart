import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/models/user.dart';
import 'package:leaders_book/providers/root_provider.dart';
import 'package:leaders_book/providers/shared_prefs_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../providers/subscription_state.dart';
import '../../methods/date_methods.dart';
import '../../providers/tracking_provider.dart';
import '../../methods/show_on_login.dart';
import '../../methods/update_methods.dart';
import '../../../methods/validate.dart';
import '../../../models/setting.dart';
import '../acft_page.dart';
import '../daily_perstat_page.dart';
import '../../../widgets/anon_warning_banner.dart';
import '../../../widgets/center_progress_indicator.dart';
import '../../providers/user_provider.dart';
import '../../widgets/perstat_rollup_card.dart';
import '../../widgets/rollup_card.dart';
import '../apft_page.dart';
import '../perstat_page.dart';
import '../appointments_page.dart';
import '../temp_profiles_page.dart';
import '../perm_profile_page.dart';
import '../bodyfat_page.dart';
import '../weapons_page.dart';
import '../flags_page.dart';
import '../medpros_page.dart';
import '../training_page.dart';
import '../../classes/iap_repo.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../widgets/show_by_name_content.dart';

class RollupTab extends ConsumerStatefulWidget {
  const RollupTab({
    Key? key,
  }) : super(key: key);

  static const String title = 'Rollup';

  @override
  HomePageState createState() => HomePageState();
}

enum HomeCard {
  appointments,
  acft,
  apft,
  bf,
  profile,
  weapons,
  flags,
  medpros,
  training
}

class HomePageState extends ConsumerState<RollupTab>
    with WidgetsBindingObserver {
  final subId = 'ad_free_sub',
      iosSubId = 'premium_sub',
      subIdTwo = 'ad_free_two';
  final androidAd = 'ca-app-pub-2431077176117105/1369522276';
  final iosAd = 'ca-app-pub-2431077176117105/9894231072';
  String subToken = '';
  bool _requireUnlock = false,
      _localAuthSupported = false,
      _adLoaded = false,
      verified = false,
      isInitial = true,
      isSubscribed = true,
      notificationsInitialized = false;
  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;
  StreamSubscription<QuerySnapshot>? _soldierSubscription;
  final _firestore = FirebaseFirestore.instance;
  Timer? timer;
  final format = DateFormat('yyyy-MM-dd');
  Setting? setting;
  late LocalAuthentication _localAuth;
  SubscriptionState? subState;
  BannerAd? myBanner;
  late RootService _rootService;
  UserObj? _userObj;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _userObj = ref.read(userProvider).user;
    if (isInitial && _userObj != null) {
      isInitial = false;
      init();
    }

    isSubscribed = ref.watch(subscriptionStateProvider);

    if (_adLoaded && isSubscribed) {
      removeAds();
    }
    if (!kIsWeb && !_adLoaded && !isSubscribed) {
      final trackingService = ref.read(trackingProvider);
      bool trackingAllowed = trackingService.trackingAllowed;
      if (trackingAllowed) {
        trackingAllowed = await trackingService.getTrackingFromPermission();
      }

      String adUnitId = kIsWeb
          ? ''
          : Platform.isAndroid
              ? androidAd
              : iosAd;

      myBanner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: AdRequest(nonPersonalizedAds: !trackingAllowed),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _adLoaded = true;
          },
        ),
      );

      await myBanner!.load();
      _adLoaded = true;
    }
  }

  //performs initial async functions
  void init() async {
    PackageInfo packageInfo;
    final prefs = ref.read(sharedPreferencesProvider);

    // if old home page overwrote user profile, rewrite
    if (_userObj!.userEmail == 'anonymous@email.com') {
      final user = ref.read(authProvider).currentUser()!;
      _userObj!.userEmail = user.email!;
      _userObj!.userName = user.displayName ?? 'Anonymous User';
      _userObj!.createdDate = user.metadata.creationTime;
      _firestore.doc('users/${_userObj!.userId}').update(_userObj!.toMap());
    }
    if (!_userObj!.tosAgree) {
      if (mounted) {
        await showTos(context, _userObj!.userId);
      }
    }
    // update users array if not updated
    try {
      if (!_userObj!.updatedUserArray) {
        updateUsersArray(_userObj!.userId);
      }
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Updated Users Array Fail');
    }

    if (!_userObj!.updatedPovs) {
      updatePovs(_userObj!.userId!);
    }
    if (!_userObj!.updatedAwards) {
      updateAwards(_userObj!.userId!);
    }

// show change log if new version
    if (!kIsWeb) {
      packageInfo = await PackageInfo.fromPlatform();
      _localAuth = LocalAuthentication();
      _localAuthSupported = await _localAuth.isDeviceSupported();
      if (prefs.getString('Version') == null ||
          packageInfo.version != prefs.getString('Version')) {
        prefs.setString('Version', packageInfo.version);
        // if (mounted) {
        //   showChangeLog(context);
        // }
      }
    }
  }

  @override
  void dispose() async {
    _streamSubscription?.cancel();
    _soldierSubscription?.cancel();
    myBanner?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //signs out or locks user after 10 minutes of inactivity
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        timer = Timer.periodic(const Duration(minutes: 10), (_) {
          _requireUnlock = true;
          if (!_localAuthSupported) {
            signOut();
          }
        });
        break;
      case AppLifecycleState.resumed:
        timer?.cancel();
        if (_requireUnlock) {
          _rootService.localSignOut();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void signOut() {
    var auth = ref.read(authProvider);
    try {
      _rootService.signOut();
      auth.signOut();

      ref.read(subscriptionStateProvider.notifier).unSubscribe();
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'Sign Out Error');
    }
  }

  void signOutWarning(BuildContext context) {
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
        signOut();
      },
      secondaryText: 'Create Account',
      secondary: () {
        _rootService.linkAnonymous();
      },
    );
  }

  void removeAds() {
    if (_adLoaded) {
      myBanner?.dispose();
      _adLoaded = false;
    }
  }

  @pragma('vm:entry-point')
  Future onSelectNotification(BuildContext context, String payload) async {
    if (payload == 'ACFT') {
      await Navigator.of(context).pushNamed(AcftPage.routeName);
    } else if (payload == 'APFT') {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ApftPage()));
    } else if (payload == 'WEAPON') {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const WeaponsPage()));
    } else if (payload == 'PHA' ||
        payload == 'Dental' ||
        payload == 'Vision' ||
        payload == 'Hearing' ||
        payload == 'HIV') {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MedProsPage()));
    } else if (payload == 'BF') {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const BodyfatPage()));
    } else {
      return Future.value(null);
    }
  }

  Future onDidReceiveNotification(
      int id, String? title, String? body, String? payload) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  showByName(String title, List<DocumentSnapshot> list, HomeCard homeCard) {
    Widget content = ShowByNameContent(
      title: title,
      list: list,
      homeCard: homeCard,
      setting: setting!,
      width: MediaQuery.of(context).size.width / 3 * 2,
      height: MediaQuery.of(context).size.height / 3,
    );
    customAlertDialog(
      context: context,
      title: Text(title),
      content: content,
      primaryText: 'OK',
      primary: () {},
    );
  }

  List<Widget> homeCards(String userId) {
    List<Widget> list = [];
    if (setting != null) {
      if (setting!.perstat) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('perstat')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int leave = 0;
                  int tdy = 0;
                  int other = 0;
                  for (DocumentSnapshot doc in snapshot.data!.docs) {
                    Object start;
                    if (isValidDate(doc['start'])) {
                      start = DateTime.parse(doc['start'] + ' 00:00:00');
                    } else {
                      start = '';
                    }
                    var end = isValidDate(doc['end'])
                        ? DateTime.parse(doc['end'] + ' 18:00:00')
                        : '';
                    if (start != '' &&
                        DateTime.now().isAfter(start as DateTime)) {
                      if (end == '' ||
                          DateTime.now().isBefore(end as DateTime)) {
                        if (doc['type'] == 'Leave') {
                          leave++;
                        } else if (doc['type'] == 'TDY') {
                          tdy++;
                        } else {
                          other++;
                        }
                      }
                    }
                  }
                  return PerstatRollupCard(
                    title: 'PERSTAT',
                    leave: leave,
                    tdy: tdy,
                    other: other,
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PerstatPage(
                                    userId: userId,
                                  ))),
                      child: const Text('Go to PERSTAT'),
                    ),
                    button2: ElevatedButton(
                        child: const Text('By Name'),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DailyPerstatPage()))),
                  );
              }
            }));
      }
      if (setting!.apts) {
        list.add(
          StreamBuilder(
            stream: _firestore
                .collection('appointments')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int aptsToday = 0;
                  int aptsFuture = 0;
                  List<DocumentSnapshot> todayByName = [];
                  List<DocumentSnapshot> futureByName = [];
                  for (DocumentSnapshot doc in snapshot.data!.docs) {
                    DateTime? start;
                    if (isValidDate(doc['date'])) {
                      start = DateTime.parse(doc['date'] + ' 00:00:00');
                    } else {
                      start = null;
                    }
                    var today = format.format(DateTime.now());
                    if (doc['date'] == today) {
                      aptsToday++;
                      todayByName.add(doc);
                    } else if (start != null && start.isAfter(DateTime.now())) {
                      aptsFuture++;
                      futureByName.add(doc);
                    }
                  }
                  todayByName.sort((a, b) => a['start'].compareTo(b['start']));
                  futureByName.sort((a, b) => a['start'].compareTo(b['start']));
                  futureByName.sort((a, b) => a['date'].compareTo(b['date']));
                  return RollupCard(
                    title: 'Appointments',
                    info1: TextButton(
                      child: Text('Apts Today: $aptsToday',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              decoration: TextDecoration.underline)),
                      onPressed: () {
                        showByName(
                            'Apts Today', todayByName, HomeCard.appointments);
                      },
                    ),
                    info2: TextButton(
                      child: Text('Future Apts: $aptsFuture',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              decoration: TextDecoration.underline)),
                      onPressed: () {
                        showByName(
                            'Future Apts', futureByName, HomeCard.appointments);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AptsPage(
                            userId: userId,
                          ),
                        ),
                      ),
                      child: const Text('Go to Appointments'),
                    ),
                  );
              }
            },
          ),
        );
      }
      if (setting!.apft) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('apftStats')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int apftOverdue = 0;
                  int apftFail = 0;
                  List<DocumentSnapshot> fails = [];
                  List<DocumentSnapshot> overdue = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot doc in snapshot.data!.docs) {
                    if (!doc['pass']) {
                      apftFail++;
                      fails.add(doc);
                    }
                    if (isOverdue(doc['date'], 30 * setting!.acftMonths)) {
                      apftOverdue++;
                      overdue.add(doc);
                    }
                  }
                  return RollupCard(
                    title: 'APFT Stats',
                    info1: TextButton(
                      child: Text('Overdue: $apftOverdue',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName('Overdue APFTs', overdue, HomeCard.apft);
                      },
                    ),
                    info2: TextButton(
                      child: Text('Failed: $apftFail',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName('Failed APFTs', fails, HomeCard.apft);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ApftPage())),
                      child: const Text('Go to APFT'),
                    ),
                  );
              }
            }));
      }
      if (setting!.acft) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('acftStats')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int acftOverdue = 0;
                  int acftFail = 0;
                  List<DocumentSnapshot> overdue = [];
                  List<DocumentSnapshot> fails = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot doc in snapshot.data!.docs) {
                    if (!doc['pass']) {
                      acftFail++;
                      fails.add(doc);
                    }
                    if (isOverdue(doc['date'], 30 * setting!.acftMonths)) {
                      acftOverdue++;
                      overdue.add(doc);
                    }
                  }
                  return RollupCard(
                    title: 'ACFT Stats',
                    info1: TextButton(
                      child: Text(
                        'Overdue: $acftOverdue',
                        style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      onPressed: () {
                        showByName('Overdue ACFTs', overdue, HomeCard.acft);
                      },
                    ),
                    info2: TextButton(
                      child: Text('Failed: $acftFail',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName('Failed ACFTs', fails, HomeCard.acft);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AcftPage.routeName),
                      child: const Text('Go to ACFT'),
                    ),
                  );
              }
            }));
      }
      if (setting!.profiles) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('profiles')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  List<DocumentSnapshot> profiles = snapshot.data!.docs;
                  List<DocumentSnapshot> tempList = profiles
                      .where((doc) => doc['type'] == 'Temporary')
                      .toList();
                  List<DocumentSnapshot> permList = profiles
                      .where((doc) => doc['type'] == 'Permanent')
                      .toList();
                  int profilesTemp = tempList.length;
                  int profilesPerm = permList.length;
                  return RollupCard(
                    title: 'Profiles',
                    info1: TextButton(
                      child: Text(
                        'Temporary: $profilesTemp',
                        style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      onPressed: () {
                        showByName('Temp Profiles', tempList, HomeCard.profile);
                      },
                    ),
                    info2: TextButton(
                      child: Text(
                        'Permanent: $profilesPerm',
                        style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      onPressed: () {
                        showByName('Perm Profiles', permList, HomeCard.profile);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TempProfilesPage(
                                    userId: userId,
                                  ))),
                      child: const Text('Go to Temp'),
                    ),
                    button2: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PermProfilesPage(
                                    userId: userId,
                                  ))),
                      child: const Text('Go to Perm'),
                    ),
                  );
              }
            }));
      }
      if (setting!.bf) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('bodyfatStats')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int bfOverdue = 0;
                  int bfFail = 0;
                  List<DocumentSnapshot> overdue = [];
                  List<DocumentSnapshot> fails = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot doc in snapshot.data!.docs) {
                    if (!doc['passBmi'] && !doc['passBf']) {
                      bfFail++;
                      fails.add(doc);
                    }
                    if (isOverdue(doc['date'], 30 * setting!.bfMonths)) {
                      bfOverdue++;
                      overdue.add(doc);
                    }
                  }
                  return RollupCard(
                    title: 'Body Comp',
                    info1: TextButton(
                      child: Text(
                        'Overdue: $bfOverdue',
                        style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        showByName(
                            'Overdue Body Compositions', overdue, HomeCard.bf);
                      },
                    ),
                    info2: TextButton(
                      child: Text('Failed: $bfFail',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName(
                            'Failed Body Compositions', fails, HomeCard.bf);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BodyfatPage())),
                      child: const Text('Go to Body Comp'),
                    ),
                  );
              }
            }));
      }
      if (setting!.weapons) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('weaponStats')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int weaponsOverdue = 0;
                  int weaponsFail = 0;
                  List<DocumentSnapshot> overdue = [];
                  List<DocumentSnapshot> fails = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot doc in snapshot.data!.docs) {
                    if (doc['pass'] != null && !doc['pass']) {
                      weaponsFail++;
                      fails.add(doc);
                    }
                    if (isOverdue(doc['date'], 30 * setting!.weaponsMonths)) {
                      weaponsOverdue++;
                      overdue.add(doc);
                    }
                  }
                  return RollupCard(
                    title: 'Weapon Stats',
                    info1: TextButton(
                      child: Text(
                        'Overdue: $weaponsOverdue',
                        style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        showByName(
                            'Overdue Weapon Quals', overdue, HomeCard.weapons);
                      },
                    ),
                    info2: TextButton(
                      child: Text('Failed: $weaponsFail',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName(
                            'Failed Weapons Quals', fails, HomeCard.weapons);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WeaponsPage())),
                      child: const Text('Go to Weapons'),
                    ),
                  );
              }
            }));
      }
      if (setting!.flags) {
        list.add(StreamBuilder(
            stream: _firestore
                .collection('flags')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int flags = snapshot.data!.docs.length;
                  int flagsOverdue = 0;
                  List<DocumentSnapshot> overdue = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot ds in snapshot.data!.docs) {
                    if (isOverdue(ds['date'], 180)) {
                      flagsOverdue++;
                      overdue.add(ds);
                    }
                  }
                  return RollupCard(
                    title: 'Flags',
                    info1: TextButton(
                      onPressed: null,
                      child: Text(
                        'Active: $flags',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    info2: TextButton(
                      child: Text('> 180 Days: $flagsOverdue',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName('Flags > 180 Days', overdue, HomeCard.flags);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FlagsPage(
                                    userId: userId,
                                  ))),
                      child: const Text('Go to Flags'),
                    ),
                  );
              }
            }));
      }
      if (setting!.medpros) {
        list.add(
          StreamBuilder(
            stream: _firestore
                .collection('medpros')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int medpros = snapshot.data!.docs.length;
                  int medprosOverdue = 0;
                  List<DocumentSnapshot> overdue = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot ds in snapshot.data!.docs) {
                    if (isOverdue(ds['pha'], 30 * setting!.phaMonths) ||
                        isOverdue(ds['dental'], 30 * setting!.dentalMonths) ||
                        isOverdue(ds['vision'], 30 * setting!.visionMonths) ||
                        isOverdue(ds['hearing'], 30 * setting!.hearingMonths) ||
                        isOverdue(ds['hiv'], 30 * setting!.hivMonths)) {
                      medprosOverdue++;
                      overdue.add(ds);
                    }
                  }
                  return RollupCard(
                    title: 'Medpros',
                    info1: TextButton(
                      onPressed: null,
                      child: Text(
                        'Records: $medpros',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    info2: TextButton(
                      child: Text('Overdue: $medprosOverdue',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName(
                            'Overdue MedPros', overdue, HomeCard.medpros);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MedProsPage())),
                      child: const Text('Go to Medpros'),
                    ),
                  );
              }
            },
          ),
        );
      }
      if (setting!.training) {
        list.add(
          StreamBuilder(
            stream: _firestore
                .collection('training')
                .where('users', isNotEqualTo: null)
                .where('users', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Card(child: CenterProgressIndicator());
                default:
                  int training = snapshot.data!.docs.length;
                  int trainingOverdue = 0;
                  List<DocumentSnapshot> overdue = [];
                  snapshot.data!.docs
                      .sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
                  for (DocumentSnapshot ds in snapshot.data!.docs) {
                    if (isOverdue(ds['cyber'], 365) ||
                        isOverdue(ds['opsec'], 365) ||
                        isOverdue(ds['antiTerror'], 365) ||
                        isOverdue(ds['lawOfWar'], 365) ||
                        isOverdue(ds['persRec'], 365) ||
                        isOverdue(ds['infoSec'], 365) ||
                        isOverdue(ds['ctip'], 365) ||
                        isOverdue(ds['gat'], 365)) {
                      trainingOverdue++;
                      overdue.add(ds);
                    }
                  }
                  return RollupCard(
                    title: 'Training',
                    info1: TextButton(
                      onPressed: null,
                      child: Text(
                        'Records: $training',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    info2: TextButton(
                      child: Text('Overdue: $trainingOverdue',
                          style: const TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onPressed: () {
                        showByName(
                            'Overdue Trainings', overdue, HomeCard.training);
                      },
                    ),
                    button: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrainingPage(
                                    userId: userId,
                                  ))),
                      child: const Text('Go to Training'),
                    ),
                  );
              }
            },
          ),
        );
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    _rootService = ref.read(rootProvider.notifier);
    final user = ref.read(authProvider).currentUser();
    ref.read(iapRepoProvider);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: ListView(
              primary: true,
              shrinkWrap: true,
              children: [
                if (user!.isAnonymous) const AnonWarningBanner(),
                StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('settings')
                        .doc(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Card(child: CenterProgressIndicator());
                        default:
                          if (snapshot.hasData) {
                            setting = Setting.fromMap(
                                snapshot.data!.data() as Map<String, dynamic>);
                          } else {
                            setting = Setting(
                              owner: user.uid,
                              hearingNotifications: [0, 30],
                              weaponsNotifications: [0, 30],
                              acftNotifications: [0, 30],
                              dentalNotifications: [0, 30],
                              visionNotifications: [0, 30],
                              bfNotifications: [0, 30],
                              hivNotifications: [0, 30],
                              phaNotifications: [0, 30],
                            );
                            if (!user.isAnonymous) {
                              _firestore
                                  .collection('settings')
                                  .doc(user.uid)
                                  .set(setting!.toMap());
                            }
                          }

                          return GridView.count(
                            crossAxisCount: width > 700 ? 2 : 1,
                            childAspectRatio:
                                width > 700 ? width / 450 : width / 225,
                            shrinkWrap: true,
                            primary: false,
                            crossAxisSpacing: 1.0,
                            mainAxisSpacing: 1.0,
                            children: homeCards(user.uid),
                          );
                      }
                    })
              ],
            ),
          ),
          if (_adLoaded && !isSubscribed)
            Container(
              alignment: Alignment.center,
              width: myBanner!.size.width.toDouble(),
              height: myBanner!.size.height.toDouble(),
              constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
              child: AdWidget(
                ad: myBanner!,
              ),
            )
        ],
      ),
    );
  }
}
