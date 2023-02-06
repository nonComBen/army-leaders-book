// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_state.dart';
import '../auth_provider.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../models/hr_action.dart';
import '../../pages/editPages/editHrActionPage.dart';
import '../../pages/uploadPages/uploadHrActionsPage.dart';
import '../../pdf/hrActionsPdf.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';

class HrActionsPage extends StatefulWidget {
  const HrActionsPage({
    Key key,
    @required this.userId,
  }) : super(key: key);
  final String userId;

  static const routeName = '/hr-actions-page';

  @override
  HrActionsPageState createState() => HrActionsPageState();
}

class HrActionsPageState extends State<HrActionsPage> {
  int _sortColumnIndex;
  bool _sortAscending = true, _adLoaded = false, isSubscribed;
  List<DocumentSnapshot> _selectedDocuments;
  List<DocumentSnapshot> documents, filteredDocs;
  StreamSubscription _subscriptionUsers;
  BannerAd myBanner;

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    isSubscribed = Provider.of<SubscriptionState>(context).isSubscribed;

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

    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection('hrActions')
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
  }

  @override
  void dispose() {
    _subscriptionUsers.cancel();
    myBanner?.dispose();
    super.dispose();
  }

  _uploadExcel(BuildContext context) {
    if (isSubscribed) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UploadHrActionsPage()));
      // Widget title = const Text('Upload HR Metrics');
      // Widget content = SingleChildScrollView(
      //   child: Container(
      //     padding: const EdgeInsets.all(8.0),
      //     child: const Text(
      //       'To upload your HR Metrics, the file must be in .csv format. Also, there needs to be a Soldier Id column and '
      //       'the Soldier Id has to match the Soldier Id in the database. To get your Soldier Ids, download the data '
      //       'from Soldiers page. If Excel gives you an error for Soldier Id, change cell format to Text from General and '
      //       'delete the \'=\'. Dates also need to be in yyyy-MM-dd or M/d/yy format.',
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
      //             builder: (context) => UploadHrActionsPage(
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
      'DD93 Date',
      'SGLV Date',
      'Record Review Date'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['dd93']);
      docs.add(doc['sglv']);
      docs.add(doc['prr']);

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
          type: 'xlsx', fileName: 'hrMetrics.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/hrMetrics.xlsx')
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
                        OpenFile.open('$dir/hrMetrics.xlsx');
                      },
                    )
                  : null,
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
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );
    HrActionsPdf pdf = HrActionsPdf(
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
                    OpenFile.open('$location/hrActions.pdf');
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
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, widget.userId, 'HR Metric$s');
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
            builder: (context) => EditHrActionPage(
                  hrAction: HrAction.fromSnapshot(_selectedDocuments.first),
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditHrActionPage(
                  hrAction: HrAction(
                    owner: widget.userId,
                    users: [widget.userId],
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
    if (width > 420) {
      columnList.add(DataColumn(
          label: const Text('DD93'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 560) {
      columnList.add(DataColumn(
          label: const Text('SGLV'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 700) {
      columnList.add(DataColumn(
          label: const Text('RR'),
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
      cellList.add(DataCell(Text(documentSnapshot['dd93'])));
    }
    if (width > 560) {
      cellList.add(DataCell(Text(documentSnapshot['sglv'])));
    }
    if (width > 700) {
      cellList.add(DataCell(Text(documentSnapshot['prr'])));
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
            filteredDocs.sort((a, b) => a['dd93'].compareTo(b['dd93']));
            break;
          case 3:
            filteredDocs.sort((a, b) => a['sglv'].compareTo(b['sglv']));
            break;
          case 4:
            filteredDocs.sort((a, b) => a['prr'].compareTo(b['prr']));
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
            filteredDocs.sort((a, b) => b['dd93'].compareTo(a['dd93']));
            break;
          case 3:
            filteredDocs.sort((a, b) => b['sglv'].compareTo(a['sglv']));
            break;
          case 4:
            filteredDocs.sort((a, b) => b['prr'].compareTo(a['prr']));
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
            title: const Text('HR Metrics'),
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
