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

import '../providers/auth_provider.dart';
import '../../providers/subscription_state.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/filter_documents.dart';
import '../methods/open_file.dart';
import '../methods/theme_methods.dart';
import '../methods/toast_messages/subscription_needed_toast.dart';
import '../methods/web_download.dart';
import '../models/app_bar_option.dart';
import '../models/working_eval.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';
import '../widgets/custom_data_table.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_working_eval_page.dart';
import 'uploadPages/upload_working_evals_page.dart';

class WorkingEvalsPage extends ConsumerStatefulWidget {
  const WorkingEvalsPage({
    super.key,
  });

  static const routeName = '/working-evaluations-page';

  @override
  WorkingEvalsPageState createState() => WorkingEvalsPageState();
}

class WorkingEvalsPageState extends ConsumerState<WorkingEvalsPage> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true, _adLoaded = false, isSubscribed = false;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [], filteredDocs = [];
  late StreamSubscription _subscription;
  late BannerAd myBanner;
  late String userId;
  FToast toast = FToast();

  @override
  void initState() {
    super.initState();
    userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

    String adUnitId = kIsWeb
        ? ''
        : Platform.isAndroid
            ? 'ca-app-pub-2431077176117105/6683225408'
            : 'ca-app-pub-2431077176117105/1331067549';

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

    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection(WorkingEval.collectionName)
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
    myBanner.dispose();
    super.dispose();
  }

  _uploadExcel(BuildContext context) {
    if (isSubscribed) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadWorkingEvalsPage()),
      );
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
      'Duty Description',
      'Appointed Duties',
      'Special Emphasis',
      'Character',
      'Presence',
      'Intellect',
      'Leads',
      'Develops',
      'Achieves',
      'Performance'
    ]);
    for (DocumentSnapshot doc in documents) {
      List<dynamic> docs = [];
      docs.add(doc['soldierId']);
      docs.add(doc['rank']);
      docs.add(doc['rankSort']);
      docs.add(doc['name']);
      docs.add(doc['firstName']);
      docs.add(doc['section']);
      docs.add(doc['dutyDescription']);
      docs.add(doc['appointedDuties']);
      docs.add(doc['specialEmphasis']);
      docs.add(doc['character']);
      docs.add(doc['presence']);
      docs.add(doc['intellect']);
      docs.add(doc['leads']);
      docs.add(doc['develops']);
      docs.add(doc['achieves']);
      docs.add(doc['performance']);

      docsList.add(docs);
    }

    var excel = Excel.createExcel();
    var sheet = excel.sheets[excel.getDefaultSheet()];
    for (var docs in docsList) {
      sheet!.appendRow(docs.map((e) => TextCellValue(e)).toList());
    }

    String dir, location;
    if (kIsWeb) {
      WebDownload webDownload = WebDownload(
          type: 'xlsx', fileName: 'workingEvals.xlsx', data: excel.encode());
      webDownload.download();
    } else {
      List<String> strings = await getPath();
      dir = strings[0];
      location = strings[1];
      try {
        var bytes = excel.encode()!;
        File('$dir/workingEvals.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          toast.showToast(
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed:
                  kIsWeb ? null : () => openFile('$dir/workingEvals.xlsx'),
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
      toast.showToast(
        child: const MyToast(
          message: 'You must select at least one record',
        ),
      );
      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, userId, 'Eval$s');
  }

  void _editRecord() {
    if (_selectedDocuments.length != 1) {
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
        builder: (context) => EditWorkingEvalPage(
          eval: WorkingEval.fromSnapshot(
            _selectedDocuments[0],
          ),
        ),
      ),
    );
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkingEvalPage(
          eval: WorkingEval(
            owner: userId,
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
            onSortColumn(columnIndex, ascending),
      ),
    ];
    if (width > 380) {
      columnList.add(
        DataColumn(
          label: const Text('Section'),
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
    List<DataCell> cellList = [
      DataCell(Text(documentSnapshot['rank'])),
      DataCell(Text(
          '${documentSnapshot['name']}, ${documentSnapshot['firstName']}')),
    ];
    if (width > 380) {
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
    toast.context = context;
    return PlatformScaffold(
      title: 'Working Evals',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New Eval',
              icon: Icon(
                CupertinoIcons.add,
                color: getPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit Eval',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete Eval',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
          ),
          AppBarOption(
            title: 'Filter Evals',
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
