//
//  MainAppView.swift
//  NeuraPath
//
//  Created for Clean Architecture refactoring
//

import SwiftUI
import Foundation

/// Vista principal de la aplicación que usa coordinators
/// Reemplaza a MainTabView con una arquitectura más limpia
struct MainAppView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    
    // Toast Manager reference
    private let toastManager = ToastManager.shared
    
    var body: some View {
        ZStack {
            // Fondo común para todas las vistas
            Color.black.ignoresSafeArea()
            
            // Contenido principal basado en el coordinator
            Group {
                switch appCoordinator.currentFlow {
                case .onboarding:
                    if let coordinator = appCoordinator.onboardingCoordinator {
                        OnboardingFlowView(coordinator: coordinator)
                            .transition(.opacity)
                    } else {
                        LoadingView()
                    }
                        
                case .test:
                    if let coordinator = appCoordinator.testCoordinator {
                        TestFlowView(coordinator: coordinator)
                            .transition(.move(edge: .trailing))
                    } else {
                        LoadingView()
                    }
                        
                case .results:
                    if let coordinator = appCoordinator.resultsCoordinator {
                        ResultsFlowView(coordinator: coordinator)
                            .transition(.move(edge: .leading))
                    } else {
                        LoadingView()
                    }
                }
            }
        }
        .onAppear {
            appCoordinator.start()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Flow Views

/// Vista que maneja el flujo de onboarding
struct OnboardingFlowView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    
    var body: some View {
        ZStack {
            // Contenido del onboarding
            Group {
                switch coordinator.currentStep {
                case .welcome:
                    WelcomeView(
                        viewModel: coordinator.viewModel,
                        onContinue: {
                            coordinator.moveToExplanationAfterWelcome()
                        }
                    )
                    
                case .explanationAfterWelcome:
                    ExplanationTransitionView(
                        title: "¡Bienvenido al test STEM!",
                        explanationText: "¿Estás listo para emprender este viaje?",
                        iconName: "person.crop.circle",
                        duration: 2.0,
                        onContinue: {
                            coordinator.moveToAvatarSelection()
                        }
                    )
                    
                case .avatarSelection:
                    AvatarSelectionView(
                        viewModel: coordinator.viewModel,
                        onContinue: {
                            coordinator.moveToExplanationAfterAvatar()
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
                            coordinator.completeOnboarding()
                        }
                    )
                }
            }
            
            // Loading overlay para onboarding
            if coordinator.shouldShowLoading {
                LoadingView()
                    .offset(y: coordinator.currentLoadingOffset)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top),
                        removal: .move(edge: .bottom)
                    ))
                    .zIndex(1)
            }
        }
    }
}

/// Vista que maneja el flujo del test
struct TestFlowView: View {
    @ObservedObject var coordinator: TestCoordinator
    
    var body: some View {
        Group {
            switch coordinator.currentStep {
            case .vocationalQuiz:
                DeckViewWrapper(
                    onComplete: {
                        coordinator.moveToExplanationAfterQuiz()
                    },
                    viewModel: coordinator.viewModel
                )
                
            case .explanationAfterQuiz:
                ExplanationTransitionView(
                    title: "Casi terminamos",
                    explanationText: "Toma una decisión rápida según tu intuición. No pienses mucho en la respuesta, solo hazlo.",
                    iconName: "bolt.circle",
                    duration: 2.0,
                    onContinue: {
                        coordinator.moveToQuickDecision()
                    }
                )
                
            case .quickDecision:
                QuickDecisionView(
                    viewModel: coordinator.viewModel,
                    onContinue: {
                        coordinator.completeTest()
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
    }
}

/// Vista que maneja el flujo de resultados
struct ResultsFlowView: View {
    @ObservedObject var coordinator: ResultsCoordinator
    
    var body: some View {
        ZStack {
            Group {
                switch coordinator.currentStep {
                case .loadingResults:
                    EmptyView()
                    
                case .results:
                    GalaxyResultsView(viewModel: coordinator.viewModel)
                    
                case .careerDetails:
                    // TODO: Implementar vista de detalles de carrera
                    EmptyView()
                }
            }
            
            // Loading overlay para resultados
            if coordinator.shouldShowResultsLoading {
                ResultsLoadingView()
                    .offset(y: coordinator.currentResultsLoadingOffset)
                    .animation(.spring(response: 0.7, dampingFraction: 0.6), value: coordinator.currentResultsLoadingOffset)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .zIndex(2)
            }
        }
    }
}

#if DEBUG
struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
#endif 