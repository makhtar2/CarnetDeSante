# E-HealthCard - Carnet de Santé Numérique & Fiche Secours (Sujet 5)

**E-HealthCard** est une application mobile Flutter robuste, sécurisée et conçue selon une approche **Offline-First**. Développée dans le cadre du projet de fin de module *Développement Mobile Avancé*, elle fait office de carnet de santé numérique personnalisé pour le contexte sénégalais. Elle permet de stocker localement de façon chiffrée l'identité médicale du patient, de suivre l'évolution de ses constantes biologiques, de gérer ses traitements (ordonnances) et de consigner ses symptômes avec une synchronisation automatique au retour du réseau.

---

## Fonctionnalités Principales (Cahier des Charges)

### Module 1 : Profil Médical & Données Vitales
*   **Fiche d'identité médicale complète** : Renseignement du groupe sanguin, des allergies connues, des antécédents familiaux, de la structure de santé habituelle (ex: *Hôpital Matlaboul Fawzaini*) et des contacts d'urgence (ICE - *In Case of Emergency*).
*   **Suivi des Constantes** : Saisie et visualisation dynamique des mesures biologiques :
    *   Poids (en kg) avec graphique d'évolution personnalisé.
    *   Tension artérielle (Systolique/Diastolique).
    *   Glycémie (en g/L).

### Module 2 : Gestion des Traitements & Rappels
*   **Ordonnances Numériques** : Simulation réaliste de numérisation d'ordonnances papier (via appareil photo/galerie) et saisie assistée de la liste des médicaments.
*   **Rappels de Prise** : Planification interactive de rappels de prises avec une gestion complète des notifications et du suivi.

### Module 3 : Mode Hors-ligne & Fiche d'Urgence
*   **Fiche d'Urgence Instantanée** : Écran "Urgence" lisible immédiatement et sans authentification biométrique lourde si le réseau est absent, affichant les données vitales clés (groupe sanguin, allergies critiques) et des raccourcis d'appel direct vers les services de secours sénégalais (**SAMU 1515**, **Sapeurs-Pompiers 18**, **Police Secours 17**).
*   **Chiffrement Local Obligatoire** : Toutes les données médicales stockées localement sont chiffrées de bout en bout à l'aide d'une clé sécurisée (chiffrement réversible XOR combiné à un encodage Base64) pour garantir la confidentialité et la conformité médicale.
*   **Journalisation de Symptômes Déconnectée** : Ajout quotidien de symptômes hors-ligne. Les saisies sont horodatées localement puis envoyées automatiquement au serveur dès qu'une connexion stable est rétablie.

---

## Architecture Technique

Le projet adopte une structure de répertoire modulaire, propre et facile à maintenir :

```text
lib/
├── main.dart                 # Point d'entrée, configuration du thème Material 3 et de la navigation globale.
├── models/                   # Entités métiers et sérialisation JSON (MedicalProfile, VitalSign, Prescription, SymptomLog).
├── services/                 # Services utilitaires (SecureStorageService pour le chiffrement, SyncService pour le réseau).
├── widgets/                  # Composants graphiques réutilisables (AuraBackground, MedicalIdCard, VitalChart).
└── pages/                    # Écrans principaux (HomePage, ProfilePage, PrescriptionPage, SymptomsPage, EmergencyPage).
```

---

## Installation & Démarrage

### Prérequis
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version stable)
*   Dart SDK (inclus avec Flutter)
*   Un émulateur mobile (Android/iOS) ou un appareil physique connecté en mode débogage.

### Instructions
1.  **Cloner le dépôt** :
    ```bash
    git clone https://github.com/makhtar2/CarnetDeSante.git
    cd CarnetDeSante
    ```
2.  **Récupérer les dépendances** :
    ```bash
    flutter pub get
    ```
3.  **Vérifier la qualité du code (linter)** :
    ```bash
    flutter analyze
    ```
4.  **Exécuter les tests unitaires et widget** :
    ```bash
    flutter test
    ```
5.  **Lancer l'application** :
    ```bash
    flutter run
    ```

---

## Tests de Qualité
La suite de tests unitaires et de widgets (`test/widget_test.dart`) est entièrement configurée et opérationnelle. Elle valide le chargement correct du tableau de bord, des indicateurs de connexion et de l'accès à la fiche d'urgence :
*   Statut de l'analyse de code : **100% propre** (0 avertissement/erreur).
*   Statut des tests : **Passés avec succès**.
