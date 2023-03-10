import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../methods/on_back_pressed.dart';
import '../providers/theme_provider.dart';
import '../../models/setting.dart';
import '../providers/notifications_plugin_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key key,
  }) : super(key: key);

  static const routeName = '/settings-page';

  @override
  SettingsPageState createState() => SettingsPageState();
}

enum Notification { acft, bf, weapon, pha, dental, vision, hearing, hiv }

class SettingsPageState extends State<SettingsPage> {
  int acftMos,
      bfMos,
      weaponMos,
      phaMos,
      dentalMos,
      visionMos,
      hearingMos,
      hivMos;
  List<dynamic> acftNotifications,
      bfNotifications,
      weaponNotifications,
      phaNotifications,
      dentalNotifications,
      visionNotifications,
      hearingNotifications,
      hivNotifications;
  bool updated,
      addNotification,
      perstat,
      apts,
      apft,
      acft,
      profiles,
      bf,
      weapons,
      flags,
      medpros,
      training,
      isInitial = true;
  String userId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Setting setting;
  ThemeData _theme = ThemeData(brightness: Brightness.light);
  // ThemeBloc _themeBloc;
  SharedPreferences prefs;
  FlutterLocalNotificationsPlugin notificationsPlugin;

  TextEditingController acftController;
  TextEditingController bfController;
  TextEditingController weaponsController;
  TextEditingController phaController;
  TextEditingController dentalController;
  TextEditingController visionController;
  TextEditingController hearingController;
  TextEditingController hivController;

  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void _editNotification(
      BuildContext context, int index, Notification notification) {
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
            child: TextFormField(
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

    firestore
        .collection('settings')
        .doc(userId)
        .set(saveSetting.toMap(), SetOptions(merge: true));

    if (!saveSetting.addNotifications) {
      notificationsPlugin.cancelAll();
    }

    Navigator.pop(context);
  }

  Future<bool> _onBackPressed() {
    if (!updated) return Future.value(true);
    return onBackPressed(context);
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
    userId = AuthProvider.of(context).auth.currentUser().uid;
    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  @override
  void initState() {
    super.initState();
    addNotification = true;
    perstat = true;
    apts = true;
    apft = true;
    acft = false;
    profiles = true;
    bf = true;
    weapons = true;
    flags = false;
    medpros = false;
    training = false;
  }

  void initialize() async {
    QuerySnapshot snapshot = await firestore
        .collection('settings')
        .where('owner', isEqualTo: userId)
        .get();
    DocumentSnapshot doc;
    if (snapshot.docs.isNotEmpty) {
      doc = snapshot.docs.firstWhere((doc) => doc.id == userId);
    }
    prefs = await SharedPreferences.getInstance();

    setState(() {
      if (doc != null) {
        setting = Setting.fromMap(doc.data());
        updated = false;
      } else {
        setting = Setting(
          owner: userId,
          hearingNotifications: [0, 30],
          weaponsNotifications: [0, 30],
          acftNotifications: [0, 30],
          dentalNotifications: [0, 30],
          visionNotifications: [0, 30],
          bfNotifications: [0, 30],
          hivNotifications: [0, 30],
          phaNotifications: [0, 30],
        );
        updated = true;
      }

      perstat = setting.perstat ?? true;
      apts = setting.apts ?? true;
      apft = setting.apft ?? true;
      acft = setting.acft ?? false;
      profiles = setting.profiles ?? true;
      bf = setting.bf ?? true;
      weapons = setting.weapons ?? true;
      flags = setting.flags ?? false;
      medpros = setting.medpros ?? false;
      training = setting.training ?? false;
      addNotification = setting.addNotifications ?? true;
      acftMos = setting.acftMonths ?? 6;
      bfMos = setting.bfMonths ?? 6;
      weaponMos = setting.weaponsMonths ?? 6;
      phaMos = setting.phaMonths ?? 12;
      dentalMos = setting.dentalMonths ?? 12;
      visionMos = setting.visionMonths ?? 12;
      hearingMos = setting.hearingMonths ?? 12;
      hivMos = setting.hivMonths ?? 24;

      acftController = TextEditingController(text: acftMos.toString());
      bfController = TextEditingController(text: bfMos.toString());
      weaponsController = TextEditingController(text: weaponMos.toString());
      phaController = TextEditingController(text: phaMos.toString());
      dentalController = TextEditingController(text: dentalMos.toString());
      visionController = TextEditingController(text: visionMos.toString());
      hearingController = TextEditingController(text: hearingMos.toString());
      hivController = TextEditingController(text: hivMos.toString());

      bfNotifications =
          setting.bfNotifications.toList(growable: true) ?? [0, 30];
      weaponNotifications =
          setting.weaponsNotifications.toList(growable: true) ?? [0, 30];
      phaNotifications =
          setting.phaNotifications.toList(growable: true) ?? [0, 30];
      dentalNotifications =
          setting.dentalNotifications.toList(growable: true) ?? [0, 30];
      visionNotifications =
          setting.visionNotifications.toList(growable: true) ?? [0, 30];
      hearingNotifications =
          setting.hearingNotifications.toList(growable: true) ?? [0, 30];
      hivNotifications =
          setting.hivNotifications.toList(growable: true) ?? [0, 30];
      acftNotifications =
          setting.acftNotifications.toList(growable: true) ?? [0, 30];

      _theme = Theme.of(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    notificationsPlugin =
        Provider.of<NotificationsPluginProvider>(context).notificationsPlugin;
    final themeProvider = Provider.of<ThemeProvider>(context);
    double width = MediaQuery.of(context).size.width;
    final accentColor = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 932 ? (width - 916) / 2 : 16),
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              child: Form(
                key: _formState,
                onWillPop: _onBackPressed,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Theme',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        RadioListTile(
                          value: Brightness.light,
                          groupValue: _theme.brightness,
                          title: const Text('Light'),
                          onChanged: (Brightness value) {
                            setState(() {
                              _theme = ThemeData(brightness: value);
                              // _themeBloc.add(LightThemeEvent());
                              themeProvider.lightTheme();
                              prefs.setBool('darkMode', false);
                            });
                          },
                        ),
                        RadioListTile(
                          value: Brightness.dark,
                          groupValue: _theme.brightness,
                          title: const Text('Dark'),
                          onChanged: (Brightness value) {
                            setState(() {
                              _theme = ThemeData(brightness: value);
                              // _themeBloc.add(DarkThemeEvent());
                              themeProvider.darkTheme();
                              prefs.setBool('darkMode', true);
                            });
                          },
                        ),
                      ],
                    ),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Home Screen Cards',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SwitchListTile(
                      title: const Text('PERSTAT'),
                      onChanged: (value) {
                        setState(() {
                          perstat = value;
                        });
                      },
                      value: perstat,
                    ),
                    SwitchListTile(
                      title: const Text('Appointments'),
                      onChanged: (value) {
                        setState(() {
                          apts = value;
                        });
                      },
                      value: apts,
                    ),
                    SwitchListTile(
                      title: const Text('APFT Stats'),
                      onChanged: (value) {
                        setState(() {
                          apft = value;
                        });
                      },
                      value: apft,
                    ),
                    SwitchListTile(
                      title: const Text('ACFT Stats'),
                      onChanged: (value) {
                        setState(() {
                          acft = value;
                        });
                      },
                      value: acft,
                    ),
                    SwitchListTile(
                      title: const Text('Profiles'),
                      onChanged: (value) {
                        setState(() {
                          profiles = value;
                        });
                      },
                      value: profiles,
                    ),
                    SwitchListTile(
                      title: const Text('Body Composition Stats'),
                      onChanged: (value) {
                        setState(() {
                          bf = value;
                        });
                      },
                      value: bf,
                    ),
                    SwitchListTile(
                      title: const Text('Weapon Stats'),
                      onChanged: (value) {
                        setState(() {
                          weapons = value;
                        });
                      },
                      value: weapons,
                    ),
                    SwitchListTile(
                      title: const Text('Flags'),
                      onChanged: (value) {
                        setState(() {
                          flags = value;
                        });
                      },
                      value: flags,
                    ),
                    SwitchListTile(
                      title: const Text('MedPros'),
                      onChanged: (value) {
                        setState(() {
                          medpros = value;
                        });
                      },
                      value: medpros,
                    ),
                    SwitchListTile(
                      title: const Text('Training'),
                      onChanged: (value) {
                        setState(() {
                          training = value;
                        });
                      },
                      value: training,
                    ),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Notifications',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SwitchListTile(
                      title: const Text('Receive Notifications'),
                      onChanged: (value) {
                        setState(() {
                          addNotification = value;
                        });
                      },
                      value: addNotification,
                    ),
                    const Text(
                      'APFT/ACFT',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: acftController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.acft);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: acftNotifications == null
                            ? 0
                            : acftNotifications.length,
                        itemBuilder: (context, index) {
                          acftNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${acftNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Body Composition',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: bfController,
                      enabled: true,
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
                        const Text('Notificatons'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(context, null, Notification.bf);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: bfNotifications == null
                            ? 0
                            : bfNotifications.length,
                        itemBuilder: (context, index) {
                          bfNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${bfNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Weapons Qualification',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: weaponsController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.weapon);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: weaponNotifications == null
                            ? 0
                            : weaponNotifications.length,
                        itemBuilder: (context, index) {
                          weaponNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${weaponNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'PHA',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: phaController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.pha);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: phaNotifications == null
                            ? 0
                            : phaNotifications.length,
                        itemBuilder: (context, index) {
                          phaNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${phaNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Dental',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: dentalController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.dental);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: dentalNotifications == null
                            ? 0
                            : dentalNotifications.length,
                        itemBuilder: (context, index) {
                          dentalNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${dentalNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Vision',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: visionController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.vision);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: visionNotifications == null
                            ? 0
                            : visionNotifications.length,
                        itemBuilder: (context, index) {
                          visionNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${visionNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'Hearing',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: hearingController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.hearing);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: hearingNotifications == null
                            ? 0
                            : hearingNotifications.length,
                        itemBuilder: (context, index) {
                          hearingNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${hearingNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    Divider(
                      color: accentColor,
                    ),
                    const Text(
                      'HIV',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: hivController,
                      enabled: true,
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
                        const Text('Notifications'),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _editNotification(
                                  context, null, Notification.hiv);
                            })
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: hivNotifications == null
                            ? 0
                            : hivNotifications.length,
                        itemBuilder: (context, index) {
                          hivNotifications.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${hivNotifications[index].toString()} Days Before'),
                              trailing: IconButton(
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
                          );
                        }),
                    ElevatedButton(
                        child: const Text('Save'),
                        onPressed: () {
                          if (_formState.currentState.validate()) {
                            submit();
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  'Form is invalid, text fields must not be blank'),
                            ));
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
