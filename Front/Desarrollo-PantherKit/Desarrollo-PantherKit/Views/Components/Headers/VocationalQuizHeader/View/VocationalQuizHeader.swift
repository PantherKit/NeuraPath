import SwiftUI

// MARK: - Vocational Quiz Header
struct VocationalQuizHeader: View {
    let currentIndex: Int
    let totalCount: Int
    let mbtiMode: Bool
    @Binding var progressGlow: Bool
    
    private var progressPercentage: Double {
        Double(currentIndex + 1) / Double(totalCount)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Main title with editorial typography
            VStack(spacing: 16) {
                Text(mbtiMode ? "Discover Your\nPersonality Type" : "Explore STEM\nCareer Paths")
                    .font(.custom("ZonaPro-Bold", size: 36))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(0.5)
                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 15, x: 0, y: 5)
                
                // Elegant subtitle
                Text(mbtiMode ? "Understanding your MBTI preferences\nhelps us match you with the perfect STEM career" : "Swipe through career options to discover\nwhat resonates with your interests")
                    .font(.custom("ZonaPro-Light", size: 16))
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(0.5)
            }
            
            // Magazine-style progress section
            VStack(spacing: 16) {
                // Progress metrics
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Progress")
                            .font(.custom("ZonaPro-Light", size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(0.5)
                        
                        Text("\(currentIndex + 1) of \(totalCount)")
                            .font(.custom("ZonaPro-Bold", size: 20))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .tracking(-1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Completion")
                            .font(.custom("ZonaPro-Light", size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(0.5)
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.custom("ZonaPro-Bold", size: 24))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .tracking(-1)
                    }
                }
                
                // Cosmic progress bar
                ProgressCosmicBar(progress: progressPercentage, progressGlow: $progressGlow)
            }
        }
        .padding(32)
        .background {
            // Authentic glass morphism
            ZStack {
                // Base glass layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
                
                // Secondary glass layer for depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
                    .opacity(0.3)
                
                // Glass tint with cosmic colors
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.06),
                                AppTheme.Colors.cosmicBlue.opacity(0.03),
                                Color.clear,
                                AppTheme.Colors.cosmicPurple.opacity(0.02)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                
                // Natural light reflection
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.06),
                                Color.clear,
                                Color.clear,
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Sophisticated border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
            .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.15), radius: 35, x: 0, y: 18)
        }
    }
}


