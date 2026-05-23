//
//  LifeStoryIntroView.swift
//  Connections
//

import SwiftUI

struct LifeStoryIntroView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(\.colorScheme) private var colorScheme

    @State private var showWhySheet = false
    @State private var dontShowAgain = false
    @State private var navigateToSession = false

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Title & Body

                VStack(spacing: 24) {
                    Text(String(localized: "lifeStoryIntro.title", defaultValue: "Life Story"))
                        .font(AppFont.screenTitle())
                        .multilineTextAlignment(.center)

                    Text(String(localized: "lifeStoryIntro.body", defaultValue: "A guided conversation for asking parents, grandparents, or older relatives the questions you may wish you had asked sooner."))
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Text(String(localized: "lifeStoryIntro.tagline", defaultValue: "Explore childhood, love, work, hardship, family history, and legacy."))
                        .font(AppFont.detail())
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Spacer()

                // MARK: - Actions

                VStack(spacing: 14) {
                    Button {
                        HapticsManager.lightImpact()
                        if dontShowAgain {
                            settings.skipLifeStoryIntro = true
                        }
                        navigateToSession = true
                    } label: {
                        Text(String(localized: "lifeStoryIntro.button.start", defaultValue: "Start session"))
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .foregroundStyle(.white)
                            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                    }

                    Button {
                        showWhySheet = true
                    } label: {
                        Text(String(localized: "lifeStoryIntro.button.howItWorks", defaultValue: "How it works"))
                            .secondaryButtonStyle()
                    }
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                // MARK: - Don't Show Again

                Button {
                    dontShowAgain.toggle()
                    HapticsManager.lightImpact()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            .font(.system(size: 15))
                            .foregroundStyle(dontShowAgain ? .secondary : .tertiary)
                            .animation(.easeOut(duration: 0.15), value: dontShowAgain)

                        Text(String(localized: "lifeStoryIntro.dontShowAgain", defaultValue: "Don't show this again"))
                            .font(AppFont.detail())
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                .padding(.bottom, AppSpacing.bottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSession) {
            LifeStoryPlayView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .sheet(isPresented: $showWhySheet) {
            HowItWorksSheet()
        }
    }
}

// MARK: - How It Works Sheet

private struct HowItWorksSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 48)

            Text(String(localized: "lifeStoryIntro.howSheet.title", defaultValue: "How it works"))
                .font(AppFont.promptText())
                .padding(.bottom, 24)

            VStack(alignment: .leading, spacing: 14) {
                BulletPoint(String(localized: "lifeStoryIntro.howSheet.bullet1", defaultValue: "50 questions organized across 9 life chapters — from childhood to legacy"))
                BulletPoint(String(localized: "lifeStoryIntro.howSheet.bullet2", defaultValue: "Each question comes with two follow-ups to help the conversation go deeper naturally"))
                BulletPoint(String(localized: "lifeStoryIntro.howSheet.bullet3", defaultValue: "Your progress is saved, so you can pause and return across multiple sittings"))
                BulletPoint(String(localized: "lifeStoryIntro.howSheet.bullet4", defaultValue: "Designed to be read aloud — one person asks, the other tells their story"))
            }
            .padding(.horizontal, AppSpacing.buttonHorizontal)

            Text(String(localized: "lifeStoryIntro.howSheet.footer", defaultValue: "Some conversations only happen\nwhen someone knows to ask."))
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, AppSpacing.buttonHorizontal)
                .padding(.top, 28)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text(String(localized: "lifeStoryIntro.howSheet.button.gotIt", defaultValue: "Got it"))
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundStyle(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .padding(.horizontal, AppSpacing.buttonHorizontal)
            .padding(.bottom, AppSpacing.bottomPadding)
        }
        .presentationDragIndicator(.visible)
    }
}

private struct BulletPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(AppFont.subtitle())
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Text(text)
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    NavigationStack {
        LifeStoryIntroView()
            .environment(SessionManager())
            .environment(SettingsStore())
    }
}
