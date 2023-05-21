class AdditionalTraining {
  final String name;
  final String date;
  AdditionalTraining({required this.name, required this.date});

  Map<String, String> toMap() {
    return {
      'name': name,
      'date': date,
    };
  }

  factory AdditionalTraining.fromMap(Map<String, dynamic> map) {
    return AdditionalTraining(
      name: map['name'].toString(),
      date: map['date'].toString(),
    );
  }
}
