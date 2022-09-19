// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../auth_provider.dart';
import '../providers/tracking_provider.dart';
import '../../providers/subscription_state.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../../pages/editPages/editEquipmentPage.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../models/equipment.dart';
import '../../pages/uploadPages/uploadEquipmentPage.dart';
import '../../pdf/equipmentPdf.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({
    Key key,
    @required this.userId,
  }) : super(key: key);
  final String userId;

  static const routeName = '/equipment-page';

  @override
  EquipmentPageState createState() => EquipmentPageState();
}

class EquipmentPageState extends State<EquipmentPage> {
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
        .collection('equipment')
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UploadEquipmentPage(
                    userId: widget.userId,
                    isSubscribed: isSubscribed,
                  )));
      // Widget title = const Text('Upload Equipment');
      // Widget content = SingleChildScrollView(
      //   child: Container(
      //     padding: const EdgeInsets.all(8.0),
      //     child: const Text(
      //       'To upload your Equipment, the file must be in .csv format. Also, there needs to be a Soldier Id column and the '
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
      //             builder: (context) => UploadEquipmentPage(
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
      'Weapon',
      'Butt Stock',
      'Serial #',
      'Optics',
      'Optics Serial #',
      'Secondary Weapon',
      'Secondary Butt Stock',
      'Secondary Serial #',
      'Secondary Optics',
      'Secondary Optics Serial #',
      'Mask',
      'Vehicle Bumper #',
      'Vehicle Type',
      'License #',
      'Miscellaneous',
      'Miscellaneous Serial #'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['weapon']);
      docs.add(doc['buttStock']);
      docs.add(doc['serial']);
      docs.add(doc['optic']);
      docs.add(doc['opticSerial']);
      docs.add(doc['weapon2']);
      docs.add(doc['buttStock2']);
      docs.add(doc['serial2']);
      docs.add(doc['optic2']);
      docs.add(doc['opticSerial2']);
      docs.add(doc['mask']);
      docs.add(doc['veh']);
      docs.add(doc['vehType']);
      docs.add(doc['license']);
      docs.add(doc['misc']);
      docs.add(doc['miscSerial']);

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
          type: 'xlsx', fileName: 'equipment.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/equipment.xlsx')
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
                      OpenFile.open('$dir/equipment.xlsx');
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
      if (_selectedDocuments.isEmpty) {
        //show snack bar requiring at least one item selected
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You must select at least one record')));
        return;
      }
      Widget title = const Text('Download PDF');
      Widget content = Container(
        padding: const EdgeInsets.all(8.0),
        child: const Text('Select full page or half page format.'),
      );
      customAlertDialog(
        context: context,
        title: title,
        content: content,
        primaryText: 'Full  Page',
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
    EquipmentPdf pdf = EquipmentPdf(
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
                    OpenFile.open('$location/equipment.pdf');
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
    deleteRecord(context, _selectedDocuments, widget.userId, 'Equipment');
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
            builder: (context) => EditEquipmentPage(
                  userId: widget.userId,
                  equipment: Equipment.fromSnapshot(_selectedDocuments.first),
                  isSubscribed: isSubscribed,
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditEquipmentPage(
                  userId: widget.userId,
                  equipment: Equipment(
                    owner: widget.userId,
                    users: [widget.userId],
                  ),
                  isSubscribed: isSubscribed,
                )));
  }

  List<DataColumn> _createColumns(double width) {
    List<DataColumn> columnList = [
      DataColumn(
        label: const Expanded(
          flex: 1,
          child: Text('Rank'),
        ),
        onSort: (int columnIndex, bool ascending) =>
            onSortColumn(columnIndex, ascending),
      ),
      DataColumn(
          label: const Expanded(
            flex: 1,
            child: Text('Name'),
          ),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)),
    ];
    if (width > 400) {
      columnList.add(DataColumn(
          label: const Expanded(
            flex: 1,
            child: Text('Weapon'),
          ),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 595) {
      columnList.add(DataColumn(
          label: const Expanded(
            flex: 1,
            child: Text('Butt Stock'),
          ),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 685) {
      columnList.add(DataColumn(
          label: const Expanded(
            flex: 1,
            child: Text('Serial'),
          ),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 825) {
      columnList.add(DataColumn(
          label: const Expanded(
            flex: 1,
            child: Text('Mask'),
          ),
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
    if (width > 400) {
      cellList.add(DataCell(Text(documentSnapshot['weapon'])));
    }
    if (width > 595) {
      cellList.add(DataCell(Text(documentSnapshot['buttStock'])));
    }
    if (width > 685) {
      cellList.add(DataCell(Text(documentSnapshot['serial'])));
    }
    if (width > 825) {
      cellList.add(DataCell(Text(documentSnapshot['mask'])));
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
            filteredDocs.sort((a, b) => a['weapon'].compareTo(b['weapon']));
            break;
          case 3:
            filteredDocs
                .sort((a, b) => a['buttStock'].compareTo(b['buttStock']));
            break;
          case 4:
            filteredDocs.sort((a, b) => a['serial'].compareTo(b['serial']));
            break;
          case 5:
            filteredDocs.sort((a, b) => a['mask'].compareTo(b['mask']));
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
            filteredDocs.sort((a, b) => b['weapon'].compareTo(a['weapon']));
            break;
          case 3:
            filteredDocs
                .sort((a, b) => b['buttStock'].compareTo(a['buttStock']));
            break;
          case 4:
            filteredDocs.sort((a, b) => b['serial'].compareTo(a['serial']));
            break;
          case 5:
            filteredDocs.sort((a, b) => b['mask'].compareTo(a['mask']));
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
            message: 'Upload Excel',
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
            title: const Text('Equipment'),
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
