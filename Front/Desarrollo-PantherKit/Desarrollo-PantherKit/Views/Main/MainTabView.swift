import SwiftUI

enum FlowStep {
    case welcome
    case explanationAfterWelcome
    case avatarSelection
    case explanationAfterAvatar
    case vocationalQuiz
    case explanationAfterQuiz
    case quickDecision
    case loadingResults
    case results
}

struct MainTabView: View {
    @State private var flowStep: FlowStep = .welcome
    @StateObject private var viewModel = VocationalTestViewModel()
    @State private var showLoading = false
    @State private var loadingOffset: CGFloat = 0
    @State private var showResultsLoading = false
    @State private var resultsLoadingOffset: CGFloat = UIScreen.main.bounds.height
    
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
                                    flowStep = .explanationAfterWelcome
                                    showLoading = false
                                    loadingOffset = 0
                                }
                            }
                        }
                    )
                    .transition(.opacity)

                case .explanationAfterWelcome:
                    ExplanationTransitionView(
                        title: "¡Bienvenido al test STEM!",
                        explanationText: "¿Estás listo para emprender este viaje?",
                        iconName: "person.crop.circle",
                        duration: 2.0,
                        onContinue: {
                            flowStep = .avatarSelection
                        }
                    )
                    

                case .avatarSelection:
                    AvatarSelectionView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .explanationAfterAvatar
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .top)
                    ))

                case .explanationAfterAvatar:
                    ExplanationTransitionView(
                        title: "Conociéndote mejor",
                        explanationText: "Nos contarás qué prefieres entre dos opciones, ¿Estás listo?",
                        iconName: "questionmark.circle",
                        duration: 2.0,
                        onContinue: {
                            flowStep = .vocationalQuiz
                        }
                    )

                case .vocationalQuiz:
                    DeckViewWrapper(
                        onComplete: {
                            flowStep = .explanationAfterQuiz
                        },
                        viewModel: viewModel
                    )
                    .transition(.move(edge: .trailing))

                case .explanationAfterQuiz:
                    ExplanationTransitionView(
                        title: "Casi terminamos",
                        explanationText: "Toma una decisión rápida según tu intuición. No pienses mucho en la respuesta, solo hazlo.",
                        iconName: "bolt.circle",
                        duration: 2.0,
                        onContinue: {
                            flowStep = .quickDecision
                        }
                    )

                case .quickDecision:
                    QuickDecisionView(
                        viewModel: viewModel,
                        onContinue: {
                            // Mostrar pantalla de carga de resultados
                            showResultsLoading = true

                            DispatchQueue.main.async {
                                withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                                    resultsLoadingOffset = 0
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    flowStep = .results
                                    showResultsLoading = false
                                    resultsLoadingOffset = UIScreen.main.bounds.height
                                }
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .loadingResults:
                    EmptyView()

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
            
            // Loading View inicial con transición
            if showLoading {
                LoadingView()
                    .offset(y: loadingOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top),
                        removal: .move(edge: .bottom)
                    ))
                    .zIndex(1)
            }
            
            // Loading View para resultados (sobrepuesta a QuickDecision)
            if showResultsLoading {
                ResultsLoadingView()
                    .offset(y: resultsLoadingOffset)
                    .animation(.spring(response: 0.7, dampingFraction: 0.6), value: resultsLoadingOffset)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .zIndex(2)
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
