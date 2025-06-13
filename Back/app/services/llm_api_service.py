import os
import json
import requests
import logging
from typing import Dict, Any, Optional, Literal
from pydantic import BaseSettings, validator

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("llm_api_service")

class LLMApiSettings(BaseSettings):
    """Configuración para las APIs de LLM"""
    OPENAI_API_KEY: Optional[str] = None
    ANTHROPIC_API_KEY: Optional[str] = None
    DEFAULT_LLM_PROVIDER: str = "openai"  # Opciones: "openai", "anthropic", "mock"
    
    class Config:
        env_file = ".env"

class LLMApiService:
    """Servicio para interactuar con APIs de LLM externas"""
    
    def __init__(self):
        """Inicializa el servicio con la configuración de las APIs"""
        self.settings = LLMApiSettings()
        logger.info(f"LLMApiService inicializado. Proveedor por defecto: {self.settings.DEFAULT_LLM_PROVIDER}")
        logger.info(f"OPENAI_API_KEY configurada: {self.settings.OPENAI_API_KEY is not None}")
        
    async def call_llm(self, 
                      prompt: str, 
                      provider: Optional[str] = None,
                      max_tokens: int = 1000) -> str:
        """
        Realiza una llamada al LLM seleccionado
        
        Args:
            prompt: El texto a enviar al LLM
            provider: El proveedor a utilizar (openai, anthropic, mock)
            max_tokens: Máximo número de tokens a generar
            
        Returns:
            La respuesta del LLM
        """
        # Determinar el proveedor a utilizar
        provider = provider or self.settings.DEFAULT_LLM_PROVIDER
        logger.info(f"Llamando al LLM con proveedor: {provider}")
        
        # Llamar al método correspondiente según el proveedor
        if provider == "openai":
            return await self._call_openai(prompt, max_tokens)
        elif provider == "anthropic":
            return await self._call_anthropic(prompt, max_tokens)
        elif provider == "mock":
            logger.info("Usando proveedor mock para testing")
            return self._mock_response(prompt)
        else:
            raise ValueError(f"Proveedor LLM no soportado: {provider}")
    
    async def _call_openai(self, prompt: str, max_tokens: int) -> str:
        """Realiza una llamada a la API de OpenAI"""
        
        logger.info("Iniciando llamada a OpenAI API")
        
        if not self.settings.OPENAI_API_KEY:
            logger.error("OpenAI API key no configurada en .env")
            raise ValueError("OpenAI API key no configurada. Verifica tu archivo .env")
        
        logger.info(f"Longitud del prompt: {len(prompt)} caracteres")
        logger.info(f"Primeros 100 caracteres del prompt: {prompt[:100]}...")
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.settings.OPENAI_API_KEY}"
        }
        
        payload = {
            "model": "gpt-4-turbo-preview",  # O cualquier otro modelo disponible
            "messages": [
                {"role": "system", "content": "Eres un asistente de orientación vocacional."},
                {"role": "user", "content": prompt}
            ],
            "max_tokens": max_tokens,
            "temperature": 0.7
        }
        
        logger.info(f"Usando modelo: {payload['model']}")
        
        try:
            logger.info("Enviando solicitud a OpenAI...")
            response = requests.post(
                "https://api.openai.com/v1/chat/completions",
                headers=headers,
                json=payload
            )
            
            if response.status_code != 200:
                logger.error(f"Error en la respuesta de OpenAI: Status {response.status_code}")
                logger.error(f"Detalle del error: {response.text}")
                response.raise_for_status()
                
            result = response.json()
            logger.info("Respuesta recibida de OpenAI correctamente")
            
            content = result.get("choices", [{}])[0].get("message", {}).get("content", "")
            logger.info(f"Longitud de la respuesta: {len(content)} caracteres")
            logger.info(f"Primeros 100 caracteres de la respuesta: {content[:100]}...")
            
            return content
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Error en la solicitud a OpenAI: {str(e)}")
            raise RuntimeError(f"Error al llamar a la API de OpenAI: {str(e)}")
        except Exception as e:
            logger.error(f"Error inesperado en la llamada a OpenAI: {str(e)}")
            raise RuntimeError(f"Error inesperado: {str(e)}")
    
    async def _call_anthropic(self, prompt: str, max_tokens: int) -> str:
        """Realiza una llamada a la API de Anthropic (Claude)"""
        
        logger.info("Iniciando llamada a Anthropic API")
        
        if not self.settings.ANTHROPIC_API_KEY:
            logger.error("Anthropic API key no configurada en .env")
            raise ValueError("Anthropic API key no configurada")
        
        headers = {
            "Content-Type": "application/json",
            "x-api-key": self.settings.ANTHROPIC_API_KEY,
            "anthropic-version": "2023-06-01"
        }
        
        payload = {
            "model": "claude-3-sonnet-20240229",  # O cualquier otro modelo disponible
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "max_tokens": max_tokens,
            "temperature": 0.7
        }
        
        try:
            logger.info("Enviando solicitud a Anthropic...")
            response = requests.post(
                "https://api.anthropic.com/v1/messages",
                headers=headers,
                json=payload
            )
            
            if response.status_code != 200:
                logger.error(f"Error en la respuesta de Anthropic: Status {response.status_code}")
                logger.error(f"Detalle del error: {response.text}")
                response.raise_for_status()
                
            result = response.json()
            logger.info("Respuesta recibida de Anthropic correctamente")
            
            return result.get("content", [{}])[0].get("text", "")
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Error en la solicitud a Anthropic: {str(e)}")
            raise RuntimeError(f"Error al llamar a la API de Anthropic: {str(e)}")
    
    def _mock_response(self, prompt: str) -> str:
        """
        Genera una respuesta simulada para pruebas
        
        Args:
            prompt: El prompt enviado (no se usa, pero se incluye para consistencia)
            
        Returns:
            Una respuesta simulada en formato JSON
        """
        logger.info("Generando respuesta mock para testing")
        return """
        Basado en el análisis de tus respuestas:
        
        {
          "MBTI": "INFP",
          "MBTI_vector": [1, 1, 1, 1],
          "MBTI_weights": {
            "E/I": "I fuerte",
            "S/N": "N medio",
            "T/F": "F fuerte",
            "J/P": "P leve"
          },
          "MI": ["Intrapersonal", "Lingüística", "Espacial", "Naturalista", "Musical", "Interpersonal", "Lógico-Matemática", "Corporal-Kinestésica"]
        }
        
        Tus respuestas indican una personalidad introspectiva, creativa y guiada por valores.
        """ 