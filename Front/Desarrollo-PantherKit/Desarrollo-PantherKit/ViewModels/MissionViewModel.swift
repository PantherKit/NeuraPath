//
//  MissionViewModel.swift
//  Desarrollo-PantherKit
//
//  Created on 5/13/25.
//

import Foundation
import SwiftUI
import Combine

class MissionViewModel: ObservableObject {
    // MARK: - Dependencies
    private let challengeService: ChallengeServiceProtocol
    let vocationalViewModel: VocationalTestViewModel
    
    // MARK: - Published Properties
    @Published var challenges: [StemChallenge] = []
    @Published var currentChallengeIndex = 0
    @Published var timeRemaining: Double = 15.0
    @Published var selectedOption: UUID?
    @Published var showFeedback = false
    @Published var isCorrect = false
    @Published var showNextScreen = false
    @Published var progress: CGFloat = 0.0
    @Published var isAnimating = false
    @Published var showCompletionAnimation = false
    
    // MARK: - Private Properties
    private var timer: Timer?
    
    // MARK: - Computed Properties
    var currentChallenge: StemChallenge {
        guard currentChallengeIndex < challenges.count else {
            // Fallback to first challenge if index is out of bounds
            return challenges.first!
        }
        return challenges[currentChallengeIndex]
    }
    
    // MARK: - Initialization
    init(vocationalViewModel: VocationalTestViewModel, challengeService: ChallengeServiceProtocol = ChallengeService()) {
        self.vocationalViewModel = vocationalViewModel
        self.challengeService = challengeService
        self.challenges = challengeService.getAllChallenges()
    }
    
    // MARK: - Public Methods
    func startTimer() {
        timeRemaining = currentChallenge.timeLimit
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 0.1
            } else {
                // Time's up, auto-select if user hasn't chosen
                if self.selectedOption == nil {
                    // Select a random option
                    if let randomOption = self.currentChallenge.options.randomElement() {
                        self.selectOption(randomOption)
                    }
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateProgressBar() {
        // Calculate progress based on screen width (will be set in the view)
        let screenWidth = UIScreen.main.bounds.width
        progress = screenWidth - 32 * CGFloat(currentChallengeIndex + 1) / CGFloat(challenges.count)
    }
    
    func selectOption(_ option: ChallengeOption) {
        selectedOption = option.id
        stopTimer()
        
        // Record the selection
        isCorrect = option.isCorrect
        
        // Update trait score based on the selected option
        vocationalViewModel.updateTraitScore(option.trait, by: 0.8)
        
        // Show feedback
        showFeedback = true
        
        // Move to next challenge or finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showFeedback = false
            
            if self.currentChallengeIndex < self.challenges.count - 1 {
                self.currentChallengeIndex += 1
                self.selectedOption = nil
                self.updateProgressBar()
                self.startTimer()
            } else {
                // All challenges completed, show completion animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showCompletionAnimation = true
                }
                
                // Move to results screen after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.vocationalViewModel.testCompleted = true
                    self.showNextScreen = true
                }
            }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        stopTimer()
    }
}
