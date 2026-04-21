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
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .multilineTextAlignment(.center)

                    Text(isFriends
                         ? "Some conversations create clarity, trust, and unexpected connection.\n\nThese questions are designed to help two people move past surface-level talk and into something more honest, open, and real."
                         : "Not by chance — but through attention, honesty, and shared moments.\n\nA series of thoughtfully designed questions can deepen connection, spark curiosity, and bring you closer — one conversation at a time.")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.horizontal, 36)

                Spacer()

                // MARK: - Actions

                VStack(spacing: 14) {
                    Button {
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
                            .foregroundColor(.white)
                            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                    }

                    Button {
                        showWhySheet = true
                    } label: {
                        Text("Why this works")
                            .secondaryButtonStyle()
                    }
                }
                .padding(.horizontal, 36)

                // MARK: - Don't Show Again

                Button {
                    dontShowAgain.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            .font(.system(size: 16))
                            .foregroundStyle(dontShowAgain ? .primary : .tertiary)

                        Text("Don't show this again")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                .padding(.bottom, 52)
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
                .font(.system(size: 28, weight: .regular, design: .serif))
                .padding(.bottom, 24)

            if isFriends {
                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint("Meaningful questions build closeness")
                    BulletPoint("Vulnerability increases trust")
                    BulletPoint("Shared attention deepens connection")
                    BulletPoint("Honest conversation changes how people see each other")
                }
                .padding(.horizontal, 36)

                Text("Some connections grow gradually.\nThis gives them room to.")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 36)
                    .padding(.top, 28)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint("Meaningful questions create emotional closeness")
                    BulletPoint("Vulnerability builds trust over time")
                    BulletPoint("Shared attention strengthens bonds")
                    BulletPoint("Small moments, repeated, create lasting connection")
                }
                .padding(.horizontal, 36)

                Text("You don't fall in love all at once.\nYou build it — moment by moment.")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 36)
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
                    .foregroundColor(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 52)
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
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)

            Text(text)
                .font(.system(size: 17))
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
