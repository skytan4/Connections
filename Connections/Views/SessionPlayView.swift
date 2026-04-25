//
//  SessionPlayView.swift
//  Connections
//

import SwiftUI
import StoreKit

struct SessionPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(ReviewPromptStore.self) private var reviewPromptStore
    @Environment(\.requestReview) private var requestReview
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var promptTransitionID = UUID()
    @State private var goDeeperPressed = false
    @State private var promptVisible = true
    @State private var followUpVisible = true
    @State private var recommendation: SessionRecommendation?
    @State private var reviewPromptTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: session.selectedIntensity)

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {
                    CloseButton {
                        session.endSession()
                        dismiss()
                    }

                    Spacer()

                    if let mode = session.selectedMode, let intensity = session.selectedIntensity {
                        TopBarLabel(text: "\(mode.rawValue) · \(intensity.rawValue)")
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        if let prompt = session.currentPrompt, !session.isSessionComplete {
                            ShareLink(item: prompt.text) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.topBarTop)

                // MARK: - Session Content

                if !session.isSessionComplete {

                    // Progress
                    SessionProgressBar(
                        progress: session.sessionProgress,
                        depthLabel: session.currentDepth.title,
                        positionLabel: "\(min(session.promptsShown + 1, session.totalPrompts)) of \(session.totalPrompts)",
                        tintColor: session.selectedIntensity?.toneColor.opacity(0.45)
                    )

                    Spacer(minLength: 40)

                    if let prompt = session.currentPrompt {
                        promptContent(prompt)
                    }

                    Spacer()

                    if session.currentPrompt != nil {
                        actionButtons
                    }

                } else {

                    // MARK: Completion

                    ScrollView(.vertical) {
                        sessionCompleteContent
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                    }
                    .scrollIndicatorsFlash(onAppear: true)
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black.opacity(0.08), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 32)
                        .allowsHitTesting(false)
                    }
                    .safeAreaInset(edge: .bottom) {
                        completionBottomButtons
                    }
                }
            }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.4), value: session.isSessionComplete)
        .onChange(of: session.isSessionComplete) { _, complete in
            if complete {
                HapticsManager.success()
                recommendation = session.generateRecommendation(isPremium: entitlements.isPremium)
                reviewPromptStore.recordCompletedSession()
                considerReviewPrompt()
            }
        }
        .onDisappear {
            reviewPromptTask?.cancel()
            reviewPromptTask = nil
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }

            // Secondary — Back, Favorite
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
                    Button {
                        if !session.isCurrentPromptFavorited() {
                            HapticsManager.lightImpact()
                        }
                        session.toggleFavoriteCurrentPrompt()
                    } label: {
                        Image(systemName: session.isCurrentPromptFavorited() ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(session.isCurrentPromptFavorited() ? Color.red : Color.secondary.opacity(0.4))
                            .scaleEffect(session.isCurrentPromptFavorited() ? 1.1 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: session.isCurrentPromptFavorited())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 14)
        }
        .padding(.horizontal, AppSpacing.contentHorizontal)
        .padding(.bottom, 48)
        .animation(.easeOut(duration: 0.2), value: session.shownFollowUps.count)
    }

    // MARK: - Session Complete Content

    private var sessionCompleteContent: some View {
        VStack(spacing: 28) {

            // 1. Emotional Anchor
            if let summary = session.generateSummary() {
                VStack(spacing: 8) {
                    Text(summary.title)
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .multilineTextAlignment(.center)

                    Text(summary.supportingLine)
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppSpacing.promptHorizontal)

                // 3. Stats Row
                sessionStatsRow

                // 4. Reflection + Recommendation
                if !summary.reflectionLines.isEmpty || summary.nextStep != nil || recommendation != nil {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            ForEach(summary.reflectionLines, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }

                            if let nextStep = summary.nextStep {
                                Text(nextStep)
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                                    .foregroundStyle(.tertiary)
                                    .italic()
                                    .padding(.top, 2)
                            }

                            if let rec = recommendation {
                                Text(rec.strength.label)
                                    .font(.system(size: 16, weight: .semibold, design: .serif))
                                    .foregroundStyle(.primary)
                                    .padding(.top, 8)

                                Text(rec.explanation)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.primary)
                                    .padding(.top, 2)

                                let topicIntensity: String = [rec.topic?.displayName, rec.intensity.rawValue].compactMap { $0 }.joined(separator: " · ")
                                Text("Based on how this session unfolded, we think a \(topicIntensity) session could be a good next step. Shall we start it for you?")
                                    .font(.system(size: 15, weight: .medium, design: .serif))
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 6)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.promptHorizontal)

                        if recommendation != nil {
                            VStack(spacing: 10) {
                                Button {
                                    applyRecommendation()
                                } label: {
                                    Text("Start next session")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                                }

                                Button {
                                    session.endSession()
                                    dismiss()
                                } label: {
                                    Text("Choose myself")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, AppSpacing.buttonHorizontal - 4)
                        }
                    }
                }
            }

            // 5. Standout Moments
            standoutMomentsSection
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Stats Row

    private var sessionStatsRow: some View {
        let stats = buildStats()
        return HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                if index > 0 {
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(.quaternary)
                        .padding(.horizontal, 14)
                }
                VStack(spacing: 3) {
                    Text(stat.value)
                        .font(.system(size: 14, weight: .medium))
                    Text(stat.label)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private func buildStats() -> [(value: String, label: String)] {
        var stats: [(value: String, label: String)] = []
        stats.append((session.formattedSessionDuration, "Time"))
        if session.maxDepthReached.rawValue > DepthLevel.warmUp.rawValue {
            stats.append((session.maxDepthReached.title, "Deepest"))
        }
        if session.goDeeperCount > 0 {
            stats.append(("\(session.goDeeperCount) deeper", "Go deeper"))
        }
        return stats
    }

    // MARK: - Standout Moments

    @ViewBuilder
    private var standoutMomentsSection: some View {
        let moments = session.sessionFavoriteMoments()
        if !moments.isEmpty {
            VStack(spacing: 14) {
                Text("Moments that stayed with you")
                    .font(.system(size: 16, weight: .medium, design: .serif))

                VStack(spacing: 10) {
                    ForEach(Array(moments.enumerated()), id: \.offset) { _, moment in
                        VStack(spacing: 6) {
                            Text(moment.promptText)
                                .font(.system(size: 14, design: .serif))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .italic()

                            if let reason = moment.reason {
                                Text(reason)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(session.selectedIntensity?.cardTint ?? Color.primary.opacity(0.04))
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.contentHorizontal)
        }
    }

    // MARK: - Completion Bottom Buttons

    private var completionBottomButtons: some View {
        VStack(spacing: 10) {
            if recommendation == nil {
                Button {
                    session.endSession()
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
        .padding(.top, 12)
        .padding(.bottom, AppSpacing.bottomPadding)
        .background(.ultraThinMaterial)
    }

    private func considerReviewPrompt() {
        let isDebugOverride: Bool = {
            #if DEBUG
            return entitlements.debugOverride != .system
            #else
            return false
            #endif
        }()
        guard reviewPromptStore.shouldPromptForReview(isDebugOverride: isDebugOverride) else { return }
        reviewPromptStore.recordReviewPromptAttempt()
        reviewPromptTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await requestReview()
        }
    }

    private func applyRecommendation() {
        guard let rec = recommendation else { return }
        HapticsManager.mediumImpact()

        session.selectedIntensity = rec.intensity
        session.selectedTopic = rec.topic
        session.selectedSessionLength = rec.sessionLength
        session.followUpsEnabled = rec.followUpsEnabled
        if rec.intensity == .mixed {
            session.mixedIntensities = entitlements.mixedIntensities
        }

        recommendation = nil
        promptTransitionID = UUID()
        promptVisible = true
        followUpVisible = true

        session.startSession()
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
            .environment(EntitlementStore())
            .environment(ReviewPromptStore())
    }
}
