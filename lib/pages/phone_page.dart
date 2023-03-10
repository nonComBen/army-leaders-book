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
import '../models/phone_number.dart';
import 'editPages/edit_phone_page.dart';
import 'uploadPages/upload_phone_page.dart';
import '../pdf/phone_pdf.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({
    Key key,
    @required this.userId,
  }) : super(key: key);
  final String userId;

  static const routeName = '/phone-page';

  @override
  PhonePageState createState() => PhonePageState();
}

class PhonePageState extends State<PhonePage> {
  int _sortColumnIndex;
  bool _sortAscending = true, _adLoaded = false, isSubscribed;
  List<DocumentSnapshot> _selectedDocuments;
  List<DocumentSnapshot> documents;
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
    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('phoneNumbers')
        .where('owner', isEqualTo: widget.userId)
        .snapshots();
    _subscription = stream.listen((updates) {
      setState(() {
        documents = updates.docs;
        _selectedDocuments.clear();
      });
      // for (DocumentChange dc in updates.docChanges) {
      //   if (dc.type == DocumentChangeType.removed) {
      //     setState(() {
      //       documents.removeWhere((doc) => doc.id == dc.doc.id);
      //       _selectedDocuments.removeWhere((doc) => doc.id == dc.doc.id);
      //     });
      //   }
      //   if (dc.type == DocumentChangeType.added) {
      //     setState(() {
      //       documents.add(dc.doc);
      //       _selectedDocuments.clear();
      //     });
      //   }
      //   if (dc.type == DocumentChangeType.modified) {
      //     setState(() {
      //       documents.removeWhere((doc) => doc.id == dc.doc.id);
      //       documents.add(dc.doc);
      //       _selectedDocuments.clear();
      //     });
      //   }
      // }
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UploadPhonePage()));
      // Widget title = const Text('Upload Phone Numbers');
      // Widget content = Container(
      //   padding: const EdgeInsets.all(8.0),
      //   child: const Text(
      //     'To upload your Phone Numbers, the file must be in .csv format.',
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
      //             builder: (context) => UploadPhonePage(
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
    docsList.add(['Title', 'POC', 'Phone Number', 'Location']);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['title']);
      docs.add(doc['name']);
      docs.add(doc['phone']);
      docs.add(doc['location']);

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
          type: 'xlsx', fileName: 'phoneDirectory.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode();
        File('$dir/phoneDirectory.xlsx')
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
                        OpenFile.open('$dir/phoneDirectory.xlsx');
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
      (a, b) => a['title'].toString().compareTo(b['title'].toString()),
    );
    PhonePdf pdf = PhonePdf(
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
                    OpenFile.open('$location/phoneNumbers.pdf');
                  },
                )));
    }
  }

  void _deleteRecord() {
    if (_selectedDocuments.isEmpty) {
      //show snack bar requiring at least one item selected
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must select at least one record')));
      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, widget.userId, 'Phone Number$s');
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
            builder: (context) => EditPhonePage(
                  phone: Phone.fromSnapshot(
                    _selectedDocuments[0],
                  ),
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditPhonePage(
                  phone: Phone(
                    owner: widget.userId,
                  ),
                )));
  }

  List<DataColumn> _createColumns(double width) {
    List<DataColumn> columnList = [
      DataColumn(
        label: const Text('Title'),
        onSort: (int columnIndex, bool ascending) =>
            onSortColumn(columnIndex, ascending),
      ),
      DataColumn(
          label: const Text('POC'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)),
    ];
    if (width > 425) {
      columnList.add(DataColumn(
          label: const Text('Phone No'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 525) {
      columnList.add(DataColumn(
          label: const Text('Location'),
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
      DataCell(Text(documentSnapshot['title'])),
      DataCell(Text(documentSnapshot['name'])),
    ];
    if (width > 425) {
      cellList.add(DataCell(Text(documentSnapshot['phone'])));
    }
    if (width > 525) {
      cellList.add(DataCell(Text(documentSnapshot['location'])));
    }
    return cellList;
  }

  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        switch (columnIndex) {
          case 0:
            documents.sort((a, b) => a['title'].compareTo(b['title']));
            break;
          case 1:
            documents.sort((a, b) => a['name'].compareTo(b['name']));
            break;
          case 2:
            documents.sort((a, b) => a['phone'].compareTo(b['phone']));
            break;
          case 3:
            documents.sort((a, b) => a['location'].compareTo(b['location']));
            break;
        }
      } else {
        switch (columnIndex) {
          case 0:
            documents.sort((a, b) => b['title'].compareTo(a['title']));
            break;
          case 1:
            documents.sort((a, b) => b['name'].compareTo(a['name']));
            break;
          case 2:
            documents.sort((a, b) => b['phone'].compareTo(a['phone']));
            break;
          case 3:
            documents.sort((a, b) => b['location'].compareTo(a['location']));
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
    List<Widget> editButton = <Widget>[
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
            title: const Text('Phone Numbers'),
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
                          documents, MediaQuery.of(context).size.width),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
