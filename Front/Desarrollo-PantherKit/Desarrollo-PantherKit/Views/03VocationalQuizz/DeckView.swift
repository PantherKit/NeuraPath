//
//  DeckView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 13/05/25.
//

import SwiftUI

struct DeckView: View {
    var onComplete: () -> Void
    @State private var cards: [STEMCard] = STEMCard.sampleData
    @State private var activeIndex: Int = 0
    @State private var showDetails = false
    @State private var selectedCard: STEMCard? = nil
    
    // Colores del tema
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    var body: some View {
        ZStack {
            // Fondo espacial
            spaceBackground
            
            VStack {
                // Header con progreso
                progressHeader
                
                Spacer()
                
                // Stack de cards
                cardStackView
                
                Spacer()
                
                // Controles de acción
                actionButtons
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showDetails) {
            if let card = selectedCard {
                CardDetailView(card: card)
            }
        }
    }
    
    // MARK: - Componentes
    
    private var spaceBackground: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Estrellas
            ForEach(0..<100) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .opacity(Double.random(in: 0.1...0.8))
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
            }
            
            // Nébulas
            ForEach(0..<3) { i in
                let colors: [Color] = [
                    Color(red: 0.5, green: 0.2, blue: 0.8),
                    Color(red: 0.1, green: 0.4, blue: 0.9),
                    Color(red: 0.3, green: 0.8, blue: 0.9)
                ]
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                colors[i % colors.count].opacity(0.2),
                                colors[i % colors.count].opacity(0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .blur(radius: 60)
            }
        }
    }
    
    private var progressHeader: some View {
        HStack {
            Text("Explora Carreras STEM")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(activeIndex + 1)/\(cards.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
    }
    
    private var cardStackView: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(
                    card: card,
                    isActive: index == activeIndex,
                    onSwipedAway: handleSwipe,
                    onShowDetails: { selectedCard = card; showDetails = true }
                )
                .zIndex(Double(cards.count - index))
            }
        }
        .frame(width: 320, height: 450)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 30) {
            // Botón de rechazo
            Button(action: {
                swipeCard(accepted: false)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.red)
                    .padding()
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            
            // Botón de información
            Button(action: {
                selectedCard = cards[activeIndex]
                showDetails = true
            }) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(accentColor))
            }
            
            // Botón de aceptación
            Button(action: {
                swipeCard(accepted: true)
            }) {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.green)
                    .padding()
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
        }
    }
    
    // MARK: - Funciones
    
    private func handleSwipe() {
        if activeIndex < cards.count - 1 {
            withAnimation(.spring()) {
                activeIndex += 1
            }
        } else {
            onComplete()
        }
    }
    
    private func swipeCard(accepted: Bool) {
        guard activeIndex < cards.count else { return }
        
        // Aquí podrías registrar la selección del usuario
        if accepted {
            print("Aceptado: \(cards[activeIndex].title)")
        }
        
        withAnimation(.spring()) {
            handleSwipe()
        }
    }
}
