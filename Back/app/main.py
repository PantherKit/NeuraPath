from flask import Flask, request, jsonify
import os
import mysql.connector
import json

app = Flask(__name__)

# Conexión a Cloud SQL
db = mysql.connector.connect(
    host=os.environ["DB_HOST"],
    user=os.environ["DB_USER"],
    password=os.environ["DB_PASS"],
    database=os.environ["DB_NAME"]
)

@app.route('/guardar_resultado', methods=['POST'])
def guardar_resultado():
    data = request.get_json()
    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO resultados (usuario_id, respuestas) VALUES (%s, %s)",
        (data["usuario_id"], json.dumps(data["respuestas"]))
    )
    db.commit()
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
