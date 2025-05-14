# Usar una imagen base oficial de Python
FROM python:3.9-slim

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar todos los archivos del proyecto al contenedor
COPY . /app

# Instalar las dependencias desde el archivo requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Exponer el puerto 8080 para Cloud Run
EXPOSE 8080

# Iniciar la aplicación Flask con gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app.main:app"]
