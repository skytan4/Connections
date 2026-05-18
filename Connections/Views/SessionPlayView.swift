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
                        TopBarLabel(text: String(format: String(localized: "sessionSetup.header.subtitle", defaultValue: "%1$@ · %2$@"), mode.localizedTitle, intensity.localizedTitle))
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        if let prompt = session.currentPrompt, !session.isSessionComplete {
                            ShareLink(item: prompt.text) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                                    .foregroundStyle(.tertiary)
                            }
                            .accessibilityLabel(String(localized: "sessionPlay.share.accessibilityLabel", defaultValue: "Share this prompt"))
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
                        depthLabel: session.currentDepth.localizedTitle,
                        positionLabel: String(format: String(localized: "sessionPlay.progress.position", defaultValue: "%1$lld of %2$lld"), min(session.promptsShown + 1, session.totalPrompts), session.totalPrompts),
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
                        if recommendation == nil {
                            completionBottomButtons
                        }
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
        .onAppear {
            // Start the session here so it runs after the view is fully mounted.
            // This avoids an iOS 18 race where @Observable state mutations in
            // SessionBuilderView's button handler could be rolled back mid-transition.
            if !session.isSessionActive {
                session.startSession()
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
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 28)
                .padding(.vertical, 44)
                .dynamicTypeSize(.xSmall...DynamicTypeSize.accessibility2)
                .id(promptTransitionID)
                .opacity(promptVisible ? 1 : 0)
                .offset(y: promptVisible ? 0 : 12)
                .accessibilityIdentifier("promptText")

            if !session.shownFollowUps.isEmpty && session.followUpsEnabled {
                VStack(spacing: 8) {
                    ForEach(session.shownFollowUps) { followUp in
                        Text(followUp.text)
                            .font(AppFont.caption())
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
                            .accessibilityHidden(true)
                        Text(String(localized: "sessionPlay.button.goDeeper", defaultValue: "Go deeper"))
                            .font(AppFont.buttonSecondary())
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(AppColor.surface(colorScheme), in: .capsule)
                    .overlay(Capsule().strokeBorder(AppColor.subtleStroke, lineWidth: 0.5))
                    .scaleEffect(goDeeperPressed ? 0.96 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("goDeeperButton")
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
                Text(String(localized: "sessionPlay.button.next", defaultValue: "Next"))
                    .font(.system(.title3, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .accessibilityIdentifier("nextPromptButton")

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
                        Text(String(localized: "common.button.back", defaultValue: "Back"))
                            .font(AppFont.buttonSecondary())
                            .fontWeight(.medium)
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
                            .font(.system(size: 25))
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
                        .font(AppFont.promptText())
                        .multilineTextAlignment(.center)

                    Text(summary.supportingLine)
                        .font(AppFont.caption())
                        .fontDesign(.serif)
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
                                    .font(AppFont.detail())
                                    .foregroundStyle(.secondary)
                            }

                            if let nextStep = summary.nextStep {
                                Text(nextStep)
                                    .font(AppFont.detail())
                                    .fontDesign(.serif)
                                    .foregroundStyle(.tertiary)
                                    .italic()
                                    .padding(.top, 2)
                            }

                            if let rec = recommendation {
                                Text(rec.strength.label)
                                    .font(AppFont.label())
                                    .fontDesign(.serif)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .padding(.top, 8)

                                Text(rec.explanation)
                                    .font(AppFont.caption())
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .padding(.top, 2)

                                let recommendationPrompt: String = {
                                    if let topic = rec.topic {
                                        return String(format: String(localized: "sessionPlay.recommendation.prompt.topicAndIntensity", defaultValue: "Based on how this session unfolded, we think a session about %1$@ at the %2$@ level could be a good next step. Shall we start it for you?"), topic.localizedDisplayName, rec.intensity.localizedTitle)
                                    } else {
                                        return String(format: String(localized: "sessionPlay.recommendation.prompt.intensityOnly", defaultValue: "Based on how this session unfolded, we think a %1$@ session could be a good next step. Shall we start it for you?"), rec.intensity.localizedTitle)
                                    }
                                }()
                                Text(recommendationPrompt)
                                    .font(AppFont.caption())
                                    .fontDesign(.serif)
                                    .fontWeight(.medium)
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
                                    Text(String(localized: "sessionPlay.button.startNextSession", defaultValue: "Start next session"))
                                        .font(AppFont.buttonSecondary())
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                                }

                                Button {
                                    session.endSession()
                                    dismiss()
                                } label: {
                                    Text(String(localized: "sessionPlay.button.chooseMyself", defaultValue: "Choose myself"))
                                        .font(AppFont.caption())
                                        .fontWeight(.medium)
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
        stats.append((session.formattedSessionDuration, String(localized: "sessionPlay.stats.time", defaultValue: "Time")))
        if session.maxDepthReached.rawValue > DepthLevel.warmUp.rawValue {
            stats.append((session.maxDepthReached.localizedTitle, String(localized: "sessionPlay.stats.deepest", defaultValue: "Deepest")))
        }
        if session.goDeeperCount > 0 {
            let deeperValue = session.goDeeperCount == 1
                ? String(localized: "sessionPlay.stats.deeperCount.one", defaultValue: "1 deeper")
                : String(format: String(localized: "sessionPlay.stats.deeperCount.other", defaultValue: "%1$lld deeper"), session.goDeeperCount)
            stats.append((deeperValue, String(localized: "sessionPlay.button.goDeeper", defaultValue: "Go deeper")))
        }
        return stats
    }

    // MARK: - Standout Moments

    @ViewBuilder
    private var standoutMomentsSection: some View {
        let moments = session.sessionFavoriteMoments()
        if !moments.isEmpty {
            VStack(spacing: 14) {
                Text(String(localized: "sessionPlay.moments.title", defaultValue: "Moments that stayed with you"))
                    .font(AppFont.label())
                    .fontDesign(.serif)

                VStack(spacing: 10) {
                    ForEach(Array(moments.enumerated()), id: \.offset) { _, moment in
                        VStack(spacing: 6) {
                            Text(moment.promptText)
                                .font(AppFont.detail())
                                .fontDesign(.serif)
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
        Button {
            session.endSession()
            dismiss()
        } label: {
            Text(String(localized: "common.button.close", defaultValue: "Close"))
                .font(AppFont.buttonSecondary())
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
        }
        .buttonStyle(.plain)
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
            requestReview()
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
