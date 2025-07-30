import SwiftUI

// MARK: - Progress Cosmic Bar
struct ProgressCosmicBar: View {
    let progress: Double
    @Binding var progressGlow: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 8)
                .overlay(
                    // Progress fill
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.cosmicCyan.opacity(0.8),
                                        AppTheme.Colors.cosmicBlue.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.6 * progress)
                            .scaleEffect(x: progress, anchor: .leading)
                            .shadow(
                                color: progressGlow ? 
                                AppTheme.Colors.cosmicCyan.opacity(0.6) : 
                                AppTheme.Colors.cosmicCyan.opacity(0.3),
                                radius: progressGlow ? 8 : 4, x: 0, y: 0
                            )
                        
                        Spacer()
                    }
                )
                .overlay(
                    // Glass overlay
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
        }
    }
}

// MARK: - Cosmic Feedback Overlay
struct CosmicFeedbackOverlay: View {
    let text: String
    let color: Color
    
    var body: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 0)
                    
                    Text(text)
                        .font(.custom("ZonaPro-Bold", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
            )
    }
}

// MARK: - Circular Timer
struct CircularTimer: View {
    let timeRemaining: Double
    let totalTime: Double
    let accentColor: Color
    let warningColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(accentColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(timeRemaining / totalTime))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(timeRemaining > totalTime * 0.25 ? accentColor : (timeRemaining > totalTime * 0.1 ? Color.orange : warningColor))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: timeRemaining)
            
            Text("\(Int(timeRemaining))")
                .font(.custom("ZonaPro-Bold", size: 16))
                .foregroundColor(timeRemaining > totalTime * 0.25 ? accentColor : (timeRemaining > totalTime * 0.1 ? Color.orange : warningColor))
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Loading Progress View
struct LoadingProgressView: View {
    let title: String
    let progress: Double
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            // Loading icon
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(accentColor)
                .rotationEffect(.degrees(progress * 360))
                .animation(
                    Animation.linear(duration: 2).repeatForever(autoreverses: false),
                    value: progress
                )
            
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            // Progress bar
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                .scaleEffect(1.5)
        }
    }
}

// MARK: - Analysis Loading View
struct AnalysisLoadingView: View {
    var body: some View {
        VStack(spacing: 15) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.cosmicCyan))
                .scaleEffect(1.2)
            
            Text("Obteniendo análisis personalizado...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.2), radius: 15)
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        ProgressCosmicBar(
            progress: 0.6,
            progressGlow: .constant(true)
        )
        
        CircularTimer(
            timeRemaining: 15.0,
            totalTime: 20.0,
            accentColor: AppTheme.Colors.cosmicCyan,
            warningColor: Color.red
        )
        
        LoadingProgressView(
            title: "Cargando...",
            progress: 0.5,
            accentColor: AppTheme.Colors.cosmicCyan
        )
        
        AnalysisLoadingView()
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 