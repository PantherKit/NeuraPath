//
//  StyledButton.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 12/05/25.
//

import SwiftUI

// Botón reutilizable
struct StyledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.black)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
