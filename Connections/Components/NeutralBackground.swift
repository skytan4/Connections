//
//  NeutralBackground.swift
//  Connections
//

import SwiftUI

struct NeutralBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(red: 0.08, green: 0.07, blue: 0.06)

                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.08, blue: 0.07),
                        Color(red: 0.06, green: 0.06, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color(red: 0.12, green: 0.10, blue: 0.08).opacity(0.25),
                        Color.clear
                    ],
                    center: .init(x: 0.5, y: 0.2),
                    startRadius: 0,
                    endRadius: 500
                )
            } else {
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
        }
        .ignoresSafeArea()
    }
}
