# main.py (o donde tengas tu app Flask)

from flask import Flask, request, jsonify

app = Flask(__name__)

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

    return jsonify(compatibilidad=compatibilidad), 200


if __name__ == '__main__':
    app.run(debug=True)