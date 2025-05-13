//
//  StarFieldView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 12/05/25.
//
import SwiftUI

struct StarField: View {
    // Very light weight star‑field using Canvas
    @State private var time = 0.0
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                ctx.opacity = 0.8
                let starCount = 150
                for i in 0..<starCount {
                    let x = Double(i) / Double(starCount) * size.width
                    let speed = 10 + Double(i % 10)
                    let y = (time * speed + Double(i)*5).truncatingRemainder(dividingBy: size.height)

                    let starSize = CGFloat.random(in: 1...2.5)  // 💫 puntos más suaves
                    let opacity = Double.random(in: 0.3...0.9)

                    var star = Path()
                    star.addEllipse(in: CGRect(x: x, y: y, width: starSize, height: starSize))

                    ctx.fill(star, with: .color(Color.white.opacity(opacity)))
                }
            }
            .onReceive(timer) { _ in time += 1 }
        }
        .blendMode(.plusLighter)
    }
}
