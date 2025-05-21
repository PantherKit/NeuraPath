"""
Utilidad para procesar el dataset RIASEC y prepararlo para su uso con el modelo de predicción de carreras.
"""

import os
import pandas as pd
import numpy as np
from typing import Dict, List, Tuple, Union
from pathlib import Path

class RIASECProcessor:
    """
    Clase para procesar y transformar datos del dataset RIASEC para
    integrarlos con el modelo de predicción de carreras.
    """
    
    def __init__(self, data_path: str = None):
        """
        Inicializa el procesador RIASEC.
        
        Args:
            data_path: Ruta al archivo CSV de datos RIASEC. Si es None,
                      se usará la ruta por defecto en app/data/RIASEC_data12Dec2018/data.csv
        """
        if data_path is None:
            self.data_path = Path(os.path.dirname(os.path.abspath(__file__))) / ".." / "data" / "RIASEC_data12Dec2018" / "data.csv"
        else:
            self.data_path = Path(data_path)
        
        self.data = None  # Se cargará bajo demanda
        self.riasec_columns = {
            'R': [f'R{i}' for i in range(1, 9)],  # R1 a R8
            'I': [f'I{i}' for i in range(1, 9)],  # I1 a I8
            'A': [f'A{i}' for i in range(1, 9)],  # A1 a A8
            'S': [f'S{i}' for i in range(1, 9)],  # S1 a S8
            'E': [f'E{i}' for i in range(1, 9)],  # E1 a E8
            'C': [f'C{i}' for i in range(1, 9)]   # C1 a C8
        }
        self.big5_columns = [f'TIPI{i}' for i in range(1, 11)]  # TIPI1 a TIPI10
        
    def load_data(self) -> pd.DataFrame:
        """
        Carga el dataset RIASEC.
        
        Returns:
            DataFrame con los datos RIASEC cargados.
        """
        if self.data is None:
            print(f"Cargando datos RIASEC desde {self.data_path}...")
            try:
                self.data = pd.read_csv(self.data_path, sep=None, engine='python')  # Auto-detectar separador
                print(f"Datos cargados: {len(self.data)} filas, {len(self.data.columns)} columnas")
            except Exception as e:
                print(f"Error al cargar los datos: {e}")
                raise
        
        return self.data
    
    def calculate_riasec_scores(self, data: pd.DataFrame = None) -> pd.DataFrame:
        """
        Calcula las puntuaciones RIASEC para cada persona.
        
        Args:
            data: DataFrame con los datos RIASEC. Si es None, se usará self.data.
        
        Returns:
            DataFrame con las puntuaciones RIASEC agregadas.
        """
        if data is None:
            data = self.load_data()
        
        # Crear DataFrame para las puntuaciones
        riasec_scores = pd.DataFrame(index=data.index)
        
        # Calcular el promedio para cada dimensión RIASEC
        for dim, cols in self.riasec_columns.items():
            riasec_scores[dim] = data[cols].mean(axis=1)
        
        # Normalizar las puntuaciones (opcional, pero útil para comparar)
        riasec_scores_normalized = riasec_scores.div(riasec_scores.sum(axis=1), axis=0)
        
        # Añadir las puntuaciones al DataFrame original
        result = data.copy()
        for dim in self.riasec_columns.keys():
            result[f'{dim}_score'] = riasec_scores[dim]
            result[f'{dim}_norm'] = riasec_scores_normalized[dim]
        
        return result
    
    def map_riasec_to_mbti(self, riasec_scores: pd.DataFrame) -> pd.DataFrame:
        """
        Mapea las puntuaciones RIASEC a vectores MBTI aproximados.
        
        NOTA: Este mapeo es una aproximación y no está basado en una correspondencia validada científicamente.
        Es un punto de partida para la integración con el modelo.
        
        Args:
            riasec_scores: DataFrame con las puntuaciones RIASEC.
        
        Returns:
            DataFrame con las aproximaciones MBTI añadidas.
        """
        # Copia para no modificar el original
        result = riasec_scores.copy()
        
        # Modelo aproximado de mapeo (basado en correlaciones sugeridas en literatura)
        # E/I: E correlaciona con Social(S) y Emprendedor(E); I con Investigador(I)
        result['mbti_E_I'] = result.apply(
            lambda row: 0 if (row['S_norm'] + row['E_norm']) > row['I_norm'] else 1, 
            axis=1
        )
        
        # S/N: S correlaciona con Realista(R) y Convencional(C); N con Artístico(A) e Investigador(I)
        result['mbti_S_N'] = result.apply(
            lambda row: 0 if (row['R_norm'] + row['C_norm']) > (row['A_norm'] + row['I_norm']) else 1,
            axis=1
        )
        
        # T/F: T correlaciona con Realista(R) e Investigador(I); F con Social(S) y Artístico(A)
        result['mbti_T_F'] = result.apply(
            lambda row: 0 if (row['R_norm'] + row['I_norm']) > (row['S_norm'] + row['A_norm']) else 1,
            axis=1
        )
        
        # J/P: J correlaciona con Convencional(C) y Emprendedor(E); P con Artístico(A)
        result['mbti_J_P'] = result.apply(
            lambda row: 0 if (row['C_norm'] + row['E_norm']) > row['A_norm'] else 1,
            axis=1
        )
        
        # Crear vector MBTI [E/I, S/N, T/F, J/P]
        result['mbti_vector'] = result.apply(
            lambda row: [row['mbti_E_I'], row['mbti_S_N'], row['mbti_T_F'], row['mbti_J_P']],
            axis=1
        )
        
        return result
    
    def estimate_mbti_weights(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Estima los pesos MBTI basados en las diferencias de puntuaciones RIASEC.
        
        Args:
            data: DataFrame con las puntuaciones RIASEC y vectores MBTI.
        
        Returns:
            DataFrame con los pesos MBTI estimados.
        """
        result = data.copy()
        
        # E/I weight: basado en la diferencia normalizada entre (S+E) e I
        result['weight_E_I'] = result.apply(
            lambda row: abs((row['S_norm'] + row['E_norm'] - row['I_norm']) / max(row['S_norm'] + row['E_norm'], row['I_norm'])),
            axis=1
        )
        
        # S/N weight: basado en la diferencia normalizada entre (R+C) y (A+I)
        result['weight_S_N'] = result.apply(
            lambda row: abs((row['R_norm'] + row['C_norm'] - row['A_norm'] - row['I_norm']) / max(row['R_norm'] + row['C_norm'], row['A_norm'] + row['I_norm'])),
            axis=1
        )
        
        # T/F weight: basado en la diferencia normalizada entre (R+I) y (S+A)
        result['weight_T_F'] = result.apply(
            lambda row: abs((row['R_norm'] + row['I_norm'] - row['S_norm'] - row['A_norm']) / max(row['R_norm'] + row['I_norm'], row['S_norm'] + row['A_norm'])),
            axis=1
        )
        
        # J/P weight: basado en la diferencia normalizada entre (C+E) y A
        result['weight_J_P'] = result.apply(
            lambda row: abs((row['C_norm'] + row['E_norm'] - row['A_norm']) / max(row['C_norm'] + row['E_norm'], row['A_norm'])),
            axis=1
        )
        
        # Crear diccionario de pesos MBTI
        result['mbti_weights'] = result.apply(
            lambda row: {
                "E/I": row['weight_E_I'],
                "S/N": row['weight_S_N'],
                "T/F": row['weight_T_F'],
                "J/P": row['weight_J_P']
            },
            axis=1
        )
        
        return result
    
    def estimate_mi_scores(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Estima puntuaciones de Inteligencias Múltiples (MI) basadas en RIASEC y TIPI.
        
        Args:
            data: DataFrame con puntuaciones RIASEC y TIPI.
        
        Returns:
            DataFrame con puntuaciones MI estimadas.
        """
        result = data.copy()
        
        # Mapeamos de forma aproximada:
        # - Lin (Lingüística): A (Artístico) + TIPI5 (Apertura) + TIPI1 (Extraversión)
        # - LogMath (Lógico-Matemática): I (Investigador) + C (Convencional) + TIPI3 (Responsabilidad)
        # - Spa (Espacial): R (Realista) + A (Artístico)
        # - BodKin (Corporal-Kinestésica): R (Realista) + S (Social)
        # - Mus (Musical): A (Artístico) + TIPI5 (Apertura)
        # - Inter (Interpersonal): S (Social) + E (Emprendedor) + TIPI1 (Extraversión) + TIPI7 (Amabilidad)
        # - Intra (Intrapersonal): I (Investigador) + TIPI9 (Estabilidad) + TIPI3 (Responsabilidad)
        # - Nat (Naturalista): I (Investigador) + R (Realista) + TIPI5 (Apertura)
        
        # Primero normalizamos los valores de TIPI en escala 0-1
        for col in self.big5_columns:
            result[f'{col}_norm'] = (result[col] - 1) / 6  # TIPI es de 1 a 7
        
        # Lin (Lingüística)
        result['MI_Lin'] = (
            result['A_norm'] * 0.6 + 
            result['TIPI5_norm'] * 0.3 + 
            result['TIPI1_norm'] * 0.1
        )
        
        # LogMath (Lógico-Matemática)
        result['MI_LogMath'] = (
            result['I_norm'] * 0.6 + 
            result['C_norm'] * 0.3 + 
            result['TIPI3_norm'] * 0.1
        )
        
        # Spa (Espacial)
        result['MI_Spa'] = (
            result['R_norm'] * 0.5 + 
            result['A_norm'] * 0.5
        )
        
        # BodKin (Corporal-Kinestésica)
        result['MI_BodKin'] = (
            result['R_norm'] * 0.6 + 
            result['S_norm'] * 0.4
        )
        
        # Mus (Musical)
        result['MI_Mus'] = (
            result['A_norm'] * 0.8 + 
            result['TIPI5_norm'] * 0.2
        )
        
        # Inter (Interpersonal)
        result['MI_Inter'] = (
            result['S_norm'] * 0.4 + 
            result['E_norm'] * 0.3 + 
            result['TIPI1_norm'] * 0.1 + 
            result['TIPI7_norm'] * 0.2
        )
        
        # Intra (Intrapersonal)
        result['MI_Intra'] = (
            result['I_norm'] * 0.4 + 
            result['TIPI9_norm'] * 0.3 + 
            result['TIPI3_norm'] * 0.3
        )
        
        # Nat (Naturalista)
        result['MI_Nat'] = (
            result['I_norm'] * 0.4 + 
            result['R_norm'] * 0.4 + 
            result['TIPI5_norm'] * 0.2
        )
        
        # Crear diccionario de puntuaciones MI
        result['mi_scores'] = result.apply(
            lambda row: {
                "Lin": row['MI_Lin'],
                "LogMath": row['MI_LogMath'],
                "Spa": row['MI_Spa'],
                "BodKin": row['MI_BodKin'],
                "Mus": row['MI_Mus'],
                "Inter": row['MI_Inter'],
                "Intra": row['MI_Intra'],
                "Nat": row['MI_Nat']
            },
            axis=1
        )
        
        return result
    
    def assign_career_labels(self, data: pd.DataFrame) -> pd.DataFrame:
        """
        Asigna etiquetas de carrera basadas en los perfiles RIASEC.
        
        Args:
            data: DataFrame con puntuaciones RIASEC.
        
        Returns:
            DataFrame con etiquetas de carrera asignadas.
        """
        result = data.copy()
        
        # Definir perfiles RIASEC típicos de diferentes carreras
        career_profiles = {
            "Ingeniería": ['R', 'I', 'C'],             # Realista, Investigador, Convencional
            "Medicina": ['I', 'S', 'R'],               # Investigador, Social, Realista
            "Psicología": ['S', 'I', 'A'],             # Social, Investigador, Artístico
            "Negocios": ['E', 'C', 'S'],               # Emprendedor, Convencional, Social
            "Arte": ['A', 'S', 'I'],                   # Artístico, Social, Investigador
            "Educación": ['S', 'A', 'E'],              # Social, Artístico, Emprendedor
            "Tecnología": ['I', 'R', 'E'],             # Investigador, Realista, Emprendedor
            "Derecho": ['E', 'S', 'I'],                # Emprendedor, Social, Investigador
            "Ciencias Sociales": ['I', 'S', 'A'],      # Investigador, Social, Artístico
            "Comunicación": ['A', 'E', 'S']            # Artístico, Emprendedor, Social
        }
        
        # Para cada persona, encontrar el perfil de carrera más cercano
        def find_closest_career(row):
            # Obtener el top 3 de dimensiones RIASEC para la persona
            top_dims = sorted(
                ['R', 'I', 'A', 'S', 'E', 'C'], 
                key=lambda dim: row[f'{dim}_score'], 
                reverse=True
            )[:3]
            
            # Calcular similitud con cada perfil de carrera
            similarities = {}
            for career, profile in career_profiles.items():
                # Calcular puntuación de coincidencia (mayor es mejor)
                # Basado en cuántas dimensiones del top 3 coinciden y en qué posición
                score = 0
                for i, dim in enumerate(top_dims):
                    if dim in profile:
                        # Las coincidencias en las primeras posiciones valen más
                        score += (3 - i) * (3 - profile.index(dim))
                similarities[career] = score
            
            # Devolver la carrera con la mayor similitud
            return max(similarities.items(), key=lambda x: x[1])[0]
        
        # Asignar etiqueta de carrera
        result['predicted_career'] = result.apply(find_closest_career, axis=1)
        
        # Asignar un índice numérico a cada carrera (para el modelo)
        career_to_index = {career: i for i, career in enumerate(career_profiles.keys())}
        result['career_label'] = result['predicted_career'].map(career_to_index)
        
        return result
    
    def prepare_training_data(self, sample_size: int = None) -> Tuple[List, List[str]]:
        """
        Prepara datos de entrenamiento para el modelo MinimalNeuralCareerModel.
        
        Args:
            sample_size: Número de muestras a incluir. Si es None, se utilizan todas.
        
        Returns:
            Tupla con (datos_entrenamiento, nombres_carreras)
        """
        # Cargar y procesar los datos
        data = self.load_data()
        data = self.calculate_riasec_scores(data)
        data = self.map_riasec_to_mbti(data)
        data = self.estimate_mbti_weights(data)
        data = self.estimate_mi_scores(data)
        data = self.assign_career_labels(data)
        
        # Limpiar datos (eliminar filas con valores nulos en columnas importantes)
        required_columns = ['mbti_vector', 'mbti_weights', 'mi_scores', 'career_label']
        data_cleaned = data.dropna(subset=required_columns)
        
        # Tomar muestra si se especifica
        if sample_size is not None and sample_size < len(data_cleaned):
            data_sample = data_cleaned.sample(sample_size, random_state=42)
        else:
            data_sample = data_cleaned
        
        # Preparar datos en el formato requerido por el modelo
        training_data = []
        for _, row in data_sample.iterrows():
            training_data.append({
                "mbti_vector": row['mbti_vector'],
                "mbti_weights": row['mbti_weights'],
                "mi_scores": row['mi_scores'],
                "career_label": int(row['career_label'])
            })
        
        # Obtener nombres de carreras
        career_names = list(data_sample['predicted_career'].unique())
        
        return training_data, career_names
    
    def get_career_distribution(self) -> pd.DataFrame:
        """
        Obtiene la distribución de las carreras en el dataset procesado.
        
        Returns:
            DataFrame con la distribución de carreras.
        """
        # Procesar datos si aún no se ha hecho
        data = self.load_data()
        data = self.calculate_riasec_scores(data)
        data = self.assign_career_labels(data)
        
        # Calcular distribución
        career_counts = data['predicted_career'].value_counts().reset_index()
        career_counts.columns = ['Career', 'Count']
        career_counts['Percentage'] = career_counts['Count'] / career_counts['Count'].sum() * 100
        
        return career_counts

if __name__ == "__main__":
    # Ejemplo de uso
    processor = RIASECProcessor()
    data = processor.load_data()
    print(f"Columnas en el dataset: {data.columns.tolist()}")
    
    # Ver la distribución de carreras
    career_dist = processor.get_career_distribution()
    print("\nDistribución de carreras:")
    print(career_dist)
    
    # Preparar datos de entrenamiento (muestra pequeña para prueba)
    training_data, career_names = processor.prepare_training_data(sample_size=1000)
    print(f"\nDatos de entrenamiento preparados: {len(training_data)} muestras")
    print(f"Carreras: {career_names}") 