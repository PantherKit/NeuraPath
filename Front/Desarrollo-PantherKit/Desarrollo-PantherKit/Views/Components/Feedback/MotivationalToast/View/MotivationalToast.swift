import SwiftUI

struct MotivationalToast: View {
    let fact: MotivationalFact
    let onDismiss: () -> Void
    
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 100
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: fact.icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 0.3, green: 0.6, blue: 0.9), Color(red: 0.2, green: 0.4, blue: 0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(fact.title).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Text(fact.message).font(.system(size: 14)).foregroundColor(.white.opacity(0.9)).lineLimit(3)
            }
            Spacer()
            Button(action: { dismissToast() }) {
                Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(.white.opacity(0.7)).padding(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.2, blue: 0.3)]), startPoint: .top, endPoint: .bottom))
                .opacity(0.95)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear { showToast(); scheduleAutoDismiss() }
    }
    
    private func showToast() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { opacity = 1; offset = 0 }
    }
    
    private func dismissToast() {
        withAnimation(.easeOut(duration: 0.3)) { opacity = 0; offset = 100 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
    }
    
    private func scheduleAutoDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { dismissToast() }
    }
}


