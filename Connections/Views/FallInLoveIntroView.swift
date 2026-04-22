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
                    Text(isFriends ? "Get closer" : "Fall in love again")
                        .font(AppFont.screenTitle())
                        .multilineTextAlignment(.center)

                    Text(isFriends
                         ? "Some conversations create clarity, trust, and unexpected connection.\n\nThese questions are designed to help two people move past surface-level talk and into something more honest, open, and real."
                         : "Not by chance — but through attention, honesty, and shared moments.\n\nA series of thoughtfully designed questions can deepen connection, spark curiosity, and bring you closer — one conversation at a time.")
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
                        Text("Start session")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .foregroundStyle(.white)
                            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                    }

                    Button {
                        showWhySheet = true
                    } label: {
                        Text("Why this works")
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

                        Text("Don't show this again")
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

            Text("Why this works")
                .font(AppFont.promptText())
                .padding(.bottom, 24)

            if isFriends {
                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint("When one person shares something real, others tend to match that openness — without being asked")
                    BulletPoint("Asking a genuine question and actually listening is one of the simplest ways to deepen a friendship")
                    BulletPoint("Trust grows in small moments — when someone feels heard, not just talked to")
                    BulletPoint("Most friendships stay at the surface not because people don't care, but because no one goes first")
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Text("The deepest friendships aren't found.\nThey're built — one real conversation at a time.")
                    .font(AppFont.subtitle())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .padding(.top, 28)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint("When two people take turns answering honest questions, they naturally match each other's openness")
                    BulletPoint("Feeling genuinely listened to — not just heard — is one of the strongest drivers of closeness")
                    BulletPoint("Vulnerability doesn't just build trust. It signals that trust already exists.")
                    BulletPoint("The conversations that deepen a relationship are rarely dramatic. They're the ones where someone feels met.")
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Text("You don't fall in love all at once.\nYou build it — one honest moment at a time.")
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
                Text("Got it")
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
