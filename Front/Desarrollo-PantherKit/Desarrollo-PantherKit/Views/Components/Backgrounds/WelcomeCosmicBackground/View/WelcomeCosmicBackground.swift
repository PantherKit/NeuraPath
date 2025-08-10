import SwiftUI
import SplineRuntime

struct WelcomeCosmicBackground: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            let url = URL(string: "https://build.spline.design/ANf4mf6cm2p8XkXO5Wjb/scene.splineswift")!
            SplineView<SplineContent?>(sceneFileURL: url)
                .ignoresSafeArea(.all)
        }
    }
}


