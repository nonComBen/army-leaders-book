// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/subscription_state.dart';
import '../providers/notifications_plugin_provider.dart';
import '../widgets/anon_warning_banner.dart';
import '../auth_provider.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../../models/setting.dart';
import '../../models/medpro.dart';
import '../../pages/editPages/editMedprosPage.dart';
import '../../pages/uploadPages/uploadMedprosPage.dart';
import '../../pdf/medprosPdf.dart';
import '../providers/tracking_provider.dart';

class MedProsPage extends StatefulWidget {
  const MedProsPage({
    Key key,
    @required this.userId,
  }) : super(key: key);
  final String userId;

  static const routeName = '/medpros-page';

  @override
  MedProsPageState createState() => MedProsPageState();
}

class MedProsPageState extends State<MedProsPage> {
  int _sortColumnIndex, startingId;
  bool _sortAscending = true,
      _adLoaded = false,
      isSubscribed,
      notificationsRefreshed = false;
  List<DocumentSnapshot> documents, filteredDocs, _selectedDocuments;
  StreamSubscription _subscriptionUsers;
  SharedPreferences prefs;
  NotificationDetails notificationDetails;
  FlutterLocalNotificationsPlugin notificationsPlugin;
  BannerAd myBanner;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    isSubscribed = Provider.of<SubscriptionState>(context).isSubscribed;

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
  }

  @override
  void initState() {
    super.initState();

    _sortAscending = false;
    _sortColumnIndex = 0;
    _selectedDocuments = [];
    documents = [];
    filteredDocs = [];

    var androidSpecifics =
        const AndroidNotificationDetails('channelId', 'channelName');
    var iosSpecifics = const IOSNotificationDetails(
        presentAlert: true, presentSound: false, presentBadge: false);
    notificationDetails =
        NotificationDetails(android: androidSpecifics, iOS: iosSpecifics);

    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection('medpros')
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: widget.userId)
        .snapshots();
    _subscriptionUsers = streamUsers.listen((updates) {
      setState(() {
        documents = updates.docs;
        filteredDocs = updates.docs;
        _selectedDocuments.clear();
      });
    });
    initialize();
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _subscriptionUsers.cancel();
    myBanner?.dispose();
    super.dispose();
  }

  void refreshNotifications() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('settings')
        .where('owner', isEqualTo: widget.userId)
        .get();
    int phaMonthsDue = 12;
    int dentalMonthsDue = 12;
    int visionMonthsDue = 12;
    int hearingMonthsDue = 12;
    int hivMonthsDue = 24;
    List<dynamic> phaDaysBefore = [0, 30];
    List<dynamic> dentalDaysBefore = [0, 30];
    List<dynamic> visionDaysBefore = [0, 30];
    List<dynamic> hearingDaysBefore = [0, 30];
    List<dynamic> hivDaysBefore = [0, 30];
    if (snapshot != null && snapshot.docs.isNotEmpty) {
      Setting setting = Setting.fromMap(snapshot.docs.first.data());
      if (setting.addNotifications != null && !setting.addNotifications) return;
      phaMonthsDue = setting.phaMonths ?? 12;
      dentalMonthsDue = setting.dentalMonths ?? 12;
      visionMonthsDue = setting.visionMonths ?? 12;
      hearingMonthsDue = setting.hearingMonths ?? 12;
      hivMonthsDue = setting.hivMonths ?? 24;
      phaDaysBefore = setting.phaNotifications ?? [0, 30];
      dentalDaysBefore = setting.dentalNotifications ?? [0, 30];
      visionDaysBefore = setting.visionNotifications ?? [0, 30];
      hearingDaysBefore = setting.hearingNotifications ?? [0, 30];
      hivDaysBefore = setting.hivNotifications ?? [0, 30];
    }

    //get pending notifications and cancel them
    List<PendingNotificationRequest> pending =
        await notificationsPlugin.pendingNotificationRequests();
    pending = pending
        .where((pr) =>
            pr.payload == 'PHA' ||
            pr.payload == 'Dental' ||
            pr.payload == 'Vision' ||
            pr.payload == 'Hearing' ||
            pr.payload == 'HIV')
        .toList();

    for (PendingNotificationRequest request in pending) {
      notificationsPlugin.cancel(request.id);
    }

    startingId = prefs.getInt('runningId') ?? 0;

    scheduleNotifications('pha', 'PHA', phaMonthsDue, phaDaysBefore);
    scheduleNotifications(
        'dental', 'Dental', dentalMonthsDue, dentalDaysBefore);
    scheduleNotifications(
        'vision', 'Vision', visionMonthsDue, visionDaysBefore);
    scheduleNotifications(
        'hearing', 'Hearing', hearingMonthsDue, hearingDaysBefore);
    scheduleNotifications('hiv', 'HIV', hivMonthsDue, hivDaysBefore);

    if (startingId > 10000000) startingId = 0;
    prefs.setInt('runningId', startingId);
  }

  void scheduleNotifications(
      String key, String payload, int monthsDue, List<dynamic> daysBefore) {
    List<List<String>> dates = [];

    //create copy of documents
    List<DocumentSnapshot> docs = List.from(documents);
    //sort by date
    docs.sort((a, b) => a[key].toString().compareTo(b[key].toString()));
    //combine Soldiers with like dates
    for (int i = 0; i < docs.length; i++) {
      String soldier =
          '${docs[i]['rank']} ${docs[i]['name']}, ${docs[i]['firstName']}';
      if (i == 0) {
        dates.add([soldier, docs[i][key]]);
      } else if (docs[i][key] == docs[i - 1][key]) {
        dates.last[0] = '${dates.last[0]}, $soldier';
      } else {
        dates.add([soldier, docs[i][key]]);
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
                '$payload(s) due in $days days',
                date[0],
                scheduledDate,
                notificationDetails,
                androidAllowWhileIdle: true,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
                payload: payload,
              );
              startingId++;
            }
          }
        }
      }
    }
  }

  _uploadExcel(BuildContext context) {
    if (isSubscribed) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UploadMedProsPage(
                    userId: widget.userId,
                    isSubscribed: isSubscribed,
                  )));
      // Widget title = const Text('Upload MedPros');
      // Widget content = SingleChildScrollView(
      //   child: Container(
      //     padding: const EdgeInsets.all(8.0),
      //     child: const Text(
      //       'To upload your MedPros, the file must be in .csv format. Also, there needs to be a Soldier Id column and the '
      //       'Soldier Id has to match the Soldier Id in the database. To get your Soldier Ids, download the data from Soldiers '
      //       'page. If Excel gives you an error for Soldier Id, change cell format to Text from General and delete the \'=\'. '
      //       'Dates also need to be in yyyy-MM-dd or M/d/yy format or be \'Exempt\' for vaccinations.',
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
      //             builder: (context) => UploadMedProsPage(
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
      'PHA Date',
      'Dental Date',
      'Hearing Date',
      'Vision Date',
      'HIV Date',
      'Flu Date',
      'Anthrax Date',
      'Encephalitis Date',
      'Hepatitis A Date',
      'Hepatitis B Date',
      'Meningococcal Date',
      'MMR Date',
      'Polio Date',
      'Small Pox Date',
      'Tetanus Date',
      'Tuberculosis Date',
      'Typhoid Date',
      'Varicella Date',
      'Yellow Fever Date',
      'Other Immunizations'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> imms = doc['otherImms'];
      String otherImms = '';
      if (doc['otherImms'].length > 0) {
        for (int i = 0; i < imms.length; i++) {
          otherImms =
              '$otherImms{title: ${imms[i]['title']}, date: ${imms[i]['date']}';
          if (i < imms.length - 1) {
            otherImms = otherImms = ';';
          }
        }
      }
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['pha']);
      docs.add(doc['dental']);
      docs.add(doc['hearing']);
      docs.add(doc['vision']);
      docs.add(doc['hiv']);
      docs.add(doc['flu']);
      docs.add(doc['anthrax']);
      docs.add(doc['encephalitis']);
      docs.add(doc['hepA']);
      docs.add(doc['hepB']);
      docs.add(doc['meningococcal']);
      docs.add(doc['mmr']);
      docs.add(doc['polio']);
      docs.add(doc['smallPox']);
      docs.add(doc['tetanus']);
      docs.add(doc['tuberculin']);
      docs.add(doc['typhoid']);
      docs.add(doc['varicella']);
      docs.add(doc['yellow']);
      docs.add(otherImms);

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
          type: 'xlsx', fileName: 'medpros.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/medpros.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Data successfully downloaded to $location'),
            duration: const Duration(seconds: 5),
            action: Platform.isAndroid
                ? SnackBarAction(
                    label: 'Open',
                    onPressed: () async {
                      await OpenFile.open('$dir/medpros.xlsx');
                    },
                  )
                : null,
          ));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Downloading PDF files is only available for subscribed users.'),
      ));
    }
  }

  void completePdfDownload(bool fullPage) async {
    bool approved = await checkPermission(context, Permission.storage);
    if (!approved) return;
    MedprosPdf pdf = MedprosPdf(
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
                    OpenFile.open('$location/medpros.pdf');
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
    setState(() {});
  }

  void _deleteRecord() {
    if (_selectedDocuments.isEmpty) {
      //show snack bar requiring at least one item selected
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must select at least one record')));
      return;
    }
    deleteRecord(context, _selectedDocuments, widget.userId, 'MedPros');
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
            builder: (context) => EditMedprosPage(
                  userId: widget.userId,
                  medpro: Medpro.fromSnapshot(_selectedDocuments.first),
                  isSubscribed: isSubscribed,
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditMedprosPage(
                  userId: widget.userId,
                  medpro: Medpro(
                    owner: widget.userId,
                    users: [widget.userId],
                    otherImms: [],
                  ),
                  isSubscribed: isSubscribed,
                )));
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
    if (width > 420) {
      columnList.add(DataColumn(
          label: const Text('PHA'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 560) {
      columnList.add(DataColumn(
          label: const Text('Dental'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 685) {
      columnList.add(DataColumn(
          label: const Text('Hearing'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 820) {
      columnList.add(DataColumn(
          label: const Text('Vision'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 960) {
      columnList.add(DataColumn(
          label: const Text('HIV'),
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
    List<DataCell> cellList = [
      DataCell(Text(documentSnapshot['rank'])),
      DataCell(Text(
          '${documentSnapshot['name']}, ${documentSnapshot['firstName']}')),
    ];
    if (width > 420) {
      cellList.add(DataCell(Text(documentSnapshot['pha'])));
    }
    if (width > 560) {
      cellList.add(DataCell(Text(documentSnapshot['dental'])));
    }
    if (width > 685) {
      cellList.add(DataCell(Text(documentSnapshot['hearing'])));
    }
    if (width > 820) {
      cellList.add(DataCell(Text(documentSnapshot['vision'])));
    }
    if (width > 960) {
      cellList.add(DataCell(Text(documentSnapshot['hiv'])));
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
            filteredDocs.sort((a, b) => a['pha'].compareTo(b['pha']));
            break;
          case 3:
            filteredDocs.sort((a, b) => a['dental'].compareTo(b['dental']));
            break;
          case 4:
            filteredDocs.sort((a, b) => a['hearin'].compareTo(b['hearing']));
            break;
          case 5:
            filteredDocs.sort((a, b) => a['vision'].compareTo(b['vision']));
            break;
          case 6:
            filteredDocs.sort((a, b) => a['hiv'].compareTo(b['hiv']));
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
            filteredDocs.sort((a, b) => b['pha'].compareTo(a['pha']));
            break;
          case 3:
            filteredDocs.sort((a, b) => b['dental'].compareTo(a['dental']));
            break;
          case 4:
            filteredDocs.sort((a, b) => b['hearing'].compareTo(a['hearing']));
            break;
          case 5:
            filteredDocs.sort((a, b) => b['vision'].compareTo(a['vision']));
            break;
          case 6:
            filteredDocs.sort((a, b) => b['hiv'].compareTo(a['hiv']));
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
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
            title: const Text('MedPros'),
            actions: appBarMenu(context, MediaQuery.of(context).size.width)),
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
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
