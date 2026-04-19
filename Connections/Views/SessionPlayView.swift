//
//  SessionPlayView.swift
//  Connections
//

import SwiftUI

struct SessionPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var isFavorited = false
    @State private var showFollowUps = false
    @State private var promptTransitionID = UUID()
    @State private var showGoDeeperHint = true
    @State private var goDeeperPressed = false
    var body: some View {
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
                        .tint(Color(.darkGray))

                    HStack {
                        Text(session.currentDepth.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("Card \(min(session.promptsShown + 1, session.totalPrompts)) of \(session.totalPrompts)")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
            }

            // MARK: - Content Area

            Spacer()

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
                        .background(Color(.darkGray), in: .capsule)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 52)
            }
        }
        .background((session.selectedIntensity?.backgroundTint ?? Color.clear).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.3), value: session.showFeelingCheckIn)
        .animation(.easeInOut(duration: 0.3), value: session.isSessionComplete)
    }

    // MARK: - Prompt Content

    @ViewBuilder
    private func promptContent(_ prompt: Prompt) -> some View {
        VStack(spacing: 0) {
            Text(prompt.text)
                .font(.system(size: 24, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
                .id(promptTransitionID)

            if showFollowUps && session.followUpsEnabled {
                VStack(spacing: 8) {
                    ForEach(prompt.followUps) { followUp in
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
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 0) {

            // MARK: Go deeper (above primary actions, with breathing room)

            if session.followUpsEnabled && !showFollowUps {
                VStack(spacing: 6) {
                    Button {
                        goDeeperPressed = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        session.recordGoDeeper()
                        withAnimation(.easeOut(duration: 0.25)) {
                            showFollowUps = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            goDeeperPressed = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .medium))
                            Text("Go deeper")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(.primary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.primary.opacity(0.04))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .scaleEffect(goDeeperPressed ? 0.95 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                    }
                    .buttonStyle(.plain)

                    if showGoDeeperHint {
                        Text("Adds deeper follow-up questions")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.bottom, 20)
                .transition(.opacity)
            }

            // MARK: Skip / Next

            HStack(spacing: 12) {
                Button {
                    session.skipPrompt()
                    advanceToNext()
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primary.opacity(0.04), in: .capsule)
                }

                Button {
                    session.continuePrompt(isFavorited: isFavorited)
                    advanceToNext()
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.darkGray), in: .capsule)
                }
            }

            // MARK: Favorite + Check in (post-follow-up)

            HStack(spacing: 28) {
                Button {
                    isFavorited.toggle()
                    if isFavorited {
                        session.favoriteCurrentPrompt()
                    }
                } label: {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(isFavorited ? Color(.darkGray) : .secondary)
                }
                .buttonStyle(.plain)

                if session.followUpsEnabled && showFollowUps {
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
                        .background(Capsule().fill(Color(.darkGray)))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
        .animation(.easeOut(duration: 0.2), value: showFollowUps)
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

            Text("Session complete")
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
                            .foregroundStyle(.tertiary)
                            .italic()
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Helpers

    private func advanceToNext() {
        isFavorited = false
        if showFollowUps { showGoDeeperHint = false }
        showFollowUps = false
        if !session.showFeelingCheckIn {
            withAnimation(.easeInOut(duration: 0.25)) {
                promptTransitionID = UUID()
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
