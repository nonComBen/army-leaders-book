import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/methods/custom_alert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../methods/on_back_pressed.dart';
import '../providers/theme_provider.dart';
import '../../models/setting.dart';
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
  int? acftMos,
      bfMos,
      weaponMos,
      phaMos,
      dentalMos,
      visionMos,
      hearingMos,
      hivMos;
  List<dynamic>? acftNotifications,
      bfNotifications,
      weaponNotifications,
      phaNotifications,
      dentalNotifications,
      visionNotifications,
      hearingNotifications,
      hivNotifications;
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
  String? userId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Setting setting;
  ThemeData _theme = ThemeData(brightness: Brightness.light);
  // ThemeBloc _themeBloc;
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
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  void _editNotification(
      BuildContext context, int? index, Notification notification) {
    int number = 10;
    TextEditingController numController =
        TextEditingController(text: number.toString());
    if (index != null) {
      switch (notification) {
        case Notification.acft:
          number = acftNotifications![index];
          break;
        case Notification.bf:
          number = bfNotifications![index];
          break;
        case Notification.weapon:
          number = weaponNotifications![index];
          break;
        case Notification.pha:
          number = phaNotifications![index];
          break;
        case Notification.dental:
          number = dentalNotifications![index];
          break;
        case Notification.vision:
          number = visionNotifications![index];
          break;
        case Notification.hearing:
          number = hearingNotifications![index];
          break;
        case Notification.hiv:
          number = hivNotifications![index];
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
                acftNotifications![index] = number;
                break;
              case Notification.bf:
                bfNotifications![index] = number;
                break;
              case Notification.weapon:
                weaponNotifications![index] = number;
                break;
              case Notification.pha:
                phaNotifications![index] = number;
                break;
              case Notification.dental:
                dentalNotifications![index] = number;
                break;
              case Notification.vision:
                visionNotifications![index] = number;
                break;
              case Notification.hearing:
                hearingNotifications![index] = number;
                break;
              case Notification.hiv:
                hivNotifications![index] = number;
                break;
            }
          });
        } else {
          setState(() {
            switch (notification) {
              case Notification.acft:
                acftNotifications!.add(number);
                break;
              case Notification.bf:
                bfNotifications!.add(number);
                break;
              case Notification.weapon:
                weaponNotifications!.add(number);
                break;
              case Notification.pha:
                phaNotifications!.add(number);
                break;
              case Notification.dental:
                dentalNotifications!.add(number);
                break;
              case Notification.vision:
                visionNotifications!.add(number);
                break;
              case Notification.hearing:
                hearingNotifications!.add(number);
                break;
              case Notification.hiv:
                hivNotifications!.add(number);
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
      acftMonths: acftMos!,
      bfMonths: bfMos!,
      weaponsMonths: weaponMos!,
      phaMonths: phaMos!,
      dentalMonths: dentalMos!,
      visionMonths: visionMos!,
      hearingMonths: hearingMos!,
      hivMonths: hivMos!,
      acftNotifications: acftNotifications!,
      bfNotifications: bfNotifications!,
      weaponsNotifications: weaponNotifications!,
      phaNotifications: phaNotifications!,
      dentalNotifications: dentalNotifications!,
      visionNotifications: visionNotifications!,
      hearingNotifications: hearingNotifications!,
      hivNotifications: hivNotifications!,
      owner: userId,
    );

    firestore.collection('settings').doc(userId).set(
          saveSetting.toMap(),
          SetOptions(merge: true),
        );

    Navigator.pop(context);
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
    userId = ref.read(authProvider).currentUser()!.uid;
    if (isInitial) {
      initialize();
      isInitial = false;
    }
  }

  void initialize() async {
    QuerySnapshot snapshot = await firestore
        .collection('settings')
        .where('owner', isEqualTo: userId)
        .get();
    DocumentSnapshot? doc;
    if (snapshot.docs.isNotEmpty) {
      doc = snapshot.docs.firstWhere((doc) => doc.id == userId);
    }
    prefs = await SharedPreferences.getInstance();

    setState(() {
      if (doc != null) {
        setting = Setting.fromMap(doc.data() as Map<String, dynamic>);
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

      _theme = Theme.of(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ref.read(themeProvider.notifier);
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
                onWillPop: updated
                    ? () => onBackPressed(context)
                    : () => Future(() => true),
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
                          onChanged: (Brightness? value) {
                            setState(() {
                              _theme = ThemeData(brightness: value);
                              themeService.lightTheme();
                              prefs.setBool('darkMode', false);
                            });
                          },
                        ),
                        RadioListTile(
                          value: Brightness.dark,
                          groupValue: _theme.brightness,
                          title: const Text('Dark'),
                          onChanged: (Brightness? value) {
                            setState(() {
                              _theme = ThemeData(brightness: value);
                              themeService.darkTheme();
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
                          acftMos = int.tryParse(value);
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
                            : acftNotifications!.length,
                        itemBuilder: (context, index) {
                          acftNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${acftNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      acftNotifications!.removeAt(index);
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
                          bfMos = int.tryParse(value);
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
                            : bfNotifications!.length,
                        itemBuilder: (context, index) {
                          bfNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${bfNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      bfNotifications!.removeAt(index);
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
                          weaponMos = int.tryParse(value);
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
                            : weaponNotifications!.length,
                        itemBuilder: (context, index) {
                          weaponNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${weaponNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      weaponNotifications!.removeAt(index);
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
                          phaMos = int.tryParse(value);
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
                            : phaNotifications!.length,
                        itemBuilder: (context, index) {
                          phaNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${phaNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      phaNotifications!.removeAt(index);
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
                          dentalMos = int.tryParse(value);
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
                            : dentalNotifications!.length,
                        itemBuilder: (context, index) {
                          dentalNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${dentalNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      dentalNotifications!.removeAt(index);
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
                          visionMos = int.tryParse(value);
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
                            : visionNotifications!.length,
                        itemBuilder: (context, index) {
                          visionNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${visionNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      visionNotifications!.removeAt(index);
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
                          hearingMos = int.tryParse(value);
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
                            : hearingNotifications!.length,
                        itemBuilder: (context, index) {
                          hearingNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${hearingNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      hearingNotifications!.removeAt(index);
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
                          hivMos = int.tryParse(value);
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
                            : hivNotifications!.length,
                        itemBuilder: (context, index) {
                          hivNotifications!.sort();
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${hivNotifications![index].toString()} Days Before'),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      hivNotifications!.removeAt(index);
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
                          if (_formState.currentState!.validate()) {
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
