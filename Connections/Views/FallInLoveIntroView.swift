//
//  FallInLoveIntroView.swift
//  Connections
//

import SwiftUI

struct FallInLoveIntroView: View {
    @Environment(SessionManager.self) private var session
    @Environment(SettingsStore.self) private var settings
    @Environment(\.colorScheme) private var colorScheme

    @State private var showWhySheet = false
    @State private var dontShowAgain = false
    @State private var navigateToSession = false

    private var isFriends: Bool { session.selectedMode == .friends }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Title & Body

                VStack(spacing: 24) {
                    Text(isFriends
                         ? String(localized: "fallInLoveIntro.title.friends", defaultValue: "Get closer")
                         : String(localized: "fallInLoveIntro.title.couples", defaultValue: "Fall in love again"))
                        .font(AppFont.screenTitle())
                        .multilineTextAlignment(.center)

                    Text(isFriends
                         ? String(localized: "fallInLoveIntro.body.friends", defaultValue: "Some conversations create clarity, trust, and unexpected connection.\n\nThese questions are designed to help two people move past surface-level talk and into something more honest, open, and real.")
                         : String(localized: "fallInLoveIntro.body.couples", defaultValue: "Not by chance — but through attention, honesty, and shared moments.\n\nA series of thoughtfully designed questions can deepen connection, spark curiosity, and bring you closer — one conversation at a time."))
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Spacer()

                // MARK: - Actions

                VStack(spacing: 14) {
                    Button {
                        HapticsManager.lightImpact()
                        if dontShowAgain {
                            if isFriends {
                                settings.skipFallInLoveIntroFriends = true
                            } else {
                                settings.skipFallInLoveIntroCouples = true
                            }
                        }
                        navigateToSession = true
                    } label: {
                        Text(String(localized: "fallInLoveIntro.button.start", defaultValue: "Start session"))
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .foregroundStyle(.white)
                            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                    }

                    Button {
                        showWhySheet = true
                    } label: {
                        Text(String(localized: "fallInLoveIntro.button.whyThisWorks", defaultValue: "Why this works"))
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

                        Text(String(localized: "fallInLoveIntro.dontShowAgain", defaultValue: "Don't show this again"))
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
            FallInLovePlayView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .sheet(isPresented: $showWhySheet) {
            WhyThisWorksSheet(isFriends: isFriends)
        }
    }
}

// MARK: - Why This Works Sheet

private struct WhyThisWorksSheet: View {
    let isFriends: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 48)

            Text(String(localized: "fallInLoveIntro.whySheet.title", defaultValue: "Why this works"))
                .font(AppFont.promptText())
                .padding(.bottom, 24)

            if isFriends {
                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.friends.bullet1", defaultValue: "When one person shares something real, others tend to match that openness — without being asked"))
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.friends.bullet2", defaultValue: "Asking a genuine question and actually listening is one of the simplest ways to deepen a friendship"))
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.friends.bullet3", defaultValue: "Trust grows in small moments — when someone feels heard, not just talked to"))
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.friends.bullet4", defaultValue: "Most friendships stay at the surface not because people don't care, but because no one goes first"))
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Text(String(localized: "fallInLoveIntro.whySheet.friends.footer", defaultValue: "The deepest friendships aren't found.\nThey're built — one real conversation at a time."))
                    .font(AppFont.subtitle())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .padding(.top, 28)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.couples.bullet1", defaultValue: "When two people take turns answering honest questions, they naturally match each other's openness"))
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.couples.bullet2", defaultValue: "Feeling genuinely listened to — not just heard — is one of the strongest drivers of closeness"))
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.couples.bullet3", defaultValue: "Vulnerability doesn't just build trust. It signals that trust already exists."))
                    BulletPoint(String(localized: "fallInLoveIntro.whySheet.couples.bullet4", defaultValue: "The conversations that deepen a relationship are rarely dramatic. They're the ones where someone feels met."))
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Text(String(localized: "fallInLoveIntro.whySheet.couples.footer", defaultValue: "You don't fall in love all at once.\nYou build it — one honest moment at a time."))
                    .font(AppFont.subtitle())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .padding(.top, 28)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text(String(localized: "fallInLoveIntro.whySheet.button.gotIt", defaultValue: "Got it"))
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
        FallInLoveIntroView()
            .environment(SessionManager())
            .environment(SettingsStore())
    }
}
