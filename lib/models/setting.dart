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
  String? owner;

  Setting({
    this.perstat = true,
    this.apts = true,
    this.apft = false,
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
    this.acftNotifications = const [0, 30],
    this.bfNotifications = const [0, 30],
    this.weaponsNotifications = const [0, 30],
    this.phaNotifications = const [0, 30],
    this.dentalNotifications = const [0, 30],
    this.visionNotifications = const [0, 30],
    this.hearingNotifications = const [0, 30],
    this.hivNotifications = const [0, 30],
    required this.owner,
  });

  static const String collectionName = 'settings';

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

  factory Setting.fromMap(Map<String, dynamic>? map, String userId) {
    if (map != null) {
      return Setting(
          perstat: map['perstat'] ?? true,
          apts: map['apts'] ?? true,
          apft: map['apft'] ?? true,
          acft: map['acft'] ?? true,
          profiles: map['profiles'] ?? true,
          bf: map['bf'] ?? true,
          weapons: map['weapons'] ?? true,
          flags: map['flags'] ?? false,
          medpros: map['medpros'] ?? false,
          training: map['training'] ?? false,
          addNotifications: map['addNotification'] ?? true,
          acftMonths: map['acftMonths'],
          bfMonths: map['bfMonths'],
          weaponsMonths: map['weaponsMonths'],
          phaMonths: map['phaMonths'],
          dentalMonths: map['dentalMonths'],
          visionMonths: map['visionMonths'],
          hearingMonths: map['hearingMonths'],
          hivMonths: map['hivMonths'],
          acftNotifications: map['acftNotifications'] ?? [],
          bfNotifications: map['bfNotifications'] ?? [],
          weaponsNotifications: map['weaponsNotifications'] ?? [],
          phaNotifications: map['phaNotifications'] ?? [],
          dentalNotifications: map['dentalNotifications'] ?? [],
          visionNotifications: map['visionNotifications'] ?? [],
          hearingNotifications: map['hearingNotifications'] ?? [],
          hivNotifications: map['hivNotifications'] ?? [],
          owner: map['owner']);
    } else {
      return Setting(
        owner: userId,
      );
    }
  }
}
