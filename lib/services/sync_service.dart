import '../models/symptom.dart';

class SyncService {
  // Simule la synchronisation réseau des symptômes avec un serveur médical sécurisé
  Future<List<SymptomLog>> syncSymptoms(List<SymptomLog> localSymptoms) async {
    // Simuler le délai de la requête réseau
    await Future.delayed(const Duration(seconds: 2));

    // Convertit toutes les tâches non synchronisées en tâches synchronisées
    return localSymptoms
        .map((symptom) => symptom.copyWith(synced: true))
        .toList();
  }
}
