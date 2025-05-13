# test_stem_prediction.py

from flask import Flask, request, jsonify
from google.cloud import storage
import os, tempfile, time, json

app = Flask(__name__)

# Asegúrate de tener GOOGLE_APPLICATION_CREDENTIALS apuntando a tu JSON de servicio
BUCKET_NAME = "pantherkit"

@app.route('/analizar_compatibilidad', methods=['POST'])
def analizar_compatibilidad():
    """
    Recibe un JSON con la forma:
      {
        "respuestas": {
          "ciencia": [v1, v2, …],
          "tecnologia": [v1, v2, …],
          "ingenieria": [v1, v2, …],
          "matematicas": [v1, v2, …]
        }
      }
    y devuelve:
      {
        "compatibilidad": {
          "mecanica_electrica": 78.3,
          "mecatronica":        85.6,
          "robotica":           62.5,
          "desarrollo_software":90.0,
          "electronica":        71.4,
          "computacion":        88.2
        }
      }
    """
    data = request.get_json(silent=True)
    if not data or "respuestas" not in data:
        return jsonify(error="Payload inválido"), 400

    resp = data["respuestas"]

    # 1) Calcular el promedio de cada dimensión STEM
    promedios = {}
    for dim in ("ciencia", "tecnologia", "ingenieria", "matematicas"):
        vals = resp.get(dim, [])
        if not isinstance(vals, list) or len(vals) == 0:
            return jsonify(error=f"Faltan respuestas para '{dim}'"), 400
        promedios[dim] = sum(vals) / len(vals)

    # 2) Definir cómo cada dimensión se mapea a cada carrera
    #    (Cada peso debería sumar 1.0)
    pesos = {
        "mecanica_electrica":   {"ciencia":0.2, "tecnologia":0.3, "ingenieria":0.4, "matematicas":0.1},
        "mecatronica":          {"ciencia":0.1, "tecnologia":0.3, "ingenieria":0.4, "matematicas":0.2},
        "robotica":             {"ciencia":0.2, "tecnologia":0.4, "ingenieria":0.3, "matematicas":0.1},
        "desarrollo_software":  {"ciencia":0.1, "tecnologia":0.5, "ingenieria":0.1, "matematicas":0.3},
        "electronica":          {"ciencia":0.3, "tecnologia":0.3, "ingenieria":0.2, "matematicas":0.2},
        "computacion":          {"ciencia":0.1, "tecnologia":0.4, "ingenieria":0.1, "matematicas":0.4},
    }

    # 3) Calcular score de compatibilidad como media ponderada normalizada a 0–100
    compatibilidad = {}
    for carrera, w in pesos.items():
        score = (
            promedios["ciencia"]      * w["ciencia"]
          + promedios["tecnologia"]   * w["tecnologia"]
          + promedios["ingenieria"]   * w["ingenieria"]
          + promedios["matematicas"]  * w["matematicas"]
        )
        # asumimos que las respuestas van de 1 a 5 → promedio máximo=5
        porcentaje = (score / 5.0) * 100
        compatibilidad[carrera] = round(porcentaje, 1)

    # Preparar el resultado para subir a GCS
    result_data = {"compatibilidad": compatibilidad, "timestamp": time.time()}

    # Guardar resultados en un archivo temporal
    tf = tempfile.NamedTemporaryFile(delete=False, suffix=".json")
    with open(tf.name, 'w') as f:
        json.dump(result_data, f)

    # Subir a Google Cloud Storage
    gcs_url = None
    try:
        client = storage.Client()
        bucket = client.bucket(BUCKET_NAME)
        # path en el bucket: stem-results/<timestamp>.json
        dest_path = f"stem-results/{int(time.time())}.json"
        blob = bucket.blob(dest_path)
        blob.upload_from_filename(tf.name, content_type="application/json")
        gcs_url = blob.public_url
    except Exception as e:
        print(f"Error al subir a GCS: {str(e)}")
    finally:
        os.unlink(tf.name)

    # Añadir URL al resultado si está disponible
    response = {"compatibilidad": compatibilidad}
    if gcs_url:
        response["gcs_url"] = gcs_url

    return jsonify(response), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)  # Permite conexiones externas
