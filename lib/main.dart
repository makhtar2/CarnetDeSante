import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/medical_profile.dart';
import 'models/vital_sign.dart';
import 'models/prescription.dart';
import 'models/symptom.dart';
import 'services/secure_storage_service.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/prescription_page.dart';
import 'pages/symptoms_page.dart';
import 'widgets/aura_background.dart';

void main() {
  runApp(const EHealthCardApp());
}

class EHealthCardApp extends StatelessWidget {
  const EHealthCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-HealthCard',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E6F68),
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFF2563EB),
          surface: Colors.white,
          error: const Color(0xFFBE123C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF102A2A),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF102A2A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7FAF9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDCE7E4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDCE7E4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
          ),
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final SecureStorageService _secureStorage = SecureStorageService();

  int _currentIndex = 0;
  bool _isOffline = false;

  // États locaux principaux
  MedicalProfile _profile = MedicalProfile.empty();
  List<VitalSign> _vitals = [];
  List<Prescription> _prescriptions = [];
  List<SymptomLog> _symptoms = [];

  @override
  void initState() {
    super.initState();
    _loadEncryptedData();
  }

  // Charger les données médicales chiffrées en local
  Future<void> _loadEncryptedData() async {
    final profileJson = await _secureStorage.loadDecrypted('profile_data');
    final vitalsJson = await _secureStorage.loadDecrypted('vitals_data');
    final prescriptionsJson = await _secureStorage.loadDecrypted(
      'prescriptions_data',
    );
    final symptomsJson = await _secureStorage.loadDecrypted('symptoms_data');

    setState(() {
      if (profileJson != null) {
        final loaded = MedicalProfile.fromJson(
          jsonDecode(profileJson) as Map<String, dynamic>,
        );
        if (loaded.fullName == 'Aminata Ndiaye' || loaded.fullName == 'Patient' || loaded.commune != 'Touba Darou Marnane' || loaded.preferredFacility != 'Hôpital Matlaboul Fawzaini') {
          _profile = const MedicalProfile(
            fullName: 'Makhtar Wade',
            birthDate: '02/08/1995',
            bloodType: 'O+',
            phone: '+221 77 567 89 01',
            commune: 'Touba Darou Marnane',
            coverage: 'CMU / Professionnel',
            preferredFacility: 'Hôpital Matlaboul Fawzaini',
            allergies: ['Aucune'],
            medicalHistory: ['Paludisme en 2023'],
            emergencyContacts: [
              EmergencyContact(
                name: 'Ibrahima Wade',
                relation: 'Frère',
                phone: '+221 77 987 65 43',
              ),
            ],
          );
          _secureStorage.saveEncrypted('profile_data', jsonEncode(_profile.toJson()));
        } else {
          _profile = loaded;
        }
      } else {
        // Données fictives initiales de démo pour l'examen
        _profile = const MedicalProfile(
          fullName: 'Makhtar Wade',
          birthDate: '02/08/1995',
          bloodType: 'O+',
          phone: '+221 77 567 89 01',
          commune: 'Touba Darou Marnane',
          coverage: 'CMU / Professionnel',
          preferredFacility: 'Hôpital Matlaboul Fawzaini',
          allergies: ['Aucune'],
          medicalHistory: ['Paludisme en 2023'],
          emergencyContacts: [
            EmergencyContact(
              name: 'Ibrahima Wade',
              relation: 'Frère',
              phone: '+221 77 987 65 43',
            ),
          ],
        );
      }

      if (vitalsJson != null) {
        final List<dynamic> decoded = jsonDecode(vitalsJson) as List<dynamic>;
        final loadedVitals = decoded
            .map((item) => VitalSign.fromJson(item as Map<String, dynamic>))
            .toList();
        if (loadedVitals.isNotEmpty && loadedVitals.any((v) => v.weight < 70)) {
          _vitals = [
            VitalSign(
              id: '1',
              dateTime: DateTime.now().subtract(const Duration(days: 4)),
              weight: 79.2,
              systolic: 120,
              diastolic: 80,
              glycemia: 0.95,
            ),
            VitalSign(
              id: '2',
              dateTime: DateTime.now().subtract(const Duration(days: 2)),
              weight: 78.6,
              systolic: 118,
              diastolic: 79,
              glycemia: 0.92,
            ),
            VitalSign(
              id: '3',
              dateTime: DateTime.now(),
              weight: 78.0,
              systolic: 115,
              diastolic: 78,
              glycemia: 0.94,
            ),
          ];
          _secureStorage.saveEncrypted(
            'vitals_data',
            jsonEncode(_vitals.map((v) => v.toJson()).toList()),
          );
        } else {
          _vitals = loadedVitals;
        }
      } else {
        // Valeurs fictives d'examen
        _vitals = [
          VitalSign(
            id: '1',
            dateTime: DateTime.now().subtract(const Duration(days: 4)),
            weight: 79.2,
            systolic: 120,
            diastolic: 80,
            glycemia: 0.95,
          ),
          VitalSign(
            id: '2',
            dateTime: DateTime.now().subtract(const Duration(days: 2)),
            weight: 78.6,
            systolic: 118,
            diastolic: 79,
            glycemia: 0.92,
          ),
          VitalSign(
            id: '3',
            dateTime: DateTime.now(),
            weight: 78.0,
            systolic: 115,
            diastolic: 78,
            glycemia: 0.94,
          ),
        ];
      }

      if (prescriptionsJson != null) {
        final List<dynamic> decoded =
            jsonDecode(prescriptionsJson) as List<dynamic>;
        _prescriptions = decoded
            .map((item) => Prescription.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (symptomsJson != null) {
        final List<dynamic> decoded = jsonDecode(symptomsJson) as List<dynamic>;
        _symptoms = decoded
            .map((item) => SymptomLog.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    });
  }

  // Sauvegarder les données en les chiffrant
  Future<void> _saveProfile(MedicalProfile profile) async {
    setState(() {
      _profile = profile;
    });
    await _secureStorage.saveEncrypted(
      'profile_data',
      jsonEncode(profile.toJson()),
    );
  }

  Future<void> _addVital(VitalSign vital) async {
    setState(() {
      _vitals.insert(0, vital);
    });
    await _secureStorage.saveEncrypted(
      'vitals_data',
      jsonEncode(_vitals.map((v) => v.toJson()).toList()),
    );
  }

  Future<void> _deleteVital(String id) async {
    setState(() {
      _vitals.removeWhere((vital) => vital.id == id);
    });
    await _secureStorage.saveEncrypted(
      'vitals_data',
      jsonEncode(_vitals.map((v) => v.toJson()).toList()),
    );
  }

  Future<void> _addPrescription(Prescription prescription) async {
    setState(() {
      _prescriptions.insert(0, prescription);
    });
    await _secureStorage.saveEncrypted(
      'prescriptions_data',
      jsonEncode(_prescriptions.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> _deletePrescription(String id) async {
    setState(() {
      _prescriptions.removeWhere((prescription) => prescription.id == id);
    });
    await _secureStorage.saveEncrypted(
      'prescriptions_data',
      jsonEncode(_prescriptions.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> _addSymptom(SymptomLog symptom) async {
    setState(() {
      _symptoms.insert(0, symptom);
    });
    await _secureStorage.saveEncrypted(
      'symptoms_data',
      jsonEncode(_symptoms.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> _deleteSymptom(String id) async {
    setState(() {
      _symptoms.removeWhere((symptom) => symptom.id == id);
    });
    await _secureStorage.saveEncrypted(
      'symptoms_data',
      jsonEncode(_symptoms.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> _syncSymptomsCompleted(List<SymptomLog> syncedList) async {
    setState(() {
      _symptoms = syncedList;
    });
    await _secureStorage.saveEncrypted(
      'symptoms_data',
      jsonEncode(_symptoms.map((s) => s.toJson()).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        profile: _profile,
        vitals: _vitals,
        prescriptions: _prescriptions,
        symptoms: _symptoms,
        isOffline: _isOffline,
        onOfflineChanged: (val) {
          setState(() {
            _isOffline = val;
          });
        },
      ),
      ProfilePage(
        profile: _profile,
        vitals: _vitals,
        onProfileUpdated: _saveProfile,
        onVitalAdded: _addVital,
        onVitalDeleted: _deleteVital,
      ),
      PrescriptionPage(
        prescriptions: _prescriptions,
        onPrescriptionAdded: _addPrescription,
        onPrescriptionDeleted: _deletePrescription,
      ),
      SymptomsPage(
        symptoms: _symptoms,
        onSymptomAdded: _addSymptom,
        onSyncCompleted: _syncSymptomsCompleted,
        onSymptomDeleted: _deleteSymptom,
        isOffline: _isOffline,
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AuraBackground(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.space_dashboard_rounded, 'Accueil'),
                    _buildNavItem(1, Icons.badge_rounded, 'Profil'),
                    _buildNavItem(2, Icons.receipt_long_rounded, 'Soins'),
                    _buildNavItem(3, Icons.sick_rounded, 'Journal'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF607574),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
