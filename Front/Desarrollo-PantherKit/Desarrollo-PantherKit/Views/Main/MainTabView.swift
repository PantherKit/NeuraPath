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
    
    // Toast Manager reference
    private let toastManager = ToastManager.shared
    
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
                            // Desactivar toasts durante la transición
                            toastManager.enableToasts(false)
                            
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
                    .onAppear {
                        // No mostrar toasts en la pantalla de bienvenida
                        toastManager.enableToasts(false)
                    }

                case .explanationAfterWelcome:
                    ExplanationTransitionView(
                        title: "¡Bienvenido al test STEM!",
                        explanationText: "¿Estás listo para emprender este viaje?",
                        iconName: "person.crop.circle",
                        duration: 2.0,
                        onContinue: {
                            flowStep = .avatarSelection
                            // Habilitar toasts a partir de la selección de avatar
                            toastManager.enableToasts(true)
                        }
                    )
                    .onAppear {
                        // No mostrar toasts durante las explicaciones
                        toastManager.enableToasts(false)
                    }
                    

                case .avatarSelection:
                    AvatarSelectionView(
                        viewModel: viewModel,
                        onContinue: {
                            flowStep = .explanationAfterAvatar
                            // Pausar toasts durante la explicación
                            toastManager.enableToasts(false)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .top)
                    ))
                    .onAppear {
                        // Habilitar toasts durante la selección de avatar
                        toastManager.enableToasts(true)
                    }

                case .explanationAfterAvatar:
                    ExplanationTransitionView(
                        title: "Conociéndote mejor",
                        explanationText: "Nos contarás qué prefieres entre dos opciones, ¿Estás listo?",
                        iconName: "questionmark.circle",
                        duration: 2.0,
                        onContinue: {
                            flowStep = .vocationalQuiz
                            // Habilitar toasts durante el cuestionario
                            toastManager.enableToasts(true)
                        }
                    )
                    .onAppear {
                        // No mostrar toasts durante las explicaciones
                        toastManager.enableToasts(false)
                    }

                case .vocationalQuiz:
                    DeckViewWrapper(
                        onComplete: {
                            flowStep = .explanationAfterQuiz
                            // Pausar toasts durante la explicación
                            toastManager.enableToasts(false)
                        },
                        viewModel: viewModel
                    )
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        // Habilitar toasts durante el cuestionario
                        toastManager.enableToasts(true)
                    }

                case .explanationAfterQuiz:
                    ExplanationTransitionView(
                        title: "Casi terminamos",
                        explanationText: "Toma una decisión rápida según tu intuición. No pienses mucho en la respuesta, solo hazlo.",
                        iconName: "bolt.circle",
                        duration: 2.0,
                        onContinue: {
                            flowStep = .quickDecision
                            // Habilitar toasts durante la decisión rápida
                            toastManager.enableToasts(true)
                        }
                    )
                    .onAppear {
                        // No mostrar toasts durante las explicaciones
                        toastManager.enableToasts(false)
                    }

                case .quickDecision:
                    QuickDecisionView(
                        viewModel: viewModel,
                        onContinue: {
                            // ✅ LLAMA A completeTest() AQUÍ
                            viewModel.completeTest()
                            
                            // Desactivar toasts durante la carga
                            toastManager.enableToasts(false)
                            
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
                                    
                                    // Habilitar toasts en la pantalla de resultados
                                    toastManager.enableToasts(true)
                                }
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        // Habilitar toasts durante la decisión rápida
                        toastManager.enableToasts(true)
                    }

                case .loadingResults:
                    EmptyView()
                    .onAppear {
                        // No mostrar toasts durante la carga
                        toastManager.enableToasts(false)
                    }

                case .results:
                    ResultsView(
                        viewModel: viewModel
                    )
                    .transition(.move(edge: .leading))
                    .onAppear {
                        // Habilitar toasts en la pantalla de resultados
                        toastManager.enableToasts(true)
                        
                        // Mostrar un toast específico sobre resultados después de un breve retraso
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            toastManager.showRandomToast()
                        }
                    }
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
