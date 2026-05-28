//
//  SelectionCard.swift
//  Connections
//

import SwiftUI

/// A reusable tappable card used throughout selection screens (mode, intensity, topic, etc.).
/// Displays a title and subtitle with an optional tint color and a subtle press animation.
/// When `glassEffect` is enabled, renders with a translucent layered-glass treatment.
struct SelectionCard: View {
    let title: String
    let subtitle: String
    var tintColor: Color? = nil
    var isSelected: Bool = false
    var glassEffect: Bool = false
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFont.buttonSecondary())
                        .foregroundColor(glassEffect && colorScheme == .light ? Color.black.opacity(0.96) : Color.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(AppFont.detail())
                        .foregroundColor(glassEffect && colorScheme == .light ? Color.black.opacity(0.46) : Color.secondary)
                }

                Spacer()
            }
        }
        .buttonStyle(
            SelectionCardButtonStyle(
                tintColor: tintColor,
                isSelected: isSelected,
                glassEffect: glassEffect
            )
        )
    }
}

// MARK: - Selection Card Button Style

private struct SelectionCardButtonStyle: ButtonStyle {
    var tintColor: Color?
    var isSelected: Bool
    var glassEffect: Bool

    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(minHeight: glassEffect ? 120 : 0)
            .background {
                if glassEffect {
                    glassBackground(isPressed: configuration.isPressed)
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(backgroundFill(isPressed: configuration.isPressed))
                }
            }
            .scaleEffect(cardScale(isPressed: configuration.isPressed))
            .animation(.easeInOut(duration: 0.16), value: isSelected)
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }

    /// Flat background fill for the default (non-glass) mode.
    private func backgroundFill(isPressed: Bool) -> Color {
        if let tint = tintColor {
            let opacity = isSelected ? 0.28 : (isPressed ? 0.22 : 0.14)
            return tint.opacity(opacity)
        }
        let opacity = isSelected ? 0.12 : (isPressed ? 0.08 : 0.04)
        return Color.primary.opacity(opacity)
    }

    private func cardScale(isPressed: Bool) -> CGFloat {
        if isPressed { return 0.98 }
        if glassEffect && isSelected { return 1.025 }
        return 1.0
    }

    // MARK: - Glass Background

    /// Layered glass surface: material → tint → white highlight → border stroke → shadow.
    @ViewBuilder
    private func glassBackground(isPressed: Bool) -> some View {
        let tint = tintColor ?? Color.primary
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        let tintOpacity = isSelected ? 0.30 : (isPressed ? 0.18 : 0.12)

        shape
            .fill(.ultraThinMaterial)
            .overlay(shape.fill(tint.opacity(tintOpacity)))
            .overlay(
                colorScheme == .light
                ? shape.fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isSelected ? 0.28 : 0.20),
                            Color.white.opacity(isSelected ? 0.02 : 0.00)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : nil
            )
            .overlay(
                shape.strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? (isSelected ? 0.12 : 0.06) : (isSelected ? 0.35 : 0.16)),
                            Color.white.opacity(colorScheme == .dark ? (isSelected ? 0.04 : 0.02) : (isSelected ? 0.12 : 0.04))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 1.4 : 1
                )
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.14 : 0.06),
                radius: isSelected ? 14 : 6,
                x: 0,
                y: isSelected ? 5 : 3
            )
    }
}
