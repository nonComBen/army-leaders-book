import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../providers/auth_provider.dart';
import '../../methods/create_app_bar_actions.dart';
import '../../methods/delete_methods.dart';
import '../../methods/soldier_methods.dart';
import '../../methods/theme_methods.dart';
import '../../methods/update_user.dart';
import '../../models/app_bar_option.dart';
import '../../models/soldier.dart';
import '../../pages/editPages/edit_soldier_page.dart';
import '../../pages/tabs/overflow_tab.dart';
import '../../pages/tabs/rollup_tab.dart';
import '../../pages/tabs/soldiers_tab.dart';
import '../../providers/filtered_soldiers_provider.dart';
import '../../providers/root_provider.dart';
import '../../providers/selected_soldiers_provider.dart';
import '../../providers/soldiers_provider.dart';
import '../../providers/subscription_state.dart';
import '../../providers/leader_provider.dart';

abstract class PlatformHomePage extends StatefulWidget {
  factory PlatformHomePage() {
    if (kIsWeb || Platform.isAndroid) {
      return const AndroidHomePage();
    } else {
      return const IOSHomePage();
    }
  }
}

class AndroidHomePage extends ConsumerStatefulWidget
    implements PlatformHomePage {
  const AndroidHomePage({super.key});

  @override
  ConsumerState<AndroidHomePage> createState() => _AndroidHomePageState();
}

class _AndroidHomePageState extends ConsumerState<AndroidHomePage>
    with WidgetsBindingObserver {
  int index = 0;
  late String userId;
  bool isSubscribed = false,
      _requireUnlock = false,
      _localAuthSupported = false;
  Timer? timer;
  late List<Soldier> soldiers, selectedSoldiers;
  late FilteredSoldiers filteredSoldiers;
  late RootService _rootService;
  List<Widget> pages = const [
    RollupTab(),
    SoldiersPage(),
    OverflowTab(),
  ];
  List<String> titles = const [
    RollupTab.title,
    SoldiersPage.title,
    OverflowTab.title,
  ];
  final RateMyApp _rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
  );

  @override
  void initState() {
    super.initState();
    User? firebaseUser = ref.read(authProvider).currentUser();
    userId = firebaseUser!.uid;

    _rootService = ref.read(rootProvider.notifier);

    if (!kIsWeb) {
      _rateMyApp.init().then((_) {
        if (_rateMyApp.shouldOpenDialog) {
          _rateMyApp.showRateDialog(
            context,
            title: 'Rate Army Leader\'s Book',
            message:
                'If you like Army Leader\'s Book, please take a minute to rate '
                ' and review the app.  Or if you are having an issue with the app, '
                'please email me at armynoncomtools@gmail.com.',
            onDismissed: () =>
                _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
            rateButton: 'Rate',
            laterButton: 'Not Now',
            noButton: 'No Thanks',
          );
        }
      });
    }

    updateUser(firebaseUser, ref.read(leaderProvider).leader);
  }

  //signs out or locks user after 10 minutes of inactivity
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        final localAuth = LocalAuthentication();
        _localAuthSupported = await localAuth.isDeviceSupported();
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
      case AppLifecycleState.hidden:
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

  List<AppBarOption> getOptions() {
    return [
      AppBarOption(
        title: 'Edit Soldier',
        icon: Icon(
          Icons.edit,
          color: getPrimaryColor(context),
        ),
        onPressed: () => editSoldier(context, selectedSoldiers),
      ),
      AppBarOption(
        title: 'Delete Soldier(s)',
        icon: Icon(
          Icons.delete,
          color: getPrimaryColor(context),
        ),
        onPressed: () => deleteSoldiers(context, selectedSoldiers, userId, ref),
      ),
      AppBarOption(
        title: 'Filter Soldiers',
        icon: Icon(
          Icons.filter_alt,
          color: getPrimaryColor(context),
        ),
        onPressed: () =>
            selectFilters(context, getSections(soldiers), filteredSoldiers),
      ),
      AppBarOption(
        title: 'Share Soldier(s)',
        icon: Icon(
          Icons.share,
          color: getPrimaryColor(context),
        ),
        onPressed: () => shareSoldiers(context, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Download Excel',
        icon: Icon(
          Icons.download,
          color: getPrimaryColor(context),
        ),
        onPressed: () => downloadExcel(context, soldiers),
      ),
      AppBarOption(
        title: 'Upload Excel',
        icon: Icon(
          Icons.upload,
          color: getPrimaryColor(context),
        ),
        onPressed: () => uploadExcel(context, isSubscribed),
      ),
      AppBarOption(
        title: 'Download PDF',
        icon: Icon(
          Icons.picture_as_pdf,
          color: getPrimaryColor(context),
        ),
        onPressed: () =>
            downloadPdf(context, isSubscribed, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Transfer Soldier',
        icon: Icon(
          Icons.arrow_circle_right,
          color: getPrimaryColor(context),
        ),
        onPressed: () => transferSoldier(context, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Manage Users',
        icon: Icon(
          Icons.people,
          color: getPrimaryColor(context),
        ),
        onPressed: () => manageUsers(context, soldiers, userId),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    soldiers = ref.watch(soldiersProvider);
    selectedSoldiers = ref.watch(selectedSoldiersProvider);
    filteredSoldiers = ref.read(filteredSoldiersProvider.notifier);
    isSubscribed = ref.watch(subscriptionStateProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text(titles[index]),
          actions: index != 1 ? [] : createAppBarActions(width, getOptions())),
      floatingActionButton: index != 1
          ? null
          : Padding(
              padding: EdgeInsets.only(bottom: isSubscribed ? 0.0 : 60.0),
              child: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditSoldierPage(
                        soldier: Soldier(owner: userId, users: [userId]),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.people,
            ),
            label: 'Soldiers',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
      ),
      body: pages[index],
    );
  }
}

class IOSHomePage extends ConsumerStatefulWidget implements PlatformHomePage {
  const IOSHomePage({super.key});

  @override
  ConsumerState<IOSHomePage> createState() => _IOSHomePageState();
}

class _IOSHomePageState extends ConsumerState<IOSHomePage>
    with WidgetsBindingObserver {
  late String userId;
  bool isSubscribed = false,
      _requireUnlock = false,
      _localAuthSupported = false;
  Timer? timer;
  late List<Soldier> soldiers, selectedSoldiers;
  late FilteredSoldiers filteredSoldiers;
  late RootService _rootService;
  final RateMyApp _rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
  );

  @override
  void initState() {
    super.initState();

    _rootService = ref.read(rootProvider.notifier);

    _rateMyApp.init().then((_) {
      if (_rateMyApp.shouldOpenDialog) {
        _rateMyApp.showRateDialog(
          context,
          title: 'Rate Army Leader\'s Book',
          message:
              'If you like Army Leader\'s Book, please take a minute to rate '
              ' and review the app.  Or if you are having an issue with the app, '
              'please email me at armynoncomtools@gmail.com.',
          onDismissed: () =>
              _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
          rateButton: 'Rate',
          laterButton: 'Not Now',
          noButton: 'No Thanks',
        );
      }
    });
    User? firebaseUser = ref.read(authProvider).currentUser();
    userId = firebaseUser!.uid;

    updateUser(firebaseUser, ref.read(leaderProvider).leader);
  }

  //signs out or locks user after 10 minutes of inactivity
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        final localAuth = LocalAuthentication();
        _localAuthSupported = await localAuth.isDeviceSupported();
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
      case AppLifecycleState.hidden:
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

  List<AppBarOption> getOptions() {
    return [
      AppBarOption(
        title: 'New Soldier',
        icon: Icon(
          CupertinoIcons.add,
          color: getPrimaryColor(context),
        ),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditSoldierPage(
              soldier: Soldier(owner: userId, users: [userId]),
            ),
          ),
        ),
      ),
      AppBarOption(
        title: 'Edit Soldier',
        icon: Icon(
          CupertinoIcons.pencil,
          color: getPrimaryColor(context),
        ),
        onPressed: () => editSoldier(context, selectedSoldiers),
      ),
      AppBarOption(
        title: 'Delete Soldier(s)',
        icon: Icon(
          CupertinoIcons.delete,
          color: getPrimaryColor(context),
        ),
        onPressed: () => deleteSoldiers(context, selectedSoldiers, userId, ref),
      ),
      AppBarOption(
        title: 'Filter Soldiers',
        icon: Icon(
          Icons.filter_alt,
          color: getPrimaryColor(context),
        ),
        onPressed: () =>
            selectFilters(context, getSections(soldiers), filteredSoldiers),
      ),
      AppBarOption(
        title: 'Share Soldier(s)',
        icon: Icon(
          CupertinoIcons.share,
          color: getPrimaryColor(context),
        ),
        onPressed: () => shareSoldiers(context, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Download Excel',
        icon: Icon(
          CupertinoIcons.cloud_download,
          color: getPrimaryColor(context),
        ),
        onPressed: () => downloadExcel(context, soldiers),
      ),
      AppBarOption(
        title: 'Upload Excel',
        icon: Icon(
          CupertinoIcons.cloud_upload,
          color: getPrimaryColor(context),
        ),
        onPressed: () => uploadExcel(context, isSubscribed),
      ),
      AppBarOption(
        title: 'Download PDF',
        icon: Icon(
          CupertinoIcons.doc,
          color: getPrimaryColor(context),
        ),
        onPressed: () =>
            downloadPdf(context, isSubscribed, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Transfer Soldier',
        icon: Icon(
          CupertinoIcons.arrow_right_circle,
          color: getPrimaryColor(context),
        ),
        onPressed: () => transferSoldier(context, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Manage Users',
        icon: Icon(
          CupertinoIcons.person_3_fill,
          color: getPrimaryColor(context),
        ),
        onPressed: () => manageUsers(context, soldiers, userId),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    isSubscribed = ref.watch(subscriptionStateProvider);
    soldiers = ref.watch(soldiersProvider);
    selectedSoldiers = ref.watch(selectedSoldiersProvider);
    filteredSoldiers = ref.read(filteredSoldiersProvider.notifier);
    List<Widget> tabs = const [
      RollupTab(),
      SoldiersPage(),
      OverflowTab(),
    ];
    List<String> titles = const [
      RollupTab.title,
      SoldiersPage.title,
      OverflowTab.title,
    ];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(CupertinoIcons.home),
          ),
          BottomNavigationBarItem(
            label: 'Soldiers',
            icon: Icon(CupertinoIcons.person_2_fill),
          ),
          BottomNavigationBarItem(
            label: 'More',
            icon: Icon(CupertinoIcons.ellipsis),
          ),
        ],
        activeColor: getPrimaryColor(context),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          defaultTitle: titles[index],
          builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: getOnPrimaryColor(context),
              trailing: SizedBox(
                width: width / 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (index == 1) ...createAppBarActions(width, getOptions()),
                  ],
                ),
              ),
            ),
            child: tabs[index],
          ),
        );
      },
    );
  }
}
