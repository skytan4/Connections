//
//  SelectionCard.swift
//  Connections
//

import SwiftUI

/// A reusable tappable card used throughout selection screens (mode, intensity, topic, etc.).
/// Displays a title and subtitle with an optional tint color and a subtle press animation.
struct SelectionCard: View {
    let title: String
    let subtitle: String
    var tintColor: Color? = nil
    let action: () -> Void

    /// Tracks whether the user is currently pressing the card, driving the visual feedback.
    @State private var isPressed = false

    /// Resolves the card's background color.
    /// When a `tintColor` is provided, it uses that color at a low opacity;
    /// otherwise it falls back to a neutral primary tint.
    /// Opacity increases slightly while the card is pressed to give tactile feedback.
    private var backgroundFill: Color {
        if let tint = tintColor {
            return tint.opacity(isPressed ? 0.22 : 0.14)
        }
        return Color.primary.opacity(isPressed ? 0.08 : 0.04)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundFill)
            )
            // Scale down slightly while pressed to reinforce the tap interaction.
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        // A zero-distance drag gesture is used instead of ButtonStyle to track
        // press/release independently, allowing the scale + opacity animation
        // to play without interfering with the button's own tap handling.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
