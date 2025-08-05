import SwiftUI
import SplineRuntime

// MARK: - Base Cosmic Background Implementation
struct BasicCosmicBackground: View {
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Spline Scene - with refresh mechanism
            //let url = Bundle.main.url(forResource: "CosmicScene", withExtension: "splineswift")!
            let url = URL(string: "https://build.spline.design/LNarwXdiaAPhbs1naRTC/scene.splineswift")!
            
            // Use sceneIndex for compatibility with all Spline SDK versions
            SplineView(sceneFileURL: url)
                .ignoresSafeArea(.all)
        }
    }
}
struct WelcomeCosmicBackground: View {
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Spline Scene - with refresh mechanism
            //let url = Bundle.main.url(forResource: "CosmicScene", withExtension: "splineswift")!
            let url = URL(string: "https://build.spline.design/ANf4mf6cm2p8XkXO5Wjb/scene.splineswift")!
            
            // Use sceneIndex for compatibility with all Spline SDK versions
            SplineView(sceneFileURL: url)
                .ignoresSafeArea(.all)
        }
    }
}

struct InteractiveCosmicBackground: View {
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Spline Scene - with refresh mechanism
            //let url = Bundle.main.url(forResource: "CosmicScene", withExtension: "splineswift")!
            let url = URL(string: "https://build.spline.design/OvoAmmmgrn7PSFf7px-O/scene.splineswift")!
            
            // Use sceneIndex for compatibility with all Spline SDK versions
            SplineView(sceneFileURL: url)
                .ignoresSafeArea(.all)
        }
    }
}
