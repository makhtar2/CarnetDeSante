import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  // Clé secrète de chiffrement (simulant une clé issue du Keystore/Keychain)
  static const String _encryptionKey = 'HEALTH_SECRET_KEY_2026';

  // Chiffrement XOR réversible suivi d'un encodage Base64
  static String _encrypt(String input) {
    final List<int> inputBytes = utf8.encode(input);
    final List<int> keyBytes = utf8.encode(_encryptionKey);
    final List<int> encryptedBytes = [];

    for (int i = 0; i < inputBytes.length; i++) {
      encryptedBytes.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encryptedBytes);
  }

  // Déchiffrement Base64 suivi du déchiffrement XOR
  static String _decrypt(String base64Input) {
    final List<int> inputBytes = base64Decode(base64Input);
    final List<int> keyBytes = utf8.encode(_encryptionKey);
    final List<int> decryptedBytes = [];

    for (int i = 0; i < inputBytes.length; i++) {
      decryptedBytes.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decryptedBytes);
  }

  // Sauvegarder des données sensibles sous forme chiffrée
  Future<void> saveEncrypted(String key, String plainText) async {
    final prefs = await SharedPreferences.getInstance();
    final String cipherText = _encrypt(plainText);
    await prefs.setString(key, cipherText);
  }

  // Charger et déchiffrer des données sensibles
  Future<String?> loadDecrypted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cipherText = prefs.getString(key);

    if (cipherText != null && cipherText.isNotEmpty) {
      try {
        return _decrypt(cipherText);
      } catch (e) {
        // En cas d'erreur de décodage, retourne null
        return null;
      }
    }
    return null;
  }
}
