import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/models/setting.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../methods/custom_alert_dialog.dart';
import '../../methods/theme_methods.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../auth_provider.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/date_methods.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/filter_documents.dart';
import '../methods/open_file.dart';
import '../methods/toast_messages/subscription_needed_toast.dart';
import '../methods/web_download.dart';
import '../models/acft.dart';
import '../models/app_bar_option.dart';
import '../pdf/acft_pdf.dart';
import '../providers/subscription_state.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_acft_page.dart';
import 'uploadPages/upload_acft_page.dart';

class AcftPage extends ConsumerStatefulWidget {
  const AcftPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/acft-page';

  @override
  AcftPageState createState() => AcftPageState();
}

class AcftPageState extends ConsumerState<AcftPage> {
  int _sortColumnIndex = 0,
      deadliftAve = 0,
      powerThrowAve = 0,
      puAve = 0,
      dragAve = 0,
      plkAve = 0,
      runAve = 0,
      totalAve = 0,
      overdueDays = 180,
      amberDays = 150;
  bool _sortAscending = true,
      _adLoaded = false,
      isSubscribed = false,
      notificationsRefreshed = false,
      isInitial = true;
  String? _userId;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [], filteredDocs = [];
  late StreamSubscription _subscriptionUsers;
  late SharedPreferences prefs;
  QuerySnapshot? snapshot;
  late BannerAd myBanner;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  @override
  void initState() {
    super.initState();

    _userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

    myBanner = BannerAd(
      adUnitId: kIsWeb
          ? ''
          : Platform.isAndroid
              ? 'ca-app-pub-2431077176117105/4679545565'
              : 'ca-app-pub-2431077176117105/2367694109',
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

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection(Acft.collectionName)
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: _userId)
        .snapshots();
    _subscriptionUsers = streamUsers.listen((updates) {
      setState(() {
        documents = updates.docs;
        filteredDocs = updates.docs;
        _selectedDocuments.clear();
      });

      _calcAves();
    });
    final setting = ref.read(settingsProvider) ?? Setting(owner: _userId);
    setState(() {
      overdueDays = setting.acftMonths * 30;
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UploadAcftPage(),
        ),
      );
    } else {
      uploadRequiresSub(context);
    }
  }

  void _downloadExcel() async {
    bool approved = await checkPermission(context, Permission.storage);
    if (!approved) return;
    List<List<dynamic>> docsList = [];
    docsList.add([
      'Soldier Id',
      'Rank',
      'Rank Sort',
      'Last Name',
      'First Name',
      'Section',
      'Date',
      'Age Group',
      'Gender',
      'MDL Raw',
      'MDL Score',
      'SPT Raw',
      'SPT Score',
      'HRP Raw',
      'HRP Score',
      'SDC Raw',
      'SDC Score',
      'PLK Raw',
      'PLK Score',
      '2MR Raw',
      '2MR Score',
      'Total',
      'Alt Event',
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
      docs.add(doc['ageGroup'] ?? '');
      docs.add(doc['gender'] ?? '');
      docs.add(doc['deadliftRaw']);
      docs.add(doc['deadliftScore']);
      docs.add(doc['powerThrowRaw']);
      docs.add(doc['powerThrowScore']);
      docs.add(doc['puRaw']);
      docs.add(doc['puScore']);
      docs.add(doc['dragRaw']);
      docs.add(doc['dragScore']);
      docs.add(doc['legTuckRaw']);
      docs.add(doc['legTuckScore']);
      docs.add(doc['runRaw']);
      docs.add(doc['runScore']);
      docs.add(doc['total']);
      docs.add(doc['altEvent']);
      docs.add(doc['pass'].toString());

      docsList.add(docs);
    }

    var excel = Excel.createExcel();
    var sheet = excel.sheets[excel.getDefaultSheet()];
    for (var docs in docsList) {
      sheet!.appendRow(docs);
    }

    String path, location;
    if (kIsWeb) {
      WebDownload webDownload = WebDownload(
          type: 'xlsx', fileName: 'acftStats.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      path = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode()!;
        File('$path/acftStats.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          FToast toast = FToast();
          toast.context = context;
          toast.showToast(
            toastDuration: const Duration(seconds: 5),
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed: kIsWeb ? null : () => openFile('$path/acftStats.xlsx'),
            ),
          );
        }
      } catch (e) {
        FirebaseAnalytics.instance.logEvent(name: 'Download Fail');
      }
    }
  }

  void _downloadPdf() async {
    if (isSubscribed) {
      Widget title = const Text('Download PDF');
      Widget content = const Text('Select full page or half page format.');
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
    bool approved = await checkPermission(context, Permission.storage);
    if (!approved) return;
    documents.sort(
      (a, b) => a['date'].toString().compareTo(b['date'].toString()),
    );
    AcftsPdf pdf = AcftsPdf(
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
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        toastDuration: const Duration(seconds: 5),
        child: MyToast(
          message: message,
          buttonText: kIsWeb ? null : 'Open',
          onPressed: kIsWeb ? null : () => openFile('$location/acftStats.pdf'),
        ),
      );
    }
  }

  void _filterRecords(List<String> sections) {
    filteredDocs = documents
        .where((element) => sections.contains(element['section']))
        .toList();
    _calcAves();
    setState(() {});
  }

  void _deleteRecord() {
    if (_selectedDocuments.isEmpty) {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(message: 'You must select at least one record'),
      );
      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, _userId, 'ACFT$s');
  }

  void _editRecord() {
    if (_selectedDocuments.length != 1) {
      //show snack bar requiring one item selected
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(message: 'You must select exactly one record'),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAcftPage(
          acft: Acft.fromSnapshot(_selectedDocuments[0]),
        ),
      ),
    );
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAcftPage(
          acft: Acft(
            owner: _userId!,
            users: [_userId],
          ),
        ),
      ),
    );
  }

  void _calcAves() {
    int deadlift = 0;
    int powerThrow = 0;
    int pu = 0;
    int drag = 0;
    int plank = 0;
    int run = 0;
    int total = 0;
    deadliftAve = 0;
    powerThrowAve = 0;
    puAve = 0;
    dragAve = 0;
    plkAve = 0;
    runAve = 0;
    totalAve = 0;
    for (DocumentSnapshot doc in filteredDocs) {
      if (doc['deadliftScore'] != 0) {
        deadliftAve += doc['deadliftScore'] as int;
        deadlift++;
      }
      if (doc['powerThrowScore'] != 0) {
        powerThrowAve += doc['powerThrowScore'] as int;
        powerThrow++;
      }
      if (doc['puScore'] != 0) {
        puAve += doc['puScore'] as int;
        pu++;
      }
      if (doc['dragScore'] != 0) {
        dragAve += doc['dragScore'] as int;
        drag++;
      }
      if (doc['legTuckScore'] != 0) {
        plkAve += doc['legTuckScore'] as int;
        plank++;
      }
      if (doc['runScore'] != 0) {
        runAve += doc['runScore'] as int;
        run++;
      }
      if (doc['deadliftScore'] != 0 &&
          doc['powerThrowScore'] != 0 &&
          doc['puScore'] != 0 &&
          doc['dragScore'] != 0 &&
          doc['legTuckScore'] != 0 &&
          doc['runScore'] != 0) {
        totalAve += doc['total'] as int;
        total++;
      }
    }
    deadliftAve = deadlift != 0 ? (deadliftAve / deadlift).floor() : 0;
    powerThrowAve = powerThrow != 0 ? (powerThrowAve / powerThrow).floor() : 0;
    puAve = pu != 0 ? (puAve / pu).floor() : 0;
    dragAve = drag != 0 ? (dragAve / drag).floor() : 0;
    plkAve = plank != 0 ? (plkAve / plank).floor() : 0;
    runAve = run != 0 ? (runAve / run).floor() : 0;
    totalAve = total != 0 ? (totalAve / total).floor() : 0;
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
            onSortColumn(columnIndex, ascending),
      ),
    ];
    if (width > 430) {
      columnList.add(
        DataColumn(
          label: const Text('Date'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 520) {
      columnList.add(
        DataColumn(
          label: const Text('Total'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 650) {
      columnList.add(
        DataColumn(
          label: const Text('MDL'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 735) {
      columnList.add(
        DataColumn(
          label: const Text('SPT'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 830) {
      columnList.add(
        DataColumn(
          label: const Text('HRP'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 935) {
      columnList.add(
        DataColumn(
          label: const Text('SDC'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 1030) {
      columnList.add(
        DataColumn(
          label: const Text('PLK'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
    }
    if (width > 1140) {
      columnList.add(
        DataColumn(
          label: const Text('2MR'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending),
        ),
      );
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
    if (width > 430) {
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
    if (width > 520) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['total'].toString(),
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
            documentSnapshot['deadliftScore'].toString(),
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
    if (width > 735) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['powerThrowScore'].toString(),
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
    if (width > 830) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['puScore'].toString(),
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
    if (width > 935) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['dragScore'].toString(),
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
    if (width > 1030) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['legTuckScore'].toString(),
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
    if (width > 1140) {
      cellList.add(
        DataCell(
          Text(
            documentSnapshot['runScore'].toString(),
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
            filteredDocs.sort((a, b) => a['total'].compareTo(b['total']));
            break;
          case 4:
            filteredDocs.sort(
                (a, b) => a['deadliftScore'].compareTo(b['deadliftScore']));
            break;
          case 5:
            filteredDocs.sort(
                (a, b) => a['powerThrowScore'].compareTo(b['powerThrowScore']));
            break;
          case 6:
            filteredDocs.sort((a, b) => a['puScore'].compareTo(b['puScore']));
            break;
          case 7:
            filteredDocs
                .sort((a, b) => a['dragScore'].compareTo(b['dragScore']));
            break;
          case 8:
            filteredDocs
                .sort((a, b) => a['legTuckScore'].compareTo(b['legTuckScore']));
            break;
          case 9:
            filteredDocs.sort((a, b) => a['runScore'].compareTo(b['runScore']));
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
            filteredDocs.sort((a, b) => b['total'].compareTo(a['total']));
            break;
          case 4:
            filteredDocs.sort(
                (a, b) => b['deadliftScore'].compareTo(a['deadliftScore']));
            break;
          case 5:
            filteredDocs.sort(
                (a, b) => b['powerThrowScore'].compareTo(a['powerThrowScore']));
            break;
          case 6:
            filteredDocs.sort((a, b) => b['puScore'].compareTo(a['puScore']));
            break;
          case 7:
            filteredDocs
                .sort((a, b) => b['dragScore'].compareTo(a['dragScore']));
            break;
          case 8:
            filteredDocs
                .sort((a, b) => b['legTuckScore'].compareTo(a['legTuckScore']));
            break;
          case 9:
            filteredDocs.sort((a, b) => b['runScore'].compareTo(a['runScore']));
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
    double width = MediaQuery.of(context).size.width;
    final user = ref.read(authProvider).currentUser()!;
    return PlatformScaffold(
        title: 'ACFT Stats',
        actions: createAppBarActions(
          width,
          [
            if (!kIsWeb && Platform.isIOS)
              if (!kIsWeb && Platform.isIOS)
                AppBarOption(
                  title: 'New ACFT',
                  icon: Icon(
                    kIsWeb || Platform.isAndroid
                        ? Icons.add
                        : CupertinoIcons.add,
                    color: getOnPrimaryColor(context),
                  ),
                  onPressed: () => _newRecord(context),
                ),
            AppBarOption(
              title: 'Edit ACFT',
              icon: Icon(
                kIsWeb || Platform.isAndroid
                    ? Icons.edit
                    : CupertinoIcons.pencil,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _editRecord(),
            ),
            AppBarOption(
              title: 'Delete ACFT(s)',
              icon: Icon(
                kIsWeb || Platform.isAndroid
                    ? Icons.delete
                    : CupertinoIcons.delete,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _deleteRecord(),
            ),
            AppBarOption(
              title: 'Filter ACFTs',
              icon: Icon(
                Icons.filter_alt,
                color: getOnPrimaryColor(context),
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
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _downloadExcel(),
            ),
            AppBarOption(
              title: 'Upload Excel',
              icon: Icon(
                kIsWeb || Platform.isAndroid
                    ? Icons.upload
                    : CupertinoIcons.cloud_upload,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _uploadExcel(context),
            ),
            AppBarOption(
              title: 'Download PDF',
              icon: Icon(
                kIsWeb || Platform.isAndroid
                    ? Icons.picture_as_pdf
                    : CupertinoIcons.doc,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _downloadPdf(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _newRecord(context);
            }),
        body: TableFrame(
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  if (user.isAnonymous) const AnonWarningBanner(),
                  Card(
                    color: getContrastingBackgroundColor(context),
                    child: DataTable(
                      sortAscending: _sortAscending,
                      sortColumnIndex: _sortColumnIndex,
                      columns:
                          _createColumns(MediaQuery.of(context).size.width),
                      rows: _createRows(
                          filteredDocs, MediaQuery.of(context).size.width),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850.0),
                    child: Card(
                      color: getContrastingBackgroundColor(context),
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: HeaderText(
                              'Average',
                            ),
                          ),
                          width > 675
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('MDL: $deadliftAve'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('SPT: $powerThrowAve'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('HRP: $puAve'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('SDC: $dragAve'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('LTK: $plkAve'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('2MR: $runAve'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text('Total: $totalAve'),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('MDL: $deadliftAve'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('SPT: $powerThrowAve'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('HRP: $puAve'),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('SDC: $dragAve'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('PLK: $plkAve'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('2MR: $runAve'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('Total: $totalAve'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              'Zeros are factored out and averages are rounded down.',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Amber Text: Due within 30 days',
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold),
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
        ));
  }
}
