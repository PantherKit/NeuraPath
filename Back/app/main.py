import os
import json
import mysql.connector
from flask import Flask, request, jsonify

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(
        user="root",
        password="",
        database="pantherkit-db",
        unix_socket="/cloudsql/pantherkit:us-central1:pantherkit-sql-instance"
    )

@app.route("/guardar_resultado", methods=["POST"])
def guardar_resultado():
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Crear la tabla si no existe
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS resultados (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_id VARCHAR(255) NOT NULL,
            respuestas JSON NOT NULL,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        cursor.execute(create_table_sql)
        
        # Insertar datos
        data = request.get_json()
        sql = "INSERT INTO resultados (usuario_id, respuestas) VALUES (%s, %s)"
        cursor.execute(sql, (data["usuario_id"], json.dumps(data["respuestas"])))
        conn.commit()
        
        cursor.close()
        return jsonify({"status": "ok", "message": "Datos guardados correctamente"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    finally:
        if conn and conn.is_connected():
            conn.close()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
