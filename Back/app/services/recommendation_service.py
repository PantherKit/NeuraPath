from typing import Dict, List, Any
from app.models.mbti_model import MBTIProcessor
from app.models.mi_model import MultipleIntelligenceProcessor
from app.models.career_model import CareerRecommender

class RecommendationService:
    def __init__(self):
        self.mbti_processor = MBTIProcessor()
        self.mi_processor = MultipleIntelligenceProcessor()
        self.career_recommender = CareerRecommender()
    
    def process_mbti_answers(self, mbti_questions: List[Dict]) -> Dict[str, Any]:
        """
        Process MBTI questions and return the MBTI profile
        
        Args:
            mbti_questions: List of MBTI question responses
            
        Returns:
            Dictionary with MBTI code, vector, and weights
        """
        mbti_code, mbti_vector, mbti_weights = self.mbti_processor.process_mbti_questions(mbti_questions)
        
        return {
            "MBTI_code": mbti_code,
            "MBTI_vector": mbti_vector,
            "MBTI_weights": mbti_weights
        }
    
    def process_mi_answers(self, mi_responses: List[Dict]) -> Dict[str, float]:
        """
        Process MI questions and return the MI profile
        
        Args:
            mi_responses: List of MI question responses
            
        Returns:
            Dictionary with MI scores
        """
        mi_scores = self.mi_processor.process_mi_responses(mi_responses)
        
        return {
            "MI_scores": mi_scores
        }
    
    def get_career_recommendations(self, mbti_result: Dict[str, Any], 
                                  mi_result: Dict[str, float],
                                  top_n: int = 3,
                                  location_filter: str = None) -> Dict[str, Any]:
        """
        Get career recommendations based on MBTI and MI profiles
        
        Args:
            mbti_result: Dictionary with MBTI code, vector, and weights
            mi_result: Dictionary with MI scores
            top_n: Number of recommendations to return
            location_filter: Optional location to filter results
            
        Returns:
            Dictionary with career recommendations and profile description
        """
        mbti_code = mbti_result["MBTI_code"]
        mbti_vector = mbti_result["MBTI_vector"]
        mbti_weights = mbti_result["MBTI_weights"]
        mi_scores = mi_result["MI_scores"]
        
        # Get career recommendations
        career_recommendations = self.career_recommender.recommend_careers(
            mbti_code, mbti_vector, mbti_weights, mi_scores, top_n, location_filter
        )
        
        # Generate profile description
        profile_description = self.career_recommender.generate_profile_description(
            mbti_code, mbti_weights, mi_scores
        )
        
        return {
            "career_recommendations": career_recommendations,
            "profile_description": profile_description
        }
        
    def get_full_profile(self, mbti_questions: List[Dict], mi_responses: List[Dict],
                       top_n: int = 3, location_filter: str = None) -> Dict[str, Any]:
        """
        Process all inputs and return a complete user profile with recommendations
        
        Args:
            mbti_questions: List of MBTI question responses
            mi_responses: List of MI question responses
            top_n: Number of recommendations to return
            location_filter: Optional location to filter results
            
        Returns:
            Complete user profile with MBTI, MI, recommendations, and description
        """
        # Process MBTI
        mbti_result = self.process_mbti_answers(mbti_questions)
        
        # Process MI
        mi_result = self.process_mi_answers(mi_responses)
        
        # Get recommendations and profile description
        recommendations = self.get_career_recommendations(
            mbti_result, mi_result, top_n, location_filter
        )
        
        # Combine all results
        return {
            "mbti_result": mbti_result,
            "mi_result": mi_result,
            "career_recommendations": recommendations["career_recommendations"],
            "profile_description": recommendations["profile_description"]
        } 