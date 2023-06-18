import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth_provider.dart';
import '../../methods/custom_alert_dialog.dart';
import '../../models/setting.dart';
import '../../providers/shared_prefs_provider.dart';
import '../methods/on_back_pressed.dart';
import '../methods/theme_methods.dart';
import '../providers/theme_provider.dart';
import '../widgets/header_text.dart';
import '../widgets/my_toast.dart';
import '../widgets/padded_text_field.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../widgets/platform_widgets/platform_icon_button.dart';
import '../widgets/platform_widgets/platform_list_tile.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/platform_widgets/platform_selection_widget.dart';
import '../widgets/platform_widgets/platform_text_field.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/settings-page';

  @override
  SettingsPageState createState() => SettingsPageState();
}

enum Notification { acft, bf, weapon, pha, dental, vision, hearing, hiv }

class SettingsPageState extends ConsumerState<SettingsPage> {
  int acftMos = 6,
      bfMos = 6,
      weaponMos = 6,
      phaMos = 12,
      dentalMos = 12,
      visionMos = 12,
      hearingMos = 12,
      hivMos = 24;
  List<dynamic> acftNotifications = [],
      bfNotifications = [],
      weaponNotifications = [],
      phaNotifications = [],
      dentalNotifications = [],
      visionNotifications = [],
      hearingNotifications = [],
      hivNotifications = [];
  bool updated = false,
      addNotification = true,
      perstat = true,
      apts = true,
      apft = true,
      acft = true,
      profiles = true,
      bf = true,
      weapons = true,
      flags = false,
      medpros = false,
      training = false,
      isInitial = true;
  late String userId;
  String _brightness = 'Dark';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Setting setting;
  late SharedPreferences prefs;

  final TextEditingController acftController = TextEditingController();
  final TextEditingController bfController = TextEditingController();
  final TextEditingController weaponsController = TextEditingController();
  final TextEditingController phaController = TextEditingController();
  final TextEditingController dentalController = TextEditingController();
  final TextEditingController visionController = TextEditingController();
  final TextEditingController hearingController = TextEditingController();
  final TextEditingController hivController = TextEditingController();

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userId = ref.read(authProvider).currentUser()!.uid;
    final theme = ref.read(themeProvider);
    prefs = ref.read(sharedPreferencesProvider);
    _brightness = theme.brightness == Brightness.light ? 'Light' : 'Dark';
  }

  @override
  void dispose() {
    acftController.dispose();
    bfController.dispose();
    weaponsController.dispose();
    phaController.dispose();
    dentalController.dispose();
    visionController.dispose();
    hearingController.dispose();
    hivController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  void initialize() async {
    QuerySnapshot snapshot = await firestore
        .collection(Setting.collectionName)
        .where('owner', isEqualTo: userId)
        .get();
    DocumentSnapshot? doc;
    if (snapshot.docs.isNotEmpty) {
      doc = snapshot.docs.firstWhere((doc) => doc.id == userId);
    }

    setState(() {
      if (doc != null) {
        setting = Setting.fromMap(doc.data() as Map<String, dynamic>, userId);
        updated = false;
      } else {
        setting = Setting(
          owner: userId,
        );
        updated = true;
      }

      perstat = setting.perstat;
      apts = setting.apts;
      apft = setting.apft;
      acft = setting.acft;
      profiles = setting.profiles;
      bf = setting.bf;
      weapons = setting.weapons;
      flags = setting.flags;
      medpros = setting.medpros;
      training = setting.training;
      addNotification = setting.addNotifications;
      acftMos = setting.acftMonths;
      bfMos = setting.bfMonths;
      weaponMos = setting.weaponsMonths;
      phaMos = setting.phaMonths;
      dentalMos = setting.dentalMonths;
      visionMos = setting.visionMonths;
      hearingMos = setting.hearingMonths;
      hivMos = setting.hivMonths;

      acftController.text = acftMos.toString();
      bfController.text = bfMos.toString();
      weaponsController.text = weaponMos.toString();
      phaController.text = phaMos.toString();
      dentalController.text = dentalMos.toString();
      visionController.text = visionMos.toString();
      hearingController.text = hearingMos.toString();
      hivController.text = hivMos.toString();

      bfNotifications = setting.bfNotifications.toList(growable: true);
      weaponNotifications = setting.weaponsNotifications.toList(growable: true);
      phaNotifications = setting.phaNotifications.toList(growable: true);
      dentalNotifications = setting.dentalNotifications.toList(growable: true);
      visionNotifications = setting.visionNotifications.toList(growable: true);
      hearingNotifications =
          setting.hearingNotifications.toList(growable: true);
      hivNotifications = setting.hivNotifications.toList(growable: true);
      acftNotifications = setting.acftNotifications.toList(growable: true);
    });
  }

  void _editNotification(
      BuildContext context, int? index, Notification notification) {
    int number = 10;
    TextEditingController numController =
        TextEditingController(text: number.toString());
    if (index != null) {
      switch (notification) {
        case Notification.acft:
          number = acftNotifications[index];
          break;
        case Notification.bf:
          number = bfNotifications[index];
          break;
        case Notification.weapon:
          number = weaponNotifications[index];
          break;
        case Notification.pha:
          number = phaNotifications[index];
          break;
        case Notification.dental:
          number = dentalNotifications[index];
          break;
        case Notification.vision:
          number = visionNotifications[index];
          break;
        case Notification.hearing:
          number = hearingNotifications[index];
          break;
        case Notification.hiv:
          number = hivNotifications[index];
          break;
      }
      numController.text = number.toString();
    }

    Widget title =
        Text(index != null ? 'Edit Notification' : 'Add Notification');
    Widget content = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformTextField(
              controller: numController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Days Before Due Date'),
            ),
          ),
        ],
      ),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: index == null ? 'Add Notification' : 'Edit Notification',
      primary: () {
        number = int.tryParse(numController.text) ?? 0;
        if (index != null) {
          setState(() {
            switch (notification) {
              case Notification.acft:
                acftNotifications[index] = number;
                break;
              case Notification.bf:
                bfNotifications[index] = number;
                break;
              case Notification.weapon:
                weaponNotifications[index] = number;
                break;
              case Notification.pha:
                phaNotifications[index] = number;
                break;
              case Notification.dental:
                dentalNotifications[index] = number;
                break;
              case Notification.vision:
                visionNotifications[index] = number;
                break;
              case Notification.hearing:
                hearingNotifications[index] = number;
                break;
              case Notification.hiv:
                hivNotifications[index] = number;
                break;
            }
          });
        } else {
          setState(() {
            switch (notification) {
              case Notification.acft:
                acftNotifications.add(number);
                break;
              case Notification.bf:
                bfNotifications.add(number);
                break;
              case Notification.weapon:
                weaponNotifications.add(number);
                break;
              case Notification.pha:
                phaNotifications.add(number);
                break;
              case Notification.dental:
                dentalNotifications.add(number);
                break;
              case Notification.vision:
                visionNotifications.add(number);
                break;
              case Notification.hearing:
                hearingNotifications.add(number);
                break;
              case Notification.hiv:
                hivNotifications.add(number);
                break;
            }
          });
        }
      },
      secondary: () {},
    );
  }

  void submit() {
    Setting saveSetting = Setting(
      perstat: perstat,
      apts: apts,
      apft: apft,
      acft: acft,
      profiles: profiles,
      bf: bf,
      weapons: weapons,
      flags: flags,
      medpros: medpros,
      training: training,
      addNotifications: addNotification,
      acftMonths: acftMos,
      bfMonths: bfMos,
      weaponsMonths: weaponMos,
      phaMonths: phaMos,
      dentalMonths: dentalMos,
      visionMonths: visionMos,
      hearingMonths: hearingMos,
      hivMonths: hivMos,
      acftNotifications: acftNotifications,
      bfNotifications: bfNotifications,
      weaponsNotifications: weaponNotifications,
      phaNotifications: phaNotifications,
      dentalNotifications: dentalNotifications,
      visionNotifications: visionNotifications,
      hearingNotifications: hearingNotifications,
      hivNotifications: hivNotifications,
      owner: userId,
    );

    firestore.collection(Setting.collectionName).doc(userId).set(
          saveSetting.toMap(),
          SetOptions(merge: true),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ref.read(themeProvider.notifier);
    final accentColor = getOnPrimaryColor(context);
    final width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Settings',
      body: Center(
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formState,
            onWillPop: updated
                ? () => onBackPressed(context)
                : () => Future(() => true),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: HeaderText(
                    'Theme',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformSelectionWidget(
                    titles: const [Text('Light'), Text('Dark')],
                    values: const ['Light', 'Dark'],
                    groupValue: _brightness,
                    onChanged: (dynamic value) {
                      setState(() {
                        _brightness = value;
                        prefs.setBool('darkMode', value == 'Dark');
                        if (value == 'Light') {
                          themeService.lightTheme();
                        } else {
                          themeService.darkTheme();
                        }
                      });
                    },
                  ),
                ),
                Divider(
                  color: accentColor,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: HeaderText(
                    'Home Screen Cards',
                  ),
                ),
                GridView.count(
                  padding: const EdgeInsets.all(8.0),
                  crossAxisCount: width > 700 ? 2 : 1,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  shrinkWrap: true,
                  childAspectRatio: width > 900
                      ? 900 / 150
                      : width > 700
                          ? width / 150
                          : width / 75,
                  primary: false,
                  children: [
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('PERSTAT'),
                      onChanged: (value) {
                        setState(() {
                          perstat = value!;
                        });
                      },
                      value: perstat,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('Appointments'),
                      onChanged: (value) {
                        setState(() {
                          apts = value!;
                        });
                      },
                      value: apts,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('APFT Stats'),
                      onChanged: (value) {
                        setState(() {
                          apft = value!;
                        });
                      },
                      value: apft,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('ACFT Stats'),
                      onChanged: (value) {
                        setState(() {
                          acft = value!;
                        });
                      },
                      value: acft,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('Profiles'),
                      onChanged: (value) {
                        setState(() {
                          profiles = value!;
                        });
                      },
                      value: profiles,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('Body Composition Stats'),
                      onChanged: (value) {
                        setState(() {
                          bf = value!;
                        });
                      },
                      value: bf,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('Weapon Stats'),
                      onChanged: (value) {
                        setState(() {
                          weapons = value!;
                        });
                      },
                      value: weapons,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('Flags'),
                      onChanged: (value) {
                        setState(() {
                          flags = value!;
                        });
                      },
                      value: flags,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('MedPros'),
                      onChanged: (value) {
                        setState(() {
                          medpros = value!;
                        });
                      },
                      value: medpros,
                    ),
                    PlatformCheckboxListTile(
                      padding: const EdgeInsets.all(8.0),
                      title: const Text('Training'),
                      onChanged: (value) {
                        setState(() {
                          training = value!;
                        });
                      },
                      value: training,
                    ),
                  ],
                ),
                Divider(
                  color: accentColor,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: HeaderText(
                    'Notifications',
                  ),
                ),
                PlatformCheckboxListTile(
                  padding: const EdgeInsets.all(8.0),
                  title: const Text('Receive Notifications'),
                  onChanged: (value) {
                    setState(() {
                      addNotification = value!;
                    });
                  },
                  value: addNotification,
                ),
                const Text(
                  'APFT/ACFT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: acftController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      acftMos = int.tryParse(value) ?? 6;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: acftNotifications.length,
                    itemBuilder: (context, index) {
                      acftNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${acftNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    acftNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.acft);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const HeaderText(
                  'Body Composition',
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: bfController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      bfMos = int.tryParse(value) ?? 6;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: bfNotifications.length,
                    itemBuilder: (context, index) {
                      bfNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${bfNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    bfNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.bf);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const Text(
                  'Weapons Qualification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: weaponsController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      weaponMos = int.tryParse(value) ?? 6;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: weaponNotifications.length,
                    itemBuilder: (context, index) {
                      weaponNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${weaponNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    weaponNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.weapon);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const Text(
                  'PHA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: phaController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      phaMos = int.tryParse(value) ?? 12;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: phaNotifications.length,
                    itemBuilder: (context, index) {
                      phaNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${phaNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    phaNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.pha);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const Text(
                  'Dental',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: dentalController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      dentalMos = int.tryParse(value) ?? 12;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: dentalNotifications.length,
                    itemBuilder: (context, index) {
                      dentalNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${dentalNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    dentalNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.dental);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const Text(
                  'Vision',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: visionController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      visionMos = int.tryParse(value) ?? 12;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: visionNotifications.length,
                    itemBuilder: (context, index) {
                      visionNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${visionNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    visionNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.vision);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const Text(
                  'Hearing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: hearingController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      hearingMos = int.tryParse(value) ?? 12;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: hearingNotifications.length,
                    itemBuilder: (context, index) {
                      hearingNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${hearingNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    hearingNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.hearing);
                            },
                          ),
                        ),
                      );
                    }),
                Divider(
                  color: accentColor,
                ),
                const Text(
                  'HIV',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                PaddedTextField(
                  keyboardType: TextInputType.number,
                  controller: hivController,
                  enabled: true,
                  label: 'Due after X months',
                  decoration: const InputDecoration(
                    labelText: 'Due after X months',
                  ),
                  onChanged: (value) {
                    setState(() {
                      hivMos = int.tryParse(value) ?? 24;
                      updated = true;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: HeaderText(
                        'Notifications',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    PlatformIconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: getTextColor(context),
                        ),
                        onPressed: () {
                          _editNotification(context, null, Notification.acft);
                        })
                  ],
                ),
                GridView.builder(
                    padding: const EdgeInsets.all(0.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 700 ? 2 : 1,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      childAspectRatio: width > 900
                          ? 900 / 150
                          : width > 700
                              ? width / 150
                              : width / 75,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: hivNotifications.length,
                    itemBuilder: (context, index) {
                      hivNotifications.sort();
                      return Card(
                        color: getContrastingBackgroundColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PlatformListTile(
                            title: Text(
                                '${hivNotifications[index].toString()} Days Before'),
                            trailing: PlatformIconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    hivNotifications.removeAt(index);
                                  });
                                }),
                            onTap: () {
                              _editNotification(
                                  context, index, Notification.hiv);
                            },
                          ),
                        ),
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (_formState.currentState!.validate()) {
                        submit();
                      } else {
                        FToast toast = FToast();
                        toast.context = context;
                        toast.showToast(
                          child: const MyToast(
                            message:
                                'Form is invalid, text fields must not be blank',
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
