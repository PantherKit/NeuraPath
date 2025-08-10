//
//  LoadingView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 13/05/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isRotating = false
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Fondo con gradiente semi-transparente
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.91, green: 0.95, blue: 0.98).opacity(0.9),
                    Color(red: 0.98, green: 0.94, blue: 0.93).opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Contenido de carga centrado
            VStack(spacing: 30) {
                // Cohete con animaciones
                ZStack {
                    Text("🚀")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(isRotating ? 8 : -8))
                        .offset(y: isPulsing ? -15 : 0)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Efecto de estela
                    if isPulsing {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 30)
                            .offset(y: 50)
                            .blur(radius: 10)
                            .opacity(isPulsing ? 1 : 0)
                    }
                }
                
                // Texto de carga con tipografía espacial
                Text("¡Empecemos este viaje!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                    .shadow(color: Color.white.opacity(0.5), radius: 2, x: 0, y: 1)
                
                // Indicador de progreso personalizado
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: Color(red: 0.25, green: 0.72, blue: 0.85))
                    )
                    .scaleEffect(1.5)
                    .overlay(
                        // Esto simulará el efecto de gradiente
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.25, green: 0.72, blue: 0.85),
                                Color(red: 0.2, green: 0.6, blue: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        )
                    )
            }
            .offset(y: -50) // Ajuste de posición vertical
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isRotating = true
            }
            
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.3)) {
                isPulsing = true
            }
        }
    }
}

#Preview{
    LoadingView()
}
