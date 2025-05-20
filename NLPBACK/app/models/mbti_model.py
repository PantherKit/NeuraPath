from typing import Dict, List, Tuple
import numpy as np

class MBTIProcessor:
    def __init__(self):
        self.dimensions = ["E/I", "S/N", "T/F", "J/P"]
        self.dimension_mapping = {
            "E/I": {"E": 0, "I": 1},
            "S/N": {"S": 0, "N": 1},
            "T/F": {"T": 0, "F": 1},
            "J/P": {"J": 0, "P": 1}
        }
        self.letter_mapping = [
            ["E", "I"],
            ["S", "N"],
            ["T", "F"],
            ["J", "P"]
        ]
        
    def process_mbti_questions(self, questions: List[Dict]) -> Tuple[str, List[int], Dict[str, float]]:
        """
        Process MBTI questions and return MBTI code, vector, and weights
        
        Args:
            questions: List of question dicts with dimension, user_choice, and weight
            
        Returns:
            Tuple containing:
            - MBTI code (e.g., "INTP")
            - MBTI vector (e.g., [0, 1, 0, 0])
            - MBTI weights (e.g., {"E/I": 0.85, "S/N": 0.62, ...})
        """
        # Initialize dimension scores
        dimension_scores = {
            "E/I": {"E": 0.0, "I": 0.0},
            "S/N": {"S": 0.0, "N": 0.0},
            "T/F": {"T": 0.0, "F": 0.0},
            "J/P": {"J": 0.0, "P": 0.0}
        }
        
        # Aggregate scores from each question
        for question in questions:
            dimension = question["dimension"]
            choice = question["user_choice"]
            weight = question["weight"]
            
            dimension_scores[dimension][choice] += weight
        
        # Calculate the dominant trait for each dimension and weights
        mbti_code = ""
        mbti_vector = []
        mbti_weights = {}
        
        for dim in self.dimensions:
            options = list(dimension_scores[dim].keys())
            scores = [dimension_scores[dim][opt] for opt in options]
            
            # Normalize if any responses for this dimension
            total = sum(scores)
            if total > 0:
                scores = [s / total for s in scores]
                
            # Determine which trait is dominant
            dominant_idx = 0 if scores[0] >= scores[1] else 1
            dominant_trait = options[dominant_idx]
            mbti_code += dominant_trait
            
            # Create binary vector representation (0 or 1)
            mbti_vector.append(self.dimension_mapping[dim][dominant_trait])
            
            # Calculate weight (strength of preference)
            if total > 0:
                weight = abs(scores[0] - scores[1])
            else:
                weight = 0.5  # Default if no data
            mbti_weights[dim] = weight
        
        return mbti_code, mbti_vector, mbti_weights 