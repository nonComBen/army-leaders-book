// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_state.dart';
import '../auth_provider.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../models/working_award.dart';
import '../../pages/editPages/editWorkingAwardPage.dart';
import '../../pages/uploadPages/uploadWorkingAwadsPage.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';

class WorkingAwardsPage extends StatefulWidget {
  const WorkingAwardsPage({
    Key key,
    @required this.userId,
  }) : super(key: key);
  final String userId;

  static const routeName = '/working-awards-page';

  @override
  WorkingAwardsPageState createState() => WorkingAwardsPageState();
}

class WorkingAwardsPageState extends State<WorkingAwardsPage> {
  int _sortColumnIndex;
  bool _sortAscending = true, _adLoaded = false, isSubscribed;
  List<DocumentSnapshot> _selectedDocuments;
  List<DocumentSnapshot> documents, filteredDocs;
  StreamSubscription _subscription;
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
    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('workingAwards')
        .where('owner', isEqualTo: widget.userId)
        .snapshots();
    _subscription = stream.listen((updates) {
      setState(() {
        documents = updates.docs;
        filteredDocs = updates.docs;
        _selectedDocuments.clear();
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    myBanner?.dispose();
    super.dispose();
  }

  _uploadExcel(BuildContext context) {
    if (isSubscribed) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UploadWorkingAwardsPage(
                    userId: widget.userId,
                    isSubscribed: isSubscribed,
                  )));
      // Widget title = const Text('Upload Working Awards');
      // Widget content = SingleChildScrollView(
      //   child: Container(
      //     padding: const EdgeInsets.all(8.0),
      //     child: const Text(
      //       'To upload your Working Awards, the file must be in .csv format. Also, there needs to be a Soldier Id column and the '
      //       'Soldier Id has to match the Soldier Id in the database. To get your Soldier Ids, download the data from Soldiers '
      //       'page. If Excel gives you an error for Soldier Id, change cell format to Text from General and delete the \'=\'.',
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
      //             builder: (context) => UploadWorkingAwardsPage(
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
    if (!await checkPermission(context, Permission.storage)) return;
    List<List<dynamic>> docsList = [];
    docsList.add([
      'Soldier Id',
      'Rank',
      'Rank Sort',
      'Last Name',
      'First Name',
      'Section',
      'Award Reason',
      'Achievement 1',
      'Achievement 2',
      'Achievement 3',
      'Achievement 4',
      'Citation'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['awardReason']);
      docs.add(doc['ach1']);
      docs.add(doc['ach2']);
      docs.add(doc['ach3']);
      docs.add(doc['ach4']);
      docs.add(doc['citation']);

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
          type: 'xlsx', fileName: 'workingAwards.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/workingAwards.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Data successfully downloaded to $location'),
            duration: const Duration(seconds: 5),
            action: Platform.isAndroid
                ? SnackBarAction(
                    label: 'Open',
                    onPressed: () {
                      OpenFile.open('$dir/workingAwards.xlsx');
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
    deleteRecord(context, _selectedDocuments, widget.userId, 'Award$s');
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
            builder: (context) => EditWorkingAwardPage(
                  userId: widget.userId,
                  award: WorkingAward.fromSnapshot(
                    _selectedDocuments[0],
                  ),
                  isSubscribed: isSubscribed,
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditWorkingAwardPage(
                  userId: widget.userId,
                  award: WorkingAward(
                    owner: widget.userId,
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
    if (width > 435) {
      columnList.add(DataColumn(
          label: const Text('Reason'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 550) {
      columnList.add(DataColumn(
          label: const Text('Section'),
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
    if (width > 435) {
      cellList.add(DataCell(Text(documentSnapshot['awardReason'])));
    }
    if (width > 550) {
      cellList.add(DataCell(Text(documentSnapshot['section'])));
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
            filteredDocs
                .sort((a, b) => a['section'].compareTo(b['awardReason']));
            break;
          case 3:
            filteredDocs
                .sort((a, b) => a['awardReason'].compareTo(b['section']));
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
            filteredDocs
                .sort((a, b) => b['section'].compareTo(a['awardReason']));
            break;
          case 3:
            filteredDocs
                .sort((a, b) => b['awardReason'].compareTo(a['section']));
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
    } else {
      popupItems.add(const PopupMenuItem(
        value: 'download',
        child: Text('Download as Excel'),
      ));
      popupItems.add(const PopupMenuItem(
        value: 'upload',
        child: Text('Upload Data'),
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
            title: const Text('Working Award'),
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
