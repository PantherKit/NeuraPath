//
//  CareerCarouselView.swift
//  Moved to Results feature UI (feature-specific)
//

import SwiftUI

// MARK: - APICareerRecommendation UI Extensions
extension APICareerRecommendation {
    var color: Color {
        let hash = nombre.hash
        let colors: [Color] = [.purple, .blue, .green, .orange, .pink, .cyan, .indigo, .mint]
        return colors[abs(hash) % colors.count]
    }
    var icon: String {
        let careerName = nombre.lowercased()
        if careerName.contains("medicina") || careerName.contains("médica") { return "stethoscope" }
        if careerName.contains("ingeniería") || careerName.contains("ingenieria") { return "gear" }
        if careerName.contains("psicología") || careerName.contains("psicologia") { return "brain.head.profile" }
        if careerName.contains("derecho") { return "scale.3d" }
        if careerName.contains("administración") || careerName.contains("negocios") { return "briefcase" }
        if careerName.contains("comunicación") || careerName.contains("comunicacion") { return "bubble.left.and.bubble.right" }
        if careerName.contains("educación") || careerName.contains("educacion") { return "graduationcap" }
        if careerName.contains("arte") || careerName.contains("diseño") { return "paintbrush" }
        if careerName.contains("computación") || careerName.contains("sistemas") { return "laptopcomputer" }
        return "star"
    }
    var description: String { careerAnalysis?.whyRecommended ?? "Una carrera que se alinea perfectamente con tu perfil y te permitirá desarrollar tu potencial al máximo." }
    var duration: String {
        let careerName = nombre.lowercased()
        if careerName.contains("medicina") { return "6-7 años" }
        if careerName.contains("ingeniería") { return "5 años" }
        if careerName.contains("derecho") { return "5 años" }
        if careerName.contains("psicología") { return "5 años" }
        return "4-5 años"
    }
    var name: String { nombre }
    var university: String { universidad }
}

// MARK: - Career Carousel View
struct CareerCarouselView: View {
    let careers: [APICareerRecommendation]
    @EnvironmentObject var viewModel: VocationalTestViewModel
    @State private var currentIndex: Int = 0
    @State private var autoScrolling: Bool = true
    @State private var scrollOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    private let cardSpacing: CGFloat = 16.0
    private let autoScrollInterval: TimeInterval = 0.03
    private let autoScrollStep: CGFloat = 0.5
    private let carouselHeight: CGFloat = 220.0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: cardSpacing) {
                ForEach(careers) { career in
                    CareerCardView(career: career).frame(width: cardWidth, height: carouselHeight)
                }
                ForEach(careers.prefix(3)) { career in
                    CareerCardView(career: career).frame(width: cardWidth, height: carouselHeight)
                }
            }
            .padding(.horizontal)
            .offset(x: -scrollOffset)
        }
        .gesture(
            DragGesture()
                .onChanged { _ in autoScrolling = false; isDragging = true }
                .onEnded { _ in isDragging = false; DispatchQueue.main.asyncAfter(deadline: .now() + 2) { autoScrolling = true } }
        )
        .onAppear { startAutoScroll() }
        .onDisappear { autoScrolling = false }
    }

    private func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            guard autoScrolling, !careers.isEmpty, !isDragging else { return }
            withAnimation(.linear(duration: autoScrollInterval)) { scrollOffset += autoScrollStep }
            let cardTotalWidth = cardWidth + cardSpacing
            if scrollOffset >= cardTotalWidth {
                currentIndex = (currentIndex + 1) % careers.count
                if currentIndex == 0 || scrollOffset >= CGFloat(careers.count) * cardTotalWidth {
                    withAnimation(nil) { scrollOffset = 0 }
                }
            }
        }
    }
}

// Subcomponents (Header/Description/Footer) same as original file
struct CareerCardHeaderView: View {
    let career: APICareerRecommendation
    private let iconSize: CGFloat = 50.0
    private let iconFontSize: CGFloat = 22.0
    private let titleFontSize: CGFloat = 18.0
    private let subtitleFontSize: CGFloat = 14.0
    private let spacing: CGFloat = 4.0
    var body: some View {
        HStack { createIconView(); createTitleView(); Spacer() }
    }
    @ViewBuilder private func createIconView() -> some View {
        ZStack {
            Circle().fill(career.color.opacity(0.2)).frame(width: iconSize, height: iconSize)
            Image(systemName: career.icon).font(.system(size: iconFontSize)).foregroundColor(career.color)
        }
    }
    @ViewBuilder private func createTitleView() -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(career.name).font(.system(size: titleFontSize, weight: .bold, design: .rounded)).foregroundColor(.white).lineLimit(1)
            Text(career.university).font(.system(size: subtitleFontSize, weight: .medium)).foregroundColor(.white.opacity(0.7))
        }
    }
}

struct CareerCardDescriptionView: View {
    let description: String
    private let fontSize: CGFloat = 14.0
    private let textOpacity: Double = 0.8
    private let lineLimit: Int = 3
    var body: some View {
        Text(description).font(.system(size: fontSize, weight: .regular)).foregroundColor(.white.opacity(textOpacity)).lineLimit(lineLimit).multilineTextAlignment(.leading)
    }
}

struct CareerCardFooterView: View {
    let duration: String
    let color: Color
    private let fontSize: CGFloat = 14.0
    private let textOpacity: Double = 0.7
    var body: some View { HStack { createDurationLabel(); Spacer(); createActionButton() } }
    @ViewBuilder private func createDurationLabel() -> some View {
        Label(duration, systemImage: "clock").font(.system(size: fontSize, weight: .medium)).foregroundColor(.white.opacity(textOpacity))
    }
    @ViewBuilder private func createActionButton() -> some View {
        Text("Ver más").font(.system(size: fontSize, weight: .semibold)).foregroundColor(color)
    }
}

struct CareerCardView: View {
    let career: APICareerRecommendation
    private let cornerRadius: CGFloat = 16.0
    private let shadowRadius: CGFloat = 10.0
    private let contentSpacing: CGFloat = 12.0
    private let padding: CGFloat = 16.0
    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) { CareerCardHeaderView(career: career); CareerCardDescriptionView(description: career.description); CareerCardFooterView(duration: career.duration, color: career.color) }
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(career.color.opacity(0.3), lineWidth: 1.0)))
            .shadow(color: career.color.opacity(0.2), radius: shadowRadius, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0.1), Color.white.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing)))
    }
}


