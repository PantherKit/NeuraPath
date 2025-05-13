import SwiftUI

struct Sock: Identifiable {
    let id = UUID()
    let imageName: String
}

struct SockDetailView: View {
    let sock: Sock
    
    let headerHeight: CGFloat = 350
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: -60) {
                Image(sock.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: headerHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        Text("Meet your perfect match!")
                            .font(.title)
                            .bold()
                        
                        Text("This sock is looking for a warm-hearted companion. 🧦❤️")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Divider().padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🧬 Sock Bio")
                                .font(.headline)
                            Text("• Size: Medium\n• Material: 100% snuggle-certified cotton\n• Last washed: 2 days ago 😌\n• Favorite activity: Sliding on hardwood floors")
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🎭 Personality")
                                .font(.headline)
                            Text("• Playful but loyal\n• Loves long walks from the laundry basket\n• Has trust issues (once lost in a dryer)")
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("💞 Looking For")
                                .font(.headline)
                            Text("• A matching pair, or someone who completes me.\n• Must enjoy warm feet and quiet cuddle nights in the drawer.")
                        }
                        
                        Divider().padding(.vertical)
                        
                        Button(action: {
                            // Maybe swipe right programmatically?
                        }) {
                            Label("Swipe Right 💘", systemImage: "hand.thumbsup.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.pink)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct DeckView: View {
    var onComplete: () -> Void
    @State private var socks: [Sock] = (1...6).map { Sock(imageName: "sock\($0)") }
    @State private var activeIndex: Int = 0
    
    let clockPhases = "🕐🕑🕒🕓🕔🕕🕖🕘🕙🕛".map { String($0) }
    
    @Namespace private var cardNamespace
    
    @State private var showDetails = false
    @State private var selectedSock: Sock? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 8) {
                    animatedLikesText()
                }
                
                Spacer()
                
                // Card stack view
                cardStackView()
                
                Spacer()
                Spacer()
            }
            .navigationDestination(isPresented: $showDetails) {
                if let sock = selectedSock {
                    SockDetailView(sock: sock)
                        .navigationTransition(
                            .zoom(sourceID: sock.id,
                                  in: cardNamespace)
                        )
                }
            }
        }
    }
    
    // Breaking down the complex animation into a separate function
    private func animatedLikesText() -> some View {
        return phaseAnimatedText()
            .padding()
    }
    
    private func phaseAnimatedText() -> some View {
        return Text("Unlimited likes for 1 hour")
            .font(.headline)
            .phaseAnimator([false, true]) { content, isRed in
                HStack {
                    moonPhaseAnimator()
                    content
                }
                .foregroundStyle(isRed ? .red : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } animation: { _ in
                    .easeInOut(duration: 1.0)
            }
    }
    
    private func moonPhaseAnimator() -> some View {
        return PhaseAnimator(clockPhases) { phase in
            Text(phase)
        } animation: { _ in
                .easeInOut(duration: 1.0)
        }
        .font(.system(size: 35))
    }
    
    // Breaking down the card stack logic
    private func cardStackView() -> some View {
        ZStack {
            ForEach(Array(socks.enumerated()), id: \.element.id) { index, sock in
                createCardView(for: sock, at: index)
                    .zIndex(Double(socks.count - index))
            }
        }
        .frame(width: 200, height: 300)
    }
    
    private func createCardView(for sock: Sock, at index: Int) -> some View {
        CardView(
            isActive: index == activeIndex,
            onSwipedAway: {
                if activeIndex < socks.count - 1 {
                    activeIndex += 1
                } else {
                    onComplete()
                }
            },
            sock: sock,
            onShowDetails: {
                selectedSock = sock
                showDetails = true
            }
        )
        
        
    }
}


struct CardView: View {
    let isActive: Bool
    let onSwipedAway: () -> Void
    let sock: Sock
    
    @State private var dragOffset = CGSize.zero
    let horizontalLimit: CGFloat = 100
    let maxRotationDegrees: Double = 15
    @State private var isGone = false
    @State private var isDragging = false
    
    let onShowDetails: () -> Void
    
    let swipeThreshold: CGFloat = 100
    
    var rotationAngle: Double {
        let percentage = dragOffset.width / horizontalLimit
        return Double(percentage) * maxRotationDegrees
    }
    
    let color: Color = .random
    
    let emojis = ["♥️", "🥵", "🤩", "👍"]
    
    @State private var superLiked: Bool = false
    
    @State private var navigateToDetails = false
    
    
    var body: some View {
        ZStack {
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
            }
            .offset(y: isActive && !isDragging ? 50 : 0)
            .animation(
                .easeOut(duration: 0.5),
                value: isActive && !isDragging
            )
            .foregroundStyle(.thickMaterial)
            .frame(width: 300, height: 400)
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: 300, height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            
            
            
            if isDragging {
                if dragOffset.width > 0 {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.red)
                        .opacity(Double(min(dragOffset.width / horizontalLimit, 1)))
                        .transition(.move(edge: .top))
                    
                } else if dragOffset.width < 0 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .opacity(Double(min(-dragOffset.width / horizontalLimit, 1)))
                        .transition(.scale)
                    
                    /*
                     .transition(
                     .asymmetric(
                     insertion: .move(edge: .top),
                     removal: .scale
                     )
                     )
                     */
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        onShowDetails()
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .padding()
        }
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .opacity(isGone ? 0 : 1)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    
                    withAnimation(.interactiveSpring()) {
                        isDragging = true
                        let newWidth = value.translation.width
                        let clampedWidth = min(max(newWidth, -horizontalLimit), horizontalLimit)
                        dragOffset = CGSize(width: clampedWidth, height: 0)
                    }
                }
                .onEnded { value in
                    if abs(value.translation.width) > swipeThreshold {
                        withAnimation(.spring()) {
                            isDragging = false
                            let horizontalDirection: CGFloat = value.translation.width > 0 ? 1 : -1
                            dragOffset = CGSize(width: horizontalDirection * 500, height: 0)
                            isGone = true
                            onSwipedAway()
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
        
        
        
        
    }
}

struct DeckViewWrapper: View {
    let onComplete: () -> Void
    @ObservedObject var viewModel: VocationalTestViewModel
    
    var body: some View {
        DeckView(onComplete: onComplete)
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.3...1),
            green: .random(in: 0.3...1),
            blue: .random(in: 0.3...1)
        )
    }
}
