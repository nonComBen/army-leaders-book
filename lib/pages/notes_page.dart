import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../models/note.dart';
import '../../providers/subscription_state.dart';
import '../providers/auth_provider.dart';
import '../methods/create_app_bar_actions.dart';
import '../methods/delete_methods.dart';
import '../methods/theme_methods.dart';
import '../models/app_bar_option.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';
import '../widgets/custom_data_table.dart';
import '../widgets/my_toast.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/table_frame.dart';
import 'editPages/edit_note_page.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({
    super.key,
  });

  static const routeName = '/notes-page';

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends ConsumerState<NotesPage> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true, _adLoaded = false, isSubscribed = false;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [];
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
            ? 'ca-app-pub-2431077176117105/5969152104'
            : 'ca-app-pub-2431077176117105/5872947783';

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
        .collection(Note.collectionName)
        .where('owner', isEqualTo: userId)
        .snapshots();
    _subscription = stream.listen(
      (updates) {
        setState(
          () {
            documents = updates.docs;
            _selectedDocuments.clear();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    myBanner.dispose();
    super.dispose();
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
    deleteRecord(context, _selectedDocuments, userId, 'Note$s');
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
        builder: (context) => EditNotePage(
          note: Note.fromSnapshot(_selectedDocuments[0]),
        ),
      ),
    );
  }

  void _newRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(
          note: Note(
            owner: userId,
          ),
        ),
      ),
    );
  }

  List<DataColumn> _createColumns(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      return [
        DataColumn(
            label: const Text('Title'),
            onSort: (int columnIndex, bool ascending) =>
                onSortColumn(columnIndex, ascending)),
        DataColumn(
            label: const Text('Comments'),
            onSort: (int columnIndex, bool ascending) =>
                onSortColumn(columnIndex, ascending)),
      ];
    } else {
      return [
        DataColumn(
            label: const Text('Title'),
            onSort: (int columnIndex, bool ascending) =>
                onSortColumn(columnIndex, ascending)),
        DataColumn(
            label: const Text('Comments'),
            onSort: (int columnIndex, bool ascending) =>
                onSortColumn(columnIndex, ascending)),
      ];
    }
  }

  List<DataRow> _createRows(List<DocumentSnapshot> snapshot, double width) {
    double maxWidth = width / 2.5;
    if (width > 400) maxWidth = width / 2.0;
    List<DataRow> newList;
    newList = snapshot.map((DocumentSnapshot documentSnapshot) {
      return DataRow(
        selected: _selectedDocuments.contains(documentSnapshot),
        onSelectChanged: (bool? selected) =>
            onSelected(selected, documentSnapshot),
        cells: <DataCell>[
          DataCell(Text(documentSnapshot['title'])),
          DataCell(
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                documentSnapshot['comments'],
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      );
    }).toList();

    return newList;
  }

  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      if (ascending) {
        switch (columnIndex) {
          case 0:
            documents.sort((a, b) => a['title'].compareTo(b['title']));
            break;
          case 1:
            documents.sort((a, b) => a['comments'].compareTo(b['comments']));
            break;
        }
      } else {
        switch (columnIndex) {
          case 0:
            documents.sort((a, b) => b['title'].compareTo(a['title']));
            break;
          case 1:
            documents.sort((a, b) => b['comments'].compareTo(a['comments']));
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
      title: 'Notes',
      actions: createAppBarActions(
        width,
        [
          if (!kIsWeb && Platform.isIOS)
            AppBarOption(
              title: 'New Note',
              icon: Icon(
                CupertinoIcons.add,
                color: getPrimaryColor(context),
              ),
              onPressed: () => _newRecord(context),
            ),
          AppBarOption(
            title: 'Edit Note',
            icon: Icon(
              kIsWeb || Platform.isAndroid ? Icons.edit : CupertinoIcons.pencil,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _editRecord(),
          ),
          AppBarOption(
            title: 'Delete Note',
            icon: Icon(
              kIsWeb || Platform.isAndroid
                  ? Icons.delete
                  : CupertinoIcons.delete,
              color: getPrimaryColor(context),
            ),
            onPressed: () => _deleteRecord(),
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
                    columns: _createColumns(MediaQuery.of(context).orientation),
                    rows: _createRows(
                        documents, MediaQuery.of(context).size.width),
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
