import SwiftUI

struct QuestionGlassCard: View {
    let card: STEMCard
    let isActive: Bool
    let onSwipedAway: () -> Void
    let onShowDetails: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isGone = false
    @State private var cardGlow = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var titleGlow = false
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    private let toastManager = ToastManager.shared
    
    var rotationAngle: Double { Double(dragOffset.width / swipeThreshold) * maxRotation }
    
    var body: some View {
        ZStack {
            GlassCardBackground(cornerRadius: 28, level: .primary, shimmerOffset: shimmerOffset)
                .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
                .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.15), radius: 35, x: 0, y: 18)
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    HStack {
                        Text("STEM CAREER")
                            .font(.custom("ZonaPro-Bold", size: 10))
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.cosmicCyan)
                            .tracking(2)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(
                                    LinearGradient(colors: [AppTheme.Colors.cosmicCyan.opacity(0.2), AppTheme.Colors.cosmicBlue.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                )
                            )
                            .overlay(Capsule().stroke(AppTheme.Colors.cosmicCyan.opacity(0.3), lineWidth: 1))
                        Spacer()
                        IssueNumberView().font(.custom("ZonaPro-Light", size: 10)).foregroundColor(.white.opacity(0.5)).tracking(1)
                    }
                    Text(card.title)
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .tracking(0.5)
                        .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 10, x: 0, y: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                Rectangle()
                    .fill(
                        LinearGradient(colors: [AppTheme.Colors.cosmicCyan.opacity(0.4), AppTheme.Colors.cosmicBlue.opacity(0.2), Color.clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
                VStack(spacing: 24) {
                    ForEach(card.details.prefix(3), id: \.title) { detail in
                        HStack(alignment: .top, spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(RadialGradient(colors: [AppTheme.Colors.cosmicCyan.opacity(0.25), AppTheme.Colors.cosmicBlue.opacity(0.15), Color.clear], center: .center, startRadius: 0, endRadius: 25))
                                    .frame(width: 50, height: 50)
                                Image(systemName: detail.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.cosmicCyan)
                                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 6, x: 0, y: 0)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text(detail.description).font(.custom("ZonaPro-Bold", size: 18)).foregroundColor(.white).tracking(0.3)
                                Text(detail.title).font(.custom("ZonaPro-Light", size: 15)).foregroundColor(.white.opacity(0.75)).lineSpacing(4).tracking(0.2).fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 28)
                Spacer()
            }
            if isDragging { swipeIndicators }
        }
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .opacity(isGone ? 0 : 1)
        .scaleEffect(isActive ? 1.0 : 0.9)
        .offset(y: isActive ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if isActive {
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            dragOffset = value.translation
                        }
                    }
                }
                .onEnded { value in
                    if isActive && abs(value.translation.width) > swipeThreshold {
                        let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isDragging = false
                            dragOffset = CGSize(width: direction * 300, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                dragOffset = CGSize(width: direction * 800, height: 0)
                                isGone = true
                            }
                            if Bool.random() { toastManager.showRandomToast() }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { onSwipedAway() }
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(1.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
        }
    }
    
    private var swipeIndicators: some View {
        VStack {
            if dragOffset.width > 0 {
                VStack(spacing: 16) {
                    ZStack {
                        Image(systemName: "arrow.right.circle.fill").font(.system(size: 90, weight: .medium)).foregroundColor(AppTheme.Colors.cosmicCyan.opacity(0.3)).blur(radius: 8).scaleEffect(1.2)
                        Image(systemName: "arrow.right.circle.fill").font(.system(size: 80, weight: .medium)).foregroundColor(AppTheme.Colors.cosmicCyan).shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.8), radius: 20, x: 0, y: 0)
                    }
                    Text("Interested").font(.custom("ZonaPro-Bold", size: 22)).fontWeight(.bold).foregroundColor(AppTheme.Colors.cosmicCyan).shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 8, x: 0, y: 2).scaleEffect(1.1)
                }
                .opacity(Double(min(dragOffset.width / swipeThreshold, 1)))
                .scaleEffect(0.8 + Double(min(dragOffset.width / swipeThreshold, 1)) * 0.4)
            } else if dragOffset.width < 0 {
                VStack(spacing: 16) {
                    ZStack {
                        Image(systemName: "arrow.left.circle.fill").font(.system(size: 90, weight: .medium)).foregroundColor(AppTheme.Colors.cosmicPurple.opacity(0.3)).blur(radius: 8).scaleEffect(1.2)
                        Image(systemName: "arrow.left.circle.fill").font(.system(size: 80, weight: .medium)).foregroundColor(AppTheme.Colors.cosmicPurple).shadow(color: AppTheme.Colors.cosmicPurple.opacity(0.8), radius: 20, x: 0, y: 0)
                    }
                    Text("Not for me").font(.custom("ZonaPro-Bold", size: 22)).fontWeight(.bold).foregroundColor(AppTheme.Colors.cosmicPurple).shadow(color: AppTheme.Colors.cosmicPurple.opacity(0.6), radius: 8, x: 0, y: 2).scaleEffect(1.1)
                }
                .opacity(Double(min(-dragOffset.width / swipeThreshold, 1)))
                .scaleEffect(0.8 + Double(min(-dragOffset.width / swipeThreshold, 1)) * 0.4)
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset.width)
    }
}


