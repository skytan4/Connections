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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                switch variant {
                case .general:
                    generalContent
                case .lifeStory:
                    lifeStoryContent
                }

                Spacer(minLength: 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            buttons
        }
        .presentationDragIndicator(.visible)
        .onAppear { reviewPromptStore.recordPaywallShown() }
    }

    // MARK: - General

    private var generalContent: some View {
        VStack(spacing: 20) {
            Text("Unlock the full app")
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text("Get deeper prompts, longer conversations, and guided experiences designed for the moments that matter most.")
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow("207 Unfiltered prompts across every mode")
                BulletRow("41 couples-only intimacy prompts")
                BulletRow("20-prompt Long sessions")
                BulletRow("36-question Fall in Love journey")
                BulletRow("50-question Life Story")
                BulletRow("Share your stories in a different conversation mode")
            }
            .padding(.top, 8)

            Text("One unlock for deeper conversations, guided journeys, and the questions people remember.")
                .font(AppFont.detail())
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
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text("A guided experience for asking parents, grandparents, or older relatives meaningful questions about their stories, memories, and legacy.")
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow("50 questions across 9 life chapters")
                BulletRow("2 follow-ups for every question")
                BulletRow("Progress saved between sessions")
                BulletRow("Included with the full app unlock")
            }
            .padding(.top, 8)

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
                    .font(AppFont.buttonPrimary())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundStyle(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }

            Text("Pay once. Keep it forever.")
                .font(AppFont.fine())
                .foregroundStyle(.quaternary)

            Button {
                dismiss()
            } label: {
                Text("Not now")
                    .font(AppFont.caption())
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
        .padding(.top, 12)
        .padding(.bottom, AppSpacing.bottomPadding)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Bullet Row

private struct BulletRow: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            Text(text)
                .font(AppFont.caption())
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
