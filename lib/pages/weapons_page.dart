import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/models/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../methods/custom_alert_dialog.dart';
import '../../models/weapon.dart';
import '../../providers/subscription_state.dart';
import '../providers/auth_provider.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/date_methods.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/filter_documents.dart';
import '../methods/open_file.dart';
import '../methods/theme_methods.dart';
import '../methods/toast_messages/subscription_needed_toast.dart';
import '../methods/web_download.dart';
import '../models/app_bar_option.dart';
import '../pdf/weapons_pdf.dart';
import '../providers/settings_provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';
import '../widgets/custom_data_table.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_weapon_page.dart';
import 'uploadPages/upload_weapons_page.dart';

class WeaponsPage extends ConsumerStatefulWidget {
  const WeaponsPage({
    super.key,
  });

  static const routeName = '/weapons-page';

  @override
  WeaponsPageState createState() => WeaponsPageState();
}

class WeaponsPageState extends ConsumerState<WeaponsPage> {
  int _sortColumnIndex = 0, overdueDays = 180, amberDays = 150;
  bool _sortAscending = true,
      _adLoaded = false,
      isSubscribed = false,
      isInitial = true;
  String? _userId;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [], filteredDocs = [];
  late StreamSubscription _subscriptionUsers;
  late SharedPreferences prefs;
  late BannerAd myBanner;
  FToast toast = FToast();

  @override
  void initState() {
    super.initState();
    _userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

    String adUnitId = kIsWeb
        ? ''
        : Platform.isAndroid
            ? 'ca-app-pub-2431077176117105/4962117079'
            : 'ca-app-pub-2431077176117105/8744677226';

    myBanner = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: AdRequest(nonPersonalizedAds: !trackingAllowed),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _adLoaded = true;
          });
        },
      ),
    );

    if (!kIsWeb) {
      myBanner.load();
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();

    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection(Weapon.collectionName)
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: _userId)
        .snapshots();
    _subscriptionUsers = streamUsers.listen((updates) {
      setState(() {
        documents = updates.docs;
        filteredDocs = updates.docs;
        _selectedDocuments.clear();
      });
    });
    final setting = ref.read(settingsProvider) ?? Setting(owner: _userId);
    debugPrint('Weapon Months: ${setting.weaponsMonths}');
    setState(() {
      overdueDays = setting.weaponsMonths * 30;
      amberDays = overdueDays - 30;
    });
  }

  @override
  void dispose() {
    _subscriptionUsers.cancel();
    myBanner.dispose();
    super.dispose();
  }

  _uploadExcel(BuildContext context) {
    if (isSubscribed) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UploadWeaponsPage()));
    } else {
      uploadRequiresSub(context);
    }
  }

  void _downloadExcel() async {
    List<List<dynamic>> docsList = [];
    docsList.add([
      'Soldier Id',
      'Rank',
      'Rank Sort',
      'Last Name',
      'First Name',
      'Section',
      'Date',
      'Weapon',
      'Qual Type',
      'Hits',
      'Max',
      'Qual Badge',
      'Pass'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['date']);
      docs.add(doc['type']);
      docs.add(doc['qualType']);
      docs.add(doc['score']);
      docs.add(doc['max']);
      docs.add(doc['badge']);
      docs.add(doc['pass'].toString());

      docsList.add(docs);
    }

    var excel = Excel.createExcel();
    var sheet = excel.sheets[excel.getDefaultSheet()];
    for (var docs in docsList) {
      sheet!.appendRow(docs.map((e) => TextCellValue(e.toString())).toList());
    }

    String dir, location;
    if (kIsWeb) {
      WebDownload webDownload = WebDownload(
          type: 'xlsx', fileName: 'weaponStats.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode()!;
        File('$dir/weaponStats.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          toast.showToast(
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed:
                  kIsWeb ? null : () => openFile('$dir/weaponStats.xlsx'),
            ),
          );
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error: $e');
      }
    }
  }

  void _downloadPdf() async {
    if (isSubscribed) {
      Widget title = const Text('Download PDF');
      Widget content = Container(
        padding: const EdgeInsets.all(8.0),
        child: const Text('Select full page or half page format.'),
      );
      customAlertDialog(
        context: context,
        title: title,
        content: content,
        primaryText: 'Full Page',
        primary: () {
          completePdfDownload(true);
        },
        secondaryText: 'Half Page',
        secondary: () {
          completePdfDownload(false);
        },
      );
    } else {
      pdfRequiresSub(context);
    }
  }

  void completePdfDownload(bool fullPage) async {
    documents.sort(
      (a, b) => a['date'].toString().compareTo(b['date'].toString()),
    );
    WeaponsPdf pdf = WeaponsPdf(
      documents: documents,
    );
    String location;
    if (fullPage) {
      location = await pdf.createFullPage();
    } else {
      location = await pdf.createHalfPage();
    }
    String message;
    if (location == '') {
      message = 'Failed to download pdf';
    } else {
      String directory =
          kIsWeb ? '/Downloads' : '\'On My iPhone(iPad)/Leader\'s Book\'';
      message = kIsWeb
          ? 'Pdf successfully downloaded to $directory'
          : 'Pdf successfully downloaded to temporary storage. Please open and save to permanent location.';
    }
    if (mounted) {
      toast.showToast(
        child: MyToast(
          message: message,
          buttonText: kIsWeb ? null : 'Open',
          onPressed:
              kIsWeb ? null : () => openFile('$location/weaponStats.pdf'),
        ),
      );
    }
  }

  void _filterRecords(List<String> sections) {
    filteredDocs = documents
        .where((element) => sections.contains(element['section']))
        .toList();

    setState(() {});
  }

  void _deleteRecord() {
    if (_selectedDocuments.isEmpty) {
      toast.showToast(
        child: const MyToast(
          message: 'You must select at least one record',
        ),
      );
      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, _userId, 'Weapon Stat$s');
  }

  void _editRecord() {
    if (_selectedDocuments.length != 1) {
      toast.init(context);
      toast.showToast(
        child: const MyToast(
          message: 'You must select exactly one record',
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWeaponPage(
          weapon: Weapon.fromSnapshot(_selectedDocuments.first),
        ),
      ),
    );
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWeaponPage(
          weapon: Weapon(
            owner: _userId!,
            users: [_userId],
          ),
        ),
      ),
    );
  }

  List<DataColumn> _createColumns(double width) {
    List<DataColumn> columnList = [
      DataColumn(
        label: const Text('Rank'),
        onSort: (int columnIndex, bool ascending) =>
            onSortColumn(columnIndex, ascending),
      ),
      DataColumn(
          label: const Text('Name'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)),
    ];
    if (width > 400) {
      columnList.add(DataColumn(
          label: const Text('Date'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 500) {
      columnList.add(DataColumn(
          label: const Text('Score'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 650) {
      columnList.add(DataColumn(
          label: const Text('Max'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 800) {
      columnList.add(DataColumn(
          label: const Text('Type'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    return columnList;
  }

  List<DataRow> _createRows(List<DocumentSnapshot> snapshot, double width) {
    List<DataRow> newList;
    newList = snapshot.map((DocumentSnapshot documentSnapshot) {
      return DataRow(
          selected: _selectedDocuments.contains(documentSnapshot),
          onSelectChanged: (bool? selected) =>
              onSelected(selected, documentSnapshot),
          cells: getCells(documentSnapshot, width));
    }).toList();

    return newList;
  }

  List<DataCell> getCells(DocumentSnapshot documentSnapshot, double width) {
    bool overdue = isOverdue(documentSnapshot['date'], overdueDays);
    bool amber = isOverdue(documentSnapshot['date'], amberDays);
    bool fail = !documentSnapshot['pass'];
    TextStyle overdueTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.red);
    TextStyle amberTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber);
    TextStyle failTextStyle =
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue);
    List<DataCell> cellList = [
      DataCell(
        Text(
          documentSnapshot['rank'],
          style: fail
              ? failTextStyle
              : overdue
                  ? overdueTextStyle
                  : amber
                      ? amberTextStyle
                      : const TextStyle(),
        ),
      ),
      DataCell(
        Text(
          '${documentSnapshot['name']}, ${documentSnapshot['firstName']}',
          style: fail
              ? failTextStyle
              : overdue
                  ? overdueTextStyle
                  : amber
                      ? amberTextStyle
                      : const TextStyle(),
        ),
      ),
    ];
    if (width > 400) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['date'],
            style: fail
                ? failTextStyle
                : overdue
                    ? overdueTextStyle
                    : amber
                        ? amberTextStyle
                        : const TextStyle(),
          ),
        ),
      );
    }
    if (width > 500) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['score'],
            style: fail
                ? failTextStyle
                : overdue
                    ? overdueTextStyle
                    : amber
                        ? amberTextStyle
                        : const TextStyle(),
          ),
        ),
      );
    }
    if (width > 650) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['max'],
            style: fail
                ? failTextStyle
                : overdue
                    ? overdueTextStyle
                    : amber
                        ? amberTextStyle
                        : const TextStyle(),
          ),
        ),
      );
    }
    if (width > 800) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['type'],
            style: fail
                ? failTextStyle
                : overdue
                    ? overdueTextStyle
                    : amber
                        ? amberTextStyle
                        : const TextStyle(),
          ),
        ),
      );
    }
    return cellList;
  }

  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        switch (columnIndex) {
          case 0:
            filteredDocs.sort((a, b) => a['rankSort'].compareTo(b['rankSort']));
            break;
          case 1:
            filteredDocs.sort((a, b) => a['name'].compareTo(b['name']));
            break;
          case 2:
            filteredDocs.sort((a, b) => a['date'].compareTo(b['date']));
            break;
          case 3:
            filteredDocs.sort((a, b) => a['score'].compareTo(b['score']));
            break;
          case 4:
            filteredDocs.sort((a, b) => a['max'].compareTo(b['max']));
            break;
          case 5:
            filteredDocs.sort((a, b) => a['type'].compareTo(b['type']));
            break;
        }
      } else {
        switch (columnIndex) {
          case 0:
            filteredDocs.sort((a, b) => b['rankSort'].compareTo(a['rankSort']));
            break;
          case 1:
            filteredDocs.sort((a, b) => b['name'].compareTo(a['name']));
            break;
          case 2:
            filteredDocs.sort((a, b) => b['date'].compareTo(a['date']));
            break;
          case 3:
            filteredDocs.sort((a, b) => b['score'].compareTo(a['score']));
            break;
          case 4:
            filteredDocs.sort((a, b) => b['max'].compareTo(a['max']));
            break;
          case 5:
            filteredDocs.sort((a, b) => b['type'].compareTo(a['type']));
            break;
        }
      }
      _sortAscending = ascending;
      _sortColumnIndex = columnIndex;
    });
  }

  void onSelected(bool? selected, DocumentSnapshot snapshot) {
    setState(() {
      if (selected!) {
        _selectedDocuments.add(snapshot);
      } else {
        _selectedDocuments.remove(snapshot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider).currentUser()!;
    final width = MediaQuery.of(context).size.width;
    toast.context = context;
    return PlatformScaffold(
      title: 'Weapon Quals',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New Qualification',
              icon: Icon(
                CupertinoIcons.add,
                color: getPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit Qualification',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete Qualification',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
          ),
          AppBarOption(
            title: 'Filter Qualifications',
            icon: Icon(
              Icons.filter_alt,
              color: getPrimaryColor(context),
            ),
            onPressed: () => showFilterOptions(
                context, getSections(documents), _filterRecords),
          ),
          AppBarOption(
            title: 'Download Excel',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.download
                  : CupertinoIcons.cloud_download,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _downloadExcel(),
          ),
          AppBarOption(
            title: 'Upload Excel',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.upload
                  : CupertinoIcons.cloud_upload,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _uploadExcel(context),
          ),
          AppBarOption(
            title: 'Download PDF',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.picture_as_pdf
                  : CupertinoIcons.doc,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _downloadPdf(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: isSubscribed ? 0.0 : 60.0),
        child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _newRecord(context);
            }),
      ),
      body: TableFrame(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                if (user.isAnonymous) const AnonWarningBanner(),
                Card(
                  color: getContrastingBackgroundColor(context),
                  child: CustomDataTable(
                    sortAscending: _sortAscending,
                    sortColumnIndex: _sortColumnIndex,
                    columns: _createColumns(MediaQuery.of(context).size.width),
                    rows: _createRows(
                        filteredDocs, MediaQuery.of(context).size.width),
                  ),
                ),
                Card(
                  color: getContrastingBackgroundColor(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Blue Text: Failed',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Amber Text: Due within 30 days',
                          style: TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Red Text: Overdue',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (!isSubscribed && _adLoaded)
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
    );
  }
}
