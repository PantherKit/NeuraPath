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
    @State private var isTransitioningToAvatar = false

    var body: some View {
        VStack(spacing: 0) {
            // 3️⃣ Aquí mostramos la vista según el paso actual
            Group {
                switch flowStep {
                case .welcome:
                    WelcomeView(
                        viewModel: viewModel,
                        onContinue: {
                            withAnimation {
                                isTransitioningToAvatar = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                flowStep = .avatarSelection
                                isTransitioningToAvatar = false
                            }
                        }
                    )

                case .avatarSelection:
                    if !isTransitioningToAvatar {
                        AvatarSelectionView(
                            viewModel: viewModel,
                            onContinue: {
                                flowStep = .vocationalQuiz
                            }
                        )
                    }

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

            if flowStep != .welcome {
                HStack(spacing: 12) {
                    ForEach([FlowStep.avatarSelection, .vocationalQuiz, .quickDecision, .results], id: \.self) { step in
                        Circle()
                            .fill(flowStep == step ? Color.blue : AppTheme.Colors.secondaryText.opacity(0.3))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.Colors.primary.opacity(flowStep == step ? 1 : 0.5), lineWidth: flowStep == step ? 2 : 1)
                            )
                            .animation(.easeInOut, value: flowStep)
                    }
                }
                .padding(.vertical, 12)
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
