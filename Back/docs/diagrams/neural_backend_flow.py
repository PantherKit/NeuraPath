"""
Diagram del flujo completo del backend neural de NeuraPath.

Requiere instalar la librería `diagrams`:
    pip install diagrams

Genera un PNG en docs/diagrams/neural_backend_flow.png
"""

from diagrams import Cluster, Diagram
from diagrams.onprem.client import Users
from diagrams.programming.framework import FastAPI
from diagrams.programming.language import Python
from diagrams.onprem.compute import Server
from diagrams.generic.compute import Rack
from diagrams.generic.storage import Storage


with Diagram(
    "NeuraPath Neural Backend Flow",
    filename="docs/diagrams/neural_backend_flow",
    show=False,
    outformat="png",
):
    user = Users("Jugador\nResponde tests")

    with Cluster("FastAPI /app/api"):
        questions_api = FastAPI("Questions &\nlegacy endpoints")
        neural_api = FastAPI("/api/neural/\nrecommendations")
        analysis_api = FastAPI("/api/neural/\nrecommendations-with-analysis")
        train_api = FastAPI("/api/neural/train")

    with Cluster("Procesamiento de rasgos"):
        mbti_proc = Python("MBTIProcessor\nMBTI_code + vector + pesos")
        mi_proc = Python("MultipleIntelligenceProcessor\n8 MI normalizadas")
        srlas_proc = Python("SRLAS\nscores (opcional)")
        feature_vector = Rack("Vector 19-D\n[MBTI + MI + SRLAS]")

    with Cluster("Motor Neural"):
        with Cluster("Entrenamiento sintético"):
            synthetic_data = Python("generate_training_data()\nMBTI/MI correlaciones")
            label_encoder = Storage("LabelEncoder.pkl")
        cnn_model = Server("CNN 1D\nConv-BN-Dropout")
        filter_stage = Python("Filtrado + fallback\nCareerRecommender")

    careers_store = Storage("careers.json\nSTEM areas + RIASEC")
    metadata = Storage("Predicciones +\nmatch_score")
    llm_api = Server("LLMApiService\n(OpenAI/Anthropic)")

    user >> questions_api
    questions_api >> mbti_proc
    questions_api >> mi_proc
    questions_api >> srlas_proc

    mbti_proc >> feature_vector
    mi_proc >> feature_vector
    srlas_proc >> feature_vector

    feature_vector >> neural_api
    feature_vector >> cnn_model

    train_api >> synthetic_data >> cnn_model
    synthetic_data >> label_encoder
    label_encoder >> cnn_model

    careers_store >> synthetic_data
    careers_store >> filter_stage

    cnn_model >> filter_stage
    filter_stage >> metadata
    metadata >> neural_api

    neural_api >> analysis_api
    analysis_api >> llm_api
    llm_api >> user
    metadata >> user
