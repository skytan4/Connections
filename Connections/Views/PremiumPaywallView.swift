//
//  PremiumPaywallView.swift
//  Connections
//

import SwiftUI

// MARK: - Paywall Variant

enum PaywallVariant: Identifiable {
    case general
    case lifeStory

    var id: String {
        switch self {
        case .general: return "general"
        case .lifeStory: return "lifeStory"
        }
    }
}

// MARK: - Paywall View

struct PremiumPaywallView: View {
    let variant: PaywallVariant
    @Environment(ReviewPromptStore.self) private var reviewPromptStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            switch variant {
            case .general:
                generalContent
            case .lifeStory:
                lifeStoryContent
            }

            Spacer()

            buttons
        }
        .presentationDragIndicator(.visible)
        .onAppear { reviewPromptStore.recordPaywallShown() }
    }

    // MARK: - General

    private var generalContent: some View {
        VStack(spacing: 20) {
            Text("Unlock the full app")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)

            Text("Get deeper sessions, longer conversations, and guided experiences like Fall in Love, Share Experience, and Life Story.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow("Unfiltered sessions")
                BulletRow("Longer conversations")
                BulletRow("Sensitive topics like Sex")
                BulletRow("Guided experiences")
                BulletRow("Life Story for parents and grandparents")
            }
            .padding(.top, 8)

            Text("A one-time unlock for the most intimate, reflective, and meaningful parts of Deeper Conversations.")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 4)
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
    }

    // MARK: - Life Story

    private var lifeStoryContent: some View {
        VStack(spacing: 20) {
            Text("Unlock Life Story")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)

            Text("A guided experience for asking meaningful questions of parents, grandparents, or older relatives while you still can.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("Included with the full app unlock.")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 4)
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 10) {
            Button {
                // TODO: Wire to StoreKit purchase flow
                dismiss()
            } label: {
                Text("Unlock Full Access")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundStyle(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }

            Text("Pay once. Keep it forever.")
                .font(.system(size: 13))
                .foregroundStyle(.quaternary)

            Button {
                dismiss()
            } label: {
                Text("Not now")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
        .padding(.bottom, AppSpacing.bottomPadding)
    }
}

// MARK: - Bullet Row

private struct BulletRow: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
        }
    }
}

#Preview("General") {
    PremiumPaywallView(variant: .general)
        .environment(ReviewPromptStore())
}

#Preview("Life Story") {
    PremiumPaywallView(variant: .lifeStory)
        .environment(ReviewPromptStore())
}
