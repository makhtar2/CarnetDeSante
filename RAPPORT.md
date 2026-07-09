# Rapport de Projet Examen - E-HealthCard (Carnet de Santé & Fiche Secours)

Ce document fait office de rapport complet pour la présentation de l'application **E-HealthCard**, développée dans le cadre de l'examen final de développement mobile Flutter.

---

## 📋 1. Présentation Générale du Projet
**E-HealthCard** est une application mobile de carnet de santé numérique et de fiche de secours conçue spécifiquement pour le contexte sénégalais. Elle permet de stocker de façon ultra-sécurisée et locale les données d'identité médicale du patient, de suivre ses constantes biologiques, de gérer ses ordonnances de traitements et de consigner ses symptômes au jour le jour, avec un fonctionnement orienté **Offline-First**.

### Patient de Démo (Mock) :
* **Identité** : Makhtar Wade (Né le 02/08/1995, Groupe sanguin O+)
* **Poids moyen** : 78 kg
* **Commune** : Touba Darou Marnane
* **Structure habituelle** : Hôpital Matlaboul Fawzaini
* **Contact d'urgence (ICE)** : Ibrahima Wade (Frère, +221 77 987 65 43)

---

## 🏗️ 2. Architecture Logicielle
Le projet est structuré de façon modulaire et propre (Clean Architecture) dans le répertoire `lib/` :
* `lib/models/` : Contient les entités métiers (`MedicalProfile`, `VitalSign`, `Prescription`, `SymptomLog`).
* `lib/services/` : Services utilitaires pour le chiffrement local (`SecureStorageService`) et la simulation réseau.
* `lib/widgets/` : Composants graphiques réutilisables (`MedicalIdCard`, `VitalChart` pour le tracé de courbes, `AuraBackground`).
* `lib/pages/` : Écrans principaux de l'application (`HomePage`, `ProfilePage`, `PrescriptionPage`, `SymptomsPage`, `EmergencyPage`).

---

## 🎨 3. Design System & Charte Graphique (Inspiré de Gym-Score)
L'interface utilisateur a été conçue pour offrir un aspect visuel extrêmement premium et moderne :
* **Aura Background** : Stack de gradients colorés (Vert Sarcelle, Vert Menthe, Rose Secours) appliqués en arrière-plan sous un flou gaussien de `80px` (`BackdropFilter`).
* **Glassmorphism (Effet de verre dépoli)** : Conteneurs de cartes semi-transparents blanc (`alpha: 0.5`) avec de fines bordures blanches brillantes (`alpha: 0.4` et `width: 1.5`).
* **Navigation Flottante** : Une barre d'onglets flottante en bas de l'écran avec un rayon de courbure de `40`, intégrant un effet de flou et des boutons actifs en forme de pilules colorées.
* **Composants Pill-shape & Formulaires M3** : Boutons d'actions arrondis à `30px` et champs de texte remplis sans bordures (`BorderRadius.circular(16)`).
* **Zéro chevauchement (Keyboard insets)** : Tous les formulaires modaux s'ajustent dynamiquement via `viewInsets.bottom` pour éviter les conflits avec le clavier virtuel.

---

## ⚙️ 4. Validation des Modules Exigés

### 🔒 Module A : Sécurité & Stockage Chiffré
* Les données médicales sont sensibles. Toutes les écritures locales (`profile_data`, `vitals_data`, `prescriptions_data`, `symptoms_data`) sont chiffrées de façon réversible via un algorithme XOR byte-par-byte combiné à un encodage Base64, évitant le stockage en clair dans le cache de l'appareil.

### 🚑 Module B : Fiche Secours (ICE) & Mode Urgence
* Un onglet et un bouton d'urgence rouge mènent à la **Fiche Secours**, lisible hors-ligne.
* Raccourcis d'appel direct vers les numéros d'urgence sénégalais : **SAMU (1515)**, **Sapeurs-Pompiers (18)**, **Police Secours (17)**.

### 💊 Module C : Numérisation & Suivi des Traitements
* Module de scan d'ordonnance simulé avec pré-remplissage automatique (OCR simulé) de l'ordonnance de grippe (Paracétamol et Amoxicilline) et programmation de rappels de prises.

### 📊 Module D : Journal de Symptômes & Suivi des Constantes
* Consignation de symptômes avec intensité (1 à 5) et synchronisation automatique avec le Cloud dès la détection de réseau.
* Graphique de poids dessiné par un `CustomPainter` pour suivre l'évolution des mesures du patient.

---

## 🛠️ 5. Qualité du Code
* **Lints & Analyse** : 100% conforme. La commande `flutter analyze` retourne **zéro** avertissement ou erreur.
* **Tests unitaires** : La commande `flutter test` s'exécute avec succès et valide le bon rendu de l'application.
