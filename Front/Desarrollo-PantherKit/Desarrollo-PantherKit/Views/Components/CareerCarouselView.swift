//
//  CareerCarouselView.swift
//  Desarrollo-PantherKit
//
//  Created on 13/5/2025.
//

import SwiftUI

// MARK: - Career Carousel View
struct CareerCarouselView: View {
    // Properties
    let careers: [UniversityCareer]
    @EnvironmentObject var viewModel: VocationalTestViewModel
    @State private var currentIndex: Int = 0
    @State private var autoScrolling: Bool = true
    @State private var scrollOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    // Constants with explicit types
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    private let cardSpacing: CGFloat = 16.0
    private let autoScrollInterval: TimeInterval = 0.03 // Más rápido
    private let autoScrollStep: CGFloat = 0.5 // Paso más pequeño para un movimiento más suave
    private let carouselHeight: CGFloat = 220.0
    
    var body: some View {
        VStack(spacing: 20) {
            // Título
            Text("Carreras Recomendadas")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Carrusel horizontal
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    // Carreras originales
                    ForEach(careers) { career in
                        CareerCardView(career: career)
                            .frame(width: cardWidth, height: carouselHeight)
                    }
                    
                    // Duplicar las primeras carreras para crear efecto continuo
                    ForEach(careers.prefix(3)) { career in
                        CareerCardView(career: career)
                            .frame(width: cardWidth, height: carouselHeight)
                    }
                }
                .padding(.horizontal)
                .offset(x: -scrollOffset)
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        // Pausa el auto-scrolling durante el arrastre manual
                        autoScrolling = false
                        isDragging = true
                    }
                    .onEnded { _ in
                        // Reanudar después de un breve retraso
                        isDragging = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            autoScrolling = true
                        }
                    }
            )
            .onAppear {
                startAutoScroll()
            }
            .onDisappear {
                // Detener el timer cuando la vista desaparece
                autoScrolling = false
            }
        }
    }
    
    // Auto-scrolling timer para desplazamiento continuo hacia la derecha
    private func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { timer in
            guard autoScrolling, !careers.isEmpty, !isDragging else { return }
            
            // Incrementar el offset para mover hacia la derecha
            withAnimation(.linear(duration: autoScrollInterval)) {
                scrollOffset += autoScrollStep
            }
            
            // Calcular el ancho total de una tarjeta + espaciado
            let cardTotalWidth = cardWidth + cardSpacing
            
            // Cuando una tarjeta completa ha pasado, ajustar el índice y reset si es necesario
            if scrollOffset >= cardTotalWidth {
                currentIndex = (currentIndex + 1) % careers.count
                
                // Si llegamos al final, resetear para simular scroll infinito
                if currentIndex == 0 {
                    withAnimation(nil) {
                        scrollOffset = 0
                    }
                } else if scrollOffset >= CGFloat(careers.count) * cardTotalWidth {
                    withAnimation(nil) {
                        scrollOffset = 0
                    }
                }
            }
        }
    }
}

// MARK: - Card Subcomponents
struct CareerCardHeaderView: View {
    let career: UniversityCareer
    
    // Constants with explicit types
    private let iconSize: CGFloat = 50.0
    private let iconFontSize: CGFloat = 22.0
    private let titleFontSize: CGFloat = 18.0
    private let subtitleFontSize: CGFloat = 14.0
    private let spacing: CGFloat = 4.0
    
    var body: some View {
        HStack {
            createIconView()
            createTitleView()
            Spacer()
        }
    }
    
    @ViewBuilder
    private func createIconView() -> some View {
        ZStack {
            Circle()
                .fill(career.color.opacity(0.2))
                .frame(width: iconSize, height: iconSize)
            
            Image(systemName: career.icon)
                .font(.system(size: iconFontSize))
                .foregroundColor(career.color)
        }
    }
    
    @ViewBuilder
    private func createTitleView() -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(career.name)
                .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(career.university)
                .font(.system(size: subtitleFontSize, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct CareerCardDescriptionView: View {
    let description: String
    
    // Constants with explicit types
    private let fontSize: CGFloat = 14.0
    private let textOpacity: Double = 0.8
    private let lineLimit: Int = 3
    
    var body: some View {
        Text(description)
            .font(.system(size: fontSize, weight: .regular))
            .foregroundColor(.white.opacity(textOpacity))
            .lineLimit(lineLimit)
            .multilineTextAlignment(.leading)
    }
}

struct CareerCardFooterView: View {
    let duration: String
    let color: Color
    
    // Constants with explicit types
    private let fontSize: CGFloat = 14.0
    private let textOpacity: Double = 0.7
    
    var body: some View {
        HStack {
            createDurationLabel()
            Spacer()
            createActionButton()
        }
    }
    
    @ViewBuilder
    private func createDurationLabel() -> some View {
        Label(duration, systemImage: "clock")
            .font(.system(size: fontSize, weight: .medium))
            .foregroundColor(.white.opacity(textOpacity))
    }
    
    @ViewBuilder
    private func createActionButton() -> some View {
        Text("Ver más")
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(color)
    }
}

// MARK: - Career Card View
struct CareerCardView: View {
    let career: UniversityCareer
    
    // Constants with explicit types
    private let cornerRadius: CGFloat = 16.0
    private let shadowRadius: CGFloat = 10.0
    private let contentSpacing: CGFloat = 12.0
    private let padding: CGFloat = 16.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            createHeaderView()
            createDescriptionView()
            createFooterView()
        }
        .padding(padding)
        .background(createCardBackground())
        .shadow(color: career.color.opacity(0.2), radius: shadowRadius, x: 0, y: 5)
        .overlay(createShimmerEffect())
    }
    
    // Extracted functions for each part of the card
    @ViewBuilder
    private func createHeaderView() -> some View {
        CareerCardHeaderView(career: career)
    }
    
    @ViewBuilder
    private func createDescriptionView() -> some View {
        CareerCardDescriptionView(description: career.description)
    }
    
    @ViewBuilder
    private func createFooterView() -> some View {
        CareerCardFooterView(duration: career.duration, color: career.color)
    }
    
    @ViewBuilder
    private func createCardBackground() -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(career.color.opacity(0.3), lineWidth: 1.0)
            )
    }
    
    @ViewBuilder
    private func createShimmerEffect() -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// Preview
struct CareerCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = VocationalTestViewModel()
        return ZStack {
            Color.black.ignoresSafeArea()
            CareerCarouselView(careers: UniversityCareer.sampleCareers)
                .environmentObject(viewModel)
        }
    }
}
