import 'package:flutter/foundation.dart';

class Setting {
  bool perstat;
  bool apts;
  bool apft;
  bool acft;
  bool profiles;
  bool bf;
  bool weapons;
  bool flags;
  bool medpros;
  bool training;
  bool addNotifications;
  int acftMonths;
  int bfMonths;
  int weaponsMonths;
  int phaMonths;
  int dentalMonths;
  int visionMonths;
  int hearingMonths;
  int hivMonths;
  List<dynamic> acftNotifications;
  List<dynamic> bfNotifications;
  List<dynamic> weaponsNotifications;
  List<dynamic> phaNotifications;
  List<dynamic> dentalNotifications;
  List<dynamic> visionNotifications;
  List<dynamic> hearingNotifications;
  List<dynamic> hivNotifications;
  String owner;

  Setting({
    this.perstat = true,
    this.apts = true,
    this.apft = true,
    this.acft = true,
    this.profiles = true,
    this.bf = true,
    this.weapons = true,
    this.flags = false,
    this.medpros = false,
    this.training = false,
    this.addNotifications = true,
    this.acftMonths = 6,
    this.bfMonths = 6,
    this.weaponsMonths = 6,
    this.phaMonths = 12,
    this.dentalMonths = 12,
    this.visionMonths = 12,
    this.hearingMonths = 12,
    this.hivMonths = 24,
    @required this.acftNotifications,
    @required this.bfNotifications,
    @required this.weaponsNotifications,
    @required this.phaNotifications,
    @required this.dentalNotifications,
    @required this.visionNotifications,
    @required this.hearingNotifications,
    @required this.hivNotifications,
    @required this.owner,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['owner'] = owner;
    map['perstat'] = perstat;
    map['apts'] = apts;
    map['apft'] = apft;
    map['acft'] = acft;
    map['profiles'] = profiles;
    map['bf'] = bf;
    map['weapons'] = weapons;
    map['flags'] = flags;
    map['medpros'] = medpros;
    map['training'] = training;
    map['addNotifications'] = addNotifications;
    map['acftMonths'] = acftMonths;
    map['bfMonths'] = bfMonths;
    map['weaponsMonths'] = weaponsMonths;
    map['phaMonths'] = phaMonths;
    map['dentalMonths'] = dentalMonths;
    map['visionMonths'] = visionMonths;
    map['hearingMonths'] = hearingMonths;
    map['hivMonths'] = hivMonths;
    map['acftNotifications'] = acftNotifications;
    map['bfNotifications'] = bfNotifications;
    map['weaponsNotifications'] = weaponsNotifications;
    map['phaNotifications'] = phaNotifications;
    map['dentalNotifications'] = dentalNotifications;
    map['visionNotifications'] = visionNotifications;
    map['hearingNotifications'] = hearingNotifications;
    map['hivNotifications'] = hivNotifications;

    return map;
  }

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
        perstat: map['perstat'],
        apts: map['apts'],
        apft: map['apft'],
        acft: map['acft'],
        profiles: map['profiles'],
        bf: map['bf'],
        weapons: map['weapons'],
        flags: map['flags'],
        medpros: map['medpros'],
        training: map['training'],
        addNotifications: map['addNotification'],
        acftMonths: map['acftMonths'],
        bfMonths: map['bfMonths'],
        weaponsMonths: map['weaponsMonths'],
        phaMonths: map['phaMonths'],
        dentalMonths: map['dentalMonths'],
        visionMonths: map['visionMonths'],
        hearingMonths: map['hearingMonths'],
        hivMonths: map['hivMonths'],
        acftNotifications: map['acftNotifications'],
        bfNotifications: map['bfNotifications'],
        weaponsNotifications: map['weaponsNotifications'],
        phaNotifications: map['phaNotifications'],
        dentalNotifications: map['dentalNotifications'],
        visionNotifications: map['visionNotifications'],
        hearingNotifications: map['hearingNotifications'],
        hivNotifications: map['hivNotifications'],
        owner: map['owner']);
  }
}
