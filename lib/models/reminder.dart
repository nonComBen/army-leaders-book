class Reminder {
  final int? id;
  final int minutes;
  final String unitOfMeasure;

  Reminder({this.id, this.minutes = 10, this.unitOfMeasure = 'Minutes'});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['minutes'] = minutes;
    map['unitOfMeasure'] = unitOfMeasure;

    return map;
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      minutes: map['minutes'],
      unitOfMeasure: map['unitOfMeasure'],
    );
  }
}
