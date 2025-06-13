@router.post("/recommend_careers")
async def recommend_careers(
    profile_data: ProfileData,
    neural_service: NeuralCareerService = Depends(get_neural_service),
    llm_service: LLMService = Depends(get_llm_service),
    llm_api_service: LLMApiService = Depends(get_llm_api_service),
    db: Session = Depends(get_db)
):
    """Recomienda carreras STEM basadas en el perfil MBTI y MI del usuario"""
    logger.info("Iniciando proceso de recomendación de carreras")
    logger.info(f"Perfil recibido: MBTI={profile_data.mbti_result}, MI disponibles={len(profile_data.mi_scores)}")
    
    try:
        # Convertir vector MBTI
        mbti_vector = [
            1 if profile_data.mbti_result.ei == "I" else 0,
            1 if profile_data.mbti_result.sn == "N" else 0,
            1 if profile_data.mbti_result.tf == "F" else 0,
            1 if profile_data.mbti_result.jp == "P" else 0
        ]
        logger.info(f"Vector MBTI creado: {mbti_vector}")
        
        # Extraer pesos MBTI
        mbti_weights = {
            "E/I": profile_data.mbti_result.ei_score,
            "S/N": profile_data.mbti_result.sn_score,
            "T/F": profile_data.mbti_result.tf_score,
            "J/P": profile_data.mbti_result.jp_score
        }
        logger.info(f"Pesos MBTI: {mbti_weights}")
        
        # Obtener scores MI
        mi_scores = profile_data.mi_scores
        logger.info(f"MI scores disponibles: {list(mi_scores.keys())}")
        
        # Realizar predicción con la RED NEURONAL (siempre)
        logger.info("Realizando predicción con red neuronal...")
        recommendations = neural_service.predict_careers(
            mbti_code=profile_data.mbti_result.MBTI_code,
            mbti_vector=mbti_vector,
            mbti_weights=mbti_weights,
            mi_scores=mi_scores,
            top_n=profile_data.num_recommendations or 5
        )
        logger.info(f"Recomendaciones generadas: {len(recommendations)}")
        
        # Si se solicita análisis, generar con LLM
        if profile_data.include_analysis:
            logger.info("Generando análisis con LLM...")
            
            # Crear texto MI para el prompt
            mi_sorted = sorted(mi_scores.items(), key=lambda x: x[1], reverse=True)
            mi_text = "\n".join([f"- {name}: {score:.2f}" for name, score in mi_sorted])
            logger.info(f"MI texto para análisis: {mi_text[:100]}...")
            
            # Generar prompt para análisis
            prompt = llm_service.generate_career_analysis_prompt(
                mbti_code=profile_data.mbti_result.MBTI_code,
                mi_scores=mi_scores,
                career_recommendations=recommendations
            )
            logger.info(f"Prompt para análisis generado: {len(prompt)} caracteres")
            
            # Llamar al LLM para análisis
            llm_analysis = await llm_api_service.call_llm(prompt=prompt)
            logger.info(f"Análisis recibido del LLM: {len(llm_analysis)} caracteres")
            
            # Procesar respuesta
            analysis_result = llm_service.process_career_analysis_response(llm_analysis)
            logger.info("Análisis procesado correctamente")
            
            # Añadir análisis a la respuesta
            response = {
                "recommendations": recommendations,
                "analysis": analysis_result["analysis"]
            }
        else:
            logger.info("No se solicitó análisis LLM")
            # Solo devolver recomendaciones
            response = {
                "recommendations": recommendations
            }
        
        logger.info("Proceso de recomendación completado exitosamente")
        return response
        
    except Exception as e:
        logger.error(f"Error en recomendación de carreras: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error generando recomendaciones: {str(e)}"
        ) 