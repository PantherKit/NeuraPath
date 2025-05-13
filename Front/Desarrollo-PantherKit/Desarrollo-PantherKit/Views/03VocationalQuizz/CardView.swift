//
//  CardView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 13/05/25.
//

import SwiftUI

struct CardView: View {
    let card: STEMCard
    let isActive: Bool
    let onSwipedAway: () -> Void
    let onShowDetails: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isGone = false
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    
    var rotationAngle: Double {
        Double(dragOffset.width / swipeThreshold) * maxRotation
    }
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.2, blue: 0.4),
                            Color(red: 0.05, green: 0.1, blue: 0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .white.opacity(0.1), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.3),
                                .clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1
                    )
                )
            
            // Card content
            VStack(spacing: 0) {
                // Image placeholder
                ZStack(alignment: .topTrailing) {
                    Color.blue.opacity(0.5)
                        .frame(height: 200)
                        .clipShape(
                            RoundedCorner(radius: 25, corners: [.topLeft, .topRight])
                        )
                    
                    Button(action: onShowDetails) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(card.subtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Mostrar los primeros 2 detalles
                    ForEach(card.details.prefix(2), id: \.title) { detail in
                        HStack(alignment: .top) {
                            Image(systemName: detail.icon)
                                .foregroundColor(accentColor)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(detail.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(detail.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Feedback de swipe
            if isDragging {
                VStack {
                    if dragOffset.width > 0 {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                            .opacity(Double(min(dragOffset.width / swipeThreshold, 1)))
                    } else if dragOffset.width < 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .opacity(Double(min(-dragOffset.width / swipeThreshold, 1)))
                    }
                }
                .transition(.scale)
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .opacity(isGone ? 0 : 1)
        .scaleEffect(isActive ? 1.0 : 0.9)
        .offset(y: isActive ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
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
                        withAnimation(.spring()) {
                            isDragging = false
                            let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                            dragOffset = CGSize(width: direction * 500, height: 0)
                            isGone = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipedAway()
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
    }
}

struct CardDetailView: View {
    let card: STEMCard
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Fondo espacial
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Imagen de cabecera
                    Color.blue.opacity(0.5)
                        .frame(height: 250)
                        .overlay(
                            VStack {
                                Spacer()
                                Text(card.title)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                            }
                        )
                    
                    // Contenido
                    VStack(alignment: .leading, spacing: 20) {
                        Text(card.subtitle)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top)
                        
                        ForEach(card.details, id: \.title) { detail in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: detail.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.25, green: 0.72, blue: 0.85))
                                    
                                    Text(detail.title)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Text(detail.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.leading, 28)
                            }
                        }
                        
                        // Botón de acción
                        Button(action: {
                            // Acción al aceptar esta opción
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text("Interesado en esta área")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.25, green: 0.72, blue: 0.85),
                                        Color(red: 0.2, green: 0.6, blue: 1.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color(red: 0.25, green: 0.72, blue: 0.85).opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 30)
                    }
                    .padding()
                }
            }
            
            // Botón de cerrar
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
