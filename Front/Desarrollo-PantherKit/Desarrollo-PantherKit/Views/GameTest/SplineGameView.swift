//
//  SplineGameView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 05/08/25.
//

import SwiftUI
import SplineRuntime

struct SplineGameView: View {
    @State private var stepValue: Int = 0
    @State private var isButtonPressed: Bool = false
    
    // SplineController para interactuar con la escena
    private var controller = SplineController()
    
    var body: some View {
        ZStack {
            // Spline Scene con controller configurado correctamente
            let url = URL(string: "https://build.spline.design/OvoAmmmgrn7PSFf7px-O/scene.splineswift")!
            
            SplineView(sceneFileURL: url, controller: controller) { phase in
                phase.content?.task {
                    // Configurar event listeners cuando la escena se carga
                    setupEventListeners()
                }
            }
            .ignoresSafeArea(.all)
            
            // Game UI Overlay
            VStack(spacing: 32) {
                Spacer()
                
                // Step Counter Display
                VStack(spacing: 12) {
                    Text("STEP COUNTER")
                        .font(AppTheme.Space.spaceCaption(12))
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.spaceElectricBlue)
                        .tracking(2)
                    
                    Text("\(stepValue)")
                        .font(AppTheme.Space.spaceLargeMetric(48))
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.spacePureWhite)
                        .scaleEffect(isButtonPressed ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isButtonPressed)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                .stroke(AppTheme.Colors.spaceElectricBlue, lineWidth: 2)
                        )
                )
                
                // Increment Button - Control desde SwiftUI
                Button("INCREMENT STEP") {
                    incrementStepFromSwiftUI()
                }
                .font(AppTheme.Space.spaceCaption(16))
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.spacePureWhite)
                .tracking(1.5)
                .padding(.horizontal, 40)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                        .fill(AppTheme.Colors.spaceElectricBlue.opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                .stroke(AppTheme.Colors.spaceElectricBlue, lineWidth: 2)
                        )
                )
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isButtonPressed)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isButtonPressed = pressing
                }, perform: {})
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Event Listeners Setup
    private func setupEventListeners() {
        // Solo escuchar eventos de Mouse Up para debugging (opcional)
        controller.addEventListener(.mouseUp) { obj in
            print("Mouse Up detected on object: \(obj.name)")
        }
        
        // Inicializar la variable Step si no existe
        if controller.getNumberVariable(name: "Step") == nil {
            controller.setNumberVariable(name: "Step", value: 0)
        }
        
        // Sincronizar el estado inicial
        DispatchQueue.main.async {
            stepValue = Int(controller.getNumberVariable(name: "Step") ?? 0)
        }
    }
    
    // MARK: - SwiftUI Controls
    private func incrementStepFromSwiftUI() {
        let currentStep = controller.getNumberVariable(name: "Step") ?? 0
        let newStep = currentStep + 1
        controller.setNumberVariable(name: "Step", value: newStep)
        
        stepValue = Int(newStep)
        print("Step incremented from SwiftUI to: \(newStep)")
    }
}

// MARK: - Preview
#Preview {
    SplineGameView()
}
