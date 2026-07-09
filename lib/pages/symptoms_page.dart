import 'package:flutter/material.dart';
import '../models/symptom.dart';
import '../services/sync_service.dart';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({
    super.key,
    required this.symptoms,
    required this.onSymptomAdded,
    required this.onSyncCompleted,
    required this.onSymptomDeleted,
    required this.isOffline,
  });

  final List<SymptomLog> symptoms;
  final Function(SymptomLog) onSymptomAdded;
  final Function(List<SymptomLog>) onSyncCompleted;
  final Function(String) onSymptomDeleted;
  final bool isOffline;

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  final _syncService = SyncService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  int _selectedIntensity = 3;
  bool _isSyncing = false;

  final List<String> _commonSymptoms = [
    'Fièvre / Température',
    'Frissons / suspicion paludisme',
    'Maux de tête',
    'Toux sèche',
    'Difficultés respiratoires',
    'Diarrhée / déshydratation',
    'Douleurs musculaires / Courbatures',
    'Fatigue intense',
    'Nausées / Vomissements',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addLog() {
    if (_formKey.currentState!.validate()) {
      final log = SymptomLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        name: _nameController.text.trim(),
        intensity: _selectedIntensity,
        notes: _notesController.text.trim(),
        synced:
            !widget.isOffline, // Si connecté, direct synchronisé, sinon faux
      );

      widget.onSymptomAdded(log);

      setState(() {
        _nameController.clear();
        _notesController.clear();
        _selectedIntensity = 3;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isOffline
                ? 'Symptôme enregistré localement en mode hors-ligne.'
                : 'Symptôme enregistré et synchronisé avec le serveur.',
          ),
          backgroundColor: widget.isOffline
              ? Colors.orange
              : const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final updatedList = await _syncService.syncSymptoms(widget.symptoms);
      widget.onSyncCompleted(updatedList);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Synchronisation réussie des données médicales.',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la synchronisation.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _openAddSymptomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F8F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
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
                      'Consigner un Symptôme',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: _addLog,
                      child: const Text(
                        'Valider',
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Choix rapide ou saisie libre
                        _buildLabel('SYMPTÔME RESSENTI *'),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Saisissez le symptôme'
                              : null,
                          decoration: _inputDecoration('Nom du symptôme'),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _commonSymptoms.map((symp) {
                            return ChoiceChip(
                              label: Text(
                                symp,
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _nameController.text == symp,
                              onSelected: (selected) {
                                setSheetState(() {
                                  _nameController.text = selected ? symp : '';
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Intensité
                        _buildLabel('INTENSITÉ DU SYMPTÔME'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            final level = index + 1;
                            final isSelected = _selectedIntensity == level;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  _selectedIntensity = level;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _getIntensityColor(level)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? _getIntensityColor(level)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$level',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Notes complémentaires
                        _buildLabel('OBSERVATIONS COMPLÉMENTAIRES'),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: _inputDecoration(
                            'Détails des symptômes (fièvre à 39°C, maux d\'estomac...)',
                          ),
                        ),
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

  Color _getIntensityColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF10B981); // Vert
      case 2:
        return const Color(0xFF3B82F6); // Bleu
      case 3:
        return const Color(0xFFF59E0B); // Orange
      case 4:
        return const Color(0xFFEF4444); // Rouge
      case 5:
      default:
        return const Color(0xFF881337); // Rose d'alerte critique
    }
  }

  @override
  Widget build(BuildContext context) {
    final unsyncedCount = widget.symptoms.where((s) => !s.synced).length;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Suivi des Symptômes',
          style: TextStyle(
            color: Color(0xFF102A2A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bandeau Hors-ligne si déconnecté
          if (widget.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.withValues(alpha: 0.15),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Mode hors-ligne : Symptômes stockés localement',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Bouton de synchro
          if (!widget.isOffline && unsyncedCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSyncing ? null : _syncData,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync_rounded, size: 18),
                  label: Text(
                    _isSyncing
                        ? 'Synchronisation...'
                        : 'Synchroniser ($unsyncedCount en attente)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          Expanded(
            child: widget.symptoms.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun symptôme consigné.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: widget.symptoms.length,
                    itemBuilder: (context, index) {
                      final log = widget.symptoms[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _getIntensityColor(log.intensity),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          log.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      if (log.synced)
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.cloud_done_rounded,
                                              color: Color(0xFF10B981),
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Sync',
                                              style: TextStyle(
                                                color: Color(0xFF10B981),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.cloud_off_rounded,
                                              color: Colors.orange,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Local',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      IconButton(
                                        tooltip: 'Supprimer',
                                        onPressed: () =>
                                            widget.onSymptomDeleted(log.id),
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.redAccent,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log.notes.isNotEmpty
                                        ? log.notes
                                        : 'Pas de détails fournis',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Saisi le ${log.dateTime.day}/${log.dateTime.month} à ${log.dateTime.hour}:${log.dateTime.minute.toString().padLeft(2, '0')} (Intensité : ${log.intensity}/5)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: FloatingActionButton.extended(
          onPressed: _openAddSymptomSheet,
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add_alert_rounded),
          label: const Text(
            'Consigner',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
