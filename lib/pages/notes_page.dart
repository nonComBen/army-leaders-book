import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_state.dart';
import '../auth_provider.dart';
import '../methods/delete_methods.dart';
import '../../models/note.dart';
import 'editPages/edit_note_page.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({
    Key? key,
    required this.userId,
  }) : super(key: key);
  final String userId;

  static const routeName = '/notes-page';

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true, _adLoaded = false, isSubscribed = false;
  final List<DocumentSnapshot> _selectedDocuments = [];
  List<DocumentSnapshot> documents = [];
  late StreamSubscription _subscription;
  BannerAd? myBanner;

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
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _adLoaded = true;
          },
        ),
      );

      if (!kIsWeb && !isSubscribed) {
        await myBanner!.load();
        _adLoaded = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('notes')
        .where('owner', isEqualTo: widget.userId)
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
    myBanner?.dispose();
    super.dispose();
  }

  void _deleteRecord() {
    if (_selectedDocuments.isEmpty) {
      //show snack bar requiring at least one item selected
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must select at least one record')));
      return;
    }
    String s = _selectedDocuments.length > 1 ? 's' : '';
    deleteRecord(context, _selectedDocuments, widget.userId, 'Note$s');
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
            owner: widget.userId,
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
    final user = AuthProvider.of(context)!.auth!.currentUser()!;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Notes'),
        actions: <Widget>[
          Tooltip(
              message: 'Delete Record(s)',
              child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteRecord())),
          Tooltip(
              message: 'Edit Record',
              child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editRecord())),
        ],
      ),
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
              width: myBanner!.size.width.toDouble(),
              height: myBanner!.size.height.toDouble(),
              constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
              child: AdWidget(
                ad: myBanner!,
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
                    columns: _createColumns(MediaQuery.of(context).orientation),
                    rows: _createRows(
                        documents, MediaQuery.of(context).size.width),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
