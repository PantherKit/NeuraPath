//
//  TestCoordinator.swift
//  NeuraPath - Simplified for Frontend-Only Architecture
//

import SwiftUI

/// Estados del flujo del test vocacional
enum TestStep {
    case vocationalQuiz
    case explanationAfterQuiz
    case quickDecision
}

/// Coordinador para el flujo del test vocacional
/// Maneja: Vocational Quiz → Explanation → Quick Decision
@MainActor
final class TestCoordinator: Coordinator {
    // MARK: - Published Properties
    @Published var currentStep: TestStep = .vocationalQuiz
    @Published var navigationState: NavigationState = .idle
    
    // MARK: - Dependencies
    weak var delegate: CoordinatorDelegate?
    private let container: DIContainer
    
    // MARK: - Shared State
    @Published var viewModel: VocationalTestViewModel
    
    // MARK: - Initialization
    init(container: DIContainer = DIContainer.shared) {
        self.container = container
        self.viewModel = container.makeVocationalTestViewModel()
    }
    
    // MARK: - Coordinator Protocol
    func start() {
        currentStep = .vocationalQuiz
        navigationState = .idle
    }
    
    func finish() {
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - Navigation Methods
    func moveToExplanationAfterQuiz() {
        currentStep = .explanationAfterQuiz
    }
    
    func moveToQuickDecision() {
        currentStep = .quickDecision
    }
    
    func completeTest() {
        viewModel.completeTest()
        finish()
    }
} 