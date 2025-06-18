//
//  OnboardingCoordinator.swift
//  NeuraPath
//
//  Created for Clean Architecture refactoring
//

import SwiftUI

/// Estados del flujo de onboarding
enum OnboardingStep {
    case welcome
    case explanationAfterWelcome
    case avatarSelection
    case explanationAfterAvatar
}

/// Coordinador para el flujo de onboarding
/// Maneja: Welcome → Explanation → Avatar Selection → Explanation
@MainActor
final class OnboardingCoordinator: Coordinator {
    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .welcome
    @Published var navigationState: NavigationState = .idle
    @Published var showLoading = false
    @Published var loadingOffset: CGFloat = 0
    
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
        currentStep = .welcome
        navigationState = .idle
    }
    
    func finish() {
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - Navigation Methods
    func moveToExplanationAfterWelcome() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showLoading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            withAnimation(.easeInOut(duration: 0.8)) {
                self?.loadingOffset = UIScreen.main.bounds.height
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.currentStep = .explanationAfterWelcome
                self?.showLoading = false
                self?.loadingOffset = 0
            }
        }
    }
    
    func moveToAvatarSelection() {
        currentStep = .avatarSelection
    }
    
    func moveToExplanationAfterAvatar() {
        currentStep = .explanationAfterAvatar
    }
    
    func completeOnboarding() {
        finish()
    }
    
    // MARK: - Public Interface for Views
    var shouldShowLoading: Bool {
        return showLoading
    }
    
    var currentLoadingOffset: CGFloat {
        return loadingOffset
    }
} 