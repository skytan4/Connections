//
//  NeutralBackground.swift
//  Connections
//

import SwiftUI

struct NeutralBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.95, blue: 0.89)

            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.96, blue: 0.91),
                    Color(red: 0.96, green: 0.92, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.white.opacity(0.0)
                ],
                center: .init(x: 0.5, y: 0.2),
                startRadius: 0,
                endRadius: 500
            )

            Color.black.opacity(0.035)
        }
        .ignoresSafeArea()
    }
}
