import 'package:flutter/material.dart';
import '../models/medical_profile.dart';
import '../models/vital_sign.dart';
import '../widgets/medical_id_card.dart';
import '../widgets/vital_chart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.vitals,
    required this.onProfileUpdated,
    required this.onVitalAdded,
    required this.onVitalDeleted,
  });

  final MedicalProfile profile;
  final List<VitalSign> vitals;
  final Function(MedicalProfile) onProfileUpdated;
  final Function(VitalSign) onVitalAdded;
  final Function(String) onVitalDeleted;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers pour la fiche médicale
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _communeController = TextEditingController();
  final _coverageController = TextEditingController();
  final _facilityController = TextEditingController();
  final _allergyController = TextEditingController();
  final _historyController = TextEditingController();

  // Controllers pour contacts d'urgence
  final _contactNameController = TextEditingController();
  final _contactRelationController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Controllers pour constantes
  final _weightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _glycemiaController = TextEditingController();

  String _selectedBloodType = 'O+';
  List<String> _allergies = [];
  List<String> _history = [];
  List<EmergencyContact> _emergencyContacts = [];

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Inconnu',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  void _loadProfileData() {
    _nameController.text = widget.profile.fullName;
    _birthController.text = widget.profile.birthDate;
    _phoneController.text = widget.profile.phone;
    _communeController.text = widget.profile.commune;
    _coverageController.text = widget.profile.coverage;
    _facilityController.text = widget.profile.preferredFacility;
    _selectedBloodType = widget.profile.bloodType;
    _allergies = List.from(widget.profile.allergies);
    _history = List.from(widget.profile.medicalHistory);
    _emergencyContacts = List.from(widget.profile.emergencyContacts);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _communeController.dispose();
    _coverageController.dispose();
    _facilityController.dispose();
    _allergyController.dispose();
    _historyController.dispose();
    _contactNameController.dispose();
    _contactRelationController.dispose();
    _contactPhoneController.dispose();
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _glycemiaController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedProfile = MedicalProfile(
      fullName: _nameController.text.trim(),
      birthDate: _birthController.text.trim(),
      bloodType: _selectedBloodType,
      phone: _phoneController.text.trim(),
      commune: _communeController.text.trim(),
      coverage: _coverageController.text.trim(),
      preferredFacility: _facilityController.text.trim(),
      allergies: _allergies,
      medicalHistory: _history,
      emergencyContacts: _emergencyContacts,
    );
    widget.onProfileUpdated(updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fiche médicale chiffrée et enregistrée en local.'),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addEmergencyContact() {
    final name = _contactNameController.text.trim();
    final relation = _contactRelationController.text.trim();
    final phone = _contactPhoneController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty) {
      setState(() {
        _emergencyContacts.add(
          EmergencyContact(name: name, relation: relation, phone: phone),
        );
      });
      _contactNameController.clear();
      _contactRelationController.clear();
      _contactPhoneController.clear();
    }
  }

  void _addVital() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final systolic = int.tryParse(_systolicController.text.trim()) ?? 0;
    final diastolic = int.tryParse(_diastolicController.text.trim()) ?? 0;
    final glycemia = double.tryParse(_glycemiaController.text.trim()) ?? 0.0;

    if (weight > 0 || (systolic > 0 && diastolic > 0) || glycemia > 0) {
      final vital = VitalSign(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        weight: weight,
        systolic: systolic,
        diastolic: diastolic,
        glycemia: glycemia,
      );
      widget.onVitalAdded(vital);

      setState(() {
        _weightController.clear();
        _systolicController.clear();
        _diastolicController.clear();
        _glycemiaController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Constante vitales ajoutées avec succès.'),
          backgroundColor: const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profil Médical',
          style: TextStyle(
            color: Color(0xFF102A2A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0F766E),
          unselectedLabelColor: const Color(0xFF607574),
          indicatorColor: const Color(0xFF0F766E),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Identité Médicale'),
            Tab(text: 'Constantes Vitales'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildIdentityTab(), _buildVitalsTab()],
        ),
      ),
    );
  }

  Widget _buildIdentityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual ID Card
          MedicalIdCard(profile: widget.profile),
          const SizedBox(height: 28),

          // Edit Form Info
          const Text(
            'INFORMATIONS PATIENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputCard(
            child: Column(
              children: [
                _buildTextField(
                  'Nom Complet',
                  _nameController,
                  hint: 'Ex: Makhtar Wade',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Date de Naissance',
                  _birthController,
                  hint: 'Ex: 12/04/1988',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Téléphone',
                  _phoneController,
                  hint: 'Ex: +221 77 123 45 67',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Groupe Sanguin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedBloodType,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedBloodType = value;
                          });
                        }
                      },
                      items: _bloodTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Commune / Quartier',
                  _communeController,
                  hint: 'Ex: Médina, Dakar',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Couverture santé',
                  _coverageController,
                  hint: 'Ex: CMU, IPM, assurance privée',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Structure de santé habituelle',
                  _facilityController,
                  hint: 'Ex: Centre de santé Nabil Choucair',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Allergies & Antécédents
          const Text(
            'ALLERGIES ET ANTÉCÉDENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Ajouter une Allergie',
                        _allergyController,
                        hint: 'Ex: Pénicilline',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF0F766E),
                        size: 28,
                      ),
                      onPressed: () {
                        final val = _allergyController.text.trim();
                        if (val.isNotEmpty) {
                          setState(() {
                            _allergies.add(val);
                          });
                          _allergyController.clear();
                        }
                      },
                    ),
                  ],
                ),
                if (_allergies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allergies.map((allergy) {
                      return Chip(
                        label: Text(
                          allergy,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: const Color(0xFFF43F5E),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          setState(() {
                            _allergies.remove(allergy);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Ajouter un Antécédent',
                        _historyController,
                        hint: 'Ex: Asthme chronique',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF0F766E),
                        size: 28,
                      ),
                      onPressed: () {
                        final val = _historyController.text.trim();
                        if (val.isNotEmpty) {
                          setState(() {
                            _history.add(val);
                          });
                          _historyController.clear();
                        }
                      },
                    ),
                  ],
                ),
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _history.map((hist) {
                      return Chip(
                        label: Text(
                          hist,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: const Color(0xFF0F766E),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          setState(() {
                            _history.remove(hist);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Emergency Contacts ICE
          const Text(
            'CONTACTS D\'URGENCE (ICE)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  'Nom du Contact',
                  _contactNameController,
                  hint: 'Ex: Marie Dupont',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Relation',
                  _contactRelationController,
                  hint: 'Ex: Épouse, Père',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Téléphone',
                  _contactPhoneController,
                  hint: 'Ex: +221 77...',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addEmergencyContact,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter le contact d\'urgence'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                if (_emergencyContacts.isNotEmpty) ...[
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _emergencyContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _emergencyContacts[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          contact.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${contact.relation} • ${contact.phone}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _emergencyContacts.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Enregistrer button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saveProfile,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Enregistrer le Profil Chiffré',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    // Calcul des valeurs de poids pour le graphique
    final List<double> weightValues = widget.vitals
        .where((v) => v.weight > 0)
        .map((v) => v.weight)
        .toList()
        .reversed
        .toList();
    final List<String> weightLabels = widget.vitals
        .where((v) => v.weight > 0)
        .map((v) => '${v.dateTime.day}/${v.dateTime.month}')
        .toList()
        .reversed
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vital Sign Chart
          const Text(
            'ÉVOLUTION DU POIDS (KG)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          VitalChart(values: weightValues, labels: weightLabels),
          const SizedBox(height: 28),

          // Saisie Constantes Form
          const Text(
            'SAISIR DE NOUVELLES CONSTANTES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Poids (kg)',
                        _weightController,
                        hint: 'Ex: 78.5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Glycémie (g/l)',
                        _glycemiaController,
                        hint: 'Ex: 0.98',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Tension Systolique',
                        _systolicController,
                        hint: 'Ex: 120',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Tension Diastolique',
                        _diastolicController,
                        hint: 'Ex: 80',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addVital,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Enregistrer les constantes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Historique des constantes
          const Text(
            'HISTORIQUE DES SAISIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.vitals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Aucune constante enregistrée.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.vitals.length,
              itemBuilder: (context, index) {
                final vital = widget.vitals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesures du ${vital.dateTime.day}/${vital.dateTime.month}/${vital.dateTime.year} à ${vital.dateTime.hour}:${vital.dateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (vital.weight > 0)
                            _buildVitalLabel(
                              'Poids',
                              '${vital.weight} kg',
                              const Color(0xFF0F766E),
                            ),
                          if (vital.systolic > 0)
                            _buildVitalLabel(
                              'Tension',
                              '${vital.systolic}/${vital.diastolic} mmHg',
                              const Color(0xFF0F766E),
                            ),
                          if (vital.glycemia > 0)
                            _buildVitalLabel(
                              'Glycémie',
                              '${vital.glycemia.toStringAsFixed(2)} g/l',
                              const Color(0xFF2563EB),
                            ),
                          IconButton.outlined(
                            tooltip: 'Supprimer la mesure',
                            onPressed: () => widget.onVitalDeleted(vital.id),
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVitalLabel(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF607574),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFF0F766E).withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0F766E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
