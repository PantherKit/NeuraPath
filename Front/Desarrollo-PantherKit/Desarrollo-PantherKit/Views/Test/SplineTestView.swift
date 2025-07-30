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

// MARK: - Preview
#Preview {
    SplineTestView()
}
