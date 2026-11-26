FROM python:3.14-slim-trixie

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Correctifs de sécurité des paquets système, sans rien installer de plus
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Outils Python préinstallés à jour
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN useradd -m appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser main.py .

USER appuser

EXPOSE 4000

# Healthcheck en Python : pas besoin d'installer curl
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:4000/')" || exit 1

CMD ["python", "main.py"]
