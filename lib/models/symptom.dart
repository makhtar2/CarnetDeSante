class SymptomLog {
  const SymptomLog({
    required this.id,
    required this.dateTime,
    required this.name,
    required this.intensity, // de 1 (faible) à 5 (critique)
    required this.notes,
    this.synced =
        false, // Indique si la donnée est synchronisée avec le serveur
  });

  final String id;
  final DateTime dateTime;
  final String name;
  final int intensity;
  final String notes;
  final bool synced;

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      name: json['name'] as String? ?? '',
      intensity: json['intensity'] as int? ?? 1,
      notes: json['notes'] as String? ?? '',
      synced: json['synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'name': name,
      'intensity': intensity,
      'notes': notes,
      'synced': synced,
    };
  }

  SymptomLog copyWith({
    String? id,
    DateTime? dateTime,
    String? name,
    int? intensity,
    String? notes,
    bool? synced,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      name: name ?? this.name,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      synced: synced ?? this.synced,
    );
  }
}
