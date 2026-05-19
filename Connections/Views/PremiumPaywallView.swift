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
        ZStack {
            PaywallBackground()
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 34)

                    PaywallMark()
                        .frame(width: 82, height: 58)
                        .padding(.bottom, 24)

                    switch variant {
                    case .general:
                        generalContent
                    case .lifeStory:
                        lifeStoryContent
                    }

                    Spacer(minLength: 32)
                }
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

    private func errorMessage(for kind: EntitlementStore.PurchaseState.ErrorKind) -> String {
        switch kind {
        case .productUnavailable:
            #if DEBUG
            return "Purchases are not configured in this local build. Use Settings > Debug > Forced Premium to unlock for testing."
            #else
            return paywallString(
                "paywall.error.productUnavailable",
                defaultValue: "Full Access isn't available right now. Please check your connection and try again, or use Restore Purchases if you've already bought it."
            )
            #endif
        case .purchaseFailed:
            return paywallString(
                "paywall.error.purchaseFailed",
                defaultValue: "Your purchase couldn't be completed. No charge was made. Please try again, or use Restore Purchases if you've already bought it."
            )
        case .verificationFailed:
            return paywallString(
                "paywall.error.verificationFailed",
                defaultValue: "We couldn't verify your purchase with the App Store. Please try again. If you were charged, use Restore Purchases."
            )
        case .restoreFailed:
            return paywallString(
                "paywall.error.restoreFailed",
                defaultValue: "Restore failed. Please check your connection and try again."
            )
        }
    }

    private func infoMessage(for kind: EntitlementStore.PurchaseState.InfoKind) -> String {
        switch kind {
        case .nothingToRestore:
            return paywallString(
                "paywall.info.nothingToRestore",
                defaultValue: "No previous purchases were found for this Apple ID."
            )
        }
    }

    private var paywallSecondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.78) : Color.primary.opacity(0.72)
    }

    private var paywallMutedText: Color {
        colorScheme == .dark ? Color.white.opacity(0.68) : Color.primary.opacity(0.62)
    }

    private var paywallAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.96, green: 0.72, blue: 0.32)
            : Color(red: 0.70, green: 0.39, blue: 0.08)
    }

    private var purchaseButtonFill: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.90, green: 0.56, blue: 0.16),
                    Color(red: 0.54, green: 0.30, blue: 0.08)
                ]
                : [
                    Color(red: 0.10, green: 0.22, blue: 0.18),
                    Color(red: 0.05, green: 0.13, blue: 0.11)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var paywallCardFill: Color {
        colorScheme == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.38)
    }

    private var paywallCardStroke: Color {
        colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.06)
    }

    // MARK: - General

    private var generalContent: some View {
        VStack(spacing: 20) {
            Text(paywallString("paywall.general.title", defaultValue: "Unlock deeper conversations"))
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text(paywallString("paywall.general.body", defaultValue: "Get the prompts and guided experiences made for the moments when small talk is not enough."))
                .font(AppFont.subtitle())
                .foregroundStyle(paywallSecondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow(paywallString("paywall.general.bullet5", defaultValue: "Feel closer, understand each other better, and keep meaningful conversations going"))
                BulletRow(paywallString("paywall.general.bullet1", defaultValue: "Candid Unfiltered prompts with thoughtful follow-ups"))
                BulletRow(paywallString("paywall.general.bullet2", defaultValue: "Intimacy questions that feel careful, not awkward"))
                BulletRow(paywallString("paywall.general.bullet3", defaultValue: "Longer 20-question sessions for when you have time"))
                BulletRow(paywallString("paywall.general.bullet4", defaultValue: "Fall in Love, Life Story, and Share an Experience included"))
            }
            .padding(18)
            .background(paywallCardFill, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(paywallCardStroke, lineWidth: 1)
            }
            .padding(.top, 8)

            Text(LocalizedStringKey(paywallString("paywall.general.footer", defaultValue: "**346** premium questions and **578** follow-ups. **2,001** total. One-time purchase, no subscription.")))
                .font(AppFont.detail())
                .foregroundStyle(paywallMutedText)
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
                .foregroundStyle(paywallSecondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                BulletRow(paywallString("paywall.lifeStory.bullet1", defaultValue: "50 questions across 9 life chapters"))
                BulletRow(paywallString("paywall.lifeStory.bullet2", defaultValue: "2 follow-ups for every question"))
                BulletRow(paywallString("paywall.lifeStory.bullet3", defaultValue: "Progress saved between sessions"))
                BulletRow(paywallString("paywall.lifeStory.bullet4", defaultValue: "Included with your one-time full app unlock"))
            }
            .padding(18)
            .background(paywallCardFill, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(paywallCardStroke, lineWidth: 1)
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
        .background(.regularMaterial)
        .animation(.easeOut(duration: 0.2), value: entitlements.purchaseState)
    }

    private var purchaseButtons: some View {
        VStack(spacing: 10) {

            // Error message — localized via Paywall.xcstrings
            if case .error(let kind) = entitlements.purchaseState {
                Text(errorMessage(for: kind))
                    .font(AppFont.fine())
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .transition(.opacity)
            }

            // Informational message — e.g. "no previous purchases found"
            if case .info(let kind) = entitlements.purchaseState {
                Text(infoMessage(for: kind))
                    .font(AppFont.fine())
                    .foregroundStyle(paywallMutedText)
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
                .background(purchaseButtonFill, in: .capsule)
                .shadow(color: paywallAccent.opacity(colorScheme == .dark ? 0.16 : 0.20), radius: 12, y: 6)
            }
            .disabled(entitlements.purchaseState == .loading)

            if let price = entitlements.productDisplayPrice {
                Text(String(format: paywallString("paywall.purchase.priceLine", defaultValue: "%1$@ once · Lifetime access"), price))
                    .font(AppFont.fine())
                    .foregroundStyle(paywallMutedText)
            } else {
                Text(paywallString("paywall.purchase.tagline", defaultValue: "One purchase. Lifetime access."))
                    .font(AppFont.fine())
                    .foregroundStyle(paywallMutedText)
            }

            // Secondary row: Restore + Not Now
            HStack(spacing: 20) {
                Button {
                    Task { await entitlements.restorePurchases() }
                } label: {
                    Text(paywallString("paywall.purchase.restore", defaultValue: "Restore Purchases"))
                        .font(AppFont.fine())
                        .foregroundStyle(paywallMutedText)
                }
                .disabled(entitlements.purchaseState == .loading)
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text(paywallString("paywall.purchase.notNow", defaultValue: "Not now"))
                        .font(AppFont.caption())
                        .foregroundStyle(paywallMutedText)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("paywall.notNow")
            }
        }
    }
}

// MARK: - Bullet Row

private struct BulletRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colorScheme == .dark
                                 ? Color(red: 0.98, green: 0.73, blue: 0.36)
                                 : Color(red: 0.72, green: 0.42, blue: 0.10))
                .padding(.top, 2)

            Text(LocalizedStringKey(text))
                .font(AppFont.caption())
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Paywall Brand Elements

private struct PaywallBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [
                        Color(red: 0.05, green: 0.11, blue: 0.09),
                        Color(red: 0.10, green: 0.08, blue: 0.06)
                    ]
                    : [
                        Color(red: 0.99, green: 0.96, blue: 0.89),
                        Color(red: 0.95, green: 0.90, blue: 0.80)
                    ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.96, green: 0.62, blue: 0.20).opacity(colorScheme == .dark ? 0.18 : 0.16))
                .frame(width: 320, height: 320)
                .blur(radius: 56)
                .offset(x: 130, y: -230)

            Circle()
                .fill(Color(red: 0.05, green: 0.20, blue: 0.16).opacity(colorScheme == .dark ? 0.30 : 0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -150, y: 260)
        }
    }
}

private struct PaywallMark: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                RoundedRectangle(cornerRadius: height * 0.28, style: .continuous)
                    .fill(squareFill)
                    .frame(width: width * 0.62, height: height * 0.84)
                    .offset(x: -width * 0.14)

                Circle()
                    .fill(circleFill)
                    .frame(width: height * 0.88, height: height * 0.88)
                    .offset(x: width * 0.20)

                Circle()
                    .fill(Color(red: 0.98, green: 0.65, blue: 0.18).opacity(0.50))
                    .frame(width: height * 0.68, height: height * 0.68)
                    .blur(radius: 10)
                    .offset(x: width * 0.03)
                    .blendMode(.plusLighter)
            }
            .drawingGroup()
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.26 : 0.10), radius: 12, y: 6)
        }
        .accessibilityHidden(true)
    }

    private var squareFill: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.82, blue: 0.48),
                Color(red: 0.86, green: 0.55, blue: 0.17)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var circleFill: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.10, green: 0.29, blue: 0.24),
                    Color(red: 0.04, green: 0.14, blue: 0.12)
                ]
                : [
                    Color(red: 0.12, green: 0.31, blue: 0.25),
                    Color(red: 0.05, green: 0.18, blue: 0.15)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
