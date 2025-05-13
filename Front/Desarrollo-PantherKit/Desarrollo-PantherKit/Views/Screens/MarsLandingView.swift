import SwiftUI

struct EmojiLandingView: View {
    // Controla la posición de la 🚀
    @State private var landed = false
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.93).ignoresSafeArea()   // 🎨 Pastel background
            
            VStack(spacing: 24) {
                Text("Fast & easy test.\nIt takes less than 5 minutes.\n\nFind your STEM Path")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                // 🚀 Rocket
                Text("🚀")
                    .font(.system(size: 80))
                    .offset(y: landed ? 0 : -250)          // Baja desde arriba
                    .animation(.interpolatingSpring(stiffness: 120, damping: 12), value: landed) // Animación spring
                // 🌍 Planeta Tierra
                Text("🌍")
                    .font(.system(size: 120))
            }
        }
        .onAppear {
            // 1) Dispara la animación de la 🚀
            landed = true
        }
    }
}

#if DEBUG
#Preview("Emoji Landing") {
    EmojiLandingView()
}
#endif
