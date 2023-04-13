import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/providers/filtered_soldiers_provider.dart';
import 'package:leaders_book/providers/selected_soldiers_provider.dart';
import 'package:leaders_book/providers/soldiers_provider.dart';
import 'package:leaders_book/providers/subscription_state.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../methods/create_app_bar_actions.dart';
import '../../methods/delete_methods.dart';
import '../../methods/soldier_methods.dart';
import '../../methods/theme_methods.dart';
import '../../models/app_bar_option.dart';
import '../../models/soldier.dart';
import '../../pages/editPages/edit_soldier_page.dart';
import '../../pages/tabs/rollup_tab.dart';
import '../../pages/tabs/overflow_tab.dart';
import '../../pages/tabs/soldiers_tab.dart';

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

class _AndroidHomePageState extends ConsumerState<AndroidHomePage> {
  int index = 0;
  late String userId;
  bool isSubscribed = false;
  late List<Soldier> soldiers, selectedSoldiers;
  late FilteredSoldiers filteredSoldiers;
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
  }

  List<AppBarOption> getOptions() {
    return [
      AppBarOption(
        title: 'New Soldier',
        icon: Icon(
          Icons.add,
          color: getOnPrimaryColor(context),
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
          Icons.edit,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => editSoldier(context, selectedSoldiers),
      ),
      AppBarOption(
        title: 'Delete Soldier(s)',
        icon: Icon(
          Icons.delete,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => deleteSoldiers(context, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Filter Soldiers',
        icon: Icon(
          Icons.filter_alt,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () =>
            selectFilters(context, getSections(soldiers), filteredSoldiers),
      ),
      AppBarOption(
        title: 'Share Soldier(s)',
        icon: Icon(
          Icons.share,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => shareSoldiers(context, soldiers, userId),
      ),
      AppBarOption(
        title: 'Download Excel',
        icon: Icon(
          Icons.download,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => downloadExcel(context, soldiers),
      ),
      AppBarOption(
        title: 'Upload Excel',
        icon: Icon(
          Icons.upload,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => uploadExcel(context, isSubscribed),
      ),
      AppBarOption(
        title: 'Download PDF',
        icon: Icon(
          Icons.picture_as_pdf,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () =>
            downloadPdf(context, isSubscribed, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Transfer Soldier',
        icon: Icon(
          Icons.arrow_circle_right,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => transferSoldier(context, selectedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Manage Users',
        icon: Icon(
          Icons.people,
          color: getOnPrimaryColor(context),
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
    userId = ref.read(authProvider).currentUser()!.uid;
    return Scaffold(
      appBar: AppBar(
          title: Text(titles[index]),
          actions: index != 1 ? [] : createAppBarActions(width, getOptions())),
      floatingActionButton: FloatingActionButton(
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

class _IOSHomePageState extends ConsumerState<IOSHomePage> {
  late String userId;
  bool isSubscribed = false;
  late List<Soldier> soldiers, selctedSoldiers;
  late FilteredSoldiers filteredSoldiers;
  final RateMyApp _rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
  );

  @override
  void initState() {
    super.initState();

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

  List<AppBarOption> getOptions() {
    return [
      AppBarOption(
        title: 'New Soldier',
        icon: Icon(
          CupertinoIcons.add,
          color: getOnPrimaryColor(context),
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
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => editSoldier(context, selctedSoldiers),
      ),
      AppBarOption(
        title: 'Delete Soldier(s)',
        icon: Icon(
          CupertinoIcons.delete,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => deleteSoldiers(context, selctedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Filter Soldiers',
        icon: Icon(
          Icons.filter_alt,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () =>
            selectFilters(context, getSections(soldiers), filteredSoldiers),
      ),
      AppBarOption(
        title: 'Share Soldier(s)',
        icon: Icon(
          CupertinoIcons.share,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => shareSoldiers(context, soldiers, userId),
      ),
      AppBarOption(
        title: 'Download Excel',
        icon: Icon(
          CupertinoIcons.cloud_download,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => downloadExcel(context, soldiers),
      ),
      AppBarOption(
        title: 'Upload Excel',
        icon: Icon(
          CupertinoIcons.cloud_upload,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => uploadExcel(context, isSubscribed),
      ),
      AppBarOption(
        title: 'Download PDF',
        icon: Icon(
          CupertinoIcons.doc,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () =>
            downloadPdf(context, isSubscribed, selctedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Transfer Soldier',
        icon: Icon(
          CupertinoIcons.arrow_right_circle,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => transferSoldier(context, selctedSoldiers, userId),
      ),
      AppBarOption(
        title: 'Manage Users',
        icon: Icon(
          CupertinoIcons.person_3_fill,
          color: getOnPrimaryColor(context),
        ),
        onPressed: () => manageUsers(context, soldiers, userId),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.watch(subscriptionStateProvider);
    soldiers = ref.watch(soldiersProvider);
    selctedSoldiers = ref.watch(selectedSoldiersProvider);
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
        activeColor: getOnPrimaryColor(context),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          defaultTitle: titles[index],
          builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: getPrimaryColor(context),
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
