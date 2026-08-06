import 'package:flutter/material.dart';
import '../models/medical_profile.dart';
import '../models/prescription.dart';
import '../models/symptom.dart';
import '../models/vital_sign.dart';
import 'emergency_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.profile,
    required this.vitals,
    required this.prescriptions,
    required this.symptoms,
    required this.isOffline,
    required this.onOfflineChanged,
  });

  final MedicalProfile profile;
  final List<VitalSign> vitals;
  final List<Prescription> prescriptions;
  final List<SymptomLog> symptoms;
  final bool isOffline;
  final ValueChanged<bool> onOfflineChanged;

  @override
  Widget build(BuildContext context) {
    final lastVital = vitals.isNotEmpty ? vitals.first : null;
    final unsyncedSymptoms = symptoms
        .where((symptom) => !symptom.synced)
        .length;
    final displayName = profile.fullName.isNotEmpty
        ? profile.fullName
        : 'Patient non renseigné';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Carnet santé',
                            style: TextStyle(
                              color: Color(0xFF102A2A),
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF607574),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ConnectionBadge(isOffline: isOffline),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _EmergencyPanel(profile: profile, isOffline: isOffline),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _NetworkSwitch(
                  isOffline: isOffline,
                  onChanged: onOfflineChanged,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.bloodtype_outlined,
                        label: 'Sang',
                        value: profile.bloodType,
                        detail: profile.allergies.isEmpty
                            ? 'Allergies: aucune'
                            : '${profile.allergies.length} allergie(s)',
                        color: const Color(0xFFC2410C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.medication_liquid_outlined,
                        label: 'Traitements',
                        value: prescriptions.length.toString(),
                        detail: 'Ordonnances actives',
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.monitor_heart_outlined,
                        label: 'Constantes',
                        value: lastVital == null
                            ? '--'
                            : '${lastVital.systolic}/${lastVital.diastolic}',
                        detail: lastVital == null
                            ? 'Aucune saisie'
                            : '${lastVital.weight.toStringAsFixed(1)} kg',
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.cloud_sync_outlined,
                        label: 'Synchronisation',
                        value: unsyncedSymptoms.toString(),
                        detail: unsyncedSymptoms == 0
                            ? 'Aucun retard'
                            : 'Symptome(s) en local',
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              sliver: SliverToBoxAdapter(
                child: _ClinicalSummary(
                  lastVital: lastVital,
                  profile: profile,
                  symptoms: symptoms,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final color = isOffline ? const Color(0xFFB45309) : const Color(0xFF0F766E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isOffline ? 'Hors ligne' : 'Connecté',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyPanel extends StatelessWidget {
  const _EmergencyPanel({required this.profile, required this.isOffline});

  final MedicalProfile profile;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF881337),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF881337).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emergency_share_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fiche d’urgence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOffline
                          ? 'Disponible sans réseau ni contrôle lourd.'
                          : 'Données critiques prêtes pour les secours.',
                      style: const TextStyle(
                        color: Color(0xFFFFE4E6),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _EmergencyFact(label: 'Groupe', value: profile.bloodType),
              const SizedBox(width: 12),
              Expanded(
                child: _EmergencyFact(
                  label: 'Allergies',
                  value: profile.allergies.isEmpty
                      ? 'Non signalées'
                      : profile.allergies.take(2).join(', '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EmergencyPage(profile: profile, isOffline: isOffline),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Ouvrir la fiche secours'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF881337),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyFact extends StatelessWidget {
  const _EmergencyFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFCCD5),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkSwitch extends StatelessWidget {
  const _NetworkSwitch({required this.isOffline, required this.onChanged});

  final bool isOffline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.router_outlined, color: Color(0xFF0F766E), size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mode réseau indisponible',
              style: TextStyle(
                color: Color(0xFF102A2A),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          Switch(
            value: isOffline,
            activeTrackColor: const Color(0xFF0F766E).withValues(alpha: 0.2),
            activeThumbColor: const Color(0xFF0F766E),
            inactiveTrackColor: const Color(0xFF64748B).withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607574),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF607574),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicalSummary extends StatelessWidget {
  const _ClinicalSummary({
    required this.lastVital,
    required this.profile,
    required this.symptoms,
  });

  final VitalSign? lastVital;
  final MedicalProfile profile;
  final List<SymptomLog> symptoms;

  @override
  Widget build(BuildContext context) {
    final lastSymptom = symptoms.isNotEmpty ? symptoms.first : null;
    final vital = lastVital;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé médical',
            style: TextStyle(
              color: Color(0xFF102A2A),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          _SummaryRow(
            icon: Icons.history_edu_outlined,
            label: 'Antécédents',
            value: profile.medicalHistory.isEmpty
                ? 'Aucun antécédent renseigné'
                : profile.medicalHistory.join(', '),
          ),
          const Divider(height: 24, color: Color(0xFFE4EBEA)),
          _SummaryRow(
            icon: Icons.location_on_outlined,
            label: 'Repères Sénégal',
            value:
                [
                  if (profile.commune.isNotEmpty) profile.commune,
                  if (profile.preferredFacility.isNotEmpty)
                    profile.preferredFacility,
                ].isEmpty
                ? 'Commune et structure de santé à compléter'
                : [
                    if (profile.commune.isNotEmpty) profile.commune,
                    if (profile.preferredFacility.isNotEmpty)
                      profile.preferredFacility,
                  ].join(' - '),
          ),
          const Divider(height: 24, color: Color(0xFFE4EBEA)),
          _SummaryRow(
            icon: Icons.monitor_weight_outlined,
            label: 'Dernière mesure',
            value: vital == null
                ? 'Aucune constante enregistrée'
                : '${vital.weight.toStringAsFixed(1)} kg, tension ${vital.systolic}/${vital.diastolic}',
          ),
          const Divider(height: 24, color: Color(0xFFE4EBEA)),
          _SummaryRow(
            icon: Icons.sick_outlined,
            label: 'Dernier symptôme',
            value: lastSymptom == null
                ? 'Aucun symptôme consigné'
                : '${lastSymptom.name} - intensité ${lastSymptom.intensity}/5',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF607574), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF607574),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF102A2A),
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
