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

    private func paywallString(_ key: String, defaultValue: String) -> String {
        Bundle.main.localizedString(forKey: key, value: defaultValue, table: "Paywall")
    }

    // MARK: - General

    private var generalContent: some View {
        VStack(spacing: 20) {
            Text(paywallString("paywall.general.title", defaultValue: "Unlock deeper conversations"))
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text(paywallString("paywall.general.body", defaultValue: "Get the prompts and guided experiences made for the moments when small talk is not enough."))
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow(paywallString("paywall.general.bullet1", defaultValue: "Candid Unfiltered prompts with thoughtful follow-ups"))
                BulletRow(paywallString("paywall.general.bullet2", defaultValue: "Intimacy questions that feel careful, not awkward"))
                BulletRow(paywallString("paywall.general.bullet3", defaultValue: "Longer 20-question sessions for when you have time"))
                BulletRow(paywallString("paywall.general.bullet4", defaultValue: "Fall in Love, Life Story, and Share an Experience included"))
            }
            .padding(.top, 8)

            Text(LocalizedStringKey(paywallString("paywall.general.footer", defaultValue: "**346** premium questions and **578** follow-ups. **2,001** total. One-time purchase, no subscription.")))
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
            Text(paywallString("paywall.lifeStory.title", defaultValue: "Life Story is included"))
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text(paywallString("paywall.lifeStory.body", defaultValue: "Unlock the full app and get Life Story too: a guided way to ask parents, grandparents, and loved ones about their memories, stories, and legacy."))
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow(paywallString("paywall.lifeStory.bullet1", defaultValue: "50 questions across 9 life chapters"))
                BulletRow(paywallString("paywall.lifeStory.bullet2", defaultValue: "2 follow-ups for every question"))
                BulletRow(paywallString("paywall.lifeStory.bullet3", defaultValue: "Progress saved between sessions"))
                BulletRow(paywallString("paywall.lifeStory.bullet4", defaultValue: "Included with your one-time full app unlock"))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 10) {
            purchaseButtons
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
        .padding(.top, 12)
        .padding(.bottom, AppSpacing.bottomPadding)
        .background(.ultraThinMaterial)
        .animation(.easeOut(duration: 0.2), value: entitlements.purchaseState)
    }

    private var purchaseButtons: some View {
        VStack(spacing: 10) {

            // Error message — dynamic from StoreKit, not localized
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
                    Text(paywallString("paywall.purchase.button", defaultValue: "Unlock Full Access"))
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
                Text(String(format: paywallString("paywall.purchase.priceLine", defaultValue: "%1$@ once · Lifetime access"), price))
                    .font(AppFont.fine())
                    .foregroundStyle(.secondary)
            } else {
                Text(paywallString("paywall.purchase.tagline", defaultValue: "One purchase. Lifetime access."))
                    .font(AppFont.fine())
                    .foregroundStyle(.quaternary)
            }

            // Secondary row: Restore + Not Now
            HStack(spacing: 20) {
                Button {
                    Task { await entitlements.restorePurchases() }
                } label: {
                    Text(paywallString("paywall.purchase.restore", defaultValue: "Restore Purchases"))
                        .font(AppFont.fine())
                        .foregroundStyle(.tertiary)
                }
                .disabled(entitlements.purchaseState == .loading)
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text(paywallString("paywall.purchase.notNow", defaultValue: "Not now"))
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

            Text(LocalizedStringKey(text))
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
