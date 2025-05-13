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
            // Fondo con gradiente
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.91, green: 0.95, blue: 0.98),
                    Color(red: 0.98, green: 0.94, blue: 0.93),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Contenido de carga
            VStack(spacing: 30) {
                // Cohete con animaciones
                ZStack(alignment: .bottom) {
                    Text("🚀")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(isRotating ? 5 : -5))
                        .offset(y: isPulsing ? -10 : 0)
                }
                
                // Texto de carga
                Text("Preparing for launch...")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                // Indicador de progreso
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.3, green: 0.5, blue: 0.7)))
                    .scaleEffect(1.5)
            }
            .offset(y: -30) // Ajuste de posición vertical
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isRotating = true
        }
        
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.2)) {
            isPulsing = true
        }
        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
