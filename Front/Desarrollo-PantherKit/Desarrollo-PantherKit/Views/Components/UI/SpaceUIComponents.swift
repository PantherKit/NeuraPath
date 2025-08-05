//
//  SpaceUIComponents.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

// MARK: - Space Button
struct SpaceButton: View {
    let title: String
    let action: () -> Void
    let style: SpaceButtonVariant
    
    init(_ title: String, style: SpaceButtonVariant = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(AppTheme.Space.spaceCaption(12))
                .fontWeight(.semibold)
                .foregroundColor(style.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .stroke(style.borderColor, lineWidth: AppTheme.Space.buttonBorderWidth)
                        .background(style.backgroundColor)
                )
        }
        .buttonStyle(SpaceButtonStyle())
    }
}

enum SpaceButtonVariant {
    case primary, secondary, alert
    
    var textColor: Color {
        switch self {
        case .primary, .secondary:
            return AppTheme.Colors.spacePureWhite
        case .alert:
            return AppTheme.Colors.spaceAlertRed
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary, .secondary:
            return AppTheme.Colors.spacePureWhite
        case .alert:
            return AppTheme.Colors.spaceAlertRed
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return AppTheme.Colors.spaceDeepBlack.opacity(0.3)
        case .secondary:
            return AppTheme.Colors.spaceNavy.opacity(0.2)
        case .alert:
            return AppTheme.Colors.spaceAlertRed.opacity(0.1)
        }
    }
}

struct SpaceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppTheme.Animation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Space Metric Panel
struct SpaceMetricPanel: View {
    let label: String
    let value: String
    let unit: String?
    
    init(label: String, value: String, unit: String? = nil) {
        self.label = label
        self.value = value
        self.unit = unit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppTheme.Space.spaceLabel(14))
                .foregroundColor(AppTheme.Colors.spaceGray)
                .textCase(.uppercase)
                .tracking(0.5)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(AppTheme.Space.spaceMetric(32))
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(-1)
                
                if let unit = unit {
                    Text(unit)
                        .font(AppTheme.Space.spaceLabel(16))
                        .foregroundColor(AppTheme.Colors.spacePureWhite)
                        .padding(.bottom, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Space Info Panel
struct SpaceInfoPanel: View {
    let title: String
    let subtitle: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Space.spaceTitle(24))
                    .fontWeight(.heavy)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(1)
                
                Text(subtitle)
                    .font(AppTheme.Space.spaceBody(14))
                    .foregroundColor(AppTheme.Colors.spaceGray)
                    .tracking(0.3)
            }
            
            Text(content)
                .font(AppTheme.Space.spaceBody(16))
                .foregroundColor(AppTheme.Colors.spaceLightGray)
                .lineSpacing(4)
                .tracking(0.2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .stroke(AppTheme.Colors.spacePureWhite.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Space Navigation Indicator
struct SpaceNavigationIndicator: View {
    let number: String
    let label: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1)
                )
                .overlay(
                    Text(number)
                        .font(AppTheme.Space.spaceLabel(14))
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.spacePureWhite)
                )
            
            Text(label.uppercased())
                .font(AppTheme.Space.spaceCaption(12))
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.spacePureWhite)
                .tracking(0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .stroke(AppTheme.Colors.spacePureWhite.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Glitch Effect
struct GlitchEffect: View {
    @State private var isGlitching = false
    
    var body: some View {
        Rectangle()
            .fill(AppTheme.Space.glitchGradient)
            .frame(width: 2, height: 40)
            .opacity(isGlitching ? 0.8 : 0.3)
            .animation(
                AppTheme.Animation.glitchFlicker,
                value: isGlitching
            )
            .onAppear {
                isGlitching = true
            }
    }
}


// MARK: - Space Header
struct SpaceHeader: View {
    let title: String
    let leftButton: String?
    let rightButton: String?
    let leftAction: (() -> Void)?
    let rightAction: (() -> Void)?
    
    init(
        title: String,
        leftButton: String? = nil,
        rightButton: String? = nil,
        leftAction: (() -> Void)? = nil,
        rightAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.leftAction = leftAction
        self.rightAction = rightAction
    }
    
    var body: some View {
        HStack {
            if let leftButton = leftButton {
                SpaceButton(leftButton, style: .secondary) {
                    leftAction?()
                }
            } else {
                Spacer()
            }
            
            Spacer()
            
            Text(title)
                .font(AppTheme.Space.spaceTitle(28))
                .fontWeight(.heavy)
                .foregroundColor(AppTheme.Colors.spacePureWhite)
            
            Spacer()
            
            if let rightButton = rightButton {
                SpaceButton(rightButton, style: .secondary) {
                    rightAction?()
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Space Add Button
struct SpaceAddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(AppTheme.Colors.spacePureWhite)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.4))
                        .overlay(
                            Circle()
                                .stroke(AppTheme.Colors.spacePureWhite.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(SpaceButtonStyle())
    }
}

// MARK: - Space Avatar Card
struct SpaceAvatarCard: View {
    let avatar: Avatar
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Avatar image placeholder
                Circle()
                    .fill(AppTheme.Colors.spaceNavy.opacity(0.6))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? AppTheme.Colors.spaceElectricBlue : AppTheme.Colors.spacePureWhite,
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                    .overlay(
                        Image(systemName: avatar.imageName)
                            .font(.system(size: 32, weight: .medium, design: .default))
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                    )
                    .background(
                        Circle()
                            .fill(
                                isSelected ? 
                                AppTheme.Colors.spaceElectricBlue.opacity(0.2) : 
                                Color.clear
                            )
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .animation(AppTheme.Animation.buttonPress, value: isSelected)
                    )
                
                // Avatar name
                Text(avatar.name)
                    .font(AppTheme.Space.spaceCaption(10))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.spaceGray)
                    .tracking(0.5)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                    .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                            .stroke(
                                isSelected ? AppTheme.Colors.spaceElectricBlue.opacity(0.6) : AppTheme.Colors.spacePureWhite.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(SpaceButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AppTheme.Animation.buttonPress, value: isSelected)
    }
}

// MARK: - Space Avatar Grid
struct SpaceAvatarGrid: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(Avatar.allAvatars.enumerated()), id: \.element.id) { index, avatar in
                SpaceAvatarCard(
                    avatar: avatar,
                    isSelected: viewModel.selectedAvatar?.id == avatar.id
                ) {
                    viewModel.selectedAvatar = avatar
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Space Navigation Header
struct SpaceNavigationHeader: View {
    let number: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            // Left side - Navigation panels
            HStack(spacing: 12) {
                // Circle with number
                Circle()
                    .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1)
                    )
                    .overlay(
                        Text(number)
                            .font(AppTheme.Space.spaceCaption(12))
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                    )
                
                // Rectangle with text
                Text(title)
                    .font(AppTheme.Space.spaceCaption(10))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(0.5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                            .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                    .stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            // Right side - Number and phrase
            VStack(alignment: .trailing, spacing: 4) {
                Text(number)
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                
                Text(subtitle)
                    .font(AppTheme.Space.spaceCaption(10))
                    .foregroundColor(AppTheme.Colors.spaceGray)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
}

// MARK: - Space Question Card
struct SpaceQuestionCard: View {
    let card: STEMCard
    let isActive: Bool
    let onSwipedAway: () -> Void
    let onShowDetails: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var rotationAngle: Double = 0
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with icon and title
            VStack(spacing: 16) {
                // Icon
                Image(systemName: card.imageName)
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .foregroundColor(AppTheme.Colors.spaceElectricBlue)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.4))
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.Colors.spaceElectricBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                // Title
                Text(card.title)
                    .font(AppTheme.Space.spaceTitle(20))
                    .fontWeight(.heavy)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Subtitle
                Text(card.subtitle)
                    .font(AppTheme.Space.spaceBody(14))
                    .foregroundColor(AppTheme.Colors.spaceGray)
                    .tracking(0.3)
            }
            
            // Options
            VStack(spacing: 12) {
                ForEach(card.details, id: \.title) { detail in
                    SpaceOptionButton(
                        icon: detail.icon,
                        title: detail.title,
                        description: detail.description
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .stroke(AppTheme.Colors.spacePureWhite.opacity(0.2), lineWidth: 1)
                )
        )
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    withAnimation(.interactiveSpring()) {
                        dragOffset = value.translation
                        rotationAngle = Double(value.translation.width / swipeThreshold) * maxRotation
                    }
                }
                .onEnded { value in
                    handleSwipe(value)
                }
        )
        .opacity(isActive ? 1.0 : 0.7)
        .scaleEffect(isActive ? 1.0 : 0.95)
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        if abs(value.translation.width) > swipeThreshold {
            // Swipe completed
            withAnimation(.spring()) {
                dragOffset = CGSize(
                    width: value.translation.width > 0 ? 1000 : -1000,
                    height: 0
                )
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipedAway()
            }
        } else {
            // Return to center
            withAnimation(.spring()) {
                dragOffset = .zero
                rotationAngle = 0
            }
        }
    }
}

// MARK: - Space Option Button
struct SpaceOptionButton: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium, design: .default))
                .foregroundColor(AppTheme.Colors.spaceElectricBlue)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                        .overlay(
                            Circle()
                                .stroke(AppTheme.Colors.spaceElectricBlue.opacity(0.3), lineWidth: 1)
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(0.5)
                
                Text(description)
                    .font(AppTheme.Space.spaceBody(14))
                    .foregroundColor(AppTheme.Colors.spaceGray)
                    .tracking(0.2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .stroke(AppTheme.Colors.spacePureWhite.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Space Progress Indicator
struct SpaceProgressIndicator: View {
    let currentIndex: Int
    let totalCount: Int
    @Binding var progressGlow: Bool
    
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(currentIndex) / Double(totalCount)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress text
            HStack {
                Text("\(currentIndex + 1)")
                    .font(AppTheme.Space.spaceMetric(24))
                    .fontWeight(.black)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(-1)
                
                Text("/")
                    .font(AppTheme.Space.spaceBody(16))
                    .foregroundColor(AppTheme.Colors.spaceGray)
                
                Text("\(totalCount)")
                    .font(AppTheme.Space.spaceBody(16))
                    .foregroundColor(AppTheme.Colors.spaceGray)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                        .frame(height: 4)
                        .overlay(
                            Rectangle()
                                .stroke(AppTheme.Colors.spacePureWhite.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Progress
                    Rectangle()
                        .fill(AppTheme.Space.glitchGradient)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .opacity(progressGlow ? 1.0 : 0.8)
                        .animation(
                            AppTheme.Animation.glitchFlicker,
                            value: progressGlow
                        )
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Space Swipe Indicators
struct SpaceSwipeIndicators: View {
    let dragOffset: CGSize
    let swipeThreshold: CGFloat
    
    var body: some View {
        Group {
            // Right swipe indicator (Option A)
            VStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 48, weight: .medium, design: .default))
                    .foregroundColor(AppTheme.Colors.spaceElectricBlue)
                
                Text("Opción A")
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.spaceElectricBlue)
                    .tracking(0.5)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                    .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                            .stroke(AppTheme.Colors.spaceElectricBlue.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(dragOffset.width > 0 ? Double(min(dragOffset.width / swipeThreshold, 1)) : 0)
            .position(x: UIScreen.main.bounds.width * 0.75, y: 100)
            
            // Left swipe indicator (Option B)
            VStack(spacing: 8) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 48, weight: .medium, design: .default))
                    .foregroundColor(AppTheme.Colors.spaceAlertRed)
                
                Text("Opción B")
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.spaceAlertRed)
                    .tracking(0.5)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                    .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                            .stroke(AppTheme.Colors.spaceAlertRed.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(dragOffset.width < 0 ? Double(min(-dragOffset.width / swipeThreshold, 1)) : 0)
            .position(x: UIScreen.main.bounds.width * 0.25, y: 100)
        }
    }
}

// MARK: - Space Feedback Overlay
struct SpaceFeedbackOverlay: View {
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32, weight: .medium, design: .default))
                .foregroundColor(color)
            
            Text(text)
                .font(AppTheme.Space.spaceCaption(14))
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.spacePureWhite)
                .tracking(0.5)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .stroke(color.opacity(0.5), lineWidth: 2)
                )
        )
        .transition(.scale.combined(with: .opacity))
    }
}

