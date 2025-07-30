import SwiftUI

// MARK: - Avatar Selection Header
struct AvatarSelectionHeader: View {
    @State private var titleGlow = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Main title with editorial typography
            VStack(spacing: 16) {
                Text("Choose Your\nCosmic Identity")
                    .font(.custom("ZonaPro-Bold", size: 42))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(0.5)
                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 15, x: 0, y: 5)
                
                // Elegant subtitle
                Text("Select the personality that resonates\nwith your inner explorer")
                    .font(.custom("ZonaPro-Light", size: 18))
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(0.5)
            }
            
            // Magazine-style metrics
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("12")
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .tracking(-1)
                    
                    Text("Personalities")
                        .font(.custom("ZonaPro-Light", size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(.white.opacity(0.65))
                        .tracking(0.5)
                }
                
                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 8) {
                    Text("100%")
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .tracking(-1)
                    
                    Text("Match Rate")
                        .font(.custom("ZonaPro-Light", size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(.white.opacity(0.65))
                        .tracking(0.5)
                }
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
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.0)) {
                titleGlow = true
            }
        }
    }
}

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

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.Colors.cosmicCyan)
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        AvatarSelectionHeader()
        
        VocationalQuizHeader(
            currentIndex: 3,
            totalCount: 8,
            mbtiMode: false,
            progressGlow: .constant(true)
        )
        
        SectionHeader(title: "Test Section", icon: "star.fill")
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 