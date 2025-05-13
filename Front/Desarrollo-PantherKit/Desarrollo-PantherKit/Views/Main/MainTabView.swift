import SwiftUI

enum FlowStep {
    case welcome
    case avatarSelection
    case vocationalQuiz
    case quickDecision
    case loadingResults // Nuevo paso para la pantalla de carga
    case results
}

struct MainTabView: View {
    @State private var flowStep: FlowStep = .welcome
    @StateObject private var viewModel = VocationalTestViewModel()
    @State private var showLoading = false
    @State private var loadingOffset: CGFloat = 0
    @State private var showResultsLoading = false
    
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
                    ))
                    
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
                            // Mostrar pantalla de carga de resultados
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showResultsLoading = true
                            }
                            
                            // Simular tiempo de procesamiento (3 segundos)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                flowStep = .results
                                showResultsLoading = false
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                    
                case .loadingResults:
                    // Esta opción no se usa directamente, manejamos la pantalla de carga con el estado showResultsLoading
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
                    .transition(.opacity)
                    .zIndex(2) // Mayor zIndex para que aparezca sobre QuickDecision
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
