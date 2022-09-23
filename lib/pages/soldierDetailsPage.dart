// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';

import '../../providers/subscription_state.dart';
import '../../models/award.dart';
import '../../models/pov.dart';
import '../../models/soldier.dart';
import '../../pages/editPages/editSoldierPage.dart';
import '../../pages/shareSoldierPage.dart';
import '../auth_provider.dart';
import '../providers/tracking_provider.dart';
import '../widgets/anon_warning_banner.dart';

class SoldierDetailsPage extends StatefulWidget {
  const SoldierDetailsPage({
    Key key,
    @required this.userId,
    @required this.soldier,
  }) : super(key: key);
  final String userId;
  final Soldier soldier;

  static const routeName = '/soldier-details-page';

  @override
  SoldierDetailsPageState createState() => SoldierDetailsPageState();
}

class SoldierDetailsPageState extends State<SoldierDetailsPage> {
  String _soldierName;
  FirebaseFirestore firestore;
  TextEditingController _supervisorController;
  BannerAd myBanner;
  bool _adLoaded = false, isSubscribed;

  Widget createField(String value, String label) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
            initialValue: value,
            enabled: false,
            decoration: InputDecoration(
              labelText: label,
            )));
  }

  String getTimeIn(String date) {
    if (date.length != 10) {
      return '';
    }
    int years, months, days;
    int plusMonths = 0;
    int plusDays = 0;
    DateTime dateTime = DateTime.parse('$date 00:00:00');
    DateTime now = DateTime.now();

    years = now.year - dateTime.year;
    if (now.month < dateTime.month ||
        (now.month == dateTime.month && now.day < dateTime.day)) {
      years--;
      plusMonths = 12;
    }
    months = now.month + plusMonths - dateTime.month;
    if (now.day < dateTime.day) {
      months--;
      plusDays = 30;
    }
    days = now.day + plusDays - dateTime.day;

    return '$years Years, $months Months, $days Days';
  }

  void _editSoldier(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditSoldierPage(
                  soldier: widget.soldier,
                )));
  }

  void deletePov(BuildContext context, String docId) {
    Widget title = const Text('Delete POV?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Are you sure you want to delete this POV?'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        firestore.collection('povs').doc(docId).delete();
      },
      secondary: () {},
    );
  }

  void deleteAward(BuildContext context, String docId) {
    Widget title = const Text('Delete Award?');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Are you sure you want to delete this award?'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Yes',
      primary: () {
        firestore.collection('awards').doc(docId).delete();
      },
      secondary: () {},
    );
  }

  void editAward(BuildContext context, Award award) {
    TextEditingController name = TextEditingController(text: award.name);
    TextEditingController number = TextEditingController(text: award.number);
    Widget title = const Text('Edit Award');
    Widget content = Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Material(
            color: Theme.of(context).dialogBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                      controller: name,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Award Name',
                      )),
                  TextFormField(
                      controller: number,
                      keyboardType: TextInputType.number,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Number of Awards',
                      )),
                ],
              ),
            ),
          ),
        ));
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: award.id == null ? 'Add Award' : 'Edit Award',
      primary: () {
        Award saveAward = Award(
            id: award.id,
            owner: award.owner,
            users: award.users,
            soldierId: award.soldierId,
            name: name.text,
            number: number.text);
        if (award.id == null) {
          firestore.collection('awards').doc().set(saveAward.toMap());
        } else {
          firestore
              .collection('awards')
              .doc(award.id)
              .update(saveAward.toMap());
        }
      },
      secondary: () {},
    );
  }

  void editPov(BuildContext context, POV pov) {
    TextEditingController year = TextEditingController(text: pov.year);
    TextEditingController make = TextEditingController(text: pov.make);
    TextEditingController model = TextEditingController(text: pov.model);
    TextEditingController plate = TextEditingController(text: pov.plate);
    TextEditingController state = TextEditingController(text: pov.state ?? '');
    TextEditingController regExp = TextEditingController(text: pov.regExp);
    TextEditingController ins = TextEditingController(text: pov.ins);
    TextEditingController insExp = TextEditingController(text: pov.insExp);
    Widget title = const Text('Edit POV');
    Widget content = Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Material(
            color: Theme.of(context).dialogBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                      controller: year,
                      keyboardType: TextInputType.number,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                      )),
                  TextFormField(
                      controller: make,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                      )),
                  TextFormField(
                      controller: model,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                      )),
                  TextFormField(
                      controller: plate,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Plates',
                      )),
                  TextFormField(
                      controller: state,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'State',
                      )),
                  TextFormField(
                      controller: regExp,
                      keyboardType: TextInputType.datetime,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Registration Exp',
                      )),
                  TextFormField(
                      controller: ins,
                      keyboardType: TextInputType.text,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Insurance',
                      )),
                  TextFormField(
                      controller: insExp,
                      keyboardType: TextInputType.datetime,
                      enabled: true,
                      decoration: const InputDecoration(
                        labelText: 'Insurance Exp',
                      )),
                ],
              ),
            ),
          ),
        ));

    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: pov.id == null ? 'Add POV' : 'Edit POV',
      primary: () {
        POV savePov = POV(
          id: pov.id,
          owner: pov.owner,
          users: pov.users,
          soldierId: pov.soldierId,
          year: year.text,
          make: make.text,
          model: model.text,
          plate: plate.text,
          state: state.text,
          regExp: regExp.text,
          ins: ins.text,
          insExp: insExp.text,
        );
        if (pov.id == null) {
          firestore.collection('povs').doc().set(savePov.toMap());
        } else {
          firestore.collection('povs').doc(pov.id).update(savePov.toMap());
        }
      },
      secondary: () {},
    );
  }

  @override
  void dispose() {
    _supervisorController.dispose();
    myBanner?.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
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

    firestore = FirebaseFirestore.instance;
    _soldierName =
        '${widget.soldier.rank}${widget.soldier.promotable} ${widget.soldier.lastName}';
    _supervisorController = TextEditingController();
    if (widget.soldier.milEd.length == 4 &&
        widget.soldier.milEd.substring(0, 3) == 'SSD') {
      widget.soldier.milEd = 'DLC${widget.soldier.milEd.substring(3)}';
      var map = <String, dynamic>{};
      map['milEd'] = widget.soldier.milEd;
      firestore.collection('soldiers').doc(widget.soldier.id).update(map);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = AuthProvider.of(context).auth.currentUser();
    return Scaffold(
      appBar: AppBar(
        title: Text(_soldierName),
        actions: <Widget>[
          Tooltip(
            message: 'Share Soldier',
            child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShareSoldierPage(
                                userId: widget.userId,
                                soldiers: [widget.soldier],
                              )));
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () {
            _editSoldier(context);
          }),
      body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    if (user.isAnonymous) const AnonWarningBanner(),
                    GridView.count(
                      primary: false,
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 700 ? width / 200 : width / 100,
                      shrinkWrap: true,
                      children: <Widget>[
                        createField(
                            '$_soldierName, ${widget.soldier.firstName} ${widget.soldier.mi}',
                            'Name'),
                        createField(
                            widget.soldier.assigned ? 'Assigned' : 'Attached',
                            'Assigned'),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                                controller: _supervisorController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: 'Supervisor',
                                ))),
                        createField(widget.soldier.section, 'Section'),
                        createField(widget.soldier.dodId, 'DoD ID'),
                        createField(widget.soldier.dor, 'Date of Rank'),
                        createField(
                            getTimeIn(widget.soldier.dor), 'Time in Grade'),
                        createField(widget.soldier.mos, 'MOS'),
                        createField(widget.soldier.duty, 'Duty Position'),
                        createField(widget.soldier.paraLn, 'Paragraph/Line'),
                        createField(widget.soldier.reqMos, 'Required MOS'),
                        createField(widget.soldier.lossDate, 'Loss Date'),
                        createField(widget.soldier.ets, 'ETS'),
                        createField(widget.soldier.basd, 'BASD'),
                        createField(
                            getTimeIn(widget.soldier.basd), 'Time in Service'),
                        createField(widget.soldier.pebd, 'PEBD'),
                        createField(widget.soldier.gainDate, 'Gain Date'),
                        createField(widget.soldier.civEd, 'Civilian Education'),
                        createField(widget.soldier.milEd, 'Military Education'),
                      ],
                    ),
                    const Divider(),
                    GridView.count(
                      primary: false,
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 700 ? width / 200 : width / 100,
                      shrinkWrap: true,
                      children: <Widget>[
                        createField(
                            widget.soldier.nbcSuitSize, 'CBRN Suit Size'),
                        createField(
                            widget.soldier.nbcMaskSize, 'CBRN Mask Size'),
                        createField(
                            widget.soldier.nbcBootSize, 'CBRN Boot Size'),
                        createField(
                            widget.soldier.nbcGloveSize, 'CBRN Glove Size'),
                        createField(widget.soldier.hatSize, 'Hat Size'),
                        createField(widget.soldier.bootSize, 'Boot Size'),
                        createField(widget.soldier.acuTopSize, 'OCP Top Size'),
                        createField(
                            widget.soldier.acuTrouserSize, 'OCP Trouser Size'),
                      ],
                    ),
                    const Divider(),
                    GridView.count(
                      primary: false,
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 700 ? width / 200 : width / 100,
                      shrinkWrap: true,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                                initialValue: widget.soldier.address ?? '',
                                enabled: true,
                                decoration: InputDecoration(
                                    labelText: 'Address',
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.map),
                                      tooltip: 'Show on Map',
                                      onPressed: (() {
                                        String address =
                                            widget.soldier.address ?? '';
                                        if (widget.soldier.address != '') {
                                          String city =
                                              widget.soldier.city ?? '';
                                          String state =
                                              widget.soldier.state ?? '';
                                          String zip = widget.soldier.zip ?? '';
                                          MapsLauncher.launchQuery(
                                              '$address $city, $state $zip');
                                        }
                                      }),
                                    )))),
                        createField(widget.soldier.city ?? '', 'City'),
                        createField(widget.soldier.state ?? '', 'State'),
                        createField(widget.soldier.zip ?? '', 'Zip Code'),
                        createField(widget.soldier.phone, 'Personal Phone'),
                        createField(widget.soldier.workPhone, 'Work Phone'),
                        createField(widget.soldier.email, 'Personal Email'),
                        createField(widget.soldier.workEmail, 'Work Email'),
                        createField(widget.soldier.nok, 'Next of Kin'),
                        createField(widget.soldier.nokPhone, 'NOK Phone'),
                        createField(
                            widget.soldier.maritalStatus, 'Marital Status'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        initialValue: widget.soldier.comments,
                        enabled: false,
                        decoration:
                            const InputDecoration(labelText: 'Comments'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          editPov(
                              context,
                              POV(
                                owner: widget.soldier.owner,
                                users: widget.soldier.users,
                                soldierId: widget.soldier.id,
                              ));
                        },
                        child: const Text('Add POV'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: firestore
                              .collection('povs')
                              .where('users', isNotEqualTo: null)
                              .where('users', arrayContains: widget.userId)
                              .where('soldierId', isEqualTo: widget.soldier.id)
                              .snapshots(),
                          builder: (BuildContext povContext,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              default:
                                List<DocumentSnapshot> povSnapshots =
                                    snapshot.data.docs;
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: povSnapshots.length,
                                    itemBuilder: (ibContext, position) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          child: ListTile(
                                            title: Text(
                                                '${povSnapshots[position]['year']} ${povSnapshots[position]['make']} ${povSnapshots[position]['model']}'),
                                            subtitle: Text(
                                                'Registration Expires: ${povSnapshots[position]['regExp']}, Insurance Expires: ${povSnapshots[position]['insExp']}'),
                                            trailing: IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  deletePov(
                                                      povContext,
                                                      povSnapshots[position]
                                                          .id);
                                                }),
                                            onTap: () {
                                              editPov(
                                                  povContext,
                                                  POV.fromSnapshot(
                                                      povSnapshots[position]));
                                            },
                                          ),
                                        ),
                                      );
                                    });
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          editAward(
                              context,
                              Award(
                                owner: widget.soldier.owner,
                                users: widget.soldier.users,
                                soldierId: widget.soldier.id,
                              ));
                        },
                        child: const Text('Add Award'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('awards')
                              .where('users', isNotEqualTo: null)
                              .where('users', arrayContains: widget.userId)
                              .where('soldierId', isEqualTo: widget.soldier.id)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              default:
                                List<DocumentSnapshot> awardSnapshots =
                                    snapshot.data.docs;
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: awardSnapshots.length,
                                    itemBuilder: (ibContext, position) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          child: ListTile(
                                            title: Text(
                                                '${awardSnapshots[position]['name']}: ${awardSnapshots[position]['number']}'),
                                            trailing: IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  deleteAward(
                                                      context,
                                                      awardSnapshots[position]
                                                          .id);
                                                }),
                                            onTap: () {
                                              editAward(
                                                  context,
                                                  Award.fromSnapshot(
                                                      awardSnapshots[
                                                          position]));
                                            },
                                          ),
                                        ),
                                      );
                                    });
                            }
                          }),
                    ),
                  ],
                ),
              ),
              if (_adLoaded)
                Container(
                  alignment: Alignment.center,
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                  constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
                  child: AdWidget(
                    ad: myBanner,
                  ),
                )
            ],
          )),
    );
  }
}
