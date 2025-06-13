FROM python:3.9-slim

WORKDIR /app

# Instalar dependencias del sistema necesarias para psycopg2 y bibliotecas de ML
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    g++ \
    libgomp1 \
    wget \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copiar archivos de requerimientos
COPY requirements.txt .

# Instalar dependencias - instalación simplificada
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    # Limpiar caché de pip después de instalar
    pip cache purge && \
    # Verificar que TensorFlow se instaló correctamente
    python -c "import tensorflow as tf; print(tf.__version__)"

# Copiar el código de la aplicación
COPY . .

# Exponer el puerto que usa la aplicación
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"] 