//
//  SplineTestView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 29/07/25.
//

import SwiftUI
import SplineRuntime

struct SplineTestView: View {
    @State private var refreshKey = 0
    @State private var lastRefreshTime = Date()
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Spline Scene - with refresh mechanism
            let url = URL(string: "https://build.spline.design/LNarwXdiaAPhbs1naRTC/scene.splineswift")!
            
            SplineView(sceneFileURL: url)
                .ignoresSafeArea(.all)
                .id(refreshKey) // Force refresh when key changes
            
            // Overlay Controls
            VStack {
                Spacer()
                
                HStack {
                    Button("Actualizar") {
                        refreshScene()
                    }
                    .buttonStyle(CosmicButtonStyle())
                    
                    Spacer()
                    
                    Button("Reiniciar") {
                        // Simple restart by recreating the view
                        print("Restart button pressed")
                        refreshScene()
                    }
                    .buttonStyle(CosmicButtonStyle())
                    
                    Spacer()
                    
                    Button("Volver") {
                        // Navigation back
                        print("Back button pressed")
                    }
                    .buttonStyle(CosmicButtonStyle())
                }
                .padding()
                
                // Last refresh indicator
                Text("Última actualización: \(lastRefreshTime, style: .time)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            // Auto-refresh on appear
            refreshScene()
        }
    }
    
    // MARK: - Refresh Methods
    private func refreshScene() {
        // Increment refresh key to force view recreation
        refreshKey += 1
        lastRefreshTime = Date()
        
        // Clear any potential caches
        clearCaches()
        
    }
    
    private func clearCaches() {
        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear Spline-specific caches if possible
        // Note: This depends on what the Spline SDK exposes
    }
}

// MARK: - Cosmic Button Style
struct CosmicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    SplineTestView()
}
