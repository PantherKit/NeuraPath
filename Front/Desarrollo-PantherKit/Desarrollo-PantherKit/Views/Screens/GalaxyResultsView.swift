//
//  GalaxyResultsView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct GalaxyResultsView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var isAnimating = false
    @State private var selectedField: EngineeringField?
    @State private var showFieldDetails = false
    
    private let starSizes: [CGFloat] = [30, 40, 50, 60, 70, 80]
    
    var body: some View {
        ZStack {
            // Space background
            Color.black
                .ignoresSafeArea()
            
            // Stars background
            ForEach(0..<100) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.5)))
                    .frame(width: Double.random(in: 1...3))
                    .position(
                        x: Double.random(in: 0...UIScreen.main.bounds.width),
                        y: Double.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
            
            // Nebula effects
            ForEach(0..<5) { i in
                Circle()
                    .fill(
                        [Color.purple, Color.blue, Color.cyan, Color.indigo, Color.pink][i % 5]
                            .opacity(0.1)
                    )
                    .frame(width: Double.random(in: 100...300))
                    .position(
                        x: Double.random(in: 0...UIScreen.main.bounds.width),
                        y: Double.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 30)
            }
            
            VStack {
                // Header
                Text("Tu Mapa Estelar STEM")
                    .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, AppTheme.Layout.spacingL)
                
                Text("Cada estrella representa tu afinidad con una carrera")
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(.gray)
                    .padding(.bottom, AppTheme.Layout.spacingL)
                
                // Galaxy view
                ZStack {
                    // Central star (primary field)
                    StarView(
                        field: viewModel.testResult?.primaryField ?? .mechatronics,
                        size: 100,
                        score: 1.0,
                        position: .center,
                        isAnimating: isAnimating
                    )
                    .onTapGesture {
                        selectedField = viewModel.testResult?.primaryField ?? .mechatronics
                        showFieldDetails = true
                    }
                    
                    // Orbiting stars (other fields)
                    ForEach(Array(viewModel.fieldScores.keys.filter { $0 != viewModel.primaryField }.enumerated()), id: \.element) { index, field in
                        let score = viewModel.normalizedScore(for: field)
                        let size = starSizes[min(index, starSizes.count - 1)]
                        let angle = Double(index) * (360.0 / Double(viewModel.fieldScores.count - 1))
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
                
                // Legend
                VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                    Text("Tus mejores coincidencias:")
                        .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Top 3 fields
                    ForEach(viewModel.topFields.prefix(3), id: \.self) { field in
                        HStack {
                            Circle()
                                .fill(field.color)
                                .frame(width: 15, height: 15)
                            
                            Text(field.rawValue)
                                .font(.system(size: AppTheme.Typography.body))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.normalizedScore(for: field) * 100))%")
                                .font(.system(size: AppTheme.Typography.body, weight: .bold))
                                .foregroundColor(field.color)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(AppTheme.Layout.cornerRadiusM)
                .padding()
                
                VStack(spacing: AppTheme.Layout.spacingM) {
                    // Share button
                    Button(action: {
                        // Share functionality would go here
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartir mis resultados")
                        }
                        .font(.system(size: AppTheme.Typography.body, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppTheme.Layout.cornerRadiusM)
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    // Return to home button
                    Button(action: {
                        // Return to MainTabView
                        if let window = UIApplication.shared.windows.first {
                            window.rootViewController = UIHostingController(rootView: MainTabView())
                        }
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Volver al inicio")
                        }
                        .font(.system(size: AppTheme.Typography.body, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppTheme.Layout.cornerRadiusM)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.bottom, AppTheme.Layout.spacingL)
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
                
                VStack(spacing: AppTheme.Layout.spacingL) {
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
                        .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Match percentage
                    Text("Coincidencia: \(Int(viewModel.normalizedScore(for: field) * 100))%")
                        .font(.system(size: AppTheme.Typography.title3))
                        .foregroundColor(field.color)
                    
                    // Description
                    Text(field.description)
                        .font(.system(size: AppTheme.Typography.body))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Examples
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
                        Text("Ejemplos del mundo real:")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(field.realWorldExample)
                            .font(.system(size: AppTheme.Typography.body))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Personality traits
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
                        Text("Rasgos de personalidad compatibles:")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            ForEach([viewModel.primaryTrait, viewModel.secondaryTrait], id: \.self) { trait in
                                HStack {
                                    Image(systemName: trait.icon)
                                        .foregroundColor(.yellow)
                                    
                                    Text(trait.rawValue)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, AppTheme.Layout.spacingM)
                                .padding(.vertical, AppTheme.Layout.spacingS)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(AppTheme.Layout.cornerRadiusM)
                                
                                if trait != viewModel.secondaryTrait {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                        .fill(Color(UIColor.systemGray6))
                        .opacity(0.95)
                )
                .padding()
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .bottom)
    }
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

struct GalaxyResultsView_Previews: PreviewProvider {
    static var previews: some View {
        GalaxyResultsView(viewModel: VocationalTestViewModel())
    }
}
