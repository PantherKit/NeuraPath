from typing import Dict, List
import numpy as np

class MultipleIntelligenceProcessor:
    def __init__(self):
        # Mapeo de los nombres antiguos a los nuevos
        self.intelligence_mapping = {
            "Lin": "Linguistic",
            "LogMath": "Logical-Mathematical", 
            "Spa": "Spatial",
            "BodKin": "Bodily-Kinesthetic",
            "Mus": "Musical",
            "Inter": "Interpersonal",
            "Intra": "Intrapersonal",
            "Nat": "Naturalistic"
        }
        
        # Nombres de inteligencias en el nuevo formato
        self.intelligence_types = [
            "Linguistic",
            "Logical-Mathematical", 
            "Spatial",
            "Bodily-Kinesthetic",
            "Musical",
            "Interpersonal",
            "Intrapersonal",
            "Naturalistic"
        ]
        
        # Mapeo de IDs de preguntas a tipo de inteligencia
        self.question_intelligence_mapping = {
            "ling_1": "Linguistic",
            "ling_2": "Linguistic", 
            "ling_3": "Linguistic",
            "log_1": "Logical-Mathematical",
            "log_2": "Logical-Mathematical",
            "log_3": "Logical-Mathematical",
            "spat_1": "Spatial",
            "spat_2": "Spatial",
            "spat_3": "Spatial",
            "body_1": "Bodily-Kinesthetic",
            "body_2": "Bodily-Kinesthetic",
            "body_3": "Bodily-Kinesthetic",
            "mus_1": "Musical",
            "mus_2": "Musical",
            "mus_3": "Musical",
            "inter_1": "Interpersonal",
            "inter_2": "Interpersonal",
            "inter_3": "Interpersonal",
            "intra_1": "Intrapersonal",
            "intra_2": "Intrapersonal",
            "intra_3": "Intrapersonal",
            "nat_1": "Naturalistic",
            "nat_2": "Naturalistic",
            "nat_3": "Naturalistic"
        }
        
    def process_mi_responses(self, responses: List[Dict]) -> Dict[str, float]:
        """
        Process multiple intelligence responses using Likert scale and return normalized scores
        
        Args:
            responses: List of dictionaries with id, intelligence, and likert_score (1-5)
            Expected format: [{"id": "ling_1", "intelligence": "Linguistic", "likert_score": 4}, ...]
            
        Returns:
            Dictionary mapping intelligence types to normalized scores (0.0 to 1.0)
        """
        # Initialize raw scores for each intelligence type
        raw_scores = {intel_type: 0.0 for intel_type in self.intelligence_types}
        question_counts = {intel_type: 0 for intel_type in self.intelligence_types}
        
        # Process each response
        for response in responses:
            question_id = response.get("id", "")
            intelligence_type = response.get("intelligence", "")
            likert_score = response.get("likert_score", 3)  # Default to neutral if missing
            
            # Determine intelligence type from question ID if not directly provided
            if question_id in self.question_intelligence_mapping:
                intelligence_type = self.question_intelligence_mapping[question_id]
            
            # Handle legacy format if intelligence_type is in old format
            if intelligence_type in self.intelligence_mapping:
                intelligence_type = self.intelligence_mapping[intelligence_type]
            
            # Skip if intelligence type is not recognized
            if intelligence_type not in self.intelligence_types:
                continue
            
            # Convert Likert score (1-5) to points
            # 1 = 0 points, 2 = 1 point, 3 = 2 points, 4 = 3 points, 5 = 4 points
            points = max(0, likert_score - 1)
            
            raw_scores[intelligence_type] += points
            question_counts[intelligence_type] += 1
        
        # Calculate normalized scores (0.0 to 1.0)
        normalized_scores = {}
        for intel_type in self.intelligence_types:
            if question_counts[intel_type] > 0:
                # Maximum possible score per question is 4 (when likert_score = 5)
                max_possible = question_counts[intel_type] * 4
                normalized_score = raw_scores[intel_type] / max_possible if max_possible > 0 else 0.0
            else:
                normalized_score = 0.0
            
            normalized_scores[intel_type] = min(1.0, max(0.0, normalized_score))
        
        return normalized_scores
    
    def process_mi_responses_legacy(self, responses: List[Dict]) -> Dict[str, float]:
        """
        Legacy method for backward compatibility with old format
        
        Args:
            responses: List of dictionaries with intelligence_type and score
            
        Returns:
            Dictionary mapping intelligence types to normalized scores
        """
        # Initialize scores for each intelligence type (using old names)
        old_intelligence_types = list(self.intelligence_mapping.keys())
        raw_scores = {intel_type: 0.0 for intel_type in old_intelligence_types}
        
        # Aggregate scores from responses
        for response in responses:
            intel_type = response["intelligence_type"]
            score = response["score"]
            
            if intel_type in raw_scores:
                raw_scores[intel_type] += score
        
        # Normalize scores to be between 0 and 1
        max_possible = 10.0  # Assuming maximum score per intelligence is 10
        normalized_scores_old = {
            intel_type: min(1.0, max(0.0, score / max_possible))
            for intel_type, score in raw_scores.items()
        }
        
        # Convert to new format
        normalized_scores = {}
        for old_name, new_name in self.intelligence_mapping.items():
            normalized_scores[new_name] = normalized_scores_old.get(old_name, 0.0)
        
        return normalized_scores 