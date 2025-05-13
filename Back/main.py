# main.py
from flask import Flask, request, jsonify
from google.cloud import storage
import os, tempfile, time

app = Flask(__name__)

# Asegúrate de tener GOOGLE_APPLCATION_CREDENTIALS apuntando a tu JSON de servicio
BUCKET_NAME = "pantherkit"

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

if __name__ == '__main__':
    app.run(debug=True)
