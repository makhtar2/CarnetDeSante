class Medication {
  const Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  final String name;
  final String dosage;
  final String frequency; // e.g., "Matin et Soir"
  final String duration; // e.g., "10 jours"

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}

class Prescription {
  const Prescription({
    required this.id,
    required this.title,
    required this.date,
    required this.medications,
    this.photoBase64,
  });

  final String id;
  final String title;
  final DateTime date;
  final List<Medication> medications;
  final String?
  photoBase64; // Simulation d'une photo d'ordonnance stockée localement

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      medications: (json['medications'] as List<dynamic>? ?? [])
          .map((item) => Medication.fromJson(item as Map<String, dynamic>))
          .toList(),
      photoBase64: json['photoBase64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'medications': medications.map((item) => item.toJson()).toList(),
      'photoBase64': photoBase64,
    };
  }
}
