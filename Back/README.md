# API de Recomendación de Carreras STEM

API basada en FastAPI para recomendar carreras STEM utilizando procesamiento de personalidad MBTI e Inteligencias Múltiples.

## Características

- Procesamiento de cuestionario MBTI (Myers-Briggs Type Indicator)
- Evaluación de Inteligencias Múltiples (Howard Gardner)
- Recomendaciones de carreras STEM basadas en perfiles personalizados
- Matching semántico con descripciones de carreras reales
- Generación de perfiles personalizados
- Persistencia de datos en PostgreSQL

## Instalación y Ejecución

### Opción 1: Usando Docker Compose (recomendado)

1. Clona este repositorio:
```bash
git clone <repositorio>
cd <directorio>
```

2. Crea el archivo .env:
```bash
python create_env.py
```

3. Inicia los contenedores con Docker Compose:
```bash
docker-compose up -d
```

La API estará disponible en `http://localhost:8000`.

### Opción 2: Entorno local

1. Clona este repositorio:
```bash
git clone <repositorio>
cd <directorio>
```

2. Crea un entorno virtual e instala las dependencias:
```bash
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. Configura y ejecuta PostgreSQL:
   - Instala PostgreSQL si aún no lo tienes
   - Crea una base de datos llamada "stem_careers"
   - Actualiza los datos de conexión en el archivo .env

4. Crea el archivo .env:
```bash
python create_env.py
# Edita el archivo .env con tus datos de conexión a PostgreSQL
```

5. Ejecuta la aplicación:
```bash
uvicorn main:app --reload
```

La API estará disponible en `http://localhost:8000`.

## Base de Datos

La aplicación utiliza PostgreSQL para almacenar:

- Perfiles de usuarios
- Resultados de tests MBTI
- Resultados de evaluaciones de Inteligencias Múltiples
- Información de carreras STEM
- Historial de recomendaciones

El esquema de la base de datos incluye:
- Tabla `users`: Información de usuarios
- Tabla `mbti_profiles`: Perfiles MBTI de los usuarios
- Tabla `mi_profiles`: Perfiles de Inteligencias Múltiples
- Tabla `careers`: Información de carreras STEM
- Tabla `career_matches`: Recomendaciones generadas para los usuarios

## Documentación

La documentación interactiva de la API estará disponible en:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Endpoints principales

### Preguntas
- GET `/api/questions/mbti` - Obtener todas las preguntas MBTI
- GET `/api/questions/multiple-intelligence` - Obtener todas las preguntas de Inteligencias Múltiples
- GET `/api/questions/careers` - Obtener todas las carreras disponibles

### Recomendaciones
- POST `/api/recommendations/mbti` - Procesar respuestas MBTI
- POST `/api/recommendations/multiple-intelligence` - Procesar respuestas de Inteligencias Múltiples
- POST `/api/recommendations/recommendations` - Obtener recomendaciones completas de carreras

## Ejemplo de uso

### Procesar preguntas MBTI

```python
import requests
import json

# Obtener preguntas
response = requests.get("http://localhost:8000/api/questions/mbti")
mbti_questions = response.json()["mbti_questions"]

# Simular respuestas (en una aplicación real, estas vendrían del usuario)
mbti_responses = []
for question in mbti_questions:
    # Simulación: elige aleatoriamente o con alguna lógica
    # En este ejemplo, elegimos la primera opción para cada pregunta
    option = question["options"][0]
    mbti_responses.append({
        "question_id": question["id"],
        "dimension": question["dimension"],
        "user_choice": option["value"],
        "weight": 0.8  # Peso de la respuesta (0.0 a 1.0)
    })

# Enviar respuestas para procesamiento
response = requests.post(
    "http://localhost:8000/api/recommendations/mbti",
    json=mbti_responses
)

mbti_result = response.json()
print(f"Tu tipo MBTI es: {mbti_result['MBTI_code']}")
```

## Estructura del proyecto

```
├── app/
│   ├── api/
│   │   ├── endpoints/
│   │   │   ├── recommendations.py
│   │   │   └── questions.py
│   │   └── api.py
│   ├── core/
│   │   └── config.py
│   ├── data/
│   │   ├── careers.json
│   │   ├── mbti_questions.json
│   │   └── mi_questions.json
│   ├── db/
│   │   ├── crud.py
│   │   ├── init_db.py
│   │   ├── models.py
│   │   └── session.py
│   ├── models/
│   │   ├── mbti_model.py
│   │   ├── mi_model.py
│   │   └── career_model.py
│   ├── schemas/
│   │   └── personality.py
│   └── services/
│       └── recommendation_service.py
├── main.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── create_env.py
└── README.md
```

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue para discutir cambios importantes. 