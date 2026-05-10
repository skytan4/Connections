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
    @Environment(EntitlementStore.self) private var entitlements
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
        .onChange(of: entitlements.systemEntitlement) { _, isEntitled in
            if isEntitled { dismiss() }
        }
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
            if EntitlementStore.betaUnlockAppliesInCurrentBuild {
                betaUnlockButtons
            } else {
                purchaseButtons
            }
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
        .padding(.top, 12)
        .padding(.bottom, AppSpacing.bottomPadding)
        .background(.ultraThinMaterial)
        .animation(.easeOut(duration: 0.2), value: entitlements.purchaseState)
    }

    private var betaUnlockButtons: some View {
        VStack(spacing: 12) {
            Text("Premium is fully included in this test build. No purchase needed.")
                .font(AppFont.caption())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("Got it")
                    .font(AppFont.buttonPrimary())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
        }
    }

    private var purchaseButtons: some View {
        VStack(spacing: 10) {

            // Error message
            if case .error(let message) = entitlements.purchaseState {
                Text(message)
                    .font(AppFont.fine())
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .transition(.opacity)
            }

            // Primary: Unlock
            Button {
                Task { await entitlements.purchase() }
            } label: {
                ZStack {
                    Text("Unlock Full Access")
                        .font(AppFont.buttonPrimary())
                        .foregroundStyle(.white)
                        .opacity(entitlements.purchaseState == .loading ? 0 : 1)

                    ProgressView()
                        .tint(.white)
                        .opacity(entitlements.purchaseState == .loading ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .disabled(entitlements.purchaseState == .loading)

            if let price = entitlements.productDisplayPrice {
                Text("\(price) · One-time purchase")
                    .font(AppFont.fine())
                    .foregroundStyle(.secondary)
            } else {
                Text("Pay once. Keep it forever.")
                    .font(AppFont.fine())
                    .foregroundStyle(.quaternary)
            }

            // Secondary row: Restore + Not Now
            HStack(spacing: 20) {
                Button {
                    Task { await entitlements.restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                        .font(AppFont.fine())
                        .foregroundStyle(.tertiary)
                }
                .disabled(entitlements.purchaseState == .loading)
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("Not now")
                        .font(AppFont.caption())
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
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
        .environment(EntitlementStore())
        .environment(ReviewPromptStore())
}

#Preview("Life Story") {
    PremiumPaywallView(variant: .lifeStory)
        .environment(EntitlementStore())
        .environment(ReviewPromptStore())
}
