# ─────────────────────────────────────────
# E-HealthCard — Dockerfile Backend FastAPI
# ─────────────────────────────────────────
FROM python:3.12-slim

# Métadonnées
LABEL maintainer="E-HealthCard Team"
LABEL description="Backend API médicale avec métriques Prometheus"

# Répertoire de travail
WORKDIR /app

# Copier et installer les dépendances en premier (cache Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code source
COPY . .

# Exposer le port de l'API
EXPOSE 8000

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Démarrer avec uvicorn (production)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
