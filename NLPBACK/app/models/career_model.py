from typing import Dict, List, Tuple
import numpy as np
import json
from pathlib import Path
import os
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

class CareerRecommender:
    def __init__(self):
        # Path to the career data
        self.data_path = Path(os.path.dirname(os.path.abspath(__file__))) / ".." / "data" / "careers.json"
        
        # Load the career data if exists, otherwise use a default set
        if self.data_path.exists():
            with open(self.data_path, "r", encoding="utf-8") as f:
                self.careers = json.load(f)
        else:
            # Default career data if file doesn't exist
            self.careers = self._get_default_careers()
            
            # Save the default careers to file
            os.makedirs(self.data_path.parent, exist_ok=True)
            with open(self.data_path, "w", encoding="utf-8") as f:
                json.dump(self.careers, f, ensure_ascii=False, indent=2)
        
        # Initialize the sentence transformer model for text embeddings
        # In a production environment, you would want to load this once and reuse
        try:
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
            # Pre-compute embeddings for all career descriptions
            self.career_embeddings = self._compute_career_embeddings()
        except Exception as e:
            print(f"Error loading sentence transformer model: {e}")
            self.model = None
            self.career_embeddings = []
    
    def _get_default_careers(self) -> List[Dict]:
        """Return a default set of STEM careers"""
        return [
            {
                "nombre": "Ingeniería en Biotecnología",
                "universidad": "Tec de Monterrey",
                "descripcion": "Carrera que combina biología y tecnología para el desarrollo de soluciones en salud, alimentos y medio ambiente.",
                "ubicacion": "Querétaro"
            },
            {
                "nombre": "Ciencia de Datos",
                "universidad": "UNAM",
                "descripcion": "Carrera enfocada en el análisis de grandes volúmenes de datos, aprendizaje automático y estadística aplicada.",
                "ubicacion": "Ciudad de México"
            },
            {
                "nombre": "Ingeniería Mecatrónica",
                "universidad": "IPN",
                "descripcion": "Combina mecánica, electrónica, control y programación para crear sistemas robotizados y automatizados.",
                "ubicacion": "Ciudad de México"
            },
            {
                "nombre": "Diseño UX",
                "universidad": "IBERO",
                "descripcion": "Enfocada en crear experiencias digitales centradas en el usuario, combinando diseño e investigación.",
                "ubicacion": "Ciudad de México"
            },
            {
                "nombre": "Ingeniería Ambiental",
                "universidad": "UAEM",
                "descripcion": "Carrera enfocada en el desarrollo de soluciones para problemas ambientales y sustentabilidad.",
                "ubicacion": "Toluca"
            }
        ]
    
    def _compute_career_embeddings(self) -> np.ndarray:
        """Compute embeddings for all career descriptions"""
        if not self.model:
            return np.array([])
            
        descriptions = [career["descripcion"] for career in self.careers]
        return self.model.encode(descriptions)
    
    def _generate_profile_embedding(self, mbti_code: str, mbti_weights: Dict[str, float], 
                                   mi_scores: Dict[str, float]) -> np.ndarray:
        """
        Generate a text representation of the user profile and convert to embedding
        """
        if not self.model:
            return np.array([])
            
        # Create a textual profile description
        profile_text = f"Perfil MBTI: {mbti_code}. "
        
        # Add information about strongest MI traits
        sorted_mi = sorted(mi_scores.items(), key=lambda x: x[1], reverse=True)
        top_mi = sorted_mi[:3]
        profile_text += f"Fortalezas en inteligencias: {', '.join([f'{mi[0]} ({mi[1]:.2f})' for mi in top_mi])}. "
        
        # Add MBTI dimensions with strong preferences
        strong_dimensions = [dim for dim, weight in mbti_weights.items() if weight > 0.7]
        if strong_dimensions:
            profile_text += f"Preferencias fuertes en dimensiones: {', '.join(strong_dimensions)}."
        
        # Convert to embedding
        return self.model.encode([profile_text])[0]
    
    def recommend_careers(self, mbti_code: str, mbti_vector: List[int], 
                         mbti_weights: Dict[str, float], mi_scores: Dict[str, float], 
                         top_n: int = 3, location_filter: str = None) -> List[Dict]:
        """
        Recommend careers based on MBTI and MI profiles.
        
        In a real implementation, this would use a trained ML model.
        For this prototype, we use semantic similarity with descriptions.
        
        Args:
            mbti_code: The MBTI personality type (e.g., "INTP")
            mbti_vector: Binary vector representation of MBTI
            mbti_weights: Dictionary of dimension weights
            mi_scores: Dictionary of multiple intelligence scores
            top_n: Number of recommendations to return
            location_filter: Optional location to filter results
            
        Returns:
            List of career recommendations with match scores
        """
        if not self.model or len(self.career_embeddings) == 0:
            # Fallback if no model is available: rule-based matching
            return self._rule_based_recommendations(mbti_code, mi_scores, top_n, location_filter)
        
        # Generate embedding for the user profile
        profile_embedding = self._generate_profile_embedding(mbti_code, mbti_weights, mi_scores)
        
        # Calculate similarity scores
        similarities = cosine_similarity([profile_embedding], self.career_embeddings)[0]
        
        # Get indices of top careers
        if location_filter:
            # Filter by location if specified
            location_indices = [i for i, career in enumerate(self.careers) 
                               if location_filter.lower() in career["ubicacion"].lower()]
            if location_indices:
                similarities = [similarities[i] if i in location_indices else -1 for i in range(len(similarities))]
        
        # Get top N indices
        top_indices = np.argsort(similarities)[::-1][:top_n]
        
        # Return top careers with match scores
        recommendations = []
        for idx in top_indices:
            if similarities[idx] > 0:  # Only include positive matches
                career = self.careers[idx]
                recommendations.append({
                    "nombre": career["nombre"],
                    "universidad": career["universidad"],
                    "ciudad": career["ubicacion"],
                    "match_score": float(similarities[idx])
                })
        
        return recommendations
    
    def _rule_based_recommendations(self, mbti_code: str, mi_scores: Dict[str, float], 
                                   top_n: int = 3, location_filter: str = None) -> List[Dict]:
        """
        Simple rule-based career matching as fallback if ML model is not available
        """
        matches = []
        
        # Simple matching rules based on MBTI type
        mbti_career_affinities = {
            "INTJ": ["Ciencia de Datos", "Ingeniería en Biotecnología"],
            "INTP": ["Ciencia de Datos", "Ingeniería Mecatrónica"],
            "ENTJ": ["Ingeniería Mecatrónica", "Diseño UX"],
            "ENTP": ["Diseño UX", "Ciencia de Datos"],
            "INFJ": ["Ingeniería Ambiental", "Diseño UX"],
            "INFP": ["Diseño UX", "Ingeniería Ambiental"],
            "ENFJ": ["Ingeniería Ambiental", "Ingeniería en Biotecnología"],
            "ENFP": ["Diseño UX", "Ingeniería en Biotecnología"],
            "ISTJ": ["Ingeniería Mecatrónica", "Ciencia de Datos"],
            "ISFJ": ["Ingeniería Ambiental", "Ingeniería en Biotecnología"],
            "ESTJ": ["Ingeniería Mecatrónica", "Ingeniería Ambiental"],
            "ESFJ": ["Ingeniería en Biotecnología", "Ingeniería Ambiental"],
            "ISTP": ["Ingeniería Mecatrónica", "Ciencia de Datos"],
            "ISFP": ["Diseño UX", "Ingeniería Ambiental"],
            "ESTP": ["Ingeniería Mecatrónica", "Diseño UX"],
            "ESFP": ["Diseño UX", "Ingeniería en Biotecnología"]
        }
        
        # Get career affinities for the MBTI type
        affinities = mbti_career_affinities.get(mbti_code, ["Ciencia de Datos", "Ingeniería Mecatrónica"])
        
        # Find the matching careers in our database
        for career_name in affinities:
            for career in self.careers:
                if location_filter and location_filter.lower() not in career["ubicacion"].lower():
                    continue
                    
                if career_name in career["nombre"]:
                    # Calculate a synthetic match score based on MI
                    match_score = 0.7 + (sum(mi_scores.values()) / len(mi_scores)) * 0.2
                    matches.append({
                        "nombre": career["nombre"],
                        "universidad": career["universidad"],
                        "ciudad": career["ubicacion"],
                        "match_score": float(match_score)
                    })
        
        # If we still need more recommendations, add others
        for career in self.careers:
            if len(matches) >= top_n:
                break
                
            if location_filter and location_filter.lower() not in career["ubicacion"].lower():
                continue
                
            # Check if career is already in matches
            if not any(match["nombre"] == career["nombre"] for match in matches):
                match_score = 0.65  # Lower match score for these additional recommendations
                matches.append({
                    "nombre": career["nombre"],
                    "universidad": career["universidad"],
                    "ciudad": career["ubicacion"],
                    "match_score": float(match_score)
                })
        
        # Return top N matches
        return sorted(matches, key=lambda x: x["match_score"], reverse=True)[:top_n]
        
    def generate_profile_description(self, mbti_code: str, mbti_weights: Dict[str, float], 
                                    mi_scores: Dict[str, float]) -> str:
        """
        Generate a personalized STEM profile description based on MBTI and MI
        
        In a production environment, this would use an LLM like GPT, but here we use templates
        """
        # Dictionary of MBTI descriptions
        mbti_descriptions = {
            "INTJ": "posees una mente analítica y estratégica. Eres independiente, determinado y tienes una gran capacidad para comprender conceptos complejos.",
            "INTP": "eres curioso, analítico y teórico. Te gusta resolver problemas complejos y buscar patrones, con un enfoque lógico y objetivo.",
            "ENTJ": "eres decidido, estratégico y tienes dotes de liderazgo natural. Te destacas por tu organización y tu capacidad para tomar decisiones.",
            "ENTP": "eres ingenioso, innovador y adaptable. Disfrutas debatiendo ideas y encontrando soluciones creativas a problemas complejos.",
            "INFJ": "eres perceptivo, idealista y comprometido. Te enfocas en comprender a los demás y trabajar por causas significativas.",
            "INFP": "eres idealista, creativo y empático. Valoras la autenticidad y buscas tener un impacto positivo en el mundo.",
            "ENFJ": "eres carismático, empático y natural para liderar. Te preocupas por el desarrollo de los demás y trabajas en crear ambientes armoniosos.",
            "ENFP": "eres entusiasta, creativo y con gran capacidad para conectar con los demás. Disfrutas explorando nuevas ideas y posibilidades.",
            "ISTJ": "eres responsable, práctico y organizado. Valoras la consistencia y la confiabilidad en tu enfoque metódico.",
            "ISFJ": "eres servicial, detallista y leal. Te destacas por tu enfoque práctico para ayudar a los demás y tu atención al detalle.",
            "ESTJ": "eres organizado, lógico y orientado a resultados. Te enfocas en implementar soluciones prácticas con eficiencia.",
            "ESFJ": "eres sociable, cooperativo y práctico. Te gusta cuidar de los demás y mantener la armonía mientras logras resultados concretos.",
            "ISTP": "eres versátil, pragmático y orientado a la acción. Tienes habilidades excepcionales para resolver problemas técnicos.",
            "ISFP": "eres artístico, adaptable y observador. Disfrutas experimentando con nuevas ideas en el momento presente.",
            "ESTP": "eres enérgico, práctico y adaptable. Te destacas en situaciones que requieren acción inmediata e improvisación.",
            "ESFP": "eres entusiasta, espontáneo y sociable. Disfrutas trabajando con otros en proyectos prácticos y dinámicos."
        }
        
        # Dictionary of MI suggestions
        mi_career_suggestions = {
            "Lin": "comunicación científica, documentación técnica o divulgación STEM",
            "LogMath": "programación, estadística, ciencia de datos o matemáticas aplicadas",
            "Spa": "diseño 3D, arquitectura, visualización de datos o ingeniería civil",
            "BodKin": "ingeniería biomédica, ergonomía o tecnologías de rehabilitación",
            "Mus": "acústica, ingeniería de sonido o tecnología musical",
            "Inter": "gestión de proyectos tecnológicos, consultoría o educación STEM",
            "Intra": "investigación, análisis de sistemas o desarrollo de soluciones autónomas",
            "Nat": "ciencias ambientales, biología, ecología o sostenibilidad"
        }
        
        # Start with MBTI description
        description = f"Como persona con perfil MBTI {mbti_code}, {mbti_descriptions.get(mbti_code, 'tienes un perfil único')}. "
        
        # Add information about strongest MI traits
        sorted_mi = sorted(mi_scores.items(), key=lambda x: x[1], reverse=True)
        top_mi = sorted_mi[:3]
        
        description += "Tus fortalezas en inteligencias múltiples indican aptitudes para "
        
        mi_suggestions = [mi_career_suggestions.get(mi_type, "diversas áreas STEM") for mi_type, _ in top_mi]
        description += ", ".join(mi_suggestions) + ". "
        
        # Add career advice based on combined profile
        description += "Estas características te hacen especialmente apto/a para carreras que combinen "
        
        if "LogMath" in [mi[0] for mi in top_mi]:
            if any(letter in mbti_code for letter in "NT"):
                description += "análisis riguroso con innovación tecnológica, "
            else:
                description += "pensamiento lógico con aplicaciones prácticas, "
                
        if "Spa" in [mi[0] for mi in top_mi] or "BodKin" in [mi[0] for mi in top_mi]:
            if any(letter in mbti_code for letter in "SP"):
                description += "diseño y construcción de soluciones físicas, "
            else:
                description += "planificación y visualización de sistemas, "
                
        if "Inter" in [mi[0] for mi in top_mi] or "Lin" in [mi[0] for mi in top_mi]:
            if any(letter in mbti_code for letter in "EF"):
                description += "comunicación y colaboración en equipos multidisciplinarios, "
            else:
                description += "documentación y explicación de conceptos complejos, "
                
        # Remove the last comma and space
        description = description.rstrip(", ") + "."
        
        return description 