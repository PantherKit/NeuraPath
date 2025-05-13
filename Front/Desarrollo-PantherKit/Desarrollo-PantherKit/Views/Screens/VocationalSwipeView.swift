//
//  VocationalSwipeView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/13/25.
//

import SwiftUI

struct CareerDetailView: View {
    let field: EngineeringField
    let viewModel: VocationalTestViewModel
    
    let headerHeight: CGFloat = 350
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: -60) {
                // Header image/icon
                ZStack {
                    field.color.opacity(0.2)
                        .frame(height: headerHeight)
                        .frame(maxWidth: .infinity)
                    
                    VStack {
                        Image(systemName: field.icon)
                            .font(.system(size: 120))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [field.color, field.color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.pulse, options: .repeating)
                            .shadow(color: field.color.opacity(0.5), radius: 10)
                        
                        Text(field.rawValue)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("¡Descubre tu carrera ideal!")
                            .font(.title)
                            .bold()
                        
                        Text("Esta carrera está buscando mentes brillantes como tú. 🚀💫")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Divider().padding(.vertical, 10)
                        
                        // Career details
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Descripción", systemImage: "doc.text.fill")
                                .font(.headline)
                                .foregroundColor(field.color)
                            
                            Text(field.description)
                                .padding(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.Colors.secondaryBackground)
                                .shadow(color: field.color.opacity(0.2), radius: 5)
                        )
                        
                        // Real world examples
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Aplicaciones del mundo real", systemImage: "globe")
                                .font(.headline)
                                .foregroundColor(field.color)
                            
                            Text(field.realWorldExample)
                                .padding(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.Colors.secondaryBackground)
                                .shadow(color: field.color.opacity(0.2), radius: 5)
                        )
                        
                        // Skills needed
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Habilidades necesarias", systemImage: "brain.fill")
                                .font(.headline)
                                .foregroundColor(field.color)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                skillRow(text: "Pensamiento analítico", level: 0.8)
                                skillRow(text: "Resolución de problemas", level: 0.9)
                                skillRow(text: "Trabajo en equipo", level: 0.7)
                                skillRow(text: "Creatividad", level: 0.75)
                            }
                            .padding(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.Colors.secondaryBackground)
                                .shadow(color: field.color.opacity(0.2), radius: 5)
                        )
                        
                        Divider().padding(.vertical, 10)
                        
                        // Action buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.updateFieldScore(field, by: -0.5)
                                dismiss()
                            }) {
                                Label("No me interesa", systemImage: "hand.thumbsdown.fill")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.Colors.error)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            Button(action: {
                                viewModel.updateFieldScore(field, by: 1.0)
                                dismiss()
                            }) {
                                Label("¡Me interesa!", systemImage: "hand.thumbsup.fill")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(field.color)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                }
                .background(AppTheme.Colors.background)
            }
            
            // Back button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.leading)
            .padding(.top, 50)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func skillRow(text: String, level: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(text)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Capsule()
                    .frame(width: UIScreen.main.bounds.width * 0.6 * level, height: 8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [field.color, field.color.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}

struct CareerCardView: View {
    let field: EngineeringField
    let isActive: Bool
    let onSwipedAway: (Bool) -> Void
    let onShowDetails: () -> Void
    let index: Int
    
    // Card state
    @State private var offset = CGSize.zero
    @State private var color: Color = .gray
    
    // Constants
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            field.color.opacity(0.6),
                            field.color.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(field.color.opacity(0.7), lineWidth: 2)
                )
                .frame(width: 300, height: 400)
                .shadow(color: field.color.opacity(0.5), radius: 10)
            
            // Card content
            VStack(spacing: 15) {
                // Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: field.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .symbolEffect(.bounce, options: .repeating)
                        .shadow(color: .black.opacity(0.2), radius: 1)
                }
                .padding(.top, 20)
                
                // Title
                Text(field.rawValue)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 1)
                
                // Description
                Text(field.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.1), radius: 1)
                
                Spacer()
                
                // Info button
                Button {
                    onShowDetails()
                } label: {
                    Label("Ver detalles", systemImage: "info.circle")
                        .font(.headline)
                        .padding(10)
                        .background(.white.opacity(0.3))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.bottom)
            }
            .frame(width: 300, height: 400)
            
            // Swipe indicators
            VStack {
                Spacer()
                HStack {
                    // Dislike indicator
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 50))
                        .opacity(offset.width < -20 ? 1.0 : 0.0)
                    
                    Spacer()
                    
                    // Like indicator
                    Image(systemName: "heart.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 50))
                        .opacity(offset.width > 20 ? 1.0 : 0.0)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .highPriorityGesture(
            DragGesture(minimumDistance: 10)
                .onChanged { gesture in
                    offset = gesture.translation
                    withAnimation {
                        // Change color based on swipe direction
                        color = offset.width > 0 ? AppTheme.Colors.success : AppTheme.Colors.error
                    }
                }
                .onEnded { gesture in
                    withAnimation(.spring()) {
                        if abs(offset.width) > swipeThreshold {
                            // Swipe away
                            offset.width = offset.width > 0 ? 1000 : -1000
                            
                            // Provide haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            // Notify parent after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipedAway(offset.width > 0)
                            }
                        } else {
                            // Reset position
                            offset = .zero
                        }
                    }
                }
        )
    }
}

struct VocationalSwipeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var currentIndex = 0
    @State private var showNextScreen = false
    @State private var showDetails = false
    @State private var selectedField: EngineeringField?
    @State private var isAnimating = false
    @State private var viewOffset: CGFloat = 0
    @State private var showSuccessAnimation = false
    
    // Add environment values to detect tab view
    @Environment(\.presentationMode) var presentationMode
    
    private let careers = EngineeringField.allCases
    private let clockPhases = "🕐🕑🕒🕓🕔🕕🕖🕘🕙🕛".map { String($0) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    // Header with animated title
                    HStack(spacing: 8) {
                        Text("Unlimited likes")
                            .font(.headline)
                            .phaseAnimator([false, true]) { content, isHighlighted in
                                HStack {
                                    PhaseAnimator(clockPhases) { phase in
                                        Text(phase)
                                    } animation: { _ in
                                        .easeInOut(duration: 1.0)
                                    }
                                    .font(.system(size: 20))
                                    
                                    content
                                }
                                .foregroundStyle(isHighlighted ? AppTheme.Colors.primary : AppTheme.Colors.text)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            } animation: { _ in
                                .easeInOut(duration: 1.0)
                            }
                    }
                    .padding()
                    
                    // Progress indicator
                    HStack {
                        Text("Descubre tu carrera")
                            .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Spacer()
                        
                        Text("\(currentIndex + 1)/\(careers.count)")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .padding(8)
                            .background(
                                Capsule()
                                    .fill(AppTheme.Colors.secondaryBackground)
                                    .overlay(
                                        Capsule()
                                            .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal)
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 10)
                            .foregroundColor(AppTheme.Colors.primary.opacity(0.2))
                        
                        Capsule()
                            .frame(width: UIScreen.main.bounds.width * CGFloat(currentIndex + 1) / CGFloat(careers.count), height: 10)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Card stack
                    ZStack {
                        // Background cards
                        ForEach((0..<min(3, careers.count - currentIndex)).reversed(), id: \.self) { i in
                            if currentIndex + i < careers.count && i > 0 {
                                CareerCardView(
                                    field: careers[currentIndex + i],
                                    isActive: false,
                                    onSwipedAway: { _ in },
                                    onShowDetails: {},
                                    index: currentIndex + i
                                )
                                .scaleEffect(1.0 - CGFloat(i) * 0.05)
                                .opacity(1.0 - Double(i) * 0.3)
                                .offset(y: CGFloat(i) * 10)
                                .zIndex(-Double(i))
                            }
                        }
                        
                        // Current card
                        if currentIndex < careers.count {
                            CareerCardView(
                                field: careers[currentIndex],
                                isActive: true,
                                onSwipedAway: { liked in
                                    // Update score based on like/dislike
                                    let field = careers[currentIndex]
                                    viewModel.updateFieldScore(field, by: liked ? 1.0 : -0.5)
                                    
                                    // Move to next card
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        if currentIndex < careers.count - 1 {
                                            currentIndex += 1
                                        } else {
                                            // All cards swiped, move to results
                                            viewModel.testCompleted = true
                                            showNextScreen = true
                                        }
                                    }
                                },
                                onShowDetails: {
                                    selectedField = careers[currentIndex]
                                    showDetails = true
                                },
                                index: currentIndex
                            )
                            .id(currentIndex) // Force view recreation when index changes
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack(spacing: 40) {
                        // Dislike button
                        Button {
                            if currentIndex < careers.count {
                                let field = careers[currentIndex]
                                viewModel.updateFieldScore(field, by: -0.5)
                                
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                // Move to next card
                                if currentIndex < careers.count - 1 {
                                    withAnimation {
                                        currentIndex += 1
                                    }
                                } else {
                                    // All cards swiped, move to results
                                    viewModel.testCompleted = true
                                    showNextScreen = true
                                }
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [AppTheme.Colors.error.opacity(0.8), AppTheme.Colors.error],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    }
                                )
                                .shadow(color: AppTheme.Colors.error.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        
                        // Like button
                        Button {
                            if currentIndex < careers.count {
                                let field = careers[currentIndex]
                                viewModel.updateFieldScore(field, by: 1.0)
                                
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                // Move to next card
                                if currentIndex < careers.count - 1 {
                                    withAnimation {
                                        currentIndex += 1
                                    }
                                } else {
                                    // All cards swiped, move to results
                                    viewModel.testCompleted = true
                                    showNextScreen = true
                                }
                            }
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [AppTheme.Colors.success.opacity(0.8), AppTheme.Colors.success],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    }
                                )
                                .shadow(color: AppTheme.Colors.success.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.vertical)
            }
            // We'll handle the transition in the onAppear modifier
            .navigationDestination(isPresented: $showDetails) {
                if let field = selectedField {
                    CareerDetailView(field: field, viewModel: viewModel)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .offset(y: viewOffset)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewOffset)
            .overlay(
                ZStack {
                    // Success animation overlay
                    if showSuccessAnimation {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                            .transition(.opacity)
                        
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.success)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: AppTheme.Colors.success.opacity(0.5), radius: 10)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                                    .symbolEffect(.bounce, options: .repeating)
                            }
                            
                            Text("¡Test Completado!")
                                .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            )
            .onChange(of: showNextScreen) { newValue in
                if newValue {
                    // Mostrar animación de éxito
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSuccessAnimation = true
                    }
                    
                    // Después de mostrar la animación, deslizar la vista hacia abajo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        
                        // Deslizar la vista hacia abajo (fuera de la pantalla)
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            viewOffset = UIScreen.main.bounds.height
                        }
                        
                        // Navegar a QuickDecisionView después de que la vista se haya deslizado
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            // Crear una instancia de NavigationLink programáticamente
                            let hostingController = UIHostingController(rootView: 
                                NavigationView {
                                    QuickDecisionView(viewModel: viewModel)
                                        .navigationBarHidden(true)
                                }
                            )
                            
                            // Obtener la ventana actual
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                
                                // Configurar la transición
                                let transition = CATransition()
                                transition.duration = 0.3
                                transition.type = .fade
                                
                                // Aplicar la transición
                                window.layer.add(transition, forKey: nil)
                                
                                // Establecer el nuevo controlador de vista
                                window.rootViewController = hostingController
                            }
                        }
                    }
                }
            }
            .onAppear {
                isAnimating = true
                viewOffset = 0 // Asegurarse de que la vista comienza en su posición normal
            }
        }
    }
}

struct VocationalSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        VocationalSwipeView(viewModel: VocationalTestViewModel())
    }
}
