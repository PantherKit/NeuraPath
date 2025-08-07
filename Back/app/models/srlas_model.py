from typing import Dict, List
import numpy as np

class SRLASProcessor:
    def __init__(self):
        # Las dimensiones SRLAS (Self-Regulation Skills, Learning, and Affective Strategies)
        self.dimensions = [
            "Self_Regulation",     # Autorregulación
            "Learning_Strategies", # Estrategias de aprendizaje
            "Affective_Strategies" # Estrategias afectivas
        ]
        
        # Nombres completos de las dimensiones
        self.dimension_names = {
            "Self_Regulation": "Self-Regulation Skills",      # Habilidades de autorregulación
            "Learning_Strategies": "Learning Strategies",     # Estrategias de aprendizaje
            "Affective_Strategies": "Affective Strategies"    # Estrategias afectivas
        }
        
        # Subdimensiones más específicas
        self.subdimensions = {
            "Self_Regulation": [
                "Goal_Setting",           # Establecimiento de metas
                "Time_Management",        # Gestión del tiempo
                "Self_Monitoring",        # Automonitoreo
                "Self_Evaluation"         # Autoevaluación
            ],
            "Learning_Strategies": [
                "Cognitive_Strategies",   # Estrategias cognitivas
                "Metacognitive_Strategies", # Estrategias metacognitivas
                "Resource_Management",    # Gestión de recursos
                "Help_Seeking"           # Búsqueda de ayuda
            ],
            "Affective_Strategies": [
                "Motivation_Regulation", # Regulación de la motivación
                "Anxiety_Management",    # Gestión de la ansiedad
                "Persistence",           # Persistencia
                "Self_Efficacy"         # Autoeficacia
            ]
        }
        
        # Mapeo de IDs de preguntas a dimensión SRLAS
        self.question_dimension_mapping = {
            # Self-Regulation questions (basadas en el archivo sr_questions.json)
            "sr_1": "Self_Regulation", "sr_2": "Self_Regulation", 
            "sr_3": "Self_Regulation", "sr_4": "Self_Regulation",
            "sr_5": "Self_Regulation", "sr_6": "Self_Regulation",
            
            # Learning Strategies questions  
            "ls_1": "Learning_Strategies", "ls_2": "Learning_Strategies",
            "ls_3": "Learning_Strategies", "ls_4": "Learning_Strategies", 
            "ls_5": "Learning_Strategies", "ls_6": "Learning_Strategies",
            
            # Affective Strategies questions
            "as_1": "Affective_Strategies", "as_2": "Affective_Strategies",
            "as_3": "Affective_Strategies", "as_4": "Affective_Strategies",
            "as_5": "Affective_Strategies", "as_6": "Affective_Strategies"
        }
        
    def process_srlas_responses(self, responses: List[Dict]) -> Dict[str, float]:
        """
        Process SRLAS responses using Likert scale and return normalized scores
        
        Args:
            responses: List of dictionaries with id, dimension, and likert_score (1-5)
            Expected format: [{"id": "sr_1", "dimension": "Self_Regulation", "likert_score": 4}, ...]
            
        Returns:
            Dictionary mapping SRLAS dimensions to normalized scores (0.0 to 1.0)
        """
        # Initialize raw scores for each dimension
        raw_scores = {dimension: 0.0 for dimension in self.dimensions}
        question_counts = {dimension: 0 for dimension in self.dimensions}
        
        # Process each response
        for response in responses:
            question_id = response.get("id", "")
            dimension = response.get("dimension", "")
            likert_score = response.get("likert_score", 3)  # Default to neutral if missing
            
            # Determine dimension from question ID if not directly provided
            if question_id in self.question_dimension_mapping:
                dimension = self.question_dimension_mapping[question_id]
            
            # Skip if dimension is not recognized
            if dimension not in self.dimensions:
                continue
            
            # Convert Likert score (1-5) to points
            # 1 = 0 points, 2 = 1 point, 3 = 2 points, 4 = 3 points, 5 = 4 points
            points = max(0, likert_score - 1)
            
            raw_scores[dimension] += points
            question_counts[dimension] += 1
        
        # Calculate normalized scores (0.0 to 1.0)
        normalized_scores = {}
        for dimension in self.dimensions:
            if question_counts[dimension] > 0:
                # Average score per question, then normalize to 0-1 scale
                avg_score = raw_scores[dimension] / question_counts[dimension]
                normalized_scores[dimension] = avg_score / 4.0  # Max possible avg is 4
            else:
                normalized_scores[dimension] = 0.0
        
        return normalized_scores
    
    def get_srlas_profile(self, srlas_scores: Dict[str, float]) -> Dict[str, str]:
        """
        Generate SRLAS profile based on scores
        
        Args:
            srlas_scores: Dictionary with SRLAS scores
            
        Returns:
            Dictionary with profile classification for each dimension
        """
        profile = {}
        
        for dimension, score in srlas_scores.items():
            if score >= 0.8:
                profile[dimension] = "Muy Alto"
            elif score >= 0.6:
                profile[dimension] = "Alto"
            elif score >= 0.4:
                profile[dimension] = "Medio"
            elif score >= 0.2:
                profile[dimension] = "Bajo"
            else:
                profile[dimension] = "Muy Bajo"
        
        return profile
    
    def get_learning_recommendations(self, srlas_scores: Dict[str, float]) -> List[str]:
        """
        Generate learning recommendations based on SRLAS scores
        
        Args:
            srlas_scores: Dictionary with SRLAS scores
            
        Returns:
            List of personalized learning recommendations
        """
        recommendations = []
        
        # Self-Regulation recommendations
        if srlas_scores.get("Self_Regulation", 0) < 0.5:
            recommendations.extend([
                "Establece metas específicas y medibles para tus estudios",
                "Usa técnicas de planificación como calendarios y listas de tareas",
                "Practica técnicas de automonitoreo durante el aprendizaje"
            ])
        
        # Learning Strategies recommendations
        if srlas_scores.get("Learning_Strategies", 0) < 0.5:
            recommendations.extend([
                "Experimenta con diferentes técnicas de estudio (mapas mentales, flashcards, resúmenes)",
                "Desarrolla estrategias metacognitivas: reflexiona sobre tu proceso de aprendizaje",
                "Busca recursos adicionales cuando no entiendas un concepto"
            ])
        
        # Affective Strategies recommendations
        if srlas_scores.get("Affective_Strategies", 0) < 0.5:
            recommendations.extend([
                "Desarrolla técnicas de manejo del estrés y la ansiedad académica",
                "Cultiva una mentalidad de crecimiento: los errores son oportunidades de aprendizaje",
                "Busca apoyo social cuando enfrentes desafíos académicos"
            ])
        
        return recommendations
    
    def generate_srlas_description(self, srlas_scores: Dict[str, float]) -> str:
        """
        Generate a description of the user's SRLAS profile
        
        Args:
            srlas_scores: Dictionary with SRLAS scores
            
        Returns:
            Descriptive text about the user's SRLAS profile
        """
        # Sort dimensions by score
        sorted_scores = sorted(srlas_scores.items(), key=lambda x: x[1], reverse=True)
        
        # Get strongest and weakest areas
        strongest = sorted_scores[0]
        weakest = sorted_scores[-1]
        
        # Description templates for each dimension
        descriptions = {
            "Self_Regulation": "tienes buenas habilidades para autorregular tu aprendizaje, establecer metas y gestionar tu tiempo",
            "Learning_Strategies": "utilizas estrategias de aprendizaje efectivas y adaptas tu enfoque según la situación",
            "Affective_Strategies": "manejas bien tus emociones durante el aprendizaje y mantienes la motivación ante los desafíos"
        }
        
        # Build description
        description = f"En cuanto a tus estrategias de aprendizaje, tu fortaleza principal es que {descriptions.get(strongest[0], 'tienes características únicas')}"
        
        if weakest[1] < 0.4:  # Include area for improvement if score is low
            weakness_descriptions = {
                "Self_Regulation": "podrías beneficiarte de desarrollar mejores habilidades de autorregulación y planificación",
                "Learning_Strategies": "sería útil que explores y desarrolles más estrategias de aprendizaje",
                "Affective_Strategies": "te ayudaría trabajar en el manejo emocional durante los procesos de aprendizaje"
            }
            description += f", mientras que {weakness_descriptions.get(weakest[0], 'hay áreas donde puedes crecer')}"
        
        description += "."
        
        return description 