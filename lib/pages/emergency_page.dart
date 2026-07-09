import 'package:flutter/material.dart';
import '../models/medical_profile.dart';
import '../widgets/aura_background.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({
    super.key,
    required this.profile,
    this.isOffline = true,
  });

  final MedicalProfile profile;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: const Color(0xFF881337),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Fiche secours',
          style: TextStyle(color: Color(0xFF881337), fontWeight: FontWeight.w900),
        ),
      ),
      body: AuraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
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
                    children: [
                      const Icon(
                        Icons.emergency_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isOffline
                              ? 'Acces hors ligne actif'
                              : 'Informations critiques',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isOffline
                        ? 'Cette fiche reste accessible sans réseau et sans authentification lourde.'
                        : 'À montrer rapidement à un professionnel de santé ou aux secours.',
                    style: const TextStyle(
                      color: Color(0xFFFFDDE4),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PatientHeader(profile: profile),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Repères Sénégal',
              icon: Icons.flag_outlined,
              children: [
                _PlainLine(
                  text: profile.commune.isEmpty
                      ? 'Commune non renseignée'
                      : 'Commune: ${profile.commune}',
                ),
                _PlainLine(
                  text: profile.preferredFacility.isEmpty
                      ? 'Structure habituelle non renseignée'
                      : 'Structure habituelle: ${profile.preferredFacility}',
                ),
                _PlainLine(
                  text: profile.coverage.isEmpty
                      ? 'Couverture santé non renseignée'
                      : 'Couverture: ${profile.coverage}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _SenegalEmergencyNumbers(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CriticalBox(
                    label: 'Groupe sanguin',
                    value: profile.bloodType,
                    color: const Color(0xFF881337),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CriticalBox(
                    label: 'Contacts ICE',
                    value: profile.emergencyContacts.length.toString(),
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Allergies critiques',
              icon: Icons.report_gmailerrorred_outlined,
              children: profile.allergies.isEmpty
                  ? const [_MutedLine('Aucune allergie critique connue')]
                  : profile.allergies
                        .map((item) => _DangerLine(text: item))
                        .toList(),
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: 'Antécédents importants',
              icon: Icons.history_edu_outlined,
              children: profile.medicalHistory.isEmpty
                  ? const [_MutedLine('Aucun antécédent renseigné')]
                  : profile.medicalHistory
                        .map((item) => _PlainLine(text: item))
                        .toList(),
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: 'Contacts à prévenir',
              icon: Icons.contact_phone_outlined,
              children: profile.emergencyContacts.isEmpty
                  ? const [_MutedLine('Aucun contact d urgence configuré')]
                  : profile.emergencyContacts
                        .map((contact) => _EmergencyContactTile(contact))
                        .toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.profile});

  final MedicalProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0D7DE), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_pin_outlined,
              color: Color(0xFF881337),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isNotEmpty
                      ? profile.fullName
                      : 'Patient non renseigné',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF102A2A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.birthDate.isNotEmpty
                      ? 'Né(e) le ${profile.birthDate}'
                      : 'Date de naissance non renseignée',
                  style: const TextStyle(
                    color: Color(0xFF607574),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (profile.phone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    profile.phone,
                    style: const TextStyle(
                      color: Color(0xFF607574),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SenegalEmergencyNumbers extends StatelessWidget {
  const _SenegalEmergencyNumbers();

  @override
  Widget build(BuildContext context) {
    const numbers = [
      ('SAMU', '1515'),
      ('Sapeurs-pompiers', '18'),
      ('Police secours', '17'),
    ];

    return _InfoSection(
      title: 'Numéros utiles',
      icon: Icons.phone_in_talk_outlined,
      children: numbers.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(child: _PlainLine(text: '${item.$1}: ${item.$2}')),
              IconButton.filled(
                tooltip: 'Appeler ${item.$1}',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Appel ${item.$1} : ${item.$2}'),
                      backgroundColor: const Color(0xFF881337),
                    ),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF881337),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.call_rounded),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CriticalBox extends StatelessWidget {
  const _CriticalBox({
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
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF607574),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0D7DE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF881337)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF102A2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DangerLine extends StatelessWidget {
  const _DangerLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Line(
      text: text,
      icon: Icons.priority_high_rounded,
      color: const Color(0xFFBE123C),
      background: const Color(0xFFFFE4E6),
    );
  }
}

class _PlainLine extends StatelessWidget {
  const _PlainLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Line(
      text: text,
      icon: Icons.check_rounded,
      color: const Color(0xFF0F766E),
      background: const Color(0xFFE2F3F1),
    );
  }
}

class _MutedLine extends StatelessWidget {
  const _MutedLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF607574),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.text,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactTile extends StatelessWidget {
  const _EmergencyContactTile(this.contact);

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF102A2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${contact.relation} - ${contact.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF607574),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appel de ${contact.name} : ${contact.phone}'),
                  backgroundColor: const Color(0xFF881337),
                ),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF881337),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.call_rounded),
          ),
        ],
      ),
    );
  }
}
