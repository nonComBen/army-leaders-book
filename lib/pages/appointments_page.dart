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
import 'package:permission_handler/permission_handler.dart';

import '../../auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/toast_messages/subscription_needed_toast.dart';
import '../../models/appointment.dart';
import '../../providers/subscription_state.dart';
import '../../widgets/anon_warning_banner.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/date_methods.dart';
import '../methods/download_methods.dart';
import '../methods/filter_documents.dart';
import '../methods/open_file.dart';
import '../methods/theme_methods.dart';
import '../methods/web_download.dart';
import '../models/app_bar_option.dart';
import '../pdf/appointments_pdf.dart';
import '../providers/tracking_provider.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_appointment_page.dart';
import 'uploadPages/upload_appointment_page.dart';

class AptsPage extends ConsumerStatefulWidget {
  const AptsPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/appointments-page';

  @override
  AptsPageState createState() => AptsPageState();
}

class AptsPageState extends ConsumerState<AptsPage> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true, _adLoaded = false, isSubscribed = false;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [], filteredDocs = [];
  late StreamSubscription _subscriptionUsers;
  late BannerAd myBanner;
  late String userId;

  @override
  void initState() {
    super.initState();

    userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

    String adUnitId = kIsWeb
        ? ''
        : Platform.isAndroid
            ? 'ca-app-pub-2431077176117105/1007921340'
            : 'ca-app-pub-2431077176117105/1441025986';

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

    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection('appointments')
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: userId)
        .snapshots();
    _subscriptionUsers = streamUsers.listen((updates) {
      setState(() {
        documents = updates.docs;
        filteredDocs = updates.docs;
        _selectedDocuments.clear();
      });
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
              builder: (context) => const UploadAppointmentsPage()));
    } else {
      uploadRequiresSub(context);
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
      'Title',
      'Date',
      'Start Time',
      'End Time',
      'Location',
      'Status',
      'Comments'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['aptTitle']);
      docs.add(doc['date']);
      docs.add(doc['start']);
      docs.add(doc['end']);
      try {
        docs.add(doc['location']);
      } catch (e) {
        docs.add('');
      }
      docs.add(doc['status']);
      docs.add(doc['comments']);

      docsList.add(docs);
    }

    var excel = Excel.createExcel();
    var sheet = excel.sheets[excel.getDefaultSheet()];
    for (var docs in docsList) {
      sheet!.appendRow(docs);
    }

    String dir, location;
    if (kIsWeb) {
      WebDownload webDownload = WebDownload(
          type: 'xlsx', fileName: 'appointments.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode()!;
        File('$dir/appointments.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          FToast toast = FToast();
          toast.context = context;
          toast.showToast(
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed:
                  kIsWeb ? null : () => openFile('$dir/appointments.xlsx'),
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
    bool approved = await checkPermission(Permission.storage);
    if (!approved) return;
    documents.sort(
      (a, b) => a['date'].toString().compareTo(b['date'].toString()),
    );
    AppointmentsPdf pdf = AppointmentsPdf(
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
        child: MyToast(
          message: message,
          buttonText: kIsWeb ? null : 'Open',
          onPressed:
              kIsWeb ? null : () => openFile('$location/appointments.pdf'),
        ),
      );
    }
  }

  void _deleteRecord() async {
    if (_selectedDocuments.isEmpty) {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'You must select at least one record',
        ),
      );

      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    Widget title = Text('Delete Appointment$s?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text('Are you sure you want to delete the selected Appointment$s?'),
          ],
        ),
      ),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        delete();
      },
      secondary: () {},
    );
  }

  void _filterRecords(List<String> sections) {
    filteredDocs = documents
        .where((element) => sections.contains(element['section']))
        .toList();
    setState(() {});
  }

  void delete() {
    for (DocumentSnapshot doc in _selectedDocuments) {
      if (doc['owner'] == userId) {
        doc.reference.delete();
      } else {
        List<dynamic> users = doc['users'];
        users.remove(userId);
        doc.reference.update({'users': users});
      }
    }
  }

  void _editRecord() {
    if (_selectedDocuments.length != 1) {
      FToast toast = FToast();
      toast.context = context;
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
            builder: (context) => EditAppointmentPage(
                  apt: Appointment.fromSnapshot(_selectedDocuments.first),
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditAppointmentPage(
                  apt: Appointment(
                    users: [userId],
                    owner: userId,
                  ),
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
    if (width > 410) {
      columnList.add(DataColumn(
          label: const Text('Date'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 500) {
      columnList.add(DataColumn(
          label: const Text('Start'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 650) {
      columnList.add(DataColumn(
          label: const Text('Title'),
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
    bool overdue = isOverdue(documentSnapshot['date'], 1);
    List<DataCell> cellList = [
      DataCell(Text(
        documentSnapshot['rank'],
        style: overdue
            ? const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            : const TextStyle(),
      )),
      DataCell(Text(
        '${documentSnapshot['name']}, ${documentSnapshot['firstName']}',
        style: overdue
            ? const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            : const TextStyle(),
      )),
    ];
    if (width > 410) {
      cellList.add(DataCell(Text(
        documentSnapshot['date'],
        style: overdue
            ? const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            : const TextStyle(),
      )));
    }
    if (width > 500) {
      cellList.add(DataCell(Text(
        documentSnapshot['start'],
        style: overdue
            ? const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            : const TextStyle(),
      )));
    }
    if (width > 650) {
      cellList.add(DataCell(Text(
        documentSnapshot['aptTitle'],
        style: overdue
            ? const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
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
            filteredDocs.sort((a, b) => a['start'].compareTo(b['start']));
            break;
          case 4:
            filteredDocs.sort((a, b) => a['aptTitle'].compareTo(b['aptTitle']));
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
            filteredDocs.sort((a, b) => b['start'].compareTo(a['start']));
            break;
          case 4:
            filteredDocs.sort((a, b) => b['aptTitle'].compareTo(a['aptTitle']));
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
      title: 'Appointments',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New Appointment',
              icon: Icon(
                CupertinoIcons.add,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit Apointment',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getOnPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete Appointment',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getOnPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
          ),
          AppBarOption(
            title: 'Filter Appointments',
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
                          'Red Text: Past Thru Date',
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
