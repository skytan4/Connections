//
//  AtmosphericBackground.swift
//  Connections
//

import SwiftUI

struct AtmosphericBackground: View {
    let intensity: Intensity?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                darkBackground
            } else {
                lightBackground
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Light Mode

    @ViewBuilder
    private var lightBackground: some View {
        switch intensity {
        case .light:
            ZStack {
                Color(red: 0.99, green: 0.96, blue: 0.90)
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.97, blue: 0.93),
                        Color(red: 0.975, green: 0.94, blue: 0.88)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.07),
                        Color.white.opacity(0.0)
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                Color.black.opacity(0.015)
            }

        case .honest:
            ZStack {
                Color(red: 0.93, green: 0.96, blue: 0.99)
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.98, blue: 1.0),
                        Color(red: 0.86, green: 0.91, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color(red: 0.90, green: 0.95, blue: 1.0).opacity(0.13),
                        Color.white.opacity(0.0)
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                Color.black.opacity(0.035)
            }

        case .unfiltered:
            ZStack {
                Color(red: 0.97, green: 0.95, blue: 0.985)
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.96, blue: 0.99),
                        Color(red: 0.92, green: 0.90, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color(red: 0.94, green: 0.92, blue: 1.0).opacity(0.055),
                        Color.white.opacity(0.0)
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                Color.black.opacity(0.02)
            }

        default:
            Color(red: 0.99, green: 0.96, blue: 0.90)
        }
    }

    // MARK: - Dark Mode

    @ViewBuilder
    private var darkBackground: some View {
        switch intensity {
        case .light:
            ZStack {
                Color(red: 0.09, green: 0.08, blue: 0.07)
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.09, blue: 0.07),
                        Color(red: 0.07, green: 0.06, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color(red: 0.14, green: 0.12, blue: 0.09).opacity(0.3),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
            }

        case .honest:
            ZStack {
                Color(red: 0.07, green: 0.08, blue: 0.10)
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.09, blue: 0.12),
                        Color(red: 0.06, green: 0.07, blue: 0.09)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color(red: 0.10, green: 0.13, blue: 0.18).opacity(0.25),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
            }

        case .unfiltered:
            ZStack {
                Color(red: 0.09, green: 0.07, blue: 0.10)
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.08, blue: 0.12),
                        Color(red: 0.07, green: 0.06, blue: 0.09)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color(red: 0.13, green: 0.10, blue: 0.16).opacity(0.25),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
            }

        default:
            Color(red: 0.09, green: 0.08, blue: 0.07)
        }
    }
}
