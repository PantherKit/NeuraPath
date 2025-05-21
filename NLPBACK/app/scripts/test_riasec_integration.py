#!/usr/bin/env python
"""
Script para probar la integración completa de los datos RIASEC con el modelo de predicción.
"""

import os
import sys
import json
from pathlib import Path

# Añadir directorio raíz a la ruta de Python
project_root = str(Path(__file__).parent.parent.parent)
if project_root not in sys.path:
    sys.path.append(project_root)

from app.utils.riasec_processor import RIASECProcessor
from app.models.minimal_neural import MinimalNeuralCareerModel
from app.services.minimal_service import MinimalRecommendationService
from app.schemas.personality import MBTIResult, MIResult

def test_riasec_integration(sample_size: int = 1000):
    """
    Prueba la integración completa:
    1. Procesamiento de datos RIASEC
    2. Entrenamiento del modelo
    3. Predicción con datos de prueba
    """
    print("\n" + "="*80)
    print(" PRUEBA DE INTEGRACIÓN: Dataset RIASEC con Modelo MinimalNeuralCareerModel ")
    print("="*80)
    
    #
    # 1. Preprocesamiento de los datos RIASEC
    #
    print("\n1. PROCESAMIENTO DE DATOS RIASEC")
    print("-" * 50)
    
    processor = RIASECProcessor()
    print(f"-> Procesando datos RIASEC con muestra de {sample_size} elementos...")
    
    # Cargando datos
    try:
        data = processor.load_data()
        print(f"-> Datos cargados: {len(data)} filas")
        
        # Calcular puntuaciones RIASEC
        data = processor.calculate_riasec_scores(data)
        print("-> Puntuaciones RIASEC calculadas")
        
        # Mapear a MBTI
        data = processor.map_riasec_to_mbti(data)
        print("-> Datos mapeados a vectores MBTI")
        
        # Estimar pesos MBTI
        data = processor.estimate_mbti_weights(data)
        print("-> Pesos MBTI estimados")
        
        # Estimar scores MI 
        data = processor.estimate_mi_scores(data)
        print("-> Puntuaciones de Inteligencias Múltiples estimadas")
        
        # Asignar etiquetas de carrera
        data = processor.assign_career_labels(data)
        print("-> Etiquetas de carrera asignadas")
        
        # Mostrar distribución de carreras
        career_distribution = data['predicted_career'].value_counts()
        print("\n-> Distribución de carreras:")
        for career, count in career_distribution.items():
            print(f"   {career}: {count} ({count/len(data)*100:.1f}%)")
        
        # Preparar datos de entrenamiento
        training_data, career_names = processor.prepare_training_data(sample_size=sample_size)
        print(f"\n-> Datos de entrenamiento preparados: {len(training_data)} muestras")
        print(f"-> Carreras en el conjunto de datos: {career_names}")
        
    except Exception as e:
        print(f"ERROR: {str(e)}")
        return
    
    #
    # 2. Entrenamiento del modelo
    #
    print("\n2. ENTRENAMIENTO DEL MODELO")
    print("-" * 50)
    
    service = MinimalRecommendationService()
    
    try:
        # Entrenar modelo con los datos procesados
        print("-> Entrenando modelo con datos de RIASEC...")
        result = service.train_model(training_data, career_names)
        print(f"-> Resultado: {result['message']}")
        print(f"-> Precisión: {result['accuracy']:.4f}")
    except Exception as e:
        print(f"ERROR en entrenamiento: {str(e)}")
        return
    
    #
    # 3. Predicción con el modelo entrenado
    #
    print("\n3. PRUEBA DE PREDICCIÓN")
    print("-" * 50)
    
    try:
        # Crear algunos perfiles de prueba
        test_profiles = [
            {
                "name": "Perfil INTJ con alta inteligencia lógico-matemática",
                "mbti": MBTIResult(
                    MBTI_code="INTJ",
                    MBTI_vector=[1, 1, 0, 0],
                    MBTI_weights={
                        "E/I": 0.8,  # Fuertemente introvertido
                        "S/N": 0.7,  # Preferencia por intuición
                        "T/F": 0.9,  # Fuertemente pensador
                        "J/P": 0.6   # Moderadamente organizado
                    },
                    ei="I", sn="N", tf="T", jp="J",
                    ei_score=0.8, sn_score=0.7, tf_score=0.9, jp_score=0.6
                ),
                "mi": MIResult(
                    logical_mathematical=0.9,  # Alta inteligencia lógico-matemática
                    spatial=0.7,              # Buena visualización espacial
                    linguistic=0.6,           # Capacidad lingüística media-alta
                    musical=0.4,              # Habilidad musical media-baja
                    bodily_kinesthetic=0.3,   # Baja habilidad kinestésica
                    interpersonal=0.5,        # Habilidad interpersonal media
                    intrapersonal=0.8,        # Alta introspección
                    naturalistic=0.5          # Habilidad naturalista media
                )
            },
            {
                "name": "Perfil ESFJ con alta inteligencia interpersonal",
                "mbti": MBTIResult(
                    MBTI_code="ESFJ",
                    MBTI_vector=[0, 0, 1, 0],
                    MBTI_weights={
                        "E/I": 0.8,  # Fuertemente extrovertido
                        "S/N": 0.7,  # Preferencia por lo concreto
                        "T/F": 0.8,  # Preferencia por sentimiento
                        "J/P": 0.7   # Preferencia por estructura
                    },
                    ei="E", sn="S", tf="F", jp="J",
                    ei_score=0.8, sn_score=0.7, tf_score=0.8, jp_score=0.7
                ),
                "mi": MIResult(
                    logical_mathematical=0.4,  # Inteligencia lógico-matemática media-baja
                    spatial=0.3,              # Baja visualización espacial
                    linguistic=0.7,           # Buena capacidad lingüística
                    musical=0.5,              # Habilidad musical media
                    bodily_kinesthetic=0.6,   # Habilidad kinestésica media-alta
                    interpersonal=0.9,        # Alta habilidad interpersonal
                    intrapersonal=0.7,        # Buena introspección
                    naturalistic=0.4          # Habilidad naturalista media-baja
                )
            },
            {
                "name": "Perfil ENFP con alta inteligencia lingüística y musical",
                "mbti": MBTIResult(
                    MBTI_code="ENFP",
                    MBTI_vector=[0, 1, 1, 1],
                    MBTI_weights={
                        "E/I": 0.6,  # Moderadamente extrovertido
                        "S/N": 0.8,  # Fuerte preferencia por la intuición
                        "T/F": 0.7,  # Preferencia por sentimiento
                        "J/P": 0.8   # Fuerte preferencia por flexibilidad
                    },
                    ei="E", sn="N", tf="F", jp="P",
                    ei_score=0.6, sn_score=0.8, tf_score=0.7, jp_score=0.8
                ),
                "mi": MIResult(
                    logical_mathematical=0.5,  # Inteligencia lógico-matemática media
                    spatial=0.6,              # Visualización espacial media-alta
                    linguistic=0.9,           # Alta capacidad lingüística
                    musical=0.8,              # Alta habilidad musical
                    bodily_kinesthetic=0.7,   # Buena habilidad kinestésica
                    interpersonal=0.8,        # Alta habilidad interpersonal
                    intrapersonal=0.7,        # Buena introspección
                    naturalistic=0.6          # Habilidad naturalista media-alta
                )
            }
        ]
        
        # Realizar predicciones para cada perfil
        for profile in test_profiles:
            print(f"\n-> Probando con {profile['name']}:")
            print(f"   - MBTI: {profile['mbti'].MBTI_code}")
            print(f"   - Inteligencias destacadas: ", end="")
            
            # Mostrar inteligencias destacadas
            mi_scores = {
                "Lingüística": profile['mi'].linguistic,
                "Lógico-Matemática": profile['mi'].logical_mathematical,
                "Espacial": profile['mi'].spatial,
                "Corporal-Kinestésica": profile['mi'].bodily_kinesthetic,
                "Musical": profile['mi'].musical,
                "Interpersonal": profile['mi'].interpersonal,
                "Intrapersonal": profile['mi'].intrapersonal,
                "Naturalista": profile['mi'].naturalistic
            }
            top_mi = sorted(mi_scores.items(), key=lambda x: x[1], reverse=True)[:3]
            print(", ".join([f"{name} ({score:.1f})" for name, score in top_mi]))
            
            # Realizar predicción
            predictions = service.predict(profile['mbti'], profile['mi'])
            
            # Mostrar resultados
            print("\n   Carreras recomendadas:")
            for i, pred in enumerate(predictions[:5]):  # Top 5
                print(f"   {i+1}. {pred['carrera']} - Puntuación: {pred['puntuacion']:.4f}")
    
    except Exception as e:
        print(f"ERROR en predicción: {str(e)}")
        return
    
    print("\n" + "="*80)
    print(" PRUEBA DE INTEGRACIÓN COMPLETADA EXITOSAMENTE ")
    print("="*80 + "\n")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Prueba la integración de RIASEC con el modelo de predicción")
    parser.add_argument("--sample-size", type=int, default=1000, help="Tamaño de la muestra para entrenamiento")
    
    args = parser.parse_args()
    
    test_riasec_integration(sample_size=args.sample_size) 