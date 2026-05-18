//
//  SummaryRow.swift
//  Connections
//

import SwiftUI

/// A compact tappable row representing a collapsed selection in the Session Builder.
/// Shows the selected value with an option to change it.
struct SummaryRow: View {
    let icon: String?
    let title: String
    let subtitle: String
    var tintColor: Color? = nil
    let onChange: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onChange) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(tintColor ?? .secondary)
                }

                Text(title)
                    .font(AppFont.caption())
                    .fontWeight(.medium)

                Text("·")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)

                Text(subtitle)
                    .font(AppFont.detail())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(backgroundFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(strokeColor, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var backgroundFill: Color {
        if let tint = tintColor {
            return tint.opacity(0.08)
        }
        return AppColor.surface(colorScheme)
    }

    private var strokeColor: Color {
        if let tint = tintColor {
            return tint.opacity(0.15)
        }
        return Color.primary.opacity(0.06)
    }
}
