//
//  SessionPlayView.swift
//  Connections
//

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
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    HStack(spacing: 14) {
                        if session.connectionTracker.checkInCount > 0 {
                            ConnectionHeartView(fillAmount: session.connectionTracker.fillAmount, size: 16)
                        }

                        if let prompt = session.currentPrompt, !session.isSessionComplete {
                            ShareLink(item: prompt.text) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                // MARK: - Session Content

                if !session.isSessionComplete {

                    // Progress
                    VStack(spacing: 4) {
                        ProgressView(value: session.sessionProgress)
                            .tint(session.selectedIntensity?.toneColor.opacity(0.45) ?? Color.primary.opacity(0.12))

                        HStack {
                            Text(session.currentDepth.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.tertiary)

                            Spacer()

                            Text("\(min(session.promptsShown + 1, session.totalPrompts)) of \(session.totalPrompts)")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 10)

                    Spacer(minLength: 40)

                    if session.showFeelingCheckIn {
                        FeelingCheckInView { feeling in
                            session.recordFeeling(feeling)
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 10)),
                            removal: .opacity
                        ))
                    } else if let prompt = session.currentPrompt {
                        promptContent(prompt)
                    }

                    Spacer()

                    if session.currentPrompt != nil && !session.showFeelingCheckIn {
                        actionButtons
                    }

                } else {

                    // MARK: Completion

                    ScrollView(.vertical, showsIndicators: false) {
                        sessionCompleteContent
                            .padding(.top, 32)
                            .padding(.bottom, 16)
                    }

                    Button {
                        session.endSession()
                        dismiss()
                    } label: {
                        Text("Close")
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
        .animation(.easeOut(duration: 0.45), value: session.showFeelingCheckIn)
        .animation(.easeInOut(duration: 0.4), value: session.isSessionComplete)
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
                .offset(y: promptVisible ? 0 : 12)

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
                .transition(.opacity.combined(with: .offset(y: 8)))
                .padding(.bottom, 24)
                .opacity(followUpVisible ? 1 : 0)
                .offset(y: followUpVisible ? 0 : 8)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 0) {

            // Go deeper — contextual invitation, close to the conversational layer
            if session.followUpsEnabled && session.hasMoreFollowUps {
                Button {
                    goDeeperPressed = true
                    HapticsManager.mediumImpact()
                    session.recordGoDeeper()
                    withAnimation(.easeOut(duration: 0.15)) {
                        followUpVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        session.revealNextFollowUp()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                            followUpVisible = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        goDeeperPressed = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Go deeper")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(session.selectedIntensity?.cardTint.opacity(0.12) ?? Color.primary.opacity(0.06))
                    )
                    .scaleEffect(goDeeperPressed ? 0.96 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
                .transition(.opacity)
            }

            // Next — primary forward action
            Button {
                HapticsManager.lightImpact()
                withAnimation(.easeOut(duration: 0.2)) {
                    promptVisible = false
                    followUpVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    session.continuePrompt(isFavorited: session.isCurrentPromptFavorited())
                    promptTransitionID = UUID()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        promptVisible = true
                        followUpVisible = true
                    }
                }
            } label: {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }

            // Secondary — Back, Check in, Favorite
            HStack {
                if session.canGoBack {
                    Button {
                        HapticsManager.lightImpact()
                        withAnimation(.easeOut(duration: 0.2)) {
                            promptVisible = false
                            followUpVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            session.goBack()
                            promptTransitionID = UUID()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                promptVisible = true
                                followUpVisible = true
                            }
                        }
                    } label: {
                        Text("Back")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                HStack(spacing: 20) {
                    if session.followUpsEnabled && !session.shownFollowUps.isEmpty && !session.hasMoreFollowUps {
                        Button {
                            session.recordGoDeeper()
                            session.triggerCheckInFromGoDeeper()
                        } label: {
                            Text("Check in")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }

                    Button {
                        if !session.isCurrentPromptFavorited() {
                            HapticsManager.lightImpact()
                        }
                        session.toggleFavoriteCurrentPrompt()
                    } label: {
                        Image(systemName: session.isCurrentPromptFavorited() ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(session.isCurrentPromptFavorited() ? .red : Color.primary.opacity(0.2))
                            .scaleEffect(session.isCurrentPromptFavorited() ? 1.1 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: session.isCurrentPromptFavorited())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 14)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
        .animation(.easeOut(duration: 0.2), value: session.shownFollowUps.count)
    }

    // MARK: - Session Complete Content

    private var sessionCompleteContent: some View {
        VStack(spacing: 28) {
            if session.connectionTracker.checkInCount > 0 {
                ConnectionHeartLargeView(
                    fillAmount: session.connectionTracker.fillAmount,
                    connectionLevel: session.connectionTracker.connectionLevel
                )
            }

            VStack(spacing: 12) {
                Text("Something was shared here")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)

                Text("You stayed for \(session.responses.filter { $0.action == .continued }.count) prompts")
                    .font(.system(size: 15))
                    .foregroundStyle(.tertiary)

                if session.connectionTracker.checkInCount > 0 {
                    Text(session.connectionTracker.connectionLevel.completionMessage)
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            // Session Summary
            if let summary = session.generateSummary() {
                VStack(spacing: 10) {
                    Text(summary.title)
                        .font(.system(size: 17, weight: .medium, design: .serif))

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
                            .font(.system(size: 14, weight: .regular, design: .serif))
                            .foregroundStyle(.tertiary)
                            .italic()
                            .padding(.top, 2)
                    }
                }
                .padding(.horizontal, 32)
            }

            // Standout Prompts
            let standout = session.standoutPromptInteractions(limit: 3)
            if !standout.isEmpty {
                VStack(spacing: 12) {
                    Text("Moments you stayed with")
                        .font(.system(size: 16, weight: .medium, design: .serif))

                    VStack(spacing: 10) {
                        ForEach(standout, id: \.promptID) { interaction in
                            Text(interaction.promptText)
                                .font(.system(size: 14, design: .serif))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .italic()
                        }
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 4)
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
