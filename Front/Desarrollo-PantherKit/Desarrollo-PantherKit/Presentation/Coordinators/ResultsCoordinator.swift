//
//  ResultsCoordinator.swift
//  NeuraPath
//
//  Created for Clean Architecture refactoring
//

import SwiftUI

/// Estados del flujo de resultados
enum ResultsStep {
    case loadingResults
    case results
    case careerDetails
}

/// Coordinador para el flujo de resultados
/// Maneja: Loading → Results → Career Details
@MainActor
final class ResultsCoordinator: Coordinator {
    // MARK: - Published Properties
    @Published var currentStep: ResultsStep = .loadingResults
    @Published var navigationState: NavigationState = .idle
    @Published var showResultsLoading = false
    @Published var resultsLoadingOffset: CGFloat = UIScreen.main.bounds.height
    
    // MARK: - Dependencies
    weak var delegate: CoordinatorDelegate?
    private let container: DIContainer
    
    // MARK: - Shared State
    @Published var viewModel: VocationalTestViewModel
    
    // MARK: - Initialization
    init(container: DIContainer = DIContainer.shared) {
        self.container = container
        self.viewModel = VocationalTestViewModel() // TODO: Inject in Phase 2
    }
    
    // MARK: - Coordinator Protocol
    func start() {
        startResultsLoading()
    }
    
    func finish() {
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - Navigation Methods
    private func startResultsLoading() {
        currentStep = .loadingResults
        showResultsLoading = true
        
        DispatchQueue.main.async { [weak self] in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                self?.resultsLoadingOffset = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.moveToResults()
        }
    }
    
    func moveToResults() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = .results
            showResultsLoading = false
            resultsLoadingOffset = UIScreen.main.bounds.height
        }
    }
    
    func moveToCareerDetails() {
        currentStep = .careerDetails
    }
    
    func restartTest() {
        // En el futuro, esto podría reiniciar toda la app
        finish()
    }
    
    // MARK: - Public Interface for Views
    var shouldShowResultsLoading: Bool {
        return showResultsLoading
    }
    
    var currentResultsLoadingOffset: CGFloat {
        return resultsLoadingOffset
    }
} 