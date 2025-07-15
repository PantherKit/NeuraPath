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
        
        # Mapeo de IDs de preguntas a polaridad (para escala Likert)
        # True significa que valores altos (4-5) indican el segundo polo (I, N, F, P)
        # False significa que valores altos (4-5) indican el primer polo (E, S, T, J)
        self.question_polarity = {
            # E/I dimension
            "ei_1": False,  # "I feel energized when I collaborate with others" -> E
            "ei_2": False,  # "I enjoy being part of group discussions" -> E
            "ei_3": True,   # "Spending quiet time alone helps me recharge" -> I
            "ei_4": True,   # "I prefer to think things through before talking" -> I
            
            # S/N dimension
            "sn_1": False,  # "I tend to focus on specific details" -> S
            "sn_2": True,   # "I enjoy exploring new ideas, even if abstract" -> N
            "sn_3": False,  # "I trust proven methods over untested approaches" -> S
            "sn_4": True,   # "I think about possibilities others may not notice" -> N
            
            # T/F dimension
            "tf_1": False,  # "When making decisions, I prioritize logic over emotions" -> T
            "tf_2": True,   # "I consider how others might feel before expressing opinion" -> F
            "tf_3": False,  # "I value fairness more than keeping everyone happy" -> T
            "tf_4": True,   # "I believe empathy is essential in group work" -> F
            
            # J/P dimension
            "jp_1": False,  # "I prefer having a structured plan when starting a new task" -> J
            "jp_2": True,   # "I work best when I can adapt and be spontaneous" -> P
            "jp_3": False,  # "I like to organize my work before I begin" -> J
            "jp_4": True,   # "I'm comfortable adjusting my plans if something unexpected happens" -> P
        }
        
    def process_mbti_questions(self, questions: List[Dict]) -> Tuple[str, List[int], Dict[str, float]]:
        """
        Process MBTI questions using Likert scale and return MBTI code, vector, and weights
        
        Args:
            questions: List of question dicts with id, dimension, and likert_score (1-5)
            Expected format: [{"id": "ei_1", "dimension": "E/I", "likert_score": 4}, ...]
            
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
        
        # Process each question response
        for question in questions:
            question_id = question["id"]
            dimension = question["dimension"]
            likert_score = question["likert_score"]  # 1-5 scale
            
            # Skip if question ID not in our mapping
            if question_id not in self.question_polarity:
                continue
                
            # Convert Likert score to preference strength
            # 1-2: Strong preference for one pole
            # 3: Neutral
            # 4-5: Strong preference for the other pole
            
            is_reverse_polarity = self.question_polarity[question_id]
            
            if likert_score <= 2:  # Disagree/Strongly disagree
                if is_reverse_polarity:
                    # Low score means first pole (E, S, T, J)
                    first_pole, second_pole = dimension.split("/")
                    dimension_scores[dimension][first_pole] += (3 - likert_score)  # 2 or 1
                else:
                    # Low score means second pole (I, N, F, P)
                    first_pole, second_pole = dimension.split("/")
                    dimension_scores[dimension][second_pole] += (3 - likert_score)  # 2 or 1
                    
            elif likert_score >= 4:  # Agree/Strongly agree
                if is_reverse_polarity:
                    # High score means second pole (I, N, F, P)
                    first_pole, second_pole = dimension.split("/")
                    dimension_scores[dimension][second_pole] += (likert_score - 2)  # 2 or 3
                else:
                    # High score means first pole (E, S, T, J)
                    first_pole, second_pole = dimension.split("/")
                    dimension_scores[dimension][first_pole] += (likert_score - 2)  # 2 or 3
            # Score of 3 (neutral) adds nothing to either pole
        
        # Calculate the dominant trait for each dimension and weights
        mbti_code = ""
        mbti_vector = []
        mbti_weights = {}
        
        for dim in self.dimensions:
            first_pole, second_pole = dim.split("/")
            first_score = dimension_scores[dim][first_pole]
            second_score = dimension_scores[dim][second_pole]
            
            # Determine which trait is dominant
            if first_score > second_score:
                dominant_trait = first_pole
                mbti_vector.append(0)  # First pole
            elif second_score > first_score:
                dominant_trait = second_pole
                mbti_vector.append(1)  # Second pole
            else:
                # Tie - default to first pole
                dominant_trait = first_pole
                mbti_vector.append(0)
                
            mbti_code += dominant_trait
            
            # Calculate weight (strength of preference)
            total_responses = first_score + second_score
            if total_responses > 0:
                weight = abs(first_score - second_score) / total_responses
            else:
                weight = 0.0  # No responses for this dimension
            mbti_weights[dim] = min(1.0, weight)  # Cap at 1.0
        
        return mbti_code, mbti_vector, mbti_weights 