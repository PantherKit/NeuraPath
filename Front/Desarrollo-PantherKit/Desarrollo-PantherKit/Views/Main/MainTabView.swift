//  MainTabView.swift

import SwiftUI

// 1️⃣ Define tus pasos de flujo
enum FlowStep {
    case welcome
    case avatarSelection
    case vocationalQuiz
    case quickDecision
    case results
}

struct MainTabView: View {
    // 2️⃣ Estado de flujo
    @State private var flowStep: FlowStep = .welcome
    @StateObject private var viewModel = VocationalTestViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // 3️⃣ Aquí mostramos la vista según el paso actual
            Group {
                switch flowStep {
                case .welcome:
                    WelcomeView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .avatarSelection
                        }
                    )

                case .avatarSelection:
                    AvatarSelectionView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .vocationalQuiz
                        }
                    )

                case .vocationalQuiz:
                    DeckViewWrapper(
                        onComplete: {
                            flowStep = .quickDecision
                        },
                        viewModel: viewModel
                    )

                case .quickDecision:
                    QuickDecisionView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .results
                        }
                    )

                case .results:
                    ResultsView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .welcome
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 4️⃣ Barra de navegación inferior manual (opcional)
            if flowStep != .welcome {
                HStack {
                    Spacer()
                    Button(action: { flowStep = .welcome }) {
                        Label("Welcome", systemImage: "lightbulb.fill")
                    }
                    Spacer()
                    Button(action: { flowStep = .avatarSelection }) {
                        Label("Avatar", systemImage: "person.crop.circle")
                    }
                    Spacer()
                    Button(action: { flowStep = .vocationalQuiz }) {
                        Label("Quiz", systemImage: "rectangle.grid.2x2")
                    }
                    Spacer()
                    Button(action: { flowStep = .quickDecision }) {
                        Label("Decide", systemImage: "clock.fill")
                    }
                    Spacer()
                    Button(action: { flowStep = .results }) {
                        Label("Results", systemImage: "star.fill")
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(AppTheme.Colors.background)
            }
        }
        .ignoresSafeArea()
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
#endif
