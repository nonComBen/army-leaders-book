import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../auth_provider.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/filter_documents.dart';
import '../methods/theme_methods.dart';
import '../models/app_bar_option.dart';
import '../providers/tracking_provider.dart';
import '../../providers/subscription_state.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/web_download.dart';
import '../../widgets/anon_warning_banner.dart';
import '../../models/counseling.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_counseling_page.dart';
import 'uploadPages/upload_counselings_page.dart';

class CounselingsPage extends ConsumerStatefulWidget {
  const CounselingsPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/counseling-page';

  @override
  CounselingsPageState createState() => CounselingsPageState();
}

class CounselingsPageState extends ConsumerState<CounselingsPage> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true, _adLoaded = false, isSubscribed = false;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [], filteredDocs = [];
  late StreamSubscription _subscription;
  BannerAd? myBanner;
  late String userId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    isSubscribed = ref.read(subscriptionStateProvider);

    if (!_adLoaded) {
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
          listener: BannerAdListener(onAdLoaded: (ad) {
            _adLoaded = true;
          }));

      if (!kIsWeb && !isSubscribed) {
        await myBanner!.load();
        _adLoaded = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    userId = ref.read(authProvider).currentUser()!.uid;

    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('counselings')
        .where('owner', isEqualTo: userId)
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
        MaterialPageRoute(builder: (context) => const UploadCounselingsPage()),
      );
    } else {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'Uploading data is only available for subscribed users.',
        ),
      );
    }
  }

  void _downloadExcel() async {
    if (!await checkPermission(Permission.storage)) return;
    List<List<dynamic>> docsList = [];
    docsList.add([
      'Soldier Id',
      'Rank',
      'Rank Sort',
      'Last Name',
      'First Name',
      'Section',
      'Date',
      'Purpose of Counseling',
      'Key Points',
      'Plan of Action',
      'Individual Remarks',
      'Leader Responsibilities',
      'Assessment'
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
      docs.add(doc['purpose']);
      docs.add(doc['keyPoints']);
      docs.add(doc['planOfAction']);
      docs.add(doc['indivRemarks']);
      docs.add(doc['leaderResp']);
      docs.add(doc['assessment']);

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
          type: 'xlsx', fileName: 'counselings.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode()!;
        File('$dir/counselings.xlsx')
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
                  kIsWeb ? null : () => OpenFile.open('$dir/counselings.xlsx'),
            ),
          );
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error: $e');
      }
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
    deleteRecord(context, _selectedDocuments, userId, 'Counseling$s');
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
            builder: (context) => EditCounselingPage(
                  counseling: Counseling.fromSnapshot(_selectedDocuments.first),
                )));
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditCounselingPage(
                  counseling: Counseling(
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
    if (width > 420) {
      columnList.add(DataColumn(
          label: const Text('Date'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 510) {
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
          onSelectChanged: (bool? selected) =>
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
      cellList.add(DataCell(Text(documentSnapshot['date'])));
    }
    if (width > 510) {
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
            filteredDocs.sort((a, b) => a['date'].compareTo(b['date']));
            break;
          case 3:
            filteredDocs.sort((a, b) => a['section'].compareTo(b['section']));
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
            filteredDocs.sort((a, b) => b['section'].compareTo(a['section']));
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
    return PlatformScaffold(
      title: 'Counselings',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New Counseling',
              icon: Icon(
                CupertinoIcons.add,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit Counseling',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getOnPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete Counseling',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getOnPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
          ),
          AppBarOption(
            title: 'Filter Counselings',
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
