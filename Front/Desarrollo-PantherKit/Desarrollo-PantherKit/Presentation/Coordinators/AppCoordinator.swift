//
//  AppCoordinator.swift
//  NeuraPath
//
//  Created for Clean Architecture refactoring
//

import SwiftUI

/// Estados principales del flujo de la aplicación
enum AppFlow {
    case onboarding
    case test
    case results
}

/// Coordinador principal de la aplicación
/// Reemplaza el FlowStep de MainTabView y maneja la navegación principal
@MainActor
final class AppCoordinator: ParentCoordinator {
    // MARK: - Published Properties
    @Published var currentFlow: AppFlow = .onboarding
    @Published var navigationState: NavigationState = .idle
    
    // MARK: - Child Coordinators
    var childCoordinators: [any Coordinator] = []
    
    // MARK: - Dependencies
    private let container: DIContainer
    
    // MARK: - Child Coordinator References
    var onboardingCoordinator: OnboardingCoordinator?
    var testCoordinator: TestCoordinator?
    var resultsCoordinator: ResultsCoordinator?
    
    // MARK: - Initialization
    init(container: DIContainer = DIContainer.shared) {
        self.container = container
        // Inicializar el coordinator de onboarding inmediatamente
        self.onboardingCoordinator = OnboardingCoordinator(container: container)
    }
    
    // MARK: - Coordinator Protocol
    func start() {
        startOnboarding()
    }
    
    func finish() {
        childCoordinators.removeAll()
        onboardingCoordinator = nil
        testCoordinator = nil
        resultsCoordinator = nil
    }
    
    // MARK: - ParentCoordinator Protocol
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator as AnyObject }
    }
    
    // MARK: - Navigation Methods
    private func startOnboarding() {
        currentFlow = .onboarding
        navigationState = .idle
        
        // Si no existe el coordinator, crearlo
        if onboardingCoordinator == nil {
            onboardingCoordinator = OnboardingCoordinator(container: container)
        }
        
        guard let coordinator = onboardingCoordinator else { return }
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startTest() {
        currentFlow = .test
        navigationState = .idle
        
        // Limpiar onboarding
        if let onboarding = onboardingCoordinator {
            removeChild(onboarding)
            onboardingCoordinator = nil
        }
        
        // Crear coordinator de test
        if testCoordinator == nil {
            testCoordinator = TestCoordinator(container: container)
        }
        
        guard let coordinator = testCoordinator else { return }
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startResults() {
        currentFlow = .results
        navigationState = .idle
        
        // Limpiar test
        if let test = testCoordinator {
            removeChild(test)
            testCoordinator = nil
        }
        
        // Crear coordinator de resultados
        if resultsCoordinator == nil {
            resultsCoordinator = ResultsCoordinator(container: container)
        }
        
        guard let coordinator = resultsCoordinator else { return }
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
    }
    
    // MARK: - Public Interface
    func moveToTest() {
        startTest()
    }
    
    func moveToResults() {
        startResults()
    }
    
    func restartApp() {
        finish()
        start()
    }
}

// MARK: - CoordinatorDelegate
extension AppCoordinator: CoordinatorDelegate {
    func coordinatorDidFinish(_ coordinator: any Coordinator) {
        removeChild(coordinator)
        
        switch coordinator {
        case is OnboardingCoordinator:
            onboardingCoordinator = nil
            startTest()
            
        case is TestCoordinator:
            testCoordinator = nil
            startResults()
            
        case is ResultsCoordinator:
            resultsCoordinator = nil
            // Podrías reiniciar la app o hacer otra acción
            
        default:
            break
        }
    }
} 