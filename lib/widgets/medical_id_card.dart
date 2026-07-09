import 'package:flutter/material.dart';
import '../models/medical_profile.dart';

class MedicalIdCard extends StatelessWidget {
  const MedicalIdCard({super.key, required this.profile});

  final MedicalProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F3F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFF0F766E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identité médicale',
                      style: TextStyle(
                        color: Color(0xFF102A2A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Données locales chiffrées',
                      style: TextStyle(
                        color: Color(0xFF607574),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F3F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Local',
                  style: TextStyle(
                    color: Color(0xFF0F766E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile.fullName.isNotEmpty ? profile.fullName : 'Patient',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF102A2A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.birthDate.isNotEmpty
                ? 'Né(e) le ${profile.birthDate}'
                : 'Date de naissance à compléter',
            style: const TextStyle(
              color: Color(0xFF607574),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (profile.commune.isNotEmpty ||
              profile.preferredFacility.isNotEmpty ||
              profile.coverage.isNotEmpty) ...[
            _LocalInfoLine(
              icon: Icons.location_on_outlined,
              text: profile.commune.isEmpty
                  ? 'Commune non renseignée'
                  : profile.commune,
            ),
            const SizedBox(height: 10),
            _LocalInfoLine(
              icon: Icons.local_hospital_outlined,
              text: profile.preferredFacility.isEmpty
                  ? 'Structure de santé non renseignée'
                  : profile.preferredFacility,
            ),
            const SizedBox(height: 10),
            _LocalInfoLine(
              icon: Icons.verified_user_outlined,
              text: profile.coverage.isEmpty
                  ? 'Couverture santé non renseignée'
                  : profile.coverage,
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(
                child: _CardFact(
                  label: 'Groupe',
                  value: profile.bloodType,
                  color: const Color(0xFF881337),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardFact(
                  label: 'Allergies',
                  value: profile.allergies.isEmpty
                      ? 'Aucune'
                      : profile.allergies.length.toString(),
                  color: const Color(0xFFC2410C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardFact(
                  label: 'ICE',
                  value: profile.emergencyContacts.length.toString(),
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalInfoLine extends StatelessWidget {
  const _LocalInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF607574)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF294342),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardFact extends StatelessWidget {
  const _CardFact({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF607574),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

