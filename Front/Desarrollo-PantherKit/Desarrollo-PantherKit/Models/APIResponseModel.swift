import Foundation

struct APIResponse: Codable {
    let status: String
    let message: String
    let responseId: Int
    let llmResultId: Int
    let llmProvider: String
    let mbtiProfile: MBTIProfile
    let miScores: MIScores
    let miRanking: [String]
    let careerRecommendations: [CareerRecommendation]
    let careerAnalysis: String?
    let detailedAnalysis: DetailedAnalysis?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case responseId = "response_id"
        case llmResultId = "llm_result_id"
        case llmProvider = "llm_provider"
        case mbtiProfile = "mbti_profile"
        case miScores = "mi_scores"
        case miRanking = "mi_ranking"
        case careerRecommendations = "career_recommendations"
        case careerAnalysis = "career_analysis"
        case detailedAnalysis = "detailed_analysis"
    }
    
    var analysis: DetailedAnalysis? {
        if let structuredAnalysis = detailedAnalysis {
            return structuredAnalysis
        }
        
        if let textAnalysis = careerAnalysis, !textAnalysis.isEmpty {
            return DetailedAnalysis(
                personalitySummary: extractSection(from: textAnalysis, header: "Por qué estas carreras son adecuadas para este perfil específico") ?? "Análisis de personalidad no disponible",
                intelligencesSummary: extractSection(from: textAnalysis, header: "Cómo las inteligencias múltiples del usuario se relacionan con las demandas de cada carrera") ?? "Análisis de inteligencias no disponible",
                recommendationRationale: extractSection(from: textAnalysis, header: "Cómo las características del perfil MBTI se alinean con cada carrera recomendada") ?? "Justificación de recomendaciones no disponible",
                suggestedSkills: extractList(from: textAnalysis, header: "Qué habilidades específicas podría desarrollar el usuario"),
                opportunities: extractOpportunities(from: textAnalysis),
                challenges: extractChallenges(from: textAnalysis)
            )
        }
        
        return nil
    }
    
    private func extractSection(from text: String, header: String) -> String? {
        if let range = text.range(of: header) {
            let startIndex = range.upperBound
            
            let nextHeaderKeywords = ["###", "Conclusión", "Oportunidades y desafíos"]
            var endIndex = text.endIndex
            
            for keyword in nextHeaderKeywords {
                if let nextRange = text.range(of: keyword, range: startIndex..<text.endIndex) {
                    endIndex = nextRange.lowerBound
                    break
                }
            }
            
            let sectionText = text[startIndex..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            return sectionText
        }
        return nil
    }
    
    private func extractList(from text: String, header: String) -> [String] {
        if let section = extractSection(from: text, header: header) {
            let patterns = ["- **([^:]*):**", "•\\s*([^•\\n]+)", "\\d+\\.\\s*([^\\n]+)"]
            var items = [String]()
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let nsString = section as NSString
                    let matches = regex.matches(in: section, options: [], range: NSRange(location: 0, length: nsString.length))
                    
                    for match in matches {
                        if match.numberOfRanges > 1 {
                            let itemRange = match.range(at: 1)
                            let item = nsString.substring(with: itemRange).trimmingCharacters(in: .whitespacesAndNewlines)
                            items.append(item)
                        }
                    }
                }
            }
            
            if items.isEmpty {
                items = section.split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
            
            return items
        }
        return ["Desarrollar habilidades técnicas relacionadas con la carrera", 
                "Mejorar capacidades de comunicación y trabajo en equipo", 
                "Fortalecer conocimientos en matemáticas y ciencias"]
    }
    
    private func extractOpportunities(from text: String) -> [String] {
        if let section = extractSection(from: text, header: "Oportunidades y desafíos") {
            if let opportunitiesText = section.split(separator: "Desafíos").first {
                let items = opportunitiesText.split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && !$0.contains("Oportunidades:") }
                
                if !items.isEmpty {
                    return items.map { String($0) }
                }
            }
        }
        return ["Trabajar en proyectos innovadores y de impacto social",
                "Desarrollar soluciones creativas a problemas importantes",
                "Contribuir al cuidado del medio ambiente"]
    }
    
    private func extractChallenges(from text: String) -> [String] {
        if let section = extractSection(from: text, header: "Oportunidades y desafíos") {
            if let parts = section.split(separator: "Desafíos").last {
                let items = parts.split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                if !items.isEmpty {
                    return items.map { String($0) }
                }
            }
        }
        return ["Adaptarse a entornos técnicos y cuantitativos",
                "Mejorar habilidades de comunicación interpersonal",
                "Equilibrar idealismo con practicidad en soluciones"]
    }
    
    // Método público para verificar si se puede generar análisis para una carrera
    func canGenerateAnalysisFor(careerName: String) -> Bool {
        guard let textAnalysis = careerAnalysis, !textAnalysis.isEmpty else {
            return false
        }
        
        return !findMentionsOfCareer(careerName, in: textAnalysis).isEmpty
    }
    
    // Genera análisis para una carrera específica basado en el texto completo
    func generateCareerAnalysis(for careerName: String) -> CareerAnalysis? {
        guard let textAnalysis = careerAnalysis, !textAnalysis.isEmpty else {
            return nil
        }
        
        // Buscar menciones específicas de esta carrera en el texto
        let careerMentions = findMentionsOfCareer(careerName, in: textAnalysis)
        if careerMentions.isEmpty {
            return nil
        }
        
        // Extraer secciones relevantes para esta carrera
        let personalityFit = extractRelevantSectionForCareer(
            from: textAnalysis,
            careerName: careerName,
            header: "Cómo las características del perfil MBTI se alinean con cada carrera recomendada"
        )
        
        let intelligencesFit = extractRelevantSectionForCareer(
            from: textAnalysis,
            careerName: careerName,
            header: "Cómo las inteligencias múltiples del usuario se relacionan con las demandas de cada carrera"
        )
        
        // Crear una lista de habilidades relevantes
        let skillsSection = extractSection(from: textAnalysis, header: "Qué habilidades específicas podría desarrollar el usuario")
        let skills = extractList(from: textAnalysis, header: "Qué habilidades específicas podría desarrollar el usuario")
        
        // Crear un resumen de por qué se recomienda esta carrera
        let whyRecommended = generateWhyRecommended(for: careerName, from: textAnalysis, mentions: careerMentions)
        
        return CareerAnalysis(
            personalityFit: personalityFit ?? "Tu perfil MBTI se alinea bien con las demandas de esta carrera",
            intelligencesFit: intelligencesFit ?? "Tus inteligencias múltiples te dan una base sólida para esta carrera",
            skillsToFocus: skills,
            whyRecommended: whyRecommended
        )
    }
    
    // Encuentra todas las menciones de una carrera específica en el texto
    private func findMentionsOfCareer(_ careerName: String, in text: String) -> [String] {
        // Buscar menciones explícitas
        let careerNameLower = careerName.lowercased()
        let textLower = text.lowercased()
        
        var mentions = [String]()
        let sentences = text.components(separatedBy: ". ")
        
        for sentence in sentences {
            if sentence.lowercased().contains(careerNameLower) {
                mentions.append(sentence.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        // Si no hay menciones explícitas, buscar menciones por campo general
        if mentions.isEmpty {
            // Extraer campo general de la carrera (ej. "Ingeniería" de "Ingeniería Química")
            let words = careerName.components(separatedBy: " ")
            if words.count > 1, let field = words.first {
                for sentence in sentences {
                    if sentence.lowercased().contains(field.lowercased()) {
                        mentions.append(sentence.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
        }
        
        return mentions
    }
    
    // Extrae la sección relevante para una carrera específica
    private func extractRelevantSectionForCareer(from text: String, careerName: String, header: String) -> String? {
        if let section = extractSection(from: text, header: header) {
            // Buscar la parte específica sobre esta carrera
            let sentences = section.components(separatedBy: ". ")
            var relevantSentences = [String]()
            
            // Buscar por nombre de carrera
            let careerNameLower = careerName.lowercased()
            for sentence in sentences {
                if sentence.lowercased().contains(careerNameLower) {
                    relevantSentences.append(sentence.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            
            // Si no hay menciones específicas, buscar por campo general
            if relevantSentences.isEmpty {
                let words = careerName.components(separatedBy: " ")
                if words.count > 1, let field = words.first {
                    for sentence in sentences {
                        if sentence.lowercased().contains(field.lowercased()) {
                            relevantSentences.append(sentence.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                }
            }
            
            // Si aún no hay menciones, tomar el primer punto del párrafo general
            if relevantSentences.isEmpty && !sentences.isEmpty {
                relevantSentences.append(sentences[0].trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            if !relevantSentences.isEmpty {
                return relevantSentences.joined(separator: ". ") + "."
            }
        }
        
        return nil
    }
    
    // Genera un texto explicando por qué se recomienda esta carrera
    private func generateWhyRecommended(for careerName: String, from text: String, mentions: [String]) -> String {
        // Si tenemos menciones específicas, usarlas
        if !mentions.isEmpty {
            return mentions.joined(separator: ". ") + "."
        }
        
        // Si no, generar un texto basado en el análisis general
        if let personalitySummary = extractSection(from: text, header: "Por qué estas carreras son adecuadas para este perfil específico") {
            return "La carrera de \(careerName) se alinea bien con tu perfil. \(personalitySummary.components(separatedBy: ". ").first ?? "")"
        }
        
        // Texto por defecto
        return "La carrera de \(careerName) se recomienda porque se alinea con tus características de personalidad e inteligencias múltiples, ofreciéndote un camino profesional donde podrás aplicar tus habilidades naturales mientras contribuyes significativamente en un campo importante."
    }
}

struct MBTIProfile: Codable {
    let code: String
    let weights: MBTIWeights
    let vector: [Int]
}

struct MBTIWeights: Codable {
    let ei: Double
    let sn: Double
    let tf: Double
    let jp: Double
    
    enum CodingKeys: String, CodingKey {
        case ei = "E/I"
        case sn = "S/N"
        case tf = "T/F"
        case jp = "J/P"
    }
}

struct MIScores: Codable {
    let linguistic: Double
    let logicalMath: Double
    let spatial: Double
    let bodilyKinesthetic: Double
    let musical: Double
    let interpersonal: Double
    let intrapersonal: Double
    let naturalist: Double
    
    enum CodingKeys: String, CodingKey {
        case linguistic = "Lin"
        case logicalMath = "LogMath"
        case spatial = "Spa"
        case bodilyKinesthetic = "BodKin"
        case musical = "Mus"
        case interpersonal = "Inter"
        case intrapersonal = "Intra"
        case naturalist = "Nat"
    }
}

struct CareerRecommendation: Codable, Identifiable {
    var id: String { nombre + universidad }
    let nombre: String
    let universidad: String
    let ciudad: String
    let matchScore: Double
    let careerAnalysis: CareerAnalysis?
    
    enum CodingKeys: String, CodingKey {
        case nombre
        case universidad
        case ciudad
        case matchScore = "match_score"
        case careerAnalysis = "career_analysis"
    }
}

struct DetailedAnalysis: Codable {
    let personalitySummary: String
    let intelligencesSummary: String
    let recommendationRationale: String
    let suggestedSkills: [String]
    let opportunities: [String]
    let challenges: [String]
    
    enum CodingKeys: String, CodingKey {
        case personalitySummary = "personality_summary"
        case intelligencesSummary = "intelligences_summary"
        case recommendationRationale = "recommendation_rationale"
        case suggestedSkills = "suggested_skills"
        case opportunities
        case challenges
    }
}

struct CareerAnalysis: Codable {
    let personalityFit: String
    let intelligencesFit: String
    let skillsToFocus: [String]
    let whyRecommended: String
    
    enum CodingKeys: String, CodingKey {
        case personalityFit = "personality_fit"
        case intelligencesFit = "intelligences_fit"
        case skillsToFocus = "skills_to_focus"
        case whyRecommended = "why_recommended"
    }
}

extension ResponseService {
    /// Carga la respuesta de la API desde UserDefaults
    func loadAPIResponse() -> APIResponse? {
        guard let data = getLastAPIResponse() else {
            return nil
        }
        
        do {
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            return response
        } catch {
            print("Error decodificando respuesta de API: \(error)")
            return nil
        }
    }
} 