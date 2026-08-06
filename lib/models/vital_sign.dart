class VitalSign {
  const VitalSign({
    required this.id,
    required this.dateTime,
    required this.weight,
    required this.systolic,
    required this.diastolic,
    required this.glycemia,
  });

  final String id;
  final DateTime dateTime;
  final double weight;
  final int systolic; // Tension Systolique (ex: 120)
  final int diastolic; // Tension Diastolique (ex: 80)
  final double glycemia; // Glycémie (ex: 0.95)

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      id: json['id'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      weight: (json['weight'] as num).toDouble(),
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      glycemia: (json['glycemia'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'weight': weight,
      'systolic': systolic,
      'diastolic': diastolic,
      'glycemia': glycemia,
    };
  }
}
