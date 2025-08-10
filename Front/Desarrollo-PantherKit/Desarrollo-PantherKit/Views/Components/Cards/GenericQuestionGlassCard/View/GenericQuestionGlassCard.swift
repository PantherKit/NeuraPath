import SwiftUI

struct GenericQuestionGlassCard<Content: QuestionCardContent>: View {
    let content: Content
    let isActive: Bool
    let onSwipedAway: () -> Void
    let onShowDetails: () -> Void

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isGone = false
    @State private var shimmerOffset: CGFloat = -200

    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15

    private var rotationAngle: Double { Double(dragOffset.width / swipeThreshold) * maxRotation }

    var body: some View {
        ZStack {
            GlassCardBackground(cornerRadius: 28, level: .primary, shimmerOffset: shimmerOffset)
                .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HStack {
                        Text(content.subtitle.uppercased())
                            .font(.custom("ZonaPro-Bold", size: 10))
                            .foregroundColor(AppTheme.Colors.cosmicCyan)
                            .tracking(2)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(AppTheme.Colors.cosmicCyan.opacity(0.12)))
                            .overlay(Capsule().stroke(AppTheme.Colors.cosmicCyan.opacity(0.25), lineWidth: 1))
                        Spacer()
                        IssueNumberView().font(.custom("ZonaPro-Light", size: 10)).foregroundColor(.white.opacity(0.5))
                    }
                    Text(content.title)
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)

                Rectangle().fill(AppTheme.Colors.cosmicCyan.opacity(0.3)).frame(height: 1).padding(.horizontal, 28).padding(.vertical, 16)

                VStack(spacing: 20) {
                    ForEach(content.questionDetails) { detail in
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: detail.icon).font(.system(size: 20, weight: .medium)).foregroundColor(AppTheme.Colors.cosmicCyan)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(detail.description).font(.custom("ZonaPro-Bold", size: 18)).foregroundColor(.white)
                                Text(detail.title).font(.custom("ZonaPro-Light", size: 15)).foregroundColor(.white.opacity(0.75))
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 28)
                Spacer(minLength: 0)
            }
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                dragOffset = CGSize(width: direction * 800, height: 0)
                                isGone = true
                            }
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
        .onTapGesture { onShowDetails() }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(1.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
        }
    }
}


