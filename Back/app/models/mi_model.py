from typing import Dict, List
import numpy as np

class MultipleIntelligenceProcessor:
    def __init__(self):
        self.intelligence_types = [
            "Lin",      # Linguistic
            "LogMath",  # Logical-Mathematical
            "Spa",      # Spatial
            "BodKin",   # Bodily-Kinesthetic
            "Mus",      # Musical
            "Inter",    # Interpersonal
            "Intra",    # Intrapersonal
            "Nat"       # Naturalist
        ]
        
    def process_mi_responses(self, responses: List[Dict]) -> Dict[str, float]:
        """
        Process multiple intelligence responses and return normalized scores
        
        Args:
            responses: List of dictionaries with intelligence_type and score
            
        Returns:
            Dictionary mapping intelligence types to normalized scores
        """
        # Initialize scores for each intelligence type
        raw_scores = {intel_type: 0.0 for intel_type in self.intelligence_types}
        
        # Aggregate scores from responses
        for response in responses:
            intel_type = response["intelligence_type"]
            score = response["score"]
            
            if intel_type in raw_scores:
                raw_scores[intel_type] += score
        
        # Normalize scores to be between 0 and 1
        max_possible = 10.0  # Assuming maximum score per intelligence is 10
        normalized_scores = {
            intel_type: min(1.0, max(0.0, score / max_possible))
            for intel_type, score in raw_scores.items()
        }
        
        return normalized_scores 