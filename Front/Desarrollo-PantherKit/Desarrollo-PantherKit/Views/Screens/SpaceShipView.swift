import SwiftUI

// ---------- MODEL ----------
struct Question {
    let prompt: String
    let answers: [String]
    let correct: Int
}

// ---------- MAIN VIEW ----------
struct SpaceQuizView: View {
    
    // MARK: – Quiz state
    @State private var index = 0
    @State private var questions: [Question] = [
        Question(prompt: "First woman to travel to space?",
                 answers: ["Valentina Tereshkova", "Mae Jemison", "Sally Ride"],
                 correct: 0),
        Question(prompt: "Unit of electrical resistance?",
                 answers: ["Pascal", "Ohm", "Newton"],
                 correct: 1),
        Question(prompt: "Chemical symbol for gold?",
                 answers: ["Ag", "Au", "Ga"],
                 correct: 1)
    ]
    
    // MARK: – Animation state
    @State private var shipOffset: CGFloat = 0          // y‑offset
    @State private var exhaustPulse = false             // exhaust flicker
    
    // convenience
    private var finished: Bool { index >= questions.count }
    
    var body: some View {
        ZStack {
            // 1️⃣  Animated star‑field
            StarField()
            
            VStack(spacing: 32) {
                
                // 2️⃣  Flying ship
                LottieView(filename: "rocket_landing", loopMode: .loop)
                    .frame(width: 120, height: 120)
                    .offset(y: shipOffset)
                    .animation(.interpolatingSpring(mass: 0.7, stiffness: 120,
                                                    damping: 15),
                               value: shipOffset)
                    .overlay(ExhaustFlame(pulse: $exhaustPulse)
                                 .offset(y: 60))
                    .onAppear { exhaustPulse.toggle() }
                
                // 3️⃣  Question / Result
                if finished {
                    Text("Mission completed! 🏁")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                } else {
                    QuestionCard(q: questions[index],
                                 answerAction: answerTapped)
                }
            }
            .padding()
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
    
    // MARK: – Logic
    private func answerTapped(_ answerIdx: Int) {
        // Only accelerate on correct answer
        if answerIdx == questions[index].correct {
            withAnimation {
                shipOffset -= 120            // move the rocket upward
            }
        }
        index += 1
    }
}

// ---------- QUESTION CARD ----------
struct QuestionCard: View {
    let q: Question
    var answerAction: (Int)->Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(q.prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            ForEach(q.answers.indices, id: \.self) { i in
                Button {
                    answerAction(i)
                } label: {
                    Text(q.answers[i])
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

// ---------- EXHAUST FLAME ----------
struct ExhaustFlame: View {
    @Binding var pulse: Bool
    
    var body: some View {
        Text("🟠")
            .font(.system(size: 30))
            .scaleEffect(pulse ? 0.6 : 1)
            .opacity(pulse ? 0.4 : 1)
            .animation(.easeInOut(duration: 0.4).repeatForever(),
                       value: pulse)
    }
}

// ---------- STAR‑FIELD ----------

// ---------- PREVIEW ----------
#Preview {
    SpaceQuizView()
}
