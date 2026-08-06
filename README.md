# E-HealthCard — Carnet de Santé Numérique & Fiche Secours (Sujet 5)

**E-HealthCard** est une application mobile Flutter sécurisée de carnet de santé numérique, conçue pour le contexte sénégalais selon une approche **Offline-First**, couplée à une infrastructure de monitoring industrielle (**Prometheus + Grafana**).

---

## 🏗️ Architecture Globale

```
┌─────────────────────────────────────────────────────────┐
│  Application Mobile Flutter (Offline-First)              │
│  • Module 1 : Profil Médical & Constantes Vitales        │
│  • Module 2 : Ordonnances & Rappels de Prise             │
│  • Module 3 : Fiche Urgence ICE + Chiffrement Local      │
│  • Module 4 : Persistance & Synchro Post-Déconnexion     │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP (Sync)
┌────────────────────▼────────────────────────────────────┐
│  Backend FastAPI (Python) — backend/main.py              │
│  • POST /api/symptoms/sync/batch                         │
│  • POST /api/vitals/sync                                 │
│  • GET  /api/emergency  (latence cible < 200ms)          │
│  • GET  /metrics  (Prometheus scrape endpoint)           │
└───────┬────────────────────────────────┬────────────────┘
        │                                │
┌───────▼──────────┐          ┌──────────▼──────────────┐
│   Prometheus     │          │   Grafana                │
│   (port 9090)    │◄─scrape─►│   (port 3000)            │
│   + Alertmanager │          │   Dashboard auto-chargé  │
│   (port 9093)    │          │   admin / ehealthcard2024│
└──────────────────┘          └─────────────────────────┘
```

---

## ✅ Fonctionnalités (Cahier des Charges)

### Module 1 : Profil Médical & Données Vitales
- Fiche d'identité médicale (groupe sanguin, allergies, antécédents, contacts ICE)
- Suivi des constantes : poids, tension artérielle, glycémie avec graphiques

### Module 2 : Gestion des Traitements & Rappels
- Ordonnances numériques avec simulation de scan photo
- Rappels de prise configurables

### Module 3 : Mode Hors-ligne & Fiche d'Urgence
- Fiche ICE accessible sans réseau (groupe sanguin, allergies critiques, contacts)
- Chiffrement local XOR+Base64 de toutes les données médicales
- Numéros d'urgence sénégalais : **SAMU 1515**, **Pompiers 18**, **Police 17**

### Module 4 : Persistance Locale
- Stockage chiffré via `SharedPreferences`
- Synchronisation automatique des symptômes au retour réseau

### Module 5 : Observabilité & Monitoring (Prometheus + Grafana)
- Métriques RED : rate, errors, duration sur tous les endpoints
- `health_api_encryption_duration_seconds` : temps de chiffrement médical
- `health_symptom_sync_total` : compteur de synchros de symptômes
- `health_auth_requests_total` : taux accès autorisés/refusés
- `health_offline_sync_reconnect_total` : synchros post-déconnexion
- Alerte Prometheus : latence `/api/emergency` > 200ms

---

## 🚀 Lancement — Application Mobile

### Prérequis
- Flutter SDK (stable) avec Dart SDK inclus
- Émulateur Android/iOS ou appareil physique

```bash
git clone https://github.com/makhtar2/CarnetDeSante.git
cd CarnetDeSante
flutter pub get
flutter run
```

---

## 🐳 Lancement — Infrastructure de Monitoring

### Prérequis
- Docker Desktop ou Docker Engine + Docker Compose v2

### Démarrage de la stack complète

```bash
# Depuis la racine du projet
docker compose up -d --build

# Vérifier que tous les services sont UP
docker compose ps
```

### Accès aux services

| Service | URL | Identifiants |
|---------|-----|--------------|
| **API Backend** | http://localhost:8000 | — |
| **Docs API (Swagger)** | http://localhost:8000/docs | — |
| **Métriques Prometheus** | http://localhost:8000/metrics | — |
| **Prometheus UI** | http://localhost:9090 | — |
| **Grafana Dashboard** | http://localhost:3000 | admin / ehealthcard2024 |
| **Alertmanager** | http://localhost:9093 | — |

### Vérification rapide

```bash
# Tester l'API backend
curl http://localhost:8000/health

# Tester les métriques Prometheus
curl http://localhost:8000/metrics | grep health_

# Tester l'endpoint urgence (latence critique)
curl -w "\nTemps: %{time_total}s\n" http://localhost:8000/api/emergency

# Simuler une synchronisation de symptôme
curl -X POST http://localhost:8000/api/symptoms/sync \
  -H "Content-Type: application/json" \
  -H "Authorization: demo-token" \
  -d '{"patient_id":"p001","symptom_name":"Céphalées","severity":3,"notes":"Légères","recorded_at":"2024-08-05T10:00:00","offline_sync":true}'
```

### Arrêt de la stack

```bash
docker compose down
# Pour supprimer aussi les volumes de données :
docker compose down -v
```

---

## 📊 Dashboard Grafana

Le dashboard **E-HealthCard Monitoring** est chargé automatiquement au démarrage.

**Panneaux inclus :**
1. 📈 Requêtes/sec, Taux d'erreurs 5xx, Latence médiane, Patients synchronisés
2. 📉 Courbe de latence de synchronisation des constantes médicales (p50/p95/p99)
3. 🔄 Synchronisations de symptômes par minute (réussies / erreurs / auth refusée)
4. 🔒 Temps de chiffrement/déchiffrement des payloads médicaux
5. 🚨 Latence API Urgence avec seuil rouge à 200ms
6. 🔐 Jauge du taux d'accès refusés
7. 🖥️ CPU & RAM serveur (via Node Exporter)
8. 📶 Volume de synchros offline → online

---

## 🧪 Tests

```bash
flutter analyze   # 0 avertissement
flutter test      # Tous les tests passent
```

---

## 📁 Structure du Projet

```
taskflow/
├── lib/                        # Code Flutter
│   ├── main.dart               # Point d'entrée & navigation
│   ├── models/                 # Entités métier
│   ├── services/               # SecureStorage + SyncService
│   ├── widgets/                # AuraBackground, MedicalIdCard, VitalChart
│   └── pages/                  # Home, Profile, Prescription, Symptoms, Emergency
├── backend/                    # Backend FastAPI Python
│   ├── main.py                 # API + métriques Prometheus
│   ├── requirements.txt        # Dépendances Python
│   └── Dockerfile              # Image Docker backend
├── monitoring/                 # Infrastructure de monitoring
│   ├── prometheus.yml          # Config scrape Prometheus
│   ├── alert_rules.yml         # Règles d'alerte (latence urgence > 200ms)
│   ├── alertmanager.yml        # Routage des alertes
│   └── grafana/
│       ├── provisioning/       # Auto-config Grafana
│       └── dashboards/
│           └── ehealthcard_dashboard.json  # Dashboard exporté
├── docker-compose.yml          # Stack complète (backend+prometheus+grafana)
└── README.md                   # Ce fichier
```
