// ignore_for_file: file_names, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/apft.dart';
import '../../pages/editPages/editApftPage.dart';
import '../../pdf/apftsPdf.dart';
import '../../providers/subscription_state.dart';
import '../auth_provider.dart';
import '../methods/date_methods.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../../models/setting.dart';
import '../../pages/uploadPages/uploadApftPage.dart';
import '../../widgets/anon_warning_banner.dart';
import '../providers/notifications_plugin_provider.dart';
import '../providers/tracking_provider.dart';

class ApftPage extends StatefulWidget {
  const ApftPage({
    Key key,
  }) : super(key: key);

  static const routeName = '/apft-page';

  @override
  ApftPageState createState() => ApftPageState();
}

class ApftPageState extends State<ApftPage> {
  int _sortColumnIndex, puAve, suAve, runAve, totalAve, overdueDays, amberDays;
  bool _sortAscending = true,
      _adLoaded = false,
      isSubscribed,
      notificationsRefreshed = false,
      isInitial = true;
  String _userId;
  List<DocumentSnapshot> _selectedDocuments;
  List<DocumentSnapshot> documents, filteredDocs;
  StreamSubscription _subscriptionUsers;
  SharedPreferences prefs;
  NotificationDetails notificationDetails;
  FlutterLocalNotificationsPlugin notificationsPlugin;
  QuerySnapshot snapshot;
  BannerAd myBanner;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _userId = AuthProvider.of(context).auth.currentUser().uid;
    isSubscribed = Provider.of<SubscriptionState>(context).isSubscribed;
    print('Provider Subscribed State: $isSubscribed');

    notificationsPlugin =
        Provider.of<NotificationsPluginProvider>(context).notificationsPlugin;
    if (!kIsWeb && !notificationsRefreshed) {
      notificationsRefreshed = true;
      refreshNotifications();
    }

    if (!_adLoaded) {
      bool trackingAllowed =
          Provider.of<TrackingProvider>(context, listen: false).trackingAllowed;

      String adUnitId = kIsWeb
          ? ''
          : Platform.isAndroid
              ? 'ca-app-pub-2431077176117105/1369522276'
              : 'ca-app-pub-2431077176117105/9894231072';

      myBanner = BannerAd(
          adUnitId: adUnitId,
          size: AdSize.banner,
          request: AdRequest(nonPersonalizedAds: !trackingAllowed),
          listener: BannerAdListener(onAdLoaded: (ad) {
            _adLoaded = true;
          }));

      if (!kIsWeb && !isSubscribed) {
        await myBanner.load();
        _adLoaded = true;
      }
    }
    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  @override
  void initState() {
    super.initState();

    _sortAscending = false;
    _sortColumnIndex = 0;
    _selectedDocuments = [];
    documents = [];
    filteredDocs = [];
    overdueDays = 180;
    amberDays = 150;

    var androidSpecifics =
        const AndroidNotificationDetails('channelId', 'channelName');
    var iosSpecifics = const DarwinNotificationDetails(
        presentAlert: true, presentSound: false, presentBadge: false);
    notificationDetails =
        NotificationDetails(android: androidSpecifics, iOS: iosSpecifics);
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection('apftStats')
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
    snapshot = await FirebaseFirestore.instance
        .collection('settings')
        .where('owner', isEqualTo: _userId)
        .get();
    DocumentSnapshot doc = snapshot.docs[0];
    setState(() {
      overdueDays = doc['acftMonths'] * 30;
      amberDays = overdueDays - 30;
    });
  }

  @override
  void dispose() {
    _subscriptionUsers.cancel();
    myBanner?.dispose();
    super.dispose();
  }

  void refreshNotifications() async {
    int monthsDue = 6;
    List<dynamic> daysBefore = [0, 30];
    if (snapshot != null && snapshot.docs.isNotEmpty) {
      Setting setting = Setting.fromMap(snapshot.docs.first.data());
      if (setting.addNotifications != null && !setting.addNotifications) return;
      monthsDue = setting.acftMonths ?? 6;
      daysBefore = setting.acftNotifications ?? [0, 30];
    }

    //get pending notifications and cancel them
    List<PendingNotificationRequest> pending =
        await notificationsPlugin.pendingNotificationRequests();
    pending = pending.where((pr) => pr.payload == 'APFT').toList();
    for (PendingNotificationRequest request in pending) {
      notificationsPlugin.cancel(request.id);
    }

    int startingId = prefs.getInt('runningId') ?? 0;
    List<List<String>> dates = [];

    //create copy of documents
    List<DocumentSnapshot> docs = List.from(documents);
    //sort by date
    docs.sort((a, b) => a['date'].toString().compareTo(b['date'].toString()));
    //combine Soldiers with like dates
    for (int i = 0; i < docs.length; i++) {
      if (i == 0) {
        dates.add([
          '${docs[i]['rank']} ${docs[i]['name']}, ${docs[i]['firstName']}',
          docs[i]['date']
        ]);
      } else if (docs[i]['date'] == docs[i - 1]['date']) {
        dates.last[0] =
            '${dates.last[0]}, ${docs[i]['rank']} ${docs[i]['name']}, ${docs[i]['firstName']}';
      } else {
        dates.add([
          '${docs[i]['rank']} ${docs[i]['name']}, ${docs[i]['firstName']}',
          docs[i]['date']
        ]);
      }
    }

    //add notifications
    for (List<String> date in dates) {
      if (date[1] != '') {
        DateTime dueDate = DateTime.tryParse(date[1]);
        dueDate = dueDate.add(Duration(days: 30 * monthsDue, hours: 6));
        if (dueDate.isAfter(DateTime.now())) {
          for (int days in daysBefore) {
            DateTime scheduledDate = dueDate.add(Duration(days: -days));
            if (scheduledDate.isAfter(DateTime.now())) {
              notificationsPlugin.zonedSchedule(
                startingId,
                'APFT(s) due in $days days',
                date[0],
                scheduledDate,
                notificationDetails,
                androidAllowWhileIdle: true,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
                payload: 'APFT',
              );
              startingId++;
            }
          }
        }
      }
    }
    if (startingId > 10000000) startingId = 0;
    prefs.setInt('runningId', startingId);
  }

  _uploadExcel(BuildContext context) {
    if (isSubscribed) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UploadApftPage()));
      // Widget title = const Text('Upload APFT Stats');
      // Widget content = SingleChildScrollView(
      //   child: Container(
      //     padding: const EdgeInsets.all(8.0),
      //     child: const Text(
      //       'To upload your APFT Stats, the file must be in .csv format. Also, there needs to be a Soldier Id column and the Soldier Id '
      //       'has to match the Soldier Id in the database. To get your Soldier Ids, download the data from Soldiers page. If Excel '
      //       'gives you an error for Soldier Id, change cell format to Text from General and delete the \'=\'. Date also needs to be in '
      //       'yyyy-MM-dd or M/d/yy format and aerobic event will default to Run if the event does not match an option in the dropdown menu (case '
      //       'sensitive).',
      //     ),
      //   ),
      // );
      // customAlertDialog(
      //   context: context,
      //   title: title,
      //   content: content,
      //   primaryText: 'Continue',
      //   primary: () {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => UploadApftPage(
      //                   userId: widget.userId,
      //                   isSubscribed: isSubscribed,
      //                 )));
      //   },
      //   secondary: () {},
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Uploading data is only available for subscribed users.'),
      ));
    }
  }

  void _downloadExcel() async {
    bool approved = await checkPermission(Permission.storage);
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
      'Age',
      'Gender',
      'PU Raw',
      'PU Score',
      'SU Raw',
      'SU Score',
      'Run Raw',
      'Run Score',
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
      docs.add(doc['age']);
      docs.add(doc['gender']);
      docs.add(doc['puRaw']);
      docs.add(doc['puScore']);
      docs.add(doc['suRaw']);
      docs.add(doc['suScore']);
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
      sheet.appendRow(docs);
    }

    String dir, location;
    if (kIsWeb) {
      WebDownload webDownload = WebDownload(
          type: 'xlsx', fileName: 'apftStats.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/apftStats.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data successfully downloaded to $location'),
              duration: const Duration(seconds: 5),
              action: Platform.isAndroid
                  ? SnackBarAction(
                      label: 'Open',
                      onPressed: () {
                        OpenFile.open('$dir/apftStats.xlsx');
                      },
                    )
                  : null,
            ),
          );
        }
      } catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Downloading PDF files is only available for subscribed users.'),
      ));
    }
  }

  void completePdfDownload(bool fullPage) async {
    bool approved = await checkPermission(Permission.storage);
    if (!approved) return;
    documents.sort(
      (a, b) => a['date'].toString().compareTo(b['date'].toString()),
    );
    ApftsPdf pdf = ApftsPdf(
      documents,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: location == ''
              ? null
              : SnackBarAction(
                  label: 'Open',
                  onPressed: () {
                    OpenFile.open('$location/apftStats.pdf');
                  },
                )));
    }
  }

  void _filterRecords(String section) {
    if (section == 'All') {
      filteredDocs = List.from(documents);
    } else {
      filteredDocs =
          documents.where((element) => element['section'] == section).toList();
    }
    _calcAves();
    setState(() {});
  }

  void _deleteRecord() {
    if (_selectedDocuments.isEmpty) {
      //show snack bar requiring at least one item selected
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must select at least one record')));
      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, _userId, 'APFT$s');
  }

  void _editRecord() {
    if (_selectedDocuments.length != 1) {
      //show snack bar requiring one item selected
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must select exactly one record')));
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditApftPage(
                  apft: Apft.fromSnapshot(_selectedDocuments[0]),
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditApftPage(
                  apft: Apft(
                    owner: _userId,
                    users: [_userId],
                  ),
                )));
  }

  void _calcAves() {
    int pu = 0;
    int su = 0;
    int run = 0;
    int total = 0;
    puAve = 0;
    suAve = 0;
    runAve = 0;
    totalAve = 0;
    for (DocumentSnapshot doc in filteredDocs) {
      if (doc['puScore'] != 0) {
        puAve += doc['puScore'];
        pu++;
      }
      if (doc['suScore'] != 0) {
        suAve += doc['suScore'];
        su++;
      }
      if (doc['runScore'] != 0) {
        runAve += doc['runScore'];
        run++;
      }
      if (doc['puScore'] != 0 && doc['suScore'] != 0 && doc['runScore'] != 0) {
        totalAve += doc['total'];
        total++;
      }
    }
    puAve = pu != 0 ? (puAve / pu).floor() : 0;
    suAve = su != 0 ? (suAve / su).floor() : 0;
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
              onSortColumn(columnIndex, ascending)),
    ];
    if (width > 430) {
      columnList.add(DataColumn(
          label: const Text('Date'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 515) {
      columnList.add(DataColumn(
          label: const Text('Total'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 650) {
      columnList.add(DataColumn(
          label: const Text('PU'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 735) {
      columnList.add(DataColumn(
          label: const Text('SU'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 820) {
      columnList.add(DataColumn(
          label: const Text('Run'),
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
          onSelectChanged: (bool selected) =>
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
      DataCell(Text(
        documentSnapshot['rank'],
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )),
      DataCell(Text(
        '${documentSnapshot['name']}, ${documentSnapshot['firstName']}',
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )),
    ];
    if (width > 430) {
      cellList.add(DataCell(Text(
        documentSnapshot['date'],
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )));
    }
    if (width > 515) {
      cellList.add(DataCell(Text(
        documentSnapshot['total'].toString(),
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )));
    }
    if (width > 650) {
      cellList.add(DataCell(Text(
        documentSnapshot['puScore'].toString(),
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )));
    }
    if (width > 735) {
      cellList.add(DataCell(Text(
        documentSnapshot['suScore'].toString(),
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )));
    }
    if (width > 820) {
      cellList.add(DataCell(Text(
        documentSnapshot['runScore'].toString(),
        style: fail
            ? failTextStyle
            : overdue
                ? overdueTextStyle
                : amber
                    ? amberTextStyle
                    : const TextStyle(),
      )));
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
            filteredDocs.sort((a, b) => a['puScore'].compareTo(b['puScore']));
            break;
          case 5:
            filteredDocs.sort((a, b) => a['suScore'].compareTo(b['suScore']));
            break;
          case 6:
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
            filteredDocs.sort((a, b) => b['puScore'].compareTo(a['puScore']));
            break;
          case 5:
            filteredDocs.sort((a, b) => b['suScore'].compareTo(a['suScore']));
            break;
          case 6:
            filteredDocs.sort((a, b) => b['runScore'].compareTo(a['runScore']));
            break;
        }
      }
      _sortAscending = ascending;
      _sortColumnIndex = columnIndex;
    });
  }

  void onSelected(bool selected, DocumentSnapshot snapshot) {
    setState(() {
      if (selected) {
        _selectedDocuments.add(snapshot);
      } else {
        _selectedDocuments.remove(snapshot);
      }
    });
  }

  List<Widget> appBarMenu(BuildContext context, double width) {
    List<Widget> buttons = <Widget>[];

    List<PopupMenuEntry<String>> sections = [
      const PopupMenuItem(
        value: 'All',
        child: Text('All'),
      )
    ];
    documents.sort((a, b) => a['section'].compareTo(b['section']));
    for (int i = 0; i < documents.length; i++) {
      if (i == 0) {
        sections.add(PopupMenuItem(
          value: documents[i]['section'],
          child: Text(documents[i]['section']),
        ));
      } else if (documents[i]['section'] != documents[i - 1]['section']) {
        sections.add(PopupMenuItem(
          value: documents[i]['section'],
          child: Text(documents[i]['section']),
        ));
      }
    }

    List<Widget> editButton = <Widget>[
      Tooltip(
          message: 'Filter Records',
          child: PopupMenuButton(
            icon: const Icon(Icons.filter_alt),
            onSelected: (String result) => _filterRecords(result),
            itemBuilder: (context) {
              return sections;
            },
          )),
      Tooltip(
          message: 'Edit Record',
          child: IconButton(
              icon: const Icon(Icons.edit), onPressed: () => _editRecord())),
    ];

    List<PopupMenuEntry<String>> popupItems = [];

    if (width > 600) {
      buttons.add(
        Tooltip(
            message: 'Download as Excel',
            child: IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () {
                  _downloadExcel();
                })),
      );
      buttons.add(
        Tooltip(
            message: 'Upload Data',
            child: IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: () {
                  _uploadExcel(context);
                })),
      );
      buttons.add(
        Tooltip(
            message: 'Download as PDF',
            child: IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () {
                  _downloadPdf();
                })),
      );
    } else {
      popupItems.add(const PopupMenuItem(
        value: 'download',
        child: Text('Download as Excel'),
      ));
      popupItems.add(const PopupMenuItem(
        value: 'upload',
        child: Text('Upload Data'),
      ));
      popupItems.add(const PopupMenuItem(
        value: 'pdf',
        child: Text('Download as PDF'),
      ));
    }
    if (width > 400) {
      buttons.add(
        Tooltip(
            message: 'Delete Record(s)',
            child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteRecord())),
      );
    } else {
      popupItems.add(const PopupMenuItem(
        value: 'delete',
        child: Text('Delete Record(s)'),
      ));
    }

    List<Widget> overflowButton = <Widget>[
      PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'upload') {
            _uploadExcel(context);
          }
          if (result == 'download') {
            _downloadExcel();
          }
          if (result == 'delete') {
            _deleteRecord();
          }
          if (result == 'pdf') {
            _downloadPdf();
          }
        },
        itemBuilder: (BuildContext context) {
          return popupItems;
        },
      )
    ];

    if (width > 600) {
      return buttons + editButton;
    } else if (width <= 400) {
      return editButton + overflowButton;
    } else {
      return buttons + editButton + overflowButton;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
            title: const Text('APFT Stats'),
            actions: appBarMenu(context, width)),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _newRecord(context);
            }),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_adLoaded)
              Container(
                alignment: Alignment.center,
                width: myBanner.size.width.toDouble(),
                height: myBanner.size.height.toDouble(),
                constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                child: AdWidget(
                  ad: myBanner,
                ),
              ),
            Flexible(
              flex: 1,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                children: <Widget>[
                  if (user.isAnonymous) const AnonWarningBanner(),
                  Card(
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
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              'Average',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('PU: $puAve'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('SU: $suAve'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('Run: $runAve'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('Total: $totalAve'),
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
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
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
          ],
        ));
  }
}
