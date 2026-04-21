//
//  SessionPlayView.swift
//  Connections
//  Animation setup

import SwiftUI

struct SessionPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var promptTransitionID = UUID()
    @State private var goDeeperPressed = false
    @State private var promptVisible = true
    @State private var followUpVisible = true
    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: session.selectedIntensity)

        VStack(spacing: 0) {

            // MARK: - Top Bar

            HStack {
                Button {
                    session.endSession()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                }
                .tint(.secondary)

                Spacer()

                if let mode = session.selectedMode, let intensity = session.selectedIntensity {
                    Text("\(mode.rawValue) · \(intensity.rawValue)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 14) {
                    if session.connectionTracker.checkInCount > 0 {
                        ConnectionHeartView(fillAmount: session.connectionTracker.fillAmount, size: 16)
                    }

                    if let prompt = session.currentPrompt, !session.isSessionComplete {
                        ShareLink(item: prompt.text) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // MARK: - Progress

            if !session.isSessionComplete {
                VStack(spacing: 6) {
                    ProgressView(value: session.sessionProgress)
                        .tint(session.selectedIntensity?.toneColor ?? AppColor.primaryButtonBg(colorScheme))

                    HStack {
                        Text(session.currentDepth.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("Card \(min(session.promptsShown + 1, session.totalPrompts)) of \(session.totalPrompts)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)
            }

            // MARK: - Content Area

            Spacer(minLength: 40)

            if session.isSessionComplete {
                // Session complete
                sessionCompleteContent
            } else if session.showFeelingCheckIn {
                // Feeling check-in interstitial
                FeelingCheckInView { feeling in
                    session.recordFeeling(feeling)
                    // Brief pause before next prompt for a moment of reflection
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            promptTransitionID = UUID()
                        }
                    }
                }
                .transition(.opacity)
            } else if let prompt = session.currentPrompt {
                // Active prompt
                promptContent(prompt)
            }

            Spacer()

            // MARK: - Actions

            if session.currentPrompt != nil && !session.showFeelingCheckIn && !session.isSessionComplete {
                actionButtons
            }

            // MARK: - Complete Actions

            if session.isSessionComplete {
                Button {
                    session.endSession()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 52)
            }
        }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.3), value: session.showFeelingCheckIn)
        .animation(.easeInOut(duration: 0.3), value: session.isSessionComplete)
        .onChange(of: session.isSessionComplete) { _, complete in
            if complete { HapticsManager.success() }
        }
    }

    // MARK: - Prompt Content

    @ViewBuilder
    private func promptContent(_ prompt: Prompt) -> some View {
        VStack(spacing: 0) {
            Text(prompt.text)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 28)
                .padding(.vertical, 44)
                .id(promptTransitionID)
                .opacity(promptVisible ? 1 : 0)
                .offset(y: promptVisible ? 0 : 10)
                .animation(.easeInOut(duration: 0.2), value: promptVisible)

            if !session.shownFollowUps.isEmpty && session.followUpsEnabled {
                VStack(spacing: 8) {
                    ForEach(session.shownFollowUps) { followUp in
                        Text(followUp.text)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(session.selectedIntensity?.cardTint ?? Color.primary.opacity(0.04))
                            )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .padding(.bottom, 24)
                .opacity(followUpVisible ? 1 : 0)
                .offset(y: followUpVisible ? 0 : 8)
                .animation(.easeInOut(duration: 0.2), value: followUpVisible)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 0) {

            // MARK: Follow-up questions (above primary actions, with breathing room)

            if session.followUpsEnabled && session.hasMoreFollowUps {
                VStack(spacing: 6) {
                    Button {
                        goDeeperPressed = true
                        HapticsManager.mediumImpact()
                        session.recordGoDeeper()
                        withAnimation(.easeOut(duration: 0.12)) {
                            followUpVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            session.revealNextFollowUp()
                            withAnimation(.easeIn(duration: 0.2)) {
                                followUpVisible = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            goDeeperPressed = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Go deeper")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(session.selectedIntensity?.cardTint.opacity(0.18) ?? Color.primary.opacity(0.1))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(session.selectedIntensity?.cardTint.opacity(0.35) ?? Color.primary.opacity(0.2), lineWidth: 1)
                        )
                        .scaleEffect(goDeeperPressed ? 0.95 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                    }
                    .buttonStyle(.plain)


                }
                .padding(.bottom, 20)
                .transition(.opacity)
            }

            // MARK: Back / Next

            HStack(spacing: 12) {
                if session.canGoBack {
                    Button {
                        HapticsManager.lightImpact()

                        withAnimation(.easeOut(duration: 0.16)) {
                            promptVisible = false
                            followUpVisible = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                            session.goBack()
                            promptTransitionID = UUID()
                            promptVisible = true
                            followUpVisible = true
                        }
                    } label: {
                        Text("Back")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.surface(colorScheme), in: .capsule)
                    }
                }

                Button {
                    HapticsManager.lightImpact()
                    withAnimation(.easeOut(duration: 0.16)) {
                        promptVisible = false
                        followUpVisible = false
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                        session.continuePrompt(isFavorited: session.isCurrentPromptFavorited())
                        promptTransitionID = UUID()
                        promptVisible = true
                        followUpVisible = true
                    }
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                }
            }

            // MARK: Favorite + Check in (post-follow-up)

            HStack(spacing: 28) {
                Button {
                    if !session.isCurrentPromptFavorited() {
                        HapticsManager.lightImpact()
                    }
                    session.toggleFavoriteCurrentPrompt()
                } label: {
                    Image(systemName: session.isCurrentPromptFavorited() ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(session.isCurrentPromptFavorited() ? .red : .gray)
                        .scaleEffect(session.isCurrentPromptFavorited() ? 1.15 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: session.isCurrentPromptFavorited())
                }
                .buttonStyle(.plain)

                if session.followUpsEnabled && !session.shownFollowUps.isEmpty && !session.hasMoreFollowUps {
                    Button {
                        session.recordGoDeeper()
                        session.triggerCheckInFromGoDeeper()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 13, weight: .medium))
                            Text("Check in")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppColor.primaryButtonBg(colorScheme)))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
        .animation(.easeOut(duration: 0.2), value: session.shownFollowUps.count)
    }

    // MARK: - Session Complete Content

    private var sessionCompleteContent: some View {
        VStack(spacing: 24) {
            if session.connectionTracker.checkInCount > 0 {
                ConnectionHeartLargeView(
                    fillAmount: session.connectionTracker.fillAmount,
                    connectionLevel: session.connectionTracker.connectionLevel
                )
            }

            Text("Something was shared here")
                .font(.system(size: 28, weight: .regular, design: .serif))

            VStack(spacing: 6) {
                Text("\(session.responses.filter { $0.action == .continued }.count) prompts answered")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)

                if session.connectionTracker.checkInCount > 0 {
                    Text(session.connectionTracker.connectionLevel.completionMessage)
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .foregroundStyle(.secondary)
                        .italic()
                        .padding(.top, 4)
                }
            }

            // Session Summary
            if let summary = session.generateSummary() {
                VStack(spacing: 12) {
                    Text(summary.title)
                        .font(.system(size: 18, weight: .medium, design: .serif))

                    VStack(spacing: 4) {
                        ForEach(summary.reflectionLines, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .multilineTextAlignment(.center)

                    if let nextStep = summary.nextStep {
                        Text(nextStep)
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundStyle(.secondary)
                            .italic()
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }

            // Standout Prompts
            let standout = session.standoutPromptInteractions(limit: 3)

            if !standout.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Moments you stayed with")
                        .font(.system(size: 18, weight: .medium, design: .serif))

                    Text("You spent more time on these questions or chose to go deeper.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(standout, id: \.promptID) { interaction in
                            Text("• \(interaction.promptText)")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
        }
    }


}

#Preview {
    NavigationStack {
        SessionPlayView()
            .environment({
                let s = SessionManager()
                s.selectedMode = .couples
                s.selectedIntensity = .honest
                s.selectedSessionLength = .medium
                s.startSession()
                return s
            }())
    }
}
