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

# Variables para Cloud Run
ENV PORT=8080
EXPOSE 8080

# Comando para ejecutar la aplicación (Uvicorn)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]