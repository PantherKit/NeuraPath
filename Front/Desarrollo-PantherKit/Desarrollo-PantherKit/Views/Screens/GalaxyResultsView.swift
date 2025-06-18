//
//  GalaxyResultsView.swift
//  NeuraPath - Simplified Demo Version
//

import SwiftUI

struct GalaxyResultsView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var isAnimating = false
    @State private var showFieldDetails = false
    @State private var selectedField: EngineeringField? = nil
    
    // Demo data
    private let demoFields = DemoData.demoFields
    private let starSizes: [CGFloat] = [60, 50, 45, 40, 35]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("🌟 Tu Galaxia STEM 🌟")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Explora tus afinidades profesionales")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 20)
                
                // Galaxy view with demo data
                ZStack {
                    // Central star (primary field)
                    StarView(
                        field: DemoData.primaryField,
                        size: 100,
                        score: 1.0,
                        position: .center,
                        isAnimating: isAnimating
                    )
                    .onTapGesture {
                        selectedField = DemoData.primaryField
                        showFieldDetails = true
                    }
                    
                    // Orbiting stars (other fields)
                    ForEach(Array(demoFields.filter { $0 != DemoData.primaryField }.enumerated()), id: \.element) { index, field in
                        let score = DemoData.normalizedScore(for: field)
                        let size = starSizes[min(index, starSizes.count - 1)]
                        let angle = Double(index) * (360.0 / Double(demoFields.count - 1))
                        let distance = 150.0 + Double(index) * 20.0
                        
                        StarView(
                            field: field,
                            size: size,
                            score: score,
                            position: .orbit(angle: angle, distance: distance),
                            isAnimating: isAnimating
                        )
                        .onTapGesture {
                            selectedField = field
                            showFieldDetails = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 400)
                .padding()
                
                // Legend with demo data
                VStack(alignment: .leading, spacing: 15) {
                    Text("Tus mejores coincidencias:")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Top 3 fields
                    ForEach(DemoData.topFields.prefix(3), id: \.self) { field in
                        HStack {
                            Circle()
                                .fill(field.color)
                                .frame(width: 15, height: 15)
                            
                            Text(field.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(Int(DemoData.normalizedScore(for: field) * 100))%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(field.color)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(15)
                .padding()
                
                // Action buttons
                VStack(spacing: 15) {
                    // Share button
                    Button(action: {
                        // Share functionality
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartir mis resultados")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    // Return to home button
                    Button(action: {
                        // Return to MainAppView
                        if let window = UIApplication.shared.windows.first {
                            window.rootViewController = UIHostingController(rootView: MainAppView())
                        }
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Volver al inicio")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0)) {
                    isAnimating = true
                }
            }
            
            // Field details sheet
            if showFieldDetails, let field = selectedField {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showFieldDetails = false
                    }
                
                VStack(spacing: 20) {
                    // Close button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showFieldDetails = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Field icon
                    ZStack {
                        Circle()
                            .fill(field.color.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: field.icon)
                            .font(.system(size: 60))
                            .foregroundColor(field.color)
                    }
                    
                    // Field name
                    Text(field.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Match percentage
                    Text("Coincidencia: \(Int(DemoData.normalizedScore(for: field) * 100))%")
                        .font(.system(size: 18))
                        .foregroundColor(field.color)
                    
                    // Description
                    Text(field.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Examples
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ejemplos del mundo real:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(field.realWorldExample)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black)
                .cornerRadius(20)
                .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GalaxyResultsView(viewModel: VocationalTestViewModel())
}

// MARK: - Star View
struct StarView: View {
    let field: EngineeringField
    let size: CGFloat
    let score: Double
    let position: StarPosition
    let isAnimating: Bool
    
    enum StarPosition {
        case center
        case orbit(angle: Double, distance: Double)
    }
    
    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(field.color.opacity(0.5))
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 15)
            
            // Star
            Circle()
                .fill(field.color)
                .frame(width: size, height: size)
            
            // Icon
            Image(systemName: field.icon)
                .font(.system(size: size / 2.5))
                .foregroundColor(.white)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.1)
        .opacity(isAnimating ? 1.0 : 0.0)
        .position(position: position)
    }
}

// MARK: - Extensions
extension View {
    func position(position: StarView.StarPosition) -> some View {
        switch position {
        case .center:
            return self.position(x: UIScreen.main.bounds.width / 2, y: 200)
        case .orbit(let angle, let distance):
            let radians = angle * .pi / 180
            let x = UIScreen.main.bounds.width / 2 + cos(radians) * distance
            let y = 200 + sin(radians) * distance
            return self.position(x: x, y: y)
        }
    }
}
