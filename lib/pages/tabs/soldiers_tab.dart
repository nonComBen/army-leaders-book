import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

import '../../providers/filtered_soldiers_provider.dart';
import '../../providers/selected_soldiers_provider.dart';
import '../../providers/subscription_state.dart';
import '../../auth_provider.dart';
import '../../models/soldier.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../providers/soldiers_provider.dart';
import '../../providers/tracking_provider.dart';

class SoldiersPage extends ConsumerStatefulWidget {
  const SoldiersPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/soldiers-page';
  static const title = 'Soldiers';

  @override
  SoldiersPageState createState() => SoldiersPageState();
}

class SoldiersPageState extends ConsumerState<SoldiersPage> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true, _adLoaded = false, isSubscribed = false;
  late List<Soldier> _selectedSoldiers;
  late List<Soldier> _filteredSoldiers;
  List<Soldier> soldiers = [];
  BannerAd? myBanner;
  late String _userId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    isSubscribed = ref.read(subscriptionStateProvider);
    _userId = ref.read(authProvider).currentUser()!.uid;

    if (!_adLoaded && !isSubscribed) {
      bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

      String adUnitId = kIsWeb
          ? ''
          : Platform.isAndroid
              ? 'ca-app-pub-2431077176117105/1369522276'
              : 'ca-app-pub-2431077176117105/9894231072';

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

      if (!kIsWeb && !isSubscribed) {
        await myBanner!.load();
        _adLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    myBanner?.dispose();
    super.dispose();
  }

  List<DataColumn> _createColumns(double width) {
    List<DataColumn> columnList = [
      DataColumn(
        label: const Flexible(
          flex: 1,
          child: Text('Rank'),
        ),
        onSort: (int columnIndex, bool ascending) {
          onSortColumn(columnIndex, ascending);
          _sortAscending = ascending;
          _sortColumnIndex = columnIndex;
        },
      ),
      DataColumn(
        label: const Flexible(
          flex: 1,
          child: Text('Name'),
        ),
        onSort: (int columnIndex, bool ascending) {
          onSortColumn(columnIndex, ascending);
          _sortAscending = ascending;
          _sortColumnIndex = columnIndex;
        },
      ),
    ];
    if (width > 415) {
      columnList.add(
        DataColumn(
          label: const Flexible(
            flex: 1,
            child: Text('Section'),
          ),
          onSort: (int columnIndex, bool ascending) {
            onSortColumn(columnIndex, ascending);
            _sortAscending = ascending;
            _sortColumnIndex = columnIndex;
          },
        ),
      );
    }
    if (width > 525) {
      columnList.add(
        DataColumn(
          label: const Flexible(
            flex: 1,
            child: Text('Duty'),
          ),
          onSort: (int columnIndex, bool ascending) {
            onSortColumn(columnIndex, ascending);
            _sortAscending = ascending;
            _sortColumnIndex = columnIndex;
          },
        ),
      );
    }
    if (width > 695) {
      columnList.add(
        DataColumn(
          label: const Flexible(
            flex: 1,
            child: Text('Loss Date'),
          ),
          onSort: (int columnIndex, bool ascending) {
            onSortColumn(columnIndex, ascending);
            _sortAscending = ascending;
            _sortColumnIndex = columnIndex;
          },
        ),
      );
    }
    if (width > 820) {
      columnList.add(
        DataColumn(
          label: const Flexible(
            flex: 1,
            child: Text('ETS Date'),
          ),
          onSort: (int columnIndex, bool ascending) {
            onSortColumn(columnIndex, ascending);
            _sortAscending = ascending;
            _sortColumnIndex = columnIndex;
          },
        ),
      );
    }
    if (width > 980) {
      columnList.add(
        DataColumn(
          label: const Flexible(
            flex: 1,
            child: Text('DOR'),
          ),
          onSort: (int columnIndex, bool ascending) {
            onSortColumn(columnIndex, ascending);
            _sortAscending = ascending;
            _sortColumnIndex = columnIndex;
          },
        ),
      );
    }
    return columnList;
  }

  List<DataRow> _createRows(List<Soldier> snapshot, double width) {
    List<DataRow> newList;
    newList = snapshot.map((Soldier soldier) {
      var selected =
          _selectedSoldiers.map((e) => e.id).toList().contains(soldier.id);
      return DataRow(
          selected: selected,
          onSelectChanged: (bool? selected) => onSelected(selected, soldier),
          cells: getCells(soldier, width));
    }).toList();

    return newList;
  }

  List<DataCell> getCells(Soldier soldier, double width) {
    bool isOwner = soldier.owner == _userId;
    TextStyle sharedTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue);
    List<DataCell> cellList = [
      DataCell(
        Text(soldier.rank,
            style: !isOwner ? sharedTextStyle : const TextStyle()),
      ),
      DataCell(
        Text('${soldier.lastName}, ${soldier.firstName}',
            style: !isOwner ? sharedTextStyle : const TextStyle()),
      ),
    ];
    if (width > 415) {
      cellList.add(
        DataCell(Text(soldier.section,
            style: !isOwner ? sharedTextStyle : const TextStyle())),
      );
    }
    if (width > 525) {
      cellList.add(
        DataCell(Text(soldier.duty,
            style: !isOwner ? sharedTextStyle : const TextStyle())),
      );
    }
    if (width > 695) {
      cellList.add(
        DataCell(Text(soldier.lossDate,
            style: !isOwner ? sharedTextStyle : const TextStyle())),
      );
    }
    if (width > 820) {
      cellList.add(
        DataCell(Text(soldier.ets,
            style: !isOwner ? sharedTextStyle : const TextStyle())),
      );
    }
    if (width > 980) {
      cellList.add(
        DataCell(Text(soldier.dor,
            style: !isOwner ? sharedTextStyle : const TextStyle())),
      );
    }
    return cellList;
  }

  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        switch (columnIndex) {
          case 0:
            _filteredSoldiers.sort((a, b) => a.rankSort.compareTo(b.rankSort));
            break;
          case 1:
            _filteredSoldiers.sort((a, b) => a.lastName.compareTo(b.lastName));
            break;
          case 2:
            _filteredSoldiers.sort((a, b) => a.section.compareTo(b.section));
            break;
          case 3:
            _filteredSoldiers.sort((a, b) => a.duty.compareTo(b.duty));
            break;
          case 4:
            _filteredSoldiers.sort((a, b) => a.lossDate.compareTo(b.lossDate));
            break;
          case 5:
            _filteredSoldiers.sort((a, b) => a.ets.compareTo(b.ets));
            break;
          case 6:
            _filteredSoldiers.sort((a, b) => a.dor.compareTo(b.dor));
            break;
        }
      } else {
        switch (columnIndex) {
          case 0:
            _filteredSoldiers.sort((a, b) => b.rankSort.compareTo(a.rankSort));
            break;
          case 1:
            _filteredSoldiers.sort((a, b) => b.lastName.compareTo(a.lastName));
            break;
          case 2:
            _filteredSoldiers.sort((a, b) => b.section.compareTo(a.section));
            break;
          case 3:
            _filteredSoldiers.sort((a, b) => b.duty.compareTo(a.duty));
            break;
          case 4:
            _filteredSoldiers.sort((a, b) => b.lossDate.compareTo(a.lossDate));
            break;
          case 5:
            _filteredSoldiers.sort((a, b) => b.ets.compareTo(a.ets));
            break;
          case 6:
            _filteredSoldiers.sort((a, b) => b.dor.compareTo(a.dor));
            break;
        }
      }
      _sortAscending = ascending;
      _sortColumnIndex = columnIndex;
    });
  }

  void onSelected(bool? selected, Soldier soldier) {
    final selectedSoldersService = ref.read(selectedSoldiersProvider.notifier);
    setState(() {
      if (selected!) {
        selectedSoldersService.addSoldier(soldier);
      } else {
        selectedSoldersService.removeSoldier(soldier);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).currentUser()!;
    _selectedSoldiers = ref.watch(selectedSoldiersProvider);
    _filteredSoldiers = ref.watch(filteredSoldiersProvider);
    soldiers = ref.watch(soldiersProvider);

    if (_selectedSoldiers.isNotEmpty) {
      for (var soldier in _selectedSoldiers) {
        if (!soldiers.contains(soldier)) {
          ref.read(selectedSoldiersProvider.notifier).removeSoldier(soldier);
        }
      }
    }
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        top: MediaQuery.of(context).viewPadding.top,
        right: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                if (user.isAnonymous) const AnonWarningBanner(),
                Card(
                  child: DataTable(
                    sortAscending: _sortAscending,
                    sortColumnIndex: _sortColumnIndex,
                    columns: _createColumns(MediaQuery.of(context).size.width),
                    rows: _createRows(
                        _filteredSoldiers, MediaQuery.of(context).size.width),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                          'Blue Text: Record is shared with you',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_adLoaded)
            Container(
              alignment: Alignment.center,
              width: myBanner!.size.width.toDouble(),
              height: myBanner!.size.height.toDouble(),
              constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
              child: AdWidget(
                ad: myBanner!,
              ),
            ),
        ],
      ),
    );
  }
}
