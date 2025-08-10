import SwiftUI
import SplineRuntime

// MARK: - Base Cosmic Background Implementation
struct BasicCosmicBackground: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            let url = URL(string: "https://build.spline.design/LNarwXdiaAPhbs1naRTC/scene.splineswift")!
            SplineView<SplineContent?>(sceneFileURL: url)
                .ignoresSafeArea(.all)
        }
    }
}


