import SwiftUI
import SplineRuntime

struct InteractiveCosmicBackground: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            let url = URL(string: "https://build.spline.design/OvoAmmmgrn7PSFf7px-O/scene.splineswift")!
            SplineView<SplineContent?>(sceneFileURL: url)
                .ignoresSafeArea(.all)
        }
    }
}


