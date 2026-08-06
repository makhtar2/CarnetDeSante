"""
E-HealthCard — Backend API Médicale (FastAPI + Prometheus)
==========================================================
Sujet 5 : Carnet de Santé Numérique et Suivi Médical
Ce backend expose les endpoints de synchronisation médicale
et instrumente les métriques RED via Prometheus.
"""

import time
import random
import base64
from datetime import datetime
from typing import Optional

from fastapi import FastAPI, HTTPException, Request, Header, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    CONTENT_TYPE_LATEST,
    REGISTRY,
)

# ─────────────────────────────────────────────────────────
# Application FastAPI
# ─────────────────────────────────────────────────────────
app = FastAPI(
    title="E-HealthCard API",
    description="Backend sécurisé du Carnet de Santé Numérique — Sujet 5",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────────────────────────────────
# Stockage en mémoire (In-Memory pour l'exam)
# ─────────────────────────────────────────────────────────
db_profiles: dict = {}
db_vitals: list = []
db_symptoms: list = []
db_prescriptions: list = []

# ─────────────────────────────────────────────────────────
# ██████  Métriques Prometheus (Cahier des Charges)
# ─────────────────────────────────────────────────────────

# 1. Histogramme du temps de chiffrement/déchiffrement des payloads médicaux
health_encryption_duration = Histogram(
    "health_api_encryption_duration_seconds",
    "Temps de chiffrement/déchiffrement des payloads médicaux côté API",
    labelnames=["operation", "endpoint"],
    buckets=[0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0],
)

# 2. Compteur de synchronisations de fiches de symptômes
health_symptom_sync_total = Counter(
    "health_symptom_sync_total",
    "Nombre total de synchronisations de fiches de symptômes",
    labelnames=["status"],
)

# 3. Taux de requêtes autorisées vs refusées
health_auth_requests_total = Counter(
    "health_auth_requests_total",
    "Nombre total de tentatives d'accès aux endpoints médicaux sécurisés",
    labelnames=["status", "endpoint"],
)

# 4. Histogramme latence globale des requêtes HTTP
health_http_request_duration = Histogram(
    "health_http_request_duration_seconds",
    "Latence des requêtes HTTP sur l'API médicale",
    labelnames=["method", "endpoint", "status_code"],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.2, 0.5, 1.0, 2.5, 5.0],
)

# 5. Compteur de requêtes HTTP (Rate)
health_http_requests_total = Counter(
    "health_http_requests_total",
    "Nombre total de requêtes HTTP reçues par l'API médicale",
    labelnames=["method", "endpoint", "status_code"],
)

# 6. Compteur d'erreurs lors de l'upload d'ordonnances
health_prescription_upload_errors = Counter(
    "health_prescription_upload_errors_total",
    "Nombre d'erreurs lors du téléversement d'images d'ordonnances",
    labelnames=["error_type"],
)

# 7. Jauge du nombre de patients synchronisés (actifs)
health_synced_patients_gauge = Gauge(
    "health_synced_patients_total",
    "Nombre total de patients ayant synchronisé leurs données médicales",
)

# 8. Compteur de synchro post-déconnexion (offline → online)
health_offline_sync_reconnect_total = Counter(
    "health_offline_sync_reconnect_total",
    "Nombre de synchronisations effectuées au retour de la connexion réseau",
    labelnames=["data_type"],
)

# ─────────────────────────────────────────────────────────
# Middleware — Instrumentation automatique des requêtes
# ─────────────────────────────────────────────────────────
@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start_time = time.time()
    
    # Normaliser le chemin pour les labels Prometheus
    path = request.url.path
    method = request.method

    response = await call_next(request)
    
    duration = time.time() - start_time
    status_code = str(response.status_code)

    # Exclure le endpoint /metrics lui-même
    if path != "/metrics":
        health_http_request_duration.labels(
            method=method,
            endpoint=path,
            status_code=status_code,
        ).observe(duration)

        health_http_requests_total.labels(
            method=method,
            endpoint=path,
            status_code=status_code,
        ).inc()

    return response


# ─────────────────────────────────────────────────────────
# Helpers — Simulation chiffrement médical
# ─────────────────────────────────────────────────────────
def simulate_encryption(data: dict, operation: str, endpoint: str) -> str:
    """
    Simule le chiffrement XOR+Base64 des données médicales
    et instrumente la durée via Prometheus.
    """
    with health_encryption_duration.labels(
        operation=operation, endpoint=endpoint
    ).time():
        # Simulation d'un traitement cryptographique
        raw = str(data).encode("utf-8")
        # Délai simulé selon la taille du payload (réaliste)
        time.sleep(random.uniform(0.002, 0.015))
        encoded = base64.b64encode(raw).decode("utf-8")
    return encoded


def simulate_decryption(encoded: str, endpoint: str) -> str:
    """Simule le déchiffrement et instrumente la durée."""
    with health_encryption_duration.labels(
        operation="decrypt", endpoint=endpoint
    ).time():
        time.sleep(random.uniform(0.001, 0.008))
        decoded = base64.b64decode(encoded.encode("utf-8")).decode("utf-8")
    return decoded


def check_auth_token(authorization: Optional[str], endpoint: str) -> bool:
    """Vérifie un token d'autorisation basique et instrumente le résultat."""
    # Pour l'exam : tout token non-vide est valide
    if authorization and len(authorization) > 5:
        health_auth_requests_total.labels(
            status="authorized", endpoint=endpoint
        ).inc()
        return True
    else:
        health_auth_requests_total.labels(
            status="rejected", endpoint=endpoint
        ).inc()
        return False


# ─────────────────────────────────────────────────────────
# Modèles Pydantic
# ─────────────────────────────────────────────────────────
class ProfileSync(BaseModel):
    patient_id: str
    full_name: str
    blood_type: str
    birth_date: str
    allergies: list[str] = []
    medical_history: list[str] = []
    offline_sync: bool = False


class VitalSign(BaseModel):
    patient_id: str
    measured_at: str
    weight: Optional[float] = None
    systolic: Optional[int] = None
    diastolic: Optional[int] = None
    glycemia: Optional[float] = None
    offline_sync: bool = False


class SymptomLog(BaseModel):
    patient_id: str
    symptom_name: str
    severity: int  # 1-5
    notes: Optional[str] = None
    recorded_at: str
    offline_sync: bool = False  # True = sync post-déconnexion


class PrescriptionUpload(BaseModel):
    patient_id: str
    doctor_name: str
    medications: list[str] = []
    dosage_notes: Optional[str] = None
    issued_at: str


class EmergencyData(BaseModel):
    patient_id: str
    full_name: str
    blood_type: str
    critical_allergies: list[str]
    emergency_contact_name: str
    emergency_contact_phone: str


# ─────────────────────────────────────────────────────────
# Endpoints — Health Check
# ─────────────────────────────────────────────────────────
@app.get("/", tags=["Status"])
async def root():
    return {
        "service": "E-HealthCard API",
        "status": "operational",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat(),
    }


@app.get("/health", tags=["Status"])
async def health_check():
    return {
        "status": "healthy",
        "uptime_seconds": time.process_time(),
        "patients_synced": len(db_profiles),
        "vitals_records": len(db_vitals),
        "symptoms_records": len(db_symptoms),
    }


# ─────────────────────────────────────────────────────────
# Endpoints — Profil Médical
# ─────────────────────────────────────────────────────────
@app.post("/api/profile/sync", tags=["Profil Médical"])
async def sync_profile(
    profile: ProfileSync,
    authorization: Optional[str] = Header(default=None),
):
    """
    Synchronise le profil médical chiffré du patient.
    Instrumente : chiffrement, authentification, synchro offline.
    """
    endpoint = "/api/profile/sync"

    # Vérification autorisation
    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        raise HTTPException(status_code=401, detail="Token d'autorisation manquant ou invalide")

    # Chiffrement du profil médical sensible
    encrypted = simulate_encryption(profile.dict(), "encrypt", endpoint)

    # Stockage en mémoire
    db_profiles[profile.patient_id] = {
        **profile.dict(),
        "synced_at": datetime.utcnow().isoformat(),
        "encrypted_payload": encrypted[:50] + "...",  # Tronqué pour la réponse
    }

    # Instrumentation synchro offline
    if profile.offline_sync:
        health_offline_sync_reconnect_total.labels(data_type="profile").inc()

    # Mise à jour jauge patients
    health_synced_patients_gauge.set(len(db_profiles))

    return {
        "status": "synchronized",
        "patient_id": profile.patient_id,
        "synced_at": datetime.utcnow().isoformat(),
        "encrypted": True,
    }


# ─────────────────────────────────────────────────────────
# Endpoints — Constantes Biologiques (Vitals)
# ─────────────────────────────────────────────────────────
@app.post("/api/vitals/sync", tags=["Constantes Vitales"])
async def sync_vitals(
    vital: VitalSign,
    authorization: Optional[str] = Header(default=None),
):
    """
    Synchronise une mesure de constante biologique.
    Instrumente : chiffrement du payload médical.
    """
    endpoint = "/api/vitals/sync"

    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        raise HTTPException(status_code=401, detail="Non autorisé")

    # Chiffrement de la mesure médicale
    simulate_encryption(vital.dict(), "encrypt", endpoint)

    db_vitals.append({
        **vital.dict(),
        "recorded_server_at": datetime.utcnow().isoformat(),
    })

    if vital.offline_sync:
        health_offline_sync_reconnect_total.labels(data_type="vitals").inc()

    return {
        "status": "recorded",
        "record_id": f"vit_{int(time.time() * 1000)}",
        "patient_id": vital.patient_id,
    }


@app.get("/api/vitals/{patient_id}", tags=["Constantes Vitales"])
async def get_vitals(
    patient_id: str,
    authorization: Optional[str] = Header(default=None),
):
    """Récupère l'historique des constantes d'un patient (avec déchiffrement simulé)."""
    endpoint = "/api/vitals/{patient_id}"

    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        raise HTTPException(status_code=401, detail="Non autorisé")

    patient_vitals = [v for v in db_vitals if v.get("patient_id") == patient_id]
    
    # Simulation déchiffrement lors de la lecture
    for _ in patient_vitals:
        simulate_encryption({}, "decrypt", endpoint)

    return {"patient_id": patient_id, "vitals": patient_vitals}


# ─────────────────────────────────────────────────────────
# Endpoints — Synchronisation des Symptômes (CLÉS)
# ─────────────────────────────────────────────────────────
@app.post("/api/symptoms/sync", tags=["Journal des Symptômes"])
async def sync_symptom(
    symptom: SymptomLog,
    authorization: Optional[str] = Header(default=None),
):
    """
    Synchronise un symptôme consigné hors-ligne.
    Endpoint clé du Module 5 : instrumente health_symptom_sync_total.
    """
    endpoint = "/api/symptoms/sync"

    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        health_symptom_sync_total.labels(status="failed_auth").inc()
        raise HTTPException(status_code=401, detail="Non autorisé")

    try:
        # Chiffrement du log de symptôme
        simulate_encryption(symptom.dict(), "encrypt", endpoint)

        db_symptoms.append({
            **symptom.dict(),
            "server_synced_at": datetime.utcnow().isoformat(),
        })

        # Incrémenter le compteur de synchros réussies
        health_symptom_sync_total.labels(status="success").inc()

        # Marquer comme synchro post-déconnexion
        if symptom.offline_sync:
            health_offline_sync_reconnect_total.labels(data_type="symptoms").inc()

        return {
            "status": "synced",
            "symptom_id": f"sym_{int(time.time() * 1000)}",
            "patient_id": symptom.patient_id,
            "severity": symptom.severity,
            "server_synced_at": datetime.utcnow().isoformat(),
        }

    except Exception as exc:
        health_symptom_sync_total.labels(status="error").inc()
        raise HTTPException(status_code=500, detail=f"Erreur de synchronisation: {str(exc)}") from exc


@app.post("/api/symptoms/sync/batch", tags=["Journal des Symptômes"])
async def sync_symptoms_batch(
    symptoms: list[SymptomLog],
    authorization: Optional[str] = Header(default=None),
):
    """Synchronisation groupée des symptômes (après reconnexion réseau)."""
    endpoint = "/api/symptoms/sync/batch"

    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        raise HTTPException(status_code=401, detail="Non autorisé")

    synced_count = 0
    errors = []

    for symptom in symptoms:
        try:
            simulate_encryption(symptom.dict(), "encrypt", endpoint)
            db_symptoms.append({
                **symptom.dict(),
                "server_synced_at": datetime.utcnow().isoformat(),
            })
            health_symptom_sync_total.labels(status="success").inc()
            if symptom.offline_sync:
                health_offline_sync_reconnect_total.labels(data_type="symptoms_batch").inc()
            synced_count += 1
        except Exception as e:
            health_symptom_sync_total.labels(status="error").inc()
            errors.append(str(e))

    return {
        "synced": synced_count,
        "errors": len(errors),
        "total": len(symptoms),
    }


# ─────────────────────────────────────────────────────────
# Endpoints — Ordonnances (Upload Photo simulé)
# ─────────────────────────────────────────────────────────
@app.post("/api/prescriptions/upload", tags=["Ordonnances"])
async def upload_prescription(
    prescription: PrescriptionUpload,
    authorization: Optional[str] = Header(default=None),
):
    """
    Enregistre une ordonnance numérisée.
    Instrumente les erreurs d'upload selon le cahier des charges.
    """
    endpoint = "/api/prescriptions/upload"

    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        health_prescription_upload_errors.labels(error_type="unauthorized").inc()
        raise HTTPException(status_code=401, detail="Non autorisé")

    try:
        # Validation des médicaments
        if not prescription.medications:
            health_prescription_upload_errors.labels(error_type="empty_medications").inc()
            raise HTTPException(status_code=422, detail="Liste des médicaments vide")

        # Simulation du traitement de l'image
        simulate_encryption(prescription.dict(), "encrypt", endpoint)
        time.sleep(random.uniform(0.05, 0.15))  # Traitement OCR simulé

        db_prescriptions.append({
            **prescription.dict(),
            "prescription_id": f"rx_{int(time.time() * 1000)}",
            "uploaded_at": datetime.utcnow().isoformat(),
        })

        return {
            "status": "uploaded",
            "prescription_id": f"rx_{int(time.time() * 1000)}",
            "medications_count": len(prescription.medications),
        }

    except HTTPException:
        raise
    except Exception as exc:
        health_prescription_upload_errors.labels(error_type="server_error").inc()
        raise HTTPException(status_code=500, detail="Erreur serveur lors de l'upload") from exc


# ─────────────────────────────────────────────────────────
# Endpoints — Fiche d'Urgence (CRITIQUE — latence < 200ms)
# ─────────────────────────────────────────────────────────
@app.get("/api/emergency", tags=["Urgence"])
async def get_emergency_data():
    """
    Endpoint de récupération de la fiche d'urgence ICE.
    CRITIQUE : La latence doit être < 200 ms (alerte Prometheus configurée).
    Aucune authentification requise (accessible en urgence).
    """
    # Données d'urgence statiques (haute disponibilité, pas de DB)
    return {
        "patient": "Makhtar Wade",
        "blood_type": "O+",
        "critical_allergies": ["Aucune"],
        "emergency_contacts": [
            {
                "name": "Ibrahima Wade",
                "relation": "Frère",
                "phone": "+221 77 987 65 43",
            }
        ],
        "emergency_numbers": {
            "SAMU": "1515",
            "Sapeurs-Pompiers": "18",
            "Police Secours": "17",
        },
        "preferred_facility": "Hôpital Matlaboul Fawzaini",
        "last_updated": datetime.utcnow().isoformat(),
    }


@app.post("/api/emergency/update", tags=["Urgence"])
async def update_emergency_data(
    data: EmergencyData,
    authorization: Optional[str] = Header(default=None),
):
    """Mise à jour de la fiche d'urgence (authentification requise)."""
    endpoint = "/api/emergency/update"
    is_authorized = check_auth_token(authorization, endpoint)
    if not is_authorized:
        raise HTTPException(status_code=401, detail="Non autorisé")

    simulate_encryption(data.dict(), "encrypt", endpoint)

    return {
        "status": "updated",
        "patient_id": data.patient_id,
        "updated_at": datetime.utcnow().isoformat(),
    }


# ─────────────────────────────────────────────────────────
# Endpoint — Webhook Alertmanager
# ─────────────────────────────────────────────────────────
@app.post("/api/alerts/webhook", tags=["Observabilité"])
async def alertmanager_webhook(request: Request):
    """
    Webhook récepteur pour les alertes Prometheus via Alertmanager.
    Reçoit les notifications d'alerte et les journalise.
    """
    payload = await request.json()
    alerts = payload.get("alerts", [])
    for alert in alerts:
        status = alert.get("status", "unknown")
        name = alert.get("labels", {}).get("alertname", "UnknownAlert")
        severity = alert.get("labels", {}).get("severity", "unknown")
        print(f"[ALERTE] [{severity.upper()}] {name} — statut: {status}")
    return {"received": len(alerts), "status": "ok"}


# ─────────────────────────────────────────────────────────
# Endpoint — Exposition des métriques Prometheus
# ─────────────────────────────────────────────────────────
@app.get("/metrics", tags=["Observabilité"])
async def metrics():
    """
    Endpoint de scrape Prometheus.
    Expose toutes les métriques instrumentées en format text/plain.
    """
    return Response(
        content=generate_latest(REGISTRY),
        media_type=CONTENT_TYPE_LATEST,
    )


# ─────────────────────────────────────────────────────────
# Point d'entrée
# ─────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
