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
    @State private var flowStep: FlowStep = .welcome
    @StateObject private var viewModel = VocationalTestViewModel()
    @State private var showLoading = false
    @State private var loadingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Fondo común para todas las vistas
            Color.black.ignoresSafeArea()
            
            // Contenido principal con transiciones
            Group {
                switch flowStep {
                case .welcome:
                    WelcomeView(
                        viewModel: viewModel,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showLoading = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    loadingOffset = UIScreen.main.bounds.height
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    flowStep = .avatarSelection
                                    showLoading = false
                                    loadingOffset = 0
                                }
                            }
                        }
                    )
                    .transition(.opacity)
                    
                case .avatarSelection:
                    AvatarSelectionView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .vocationalQuiz
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .top)
                    )) // Aquí faltaba este paréntesis de cierre
                    
                case .vocationalQuiz:
                    DeckViewWrapper(
                        onComplete: {
                            flowStep = .quickDecision
                        },
                        viewModel: viewModel
                    )
                    .transition(.move(edge: .trailing))
                    
                case .quickDecision:
                    QuickDecisionView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .results
                        }
                    )
                    .transition(.move(edge: .trailing))
                    
                case .results:
                    ResultsView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .welcome
                        }
                    )
                    .transition(.move(edge: .leading))
                }
            }
            
            // Loading View con transición
            if showLoading {
                LoadingView()
                    .offset(y: loadingOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top),
                        removal: .move(edge: .bottom)
                    ))
                    .zIndex(1) // Asegura que esté por encima de otras vistas
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
