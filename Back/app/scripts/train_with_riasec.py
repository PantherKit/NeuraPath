#!/usr/bin/env python
"""
Script para entrenar el modelo MinimalNeuralCareerModel con datos reales del dataset RIASEC.
"""

import os
import sys
import json
import argparse
from pathlib import Path

# Añadir directorio raíz a la ruta de Python
project_root = str(Path(__file__).parent.parent.parent)
if project_root not in sys.path:
    sys.path.append(project_root)

from app.utils.riasec_processor import RIASECProcessor
from app.models.minimal_neural import MinimalNeuralCareerModel

def train_model_with_riasec(sample_size=5000, save_training_data=False, verbose=True):
    """
    Entrena el modelo MinimalNeuralCareerModel usando datos procesados de RIASEC.
    
    Args:
        sample_size: Número de muestras a usar para entrenamiento (None para usar todas)
        save_training_data: Si es True, guarda los datos de entrenamiento en un archivo
        verbose: Si es True, muestra información sobre el progreso
    
    Returns:
        Modelo entrenado
    """
    if verbose:
        print("\n╔═════════════════════════════════════════════════╗")
        print("║ Entrenando modelo con datos reales RIASEC        ║")
        print("╚═════════════════════════════════════════════════╝\n")
        print(f"Usando {sample_size} muestras para entrenamiento." if sample_size else "Usando todas las muestras disponibles.")
        
    # Crear procesador de datos RIASEC
    processor = RIASECProcessor()
    
    # Obtener datos de entrenamiento procesados
    if verbose:
        print("\n1. Procesando datos RIASEC...")
    training_data, career_names = processor.prepare_training_data(sample_size=sample_size)
    
    if verbose:
        print(f"   - Datos procesados: {len(training_data)} muestras")
        print(f"   - Carreras identificadas: {len(career_names)}")
        for i, career in enumerate(career_names):
            print(f"     {i}: {career}")
    
    # Guardar datos de entrenamiento si se solicita
    if save_training_data:
        data_dir = Path(project_root) / "app" / "data" / "training_data"
        os.makedirs(data_dir, exist_ok=True)
        training_file = data_dir / "riasec_training_data.json"
        
        if verbose:
            print(f"\n2. Guardando datos de entrenamiento en {training_file}...")
        
        with open(training_file, 'w') as f:
            json.dump({
                'training_data': training_data,
                'career_names': career_names
            }, f, indent=2)
            
        if verbose:
            print("   - Datos guardados exitosamente.")
    
    # Crear y entrenar el modelo
    if verbose:
        print("\n3. Creando y entrenando el modelo...")
    
    model = MinimalNeuralCareerModel()
    
    # Preparar datos para el formato esperado por el modelo
    X_train = []
    y_train = []
    
    for item in training_data:
        # Crear vector de características
        features = model.prepare_input_features(
            item["mbti_vector"],
            item["mbti_weights"],
            item["mi_scores"]
        )
        X_train.append(features)
        y_train.append(item["career_label"])
    
    # Entrenar modelo
    import numpy as np
    X_train_array = np.vstack(X_train)
    y_train_array = np.array(y_train)
    
    result = model.train_model(X_train_array, y_train_array)
    
    if verbose:
        print(f"   - {result['message']}")
        print(f"   - Precisión en datos de entrenamiento: {result['accuracy']:.2f}")
    
    # Realizar algunas predicciones de ejemplo
    if verbose:
        print("\n4. Probando el modelo con algunos ejemplos aleatorios...")
        
        import random
        
        for _ in range(3):
            # Seleccionar un ejemplo aleatorio
            sample = random.choice(training_data)
            
            # Hacer predicción
            predictions = model.predict_career(
                sample["mbti_vector"],
                sample["mbti_weights"],
                sample["mi_scores"],
                career_names
            )
            
            # Mostrar resultado
            actual_career = career_names[sample["career_label"]]
            predicted_career = predictions[0][0]
            confidence = predictions[0][1]
            
            print(f"\n   Ejemplo:")
            print(f"   - MBTI: {sample['mbti_vector']}")
            print(f"   - Carrera real: {actual_career}")
            print(f"   - Predicción: {predicted_career} (Confianza: {confidence:.2f})")
    
    if verbose:
        print("\n╔═════════════════════════════════════════════════╗")
        print("║ ¡Entrenamiento completado exitosamente!          ║")
        print("╚═════════════════════════════════════════════════╝\n")
    
    return model

if __name__ == "__main__":
    # Configurar argumentos de línea de comandos
    parser = argparse.ArgumentParser(description='Entrenar modelo de recomendación de carreras con datos RIASEC')
    parser.add_argument('--sample-size', type=int, default=5000, help='Número de muestras para entrenamiento (0 para usar todas)')
    parser.add_argument('--save-data', action='store_true', help='Guardar datos de entrenamiento procesados')
    parser.add_argument('--quiet', action='store_true', help='Modo silencioso (no mostrar mensajes)')
    
    args = parser.parse_args()
    
    # Ajustar parámetros
    sample_size = None if args.sample_size == 0 else args.sample_size
    
    # Entrenar modelo
    train_model_with_riasec(
        sample_size=sample_size,
        save_training_data=args.save_data,
        verbose=not args.quiet
    ) 