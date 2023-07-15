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
import 'package:permission_handler/permission_handler.dart';

import '../../auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../methods/toast_messages/subscription_needed_toast.dart';
import '../../models/equipment.dart';
import '../../providers/subscription_state.dart';
import '../../widgets/anon_warning_banner.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/delete_methods.dart';
import '../methods/download_methods.dart';
import '../methods/filter_documents.dart';
import '../methods/open_file.dart';
import '../methods/theme_methods.dart';
import '../methods/web_download.dart';
import '../models/app_bar_option.dart';
import '../pdf/equipment_pdf.dart';
import '../providers/tracking_provider.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_equipment_page.dart';
import 'uploadPages/upload_equipment_page.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  const EquipmentPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/equipment-page';

  @override
  EquipmentPageState createState() => EquipmentPageState();
}

class EquipmentPageState extends ConsumerState<EquipmentPage> {
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
            ? 'ca-app-pub-2431077176117105/9392316670'
            : 'ca-app-pub-2431077176117105/6062797275';

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
        .collection(Equipment.collectionName)
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
        MaterialPageRoute(builder: (context) => const UploadEquipmentPage()),
      );
    } else {
      uploadRequiresSub(context);
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
      sheet!.appendRow(docs);
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
        var bytes = excel.encode()!;
        File('$dir/equipment.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        if (mounted) {
          FToast toast = FToast();
          toast.context = context;
          toast.showToast(
            child: MyToast(
              message: 'Data successfully downloaded to $location',
              buttonText: kIsWeb ? null : 'Open',
              onPressed: kIsWeb ? null : () => openFile('$dir/equipment.xlsx'),
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
      pdfRequiresSub(context);
    }
  }

  void completePdfDownload(bool fullPage) async {
    bool approved = await checkPermission(context, Permission.storage);
    if (!approved) return;
    documents.sort(
      (a, b) => a['name'].toString().compareTo(b['name'].toString()),
    );
    EquipmentPdf pdf = EquipmentPdf(
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
          onPressed: kIsWeb ? null : () => openFile('$location/equipment.pdf'),
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
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'You must select at least one record',
        ),
      );
      return;
    }
    deleteRecord(context, _selectedDocuments, userId, 'Equipment');
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
        builder: (context) => EditEquipmentPage(
          equipment: Equipment.fromSnapshot(_selectedDocuments.first),
        ),
      ),
    );
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEquipmentPage(
          equipment: Equipment(
            owner: userId,
            users: [userId],
          ),
        ),
      ),
    );
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
      title: 'Equipment',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New Equipment',
              icon: Icon(
                CupertinoIcons.add,
                color: getOnPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit Equipment',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getOnPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete Equipment',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getOnPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
          ),
          AppBarOption(
            title: 'Filter Equipment',
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
                    checkboxHorizontalMargin: 8.0,
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
