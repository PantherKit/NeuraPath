//
//  SplashView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 14/05/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0

    var body: some View {
        if isActive {
            MainAppView() // Reemplaza con tu vista principal
        } else {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    Image("neurapathlogo") // 👈 tu ícono (agrega en Assets)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.0)) {
                                self.scale = 1.0
                                self.opacity = 1.0
                            }
                        }

                    Text("NeuraPath")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .padding(.top, 20)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
