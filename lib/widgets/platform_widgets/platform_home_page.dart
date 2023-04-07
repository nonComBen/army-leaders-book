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
import 'package:leaders_book/widgets/platform_widgets/platform_text_button.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../methods/delete_methods.dart';
import '../../methods/soldier_methods.dart';
import '../../methods/theme_methods.dart';
import '../../models/soldier.dart';
import '../../pages/editPages/edit_soldier_page.dart';
import '../../pages/tabs/rollup_tab.dart';
import '../../pages/tabs/overflow_tab.dart';
import '../../pages/tabs/soldiers_tab.dart';
import 'platform_icon_button.dart';

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

  List<Widget> appBarMenu(BuildContext context, double width) {
    List<Widget> buttons = <Widget>[];
    List<PopupMenuEntry<String>> sections = [
      const PopupMenuItem(
        value: 'All',
        child: Text('All'),
      )
    ];
    soldiers.sort((a, b) => a.section.compareTo(b.section));
    for (int i = 0; i < soldiers.length; i++) {
      if (i == 0) {
        sections.add(
          PopupMenuItem(
            value: soldiers[i].section,
            child: Text(soldiers[i].section),
          ),
        );
      } else if (soldiers[i].section != soldiers[i - 1].section) {
        sections.add(
          PopupMenuItem(
            value: soldiers[i].section,
            child: Text(soldiers[i].section),
          ),
        );
      }
    }

    List<Widget> editButton = <Widget>[
      Tooltip(
        message: 'Filter Records',
        child: PopupMenuButton(
          icon: const Icon(Icons.filter_alt),
          onSelected: (String result) {
            filteredSoldiers.filter(result);
          },
          itemBuilder: (context) {
            return sections;
          },
        ),
      ),
      Tooltip(
        message: 'Delete Record(s)',
        child: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => deleteSoldiers(context, selectedSoldiers, userId),
        ),
      ),
      Tooltip(
        message: 'Edit Soldier',
        child: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            editSoldier(context, selectedSoldiers);
          },
        ),
      ),
    ];

    List<PopupMenuEntry<String>> popupItems = [];

    if (width > 600) {
      buttons.add(
        Tooltip(
          message: 'Download as Excel',
          child: IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              downloadExcel(context, soldiers);
            },
          ),
        ),
      );
      buttons.add(
        Tooltip(
          message: 'Upload Data',
          child: IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: () {
                uploadExcel(context, isSubscribed);
              }),
        ),
      );
      buttons.add(
        Tooltip(
          message: 'Download as PDF',
          child: IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              downloadPdf(context, isSubscribed, selectedSoldiers, userId);
            },
          ),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'share',
          child: Text('Share Record(s)'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'transfer',
          child: Text('Transfer Ownership'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'manage',
          child: Text('Manage Users'),
        ),
      );
    } else {
      popupItems.add(
        const PopupMenuItem(
          value: 'share',
          child: Text('Share Record(s)'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'download',
          child: Text('Download as Excel'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'upload',
          child: Text('Upload Data'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'pdf',
          child: Text('Download as PDF'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'transfer',
          child: Text('Transfer Ownership'),
        ),
      );
      popupItems.add(
        const PopupMenuItem(
          value: 'manage',
          child: Text('Manage Users'),
        ),
      );
    }

    List<Widget> overflowButton = <Widget>[
      PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'upload') {
            uploadExcel(context, isSubscribed);
          }
          if (result == 'download') {
            downloadExcel(context, soldiers);
          }
          if (result == 'share') {
            shareSoldiers(context, soldiers, userId);
          }
          if (result == 'pdf') {
            downloadPdf(context, isSubscribed, selectedSoldiers, userId);
          }
          if (result == 'transfer') {
            transferSoldier(context, selectedSoldiers, userId);
          }
          if (result == 'manage') {
            manageUsers(context, soldiers, userId);
          }
        },
        itemBuilder: (BuildContext context) {
          return popupItems;
        },
      )
    ];

    if (width > 600) {
      return buttons + editButton + overflowButton;
    } else if (width <= 400) {
      return editButton + overflowButton;
    } else {
      return buttons + editButton + overflowButton;
    }
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
          actions: index != 1 ? [] : appBarMenu(context, width)),
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

  Widget menuPullDownButton() {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditSoldierPage(
                soldier: Soldier(owner: userId, users: [userId]),
              ),
            ),
          ),
          title: 'New Soldier',
        ),
        PullDownMenuItem(
          onTap: () => editSoldier(context, selctedSoldiers),
          title: 'Edit Soldier',
        ),
        PullDownMenuItem(
          onTap: () => deleteSoldiers(context, selctedSoldiers, userId),
          title: 'Delete Soldier(s)',
        ),
        PullDownMenuItem(
          onTap: () => PullDownButton(
            itemBuilder: (context) => getSections(soldiers)
                .map((e) => PullDownMenuItem(
                    onTap: () => filteredSoldiers.filter(e), title: e))
                .toList(),
            buttonBuilder: (context, showFilterMenu) => PlatformTextButton(
              onPressed: showFilterMenu,
              child: const Text('Filter'),
            ),
          ),
          title: 'Filter Soldiers',
        ),
        PullDownMenuItem(
          onTap: () => shareSoldiers(context, soldiers, userId),
          title: 'Share Soldier(s)',
        ),
        PullDownMenuItem(
          onTap: () => downloadExcel(context, soldiers),
          title: 'Download Excel',
        ),
        PullDownMenuItem(
          onTap: () => uploadExcel(context, isSubscribed),
          title: 'Upload Soldiers',
        ),
        PullDownMenuItem(
          onTap: () =>
              downloadPdf(context, isSubscribed, selctedSoldiers, userId),
          title: 'Download PDF',
        ),
        PullDownMenuItem(
          onTap: () => transferSoldier(context, selctedSoldiers, userId),
          title: 'Transfer Ownership',
        ),
        PullDownMenuItem(
          onTap: () => manageUsers(context, soldiers, userId),
          title: 'Manage Users',
        ),
      ],
      buttonBuilder: (context, showMenu) => PlatformIconButton(
        icon: Icon(
          CupertinoIcons.ellipsis_vertical,
          color: getOnPrimaryColor(context),
        ),
        onPressed: showMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              trailing: index == 1 ? menuPullDownButton() : null,
            ),
            child: tabs[index],
          ),
        );
      },
    );
  }
}
