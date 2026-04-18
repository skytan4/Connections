//
//  SelectionCard.swift
//  Connections
//

import SwiftUI

struct SelectionCard: View {
    let title: String
    let subtitle: String
    var tintColor: Color? = nil
    let action: () -> Void

    @State private var isPressed = false

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
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
