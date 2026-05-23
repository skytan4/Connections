//
//  FeelingCheckInView.swift
//  Connections
//

import SwiftUI

struct FeelingCheckInView: View {
    let onSelect: (Feeling) -> Void

    @State private var selectedFeeling: Feeling?
    @State private var showMessage = false
    @State private var displayedMessage: String?

    var body: some View {
        VStack(spacing: 32) {

            Text(String(localized: "feelingCheckIn.header", defaultValue: "How did that feel?"))
                .font(AppFont.checkInPrompt())
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                ForEach(Feeling.allCases) { feeling in
                    FeelingButton(feeling: feeling, isSelected: selectedFeeling == feeling) {
                        guard selectedFeeling == nil else { return }
                        selectedFeeling = feeling

                        // Determine if we show a micro-message (~65% chance, never for Light)
                        let shouldShowMessage = feeling.localizedMicroMessages != nil && Double.random(in: 0...1) < 0.65
                        if shouldShowMessage, let messages = feeling.localizedMicroMessages {
                            displayedMessage = messages.randomElement()
                            withAnimation(.easeOut(duration: 0.3)) {
                                showMessage = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                                onSelect(feeling)
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onSelect(feeling)
                            }
                        }
                    }
                }
            }

            if showMessage, let message = displayedMessage {
                Text(message)
                    .font(AppFont.caption())
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Feeling Button

private struct FeelingButton: View {
    let feeling: Feeling
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                feelingIcon
                    .frame(height: 32)

                Text(feeling.localizedLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.primary.opacity(0.08) : Color.clear)
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var feelingIcon: some View {
        if let symbolName = feeling.symbolName {
            Image(systemName: symbolName)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.primary.opacity(0.35))
        } else if let emoji = feeling.emoji {
            Text(emoji)
                .font(.system(size: 28))
        }
    }
}

#Preview {
    FeelingCheckInView { feeling in
        print("Selected: \(feeling.label)")
    }
}
