from flask import Flask, request, jsonify
from google.cloud import storage
import os, tempfile
import time  # Asegúrate de importar el módulo time

app = Flask(__name__)

# Asegúrate de tener GOOGLE_APPLICATION_CREDENTIALS apuntando a tu JSON de servicio
BUCKET_NAME = "pantherkit"

# Definición de personalidades STEM
STEM_PERSONALITIES = {
    "S": "Science (Ciencia)",
    "T": "Technology (Tecnología)",
    "E": "Engineering (Ingeniería)",
    "M": "Mathematics (Matemáticas)"
}

@app.route('/upload_csv', methods=['POST'])
def upload_csv():
    # 1) leemos el CSV del body
    csv_bytes = request.get_data()       # bytes del CSV
    if not csv_bytes:
        return "No CSV received", 400

    # 2) guardamos a un temp file
    tf = tempfile.NamedTemporaryFile(delete=False, suffix=".csv")
    tf.write(csv_bytes)
    tf.flush()
    tf.close()

    # 3) subimos a GCS
    try:
        client = storage.Client()
        bucket = client.bucket(BUCKET_NAME)
        # path en el bucket: quiz-results/<timestamp>.csv
        dest_path = f"quiz-results/{int(time.time())}.csv"
        blob = bucket.blob(dest_path)
        blob.upload_from_filename(tf.name, content_type="text/csv")
        # opcional: URL firmada o pública
        url = blob.public_url
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        os.unlink(tf.name)

    return jsonify({"message":"CSV uploaded", "url": url}), 200

@app.route('/predict_stem_personality', methods=['POST'])
def predict_stem_personality():
    """
    Recibe un JSON con las respuestas del usuario y predice su personalidad STEM.

    Ejemplo de JSON de entrada:
    {
        "respuestas": {
            "ciencia": [3, 4, 5],  # Puntuaciones para preguntas de ciencia (1-5)
            "tecnologia": [4, 5, 3],  # Puntuaciones para preguntas de tecnología
            "ingenieria": [2, 3, 4],  # Puntuaciones para preguntas de ingeniería
            "matematicas": [5, 4, 3]  # Puntuaciones para preguntas de matemáticas
        }
    }
    """
    try:
        # Obtener datos del request
        data = request.get_json()

        if not data or 'respuestas' not in data:
            return jsonify({"error": "Formato de datos inválido. Se requiere un objeto JSON con el campo 'respuestas'."}), 400

        respuestas = data['respuestas']

        # Verificar que todas las categorías STEM estén presentes
        categorias_requeridas = ['ciencia', 'tecnologia', 'ingenieria', 'matematicas']
        for categoria in categorias_requeridas:
            if categoria not in respuestas:
                return jsonify({"error": f"Falta la categoría '{categoria}' en las respuestas."}), 400

        # Calcular puntuación promedio para cada categoría
        promedios = {}
        for categoria in categorias_requeridas:
            if not respuestas[categoria] or not isinstance(respuestas[categoria], list):
                return jsonify({"error": f"La categoría '{categoria}' debe ser una lista de puntuaciones."}), 400

            # Verificar que todas las puntuaciones sean números entre 1 y 5
            for puntuacion in respuestas[categoria]:
                if not isinstance(puntuacion, (int, float)) or puntuacion < 1 or puntuacion > 5:
                    return jsonify({"error": f"Todas las puntuaciones deben ser números entre 1 y 5."}), 400

            promedios[categoria] = sum(respuestas[categoria]) / len(respuestas[categoria])

        # Determinar la personalidad STEM basada en la categoría con mayor puntuación
        categoria_max = max(promedios, key=promedios.get)

        # Mapear la categoría a la personalidad STEM
        stem_map = {
            'ciencia': 'S',
            'tecnologia': 'T',
            'ingenieria': 'E',
            'matematicas': 'M'
        }

        personalidad_stem = stem_map[categoria_max]
        descripcion_stem = STEM_PERSONALITIES[personalidad_stem]

        # Preparar resultados detallados
        resultados = {
            "personalidad_stem": personalidad_stem,
            "descripcion": descripcion_stem,
            "puntuaciones": promedios,
            "detalles": {
                "S": {
                    "nombre": STEM_PERSONALITIES["S"],
                    "puntuacion": promedios['ciencia'],
                    "porcentaje": round(promedios['ciencia'] / 5 * 100, 2)
                },
                "T": {
                    "nombre": STEM_PERSONALITIES["T"],
                    "puntuacion": promedios['tecnologia'],
                    "porcentaje": round(promedios['tecnologia'] / 5 * 100, 2)
                },
                "E": {
                    "nombre": STEM_PERSONALITIES["E"],
                    "puntuacion": promedios['ingenieria'],
                    "porcentaje": round(promedios['ingenieria'] / 5 * 100, 2)
                },
                "M": {
                    "nombre": STEM_PERSONALITIES["M"],
                    "puntuacion": promedios['matematicas'],
                    "porcentaje": round(promedios['matematicas'] / 5 * 100, 2)
                }
            }
        }

        # Suggestions mapping
        degree_map = {
            'ciencia': ['Mecánica eléctrica'],
            'tecnologia': ['Desarrollo de software', 'Computación'],
            'ingenieria': ['Mecatrónica', 'Robótica'],
            'matematicas': ['Electrónica y Computación']
        }
        max_score = max(promedios.values())
        top_categories = [cat for cat, score in promedios.items() if score == max_score]
        suggested_degrees = []
        for cat in top_categories:
            suggested_degrees.extend(degree_map.get(cat, []))
        resultados['carreras'] = suggested_degrees

        return jsonify(resultados), 200

    except Exception as e:
        return jsonify({"error": f"Error al procesar la solicitud: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)  # Permite conexiones externas
