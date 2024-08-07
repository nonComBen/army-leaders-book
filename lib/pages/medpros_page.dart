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
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/toast_messages/subscription_needed_toast.dart';
import '../../models/medpro.dart';
import '../../providers/subscription_state.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/filter_documents.dart';
import '../methods/open_file.dart';
import '../methods/theme_methods.dart';
import '../methods/web_download.dart';
import '../models/app_bar_option.dart';
import '../pdf/medpros_pdf.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';
import '../widgets/custom_data_table.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_medpros_page.dart';
import 'uploadPages/upload_medpros_page.dart';

class MedProsPage extends ConsumerStatefulWidget {
  const MedProsPage({
    super.key,
  });

  static const routeName = '/medpros-page';

  @override
  MedProsPageState createState() => MedProsPageState();
}

class MedProsPageState extends ConsumerState<MedProsPage> {
  int _sortColumnIndex = 0, startingId = 0;
  bool _sortAscending = true,
      _adLoaded = false,
      isSubscribed = false,
      notificationsRefreshed = false,
      isInitial = true;
  String? _userId;
  List<DocumentSnapshot> documents = [], filteredDocs = [];
  final List<DocumentSnapshot> _selectedDocuments = [];
  late StreamSubscription _subscriptionUsers;
  late SharedPreferences prefs;
  late BannerAd myBanner;
  FToast toast = FToast();

  @override
  void initState() {
    super.initState();

    _userId = ref.read(authProvider).currentUser()!.uid;
    isSubscribed = ref.read(subscriptionStateProvider);
    bool trackingAllowed = ref.read(trackingProvider).trackingAllowed;

    String adUnitId = kIsWeb
        ? ''
        : Platform.isAndroid
            ? 'ca-app-pub-2431077176117105/9840714678'
            : 'ca-app-pub-2431077176117105/7184307250';

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
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();

    final Stream<QuerySnapshot> streamUsers = FirebaseFirestore.instance
        .collection(Medpro.collectionName)
        .where('users', isNotEqualTo: null)
        .where('users', arrayContains: _userId)
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UploadMedProsPage()));
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
      List<dynamic>? imms = doc['otherImms'];
      String otherImms = '';
      if (doc['otherImms'].length > 0) {
        for (int i = 0; i < imms!.length; i++) {
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
      sheet!.appendRow(docs.map((e) => TextCellValue(e.toString())).toList());
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
        var bytes = excel.encode()!;
        File('$dir/medpros.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          toast.showToast(
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed: kIsWeb ? null : () => openFile('$dir/medpros.xlsx'),
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
      pdfRequiresSub(context);
    }
  }

  void completePdfDownload(bool fullPage) async {
    documents.sort(
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );
    MedprosPdf pdf = MedprosPdf(
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
      toast.showToast(
        child: MyToast(
          message: message,
          buttonText: kIsWeb ? null : 'Open',
          onPressed: kIsWeb ? null : () => openFile('$location/medpros.pdf'),
        ),
      );
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
    deleteRecord(context, _selectedDocuments, _userId, 'MedPros');
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
        builder: (context) => EditMedprosPage(
          medpro: Medpro.fromSnapshot(_selectedDocuments.first),
        ),
      ),
    );
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedprosPage(
          medpro: Medpro(
            owner: _userId!,
            users: [_userId],
            otherImms: [],
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
              onSortColumn(columnIndex, ascending)),
    ];
    if (width > 400) {
      columnList.add(DataColumn(
          label: const Text('PHA'),
          onSort: (int columnIndex, bool ascending) =>
              onSortColumn(columnIndex, ascending)));
    }
    if (width > 550) {
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
    if (width > 400) {
      cellList.add(DataCell(Text(documentSnapshot['pha'])));
    }
    if (width > 550) {
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
      title: 'MedPros',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New MedPro',
              icon: Icon(
                CupertinoIcons.add,
                color: getPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit MedPro',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete MedPro',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
          ),
          AppBarOption(
            title: 'Filter MedPros',
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
          AppBarOption(
            title: 'Download PDF',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.picture_as_pdf
                  : CupertinoIcons.doc,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _downloadPdf(),
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
