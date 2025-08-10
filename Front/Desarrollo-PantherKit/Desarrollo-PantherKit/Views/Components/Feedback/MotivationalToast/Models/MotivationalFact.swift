import Foundation

struct MotivationalFact: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    
    static var random: MotivationalFact { allFacts.randomElement()! }
    
    static let allFacts: [MotivationalFact] = [
        MotivationalFact(title: "Ada Lovelace", message: "Considerada la primera programadora de la historia, escribió el primer algoritmo para ser procesado por una máquina en 1843.", icon: "laptopcomputer"),
        MotivationalFact(title: "¿Sabías que?", message: "Marie Curie fue la primera persona en recibir dos premios Nobel en distintas disciplinas científicas: Física y Química.", icon: "atom"),
        MotivationalFact(title: "Katherine Johnson", message: "Sus cálculos matemáticos fueron fundamentales para las primeras misiones espaciales de la NASA. Su historia inspiró la película 'Figuras Ocultas'.", icon: "airplane"),
        MotivationalFact(title: "Dato curioso", message: "Grace Hopper, pionera en programación, acuñó el término 'bug' cuando encontró un insecto real causando un error en una computadora.", icon: "ladybug"),
        MotivationalFact(title: "Hedy Lamarr", message: "Además de ser actriz de Hollywood, inventó un sistema de comunicaciones que es la base del WiFi, GPS y Bluetooth que usamos hoy.", icon: "wifi"),
        MotivationalFact(title: "Rosalyn Yalow", message: "Desarrolló la técnica del radioinmunoensayo, revolucionando el diagnóstico médico, a pesar de que inicialmente le negaron un puesto de asistente graduada por ser mujer.", icon: "cross.case"),
        MotivationalFact(title: "Dato inspirador", message: "El 40% de los graduados en matemáticas son mujeres. ¡Las mujeres tienen un papel fundamental en el futuro de STEM!", icon: "percent"),
        MotivationalFact(title: "Ellen Ochoa", message: "Primera mujer hispana en viajar al espacio y ex directora del Centro Espacial Johnson de la NASA.", icon: "sparkles"),
        MotivationalFact(title: "Ángela Ruiz Robles", message: "Maestra e inventora española, creó en 1949 la 'Enciclopedia Mecánica', considerada precursora del libro electrónico actual.", icon: "book"),
        MotivationalFact(title: "¿Lo sabías?", message: "Los equipos diversos que incluyen mujeres tienen un 40% más de probabilidades de desarrollar patentes más innovadoras.", icon: "person.3"),
        MotivationalFact(title: "Margarita Salas", message: "Bioquímica española cuyas investigaciones sobre el ADN han sido fundamentales para la biología molecular. Su patente ha sido la más rentable en la historia del CSIC.", icon: "dna"),
        MotivationalFact(title: "Mary Jackson", message: "Primera ingeniera afroamericana en la NASA, superó barreras de segregación racial para conseguir su título y contribuir a la ingeniería aeroespacial.", icon: "paperplane"),
        MotivationalFact(title: "Dato motivador", message: "Las empresas con mayor representación femenina en ingeniería y tecnología reportan un 34% mayor retorno a los accionistas.", icon: "chart.line.uptrend.xyaxis"),
        MotivationalFact(title: "¡Tú puedes!", message: "Las mujeres en STEM ganan un 35% más que las mujeres en otros campos profesionales. ¡Las carreras STEM abren puertas!", icon: "dollarsign.circle"),
        MotivationalFact(title: "Frances Allen", message: "Primera mujer en ganar el Premio Turing (el 'Nobel de la Computación') por sus contribuciones pioneras a la teoría y práctica de la optimización de compiladores.", icon: "gearshape")
    ]
}


