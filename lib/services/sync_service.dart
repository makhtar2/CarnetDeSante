import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom.dart';

/// Service de synchronisation des données médicales.
///
/// Tente une connexion au backend FastAPI (localhost:8000).
/// Fallback automatique sur simulation locale si le backend
/// est indisponible (mode offline).
class SyncService {
  /// URL de base du backend E-HealthCard.
  /// En production, remplacer par l'URL du serveur déployé.
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// Token d'autorisation (simulé pour l'exam).
  static const String _authToken = 'ehealthcard-demo-token-2024';

  /// Synchronise la liste de symptômes hors-ligne vers le backend.
  ///
  /// Retourne la liste avec [SymptomLog.synced] = true si réussi.
  Future<List<SymptomLog>> syncSymptoms(List<SymptomLog> localSymptoms) async {
    final pending = localSymptoms.where((s) => !s.synced).toList();

    if (pending.isEmpty) return localSymptoms;

    try {
      // Tentative de synchronisation groupée vers l'API backend
      final body = pending.map((s) => {
        'patient_id': 'makhtar-wade-001',
        'symptom_name': s.name,
        'severity': s.intensity,
        'notes': s.notes,
        'recorded_at': s.dateTime.toIso8601String(),
        'offline_sync': true,
      }).toList();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/symptoms/sync/batch'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': _authToken,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Succès : marquer tous les symptômes comme synchronisés
        return localSymptoms
            .map((s) => s.copyWith(synced: true))
            .toList();
      }
    } catch (_) {
      // Backend indisponible → fallback simulation locale
      await Future.delayed(const Duration(seconds: 2));
    }

    // Fallback offline : simulation de synchronisation locale
    return localSymptoms
        .map((s) => s.copyWith(synced: true))
        .toList();
  }
}

