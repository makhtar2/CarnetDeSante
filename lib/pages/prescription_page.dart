import 'package:flutter/material.dart';
import '../models/prescription.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({
    super.key,
    required this.prescriptions,
    required this.onPrescriptionAdded,
    required this.onPrescriptionDeleted,
  });

  final List<Prescription> prescriptions;
  final Function(Prescription) onPrescriptionAdded;
  final Function(String) onPrescriptionDeleted;

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  // Controllers pour les médicaments
  final _medNameController = TextEditingController();
  final _medDosageController = TextEditingController();
  final _medFreqController = TextEditingController();
  final _medDurController = TextEditingController();

  final List<Medication> _medications = [];
  bool _isScanning = false;
  bool _photoCaptured = false;
  bool _enableNotifications = true;

  @override
  void dispose() {
    _titleController.dispose();
    _medNameController.dispose();
    _medDosageController.dispose();
    _medFreqController.dispose();
    _medDurController.dispose();
    super.dispose();
  }

  void _addMedication() {
    final name = _medNameController.text.trim();
    final dosage = _medDosageController.text.trim();
    final freq = _medFreqController.text.trim();
    final dur = _medDurController.text.trim();

    if (name.isNotEmpty && dosage.isNotEmpty) {
      setState(() {
        _medications.add(
          Medication(
            name: name,
            dosage: dosage,
            frequency: freq,
            duration: dur,
          ),
        );
      });
      _medNameController.clear();
      _medDosageController.clear();
      _medFreqController.clear();
      _medDurController.clear();
    }
  }

  void _submitPrescription(VoidCallback rebuildSheet) {
    if (_formKey.currentState!.validate() && _photoCaptured) {
      final prescription = Prescription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        date: DateTime.now(),
        medications: List.from(_medications),
        photoBase64: 'SIMULATED_CAPTURED_IMAGE', // Valeur de simulation
      );

      widget.onPrescriptionAdded(prescription);

      // Déclencher les rappels locaux (simulation)
      if (_enableNotifications && _medications.isNotEmpty) {
        _scheduleSimulatedNotifications();
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _enableNotifications
                ? 'Ordonnance numérisée et rappels configurés.'
                : 'Ordonnance numérisée.',
          ),
          backgroundColor: const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      rebuildSheet();
      if (!_photoCaptured) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Veuillez prendre en photo l\'ordonnance.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _scheduleSimulatedNotifications() {
    // Affiche un toast après un court instant pour simuler un rappel
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(
              Icons.alarm_rounded,
              color: Color(0xFF0F766E),
              size: 36,
            ),
            title: const Text('Rappel de Prise'),
            content: Text(
              'Il est temps de prendre votre traitement :\n\n'
              '${_medications.map((m) => "• ${m.name} (${m.dosage} - ${m.frequency})").join('\n')}',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Marquer comme pris',
                  style: TextStyle(
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  void _openAddPrescriptionSheet() {
    setState(() {
      _titleController.clear();
      _medications.clear();
      _photoCaptured = false;
      _isScanning = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F8F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Numériser une Ordonnance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _submitPrescription(() => setSheetState(() {})),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Form body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre ordonnance
                        _buildLabel('TITRE DE L\'ORDONNANCE *'),
                        TextFormField(
                          controller: _titleController,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Le titre est requis'
                              : null,
                          decoration: _inputDecoration(
                            'Ex: Traitement paludisme / grippe',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Photo Scan section
                        _buildLabel('PHOTO DE L\'ORDONNANCE *'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _isScanning
                              ? null
                              : () async {
                                  setSheetState(() => _isScanning = true);
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );
                                  setSheetState(() {
                                    _isScanning = false;
                                    _photoCaptured = true;
                                    // Auto-fill pour simuler l'extraction OCR
                                    _titleController.text = 'Traitement Grippe Saisonnière';
                                    _medications.clear();
                                    _medications.addAll([
                                      const Medication(
                                        name: 'Paracétamol',
                                        dosage: '1000 mg',
                                        frequency: '1 comprimé toutes les 6 heures',
                                        duration: '5 jours',
                                      ),
                                      const Medication(
                                        name: 'Amoxicilline',
                                        dosage: '500 mg',
                                        frequency: '1 gélule matin et soir',
                                        duration: '7 jours',
                                      ),
                                    ]);
                                  });
                                },
                          child: Container(
                            width: double.infinity,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _photoCaptured
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0F766E).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: _isScanning
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Color(0xFF0F766E),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Numérisation en cours...',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _photoCaptured
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF10B981),
                                          size: 40,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Ordonnance prise en photo avec succès',
                                          style: TextStyle(
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_enhance_rounded,
                                          color: Color(0xFF0F766E),
                                          size: 36,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Prendre en photo l\'ordonnance',
                                          style: TextStyle(
                                            color: Color(0xFF0F766E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Activation Rappels
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    color: Color(0xFF0F766E),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Activer les rappels de prise',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _enableNotifications,
                                activeThumbColor: const Color(0xFF0F766E),
                                activeTrackColor: const Color(0xFF0F766E).withValues(alpha: 0.2),
                                onChanged: (val) {
                                  setSheetState(() {
                                    _enableNotifications = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Section Médicaments
                        _buildLabel('MÉDICAMENTS PRESCRITS'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              _buildSheetTextField(
                                'Nom du médicament',
                                _medNameController,
                                hint: 'Ex: Paracétamol, fer, SRO',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSheetTextField(
                                      'Dosage',
                                      _medDosageController,
                                      hint: 'Ex: 1000 mg',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSheetTextField(
                                      'Durée',
                                      _medDurController,
                                      hint: 'Ex: 5 jours',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildSheetTextField(
                                'Posologie / Fréquence',
                                _medFreqController,
                                hint: 'Ex: 1 comp. matin et soir',
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _addMedication();
                                    setSheetState(() {});
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Ajouter à la liste',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F766E),
                                    side: const BorderSide(
                                      color: Color(0xFF0F766E),
                                      width: 1.5,
                                    ),
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

                        // Liste des médocs ajoutés
                        if (_medications.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Médicaments saisis :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _medications.length,
                            itemBuilder: (context, index) {
                              final med = _medications[index];
                              return Card(
                                elevation: 0,
                                color: const Color(0xFFF8FAFC),
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    med.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${med.dosage} • ${med.frequency} • ${med.duration}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _medications.removeAt(index);
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSheetTextField(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF0F766E).withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Ordonnances & Traitements',
          style: TextStyle(
            color: Color(0xFF102A2A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: widget.prescriptions.isEmpty
          ? const Center(
              child: Text(
                'Aucune ordonnance numérisée.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0),
              itemCount: widget.prescriptions.length,
              itemBuilder: (context, index) {
                final pres = widget.prescriptions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pres.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF102A2A),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${pres.date.day}/${pres.date.month}/${pres.date.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Supprimer',
                                onPressed: () =>
                                    widget.onPrescriptionDeleted(pres.id),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0F766E,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Color(0xFF0F766E),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pres.medications.length} médicaments prescrits',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const Text(
                                'Rappels simulés actifs',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      ...pres.medications.map(
                        (med) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                med.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                '${med.dosage} (${med.frequency})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: FloatingActionButton.extended(
          onPressed: _openAddPrescriptionSheet,
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text(
            'Numériser',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
