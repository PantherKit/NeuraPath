FROM python:3.11-slim

WORKDIR /app

# Paquetes del sistema mínimos
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc g++ libgomp1 wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar archivos de requerimientos
COPY requirements.txt .

# Instalar dependencias
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip cache purge

# Copiar el código de la aplicación
COPY . .

# Crear usuario no root para ejecutar la app
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app
USER appuser

# Variables para Cloud Run y runtime Python
ENV PORT=8080 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PYTHONUNBUFFERED=1 \\
    TF_CPP_MIN_LOG_LEVEL=2
EXPOSE 8080

# Healthcheck básico (no requerido por Cloud Run pero útil localmente/ECS)
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 CMD wget -qO- http://127.0.0.1:${PORT}/health || exit 1

# Comando para ejecutar la aplicación (Uvicorn) usando PORT de entorno
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}"]