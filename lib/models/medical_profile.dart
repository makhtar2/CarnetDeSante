class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
  });

  final String name;
  final String relation;
  final String phone;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'relation': relation, 'phone': phone};
  }
}

class MedicalProfile {
  const MedicalProfile({
    required this.fullName,
    required this.birthDate,
    required this.bloodType,
    required this.phone,
    required this.commune,
    required this.coverage,
    required this.preferredFacility,
    required this.allergies,
    required this.medicalHistory,
    required this.emergencyContacts,
  });

  final String fullName;
  final String birthDate;
  final String bloodType;
  final String phone;
  final String commune;
  final String coverage;
  final String preferredFacility;
  final List<String> allergies;
  final List<String> medicalHistory;
  final List<EmergencyContact> emergencyContacts;

  factory MedicalProfile.empty() {
    return const MedicalProfile(
      fullName: '',
      birthDate: '',
      bloodType: 'Inconnu',
      phone: '',
      commune: '',
      coverage: '',
      preferredFacility: '',
      allergies: [],
      medicalHistory: [],
      emergencyContacts: [],
    );
  }

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      fullName: json['fullName'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      bloodType: json['bloodType'] as String? ?? 'Inconnu',
      phone: json['phone'] as String? ?? '',
      commune: json['commune'] as String? ?? '',
      coverage: json['coverage'] as String? ?? '',
      preferredFacility: json['preferredFacility'] as String? ?? '',
      allergies: List<String>.from(json['allergies'] as List<dynamic>? ?? []),
      medicalHistory: List<String>.from(
        json['medicalHistory'] as List<dynamic>? ?? [],
      ),
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>? ?? [])
          .map(
            (item) => EmergencyContact.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'birthDate': birthDate,
      'bloodType': bloodType,
      'phone': phone,
      'commune': commune,
      'coverage': coverage,
      'preferredFacility': preferredFacility,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'emergencyContacts': emergencyContacts
          .map((item) => item.toJson())
          .toList(),
    };
  }

  MedicalProfile copyWith({
    String? fullName,
    String? birthDate,
    String? bloodType,
    String? phone,
    String? commune,
    String? coverage,
    String? preferredFacility,
    List<String>? allergies,
    List<String>? medicalHistory,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return MedicalProfile(
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      commune: commune ?? this.commune,
      coverage: coverage ?? this.coverage,
      preferredFacility: preferredFacility ?? this.preferredFacility,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}
