//
//  LifeStoryPlayView.swift
//  Connections
//

import SwiftUI

struct LifeStoryPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var manager = LifeStoryManager()

    @State private var promptTransitionID = UUID()
    @State private var promptVisible = true
    @State private var isTransitioning = false
    @State private var transitionGeneration: UInt = 0
    @State private var showResetConfirmation = false
    @State private var followUpsShown: Int = 0

    private enum ScrollAnchor {
        static let top = "lifeStoryPromptTop"
        static let bottom = "lifeStoryPromptBottom"
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {
                    CloseButton { dismiss() }

                    Spacer()

                    TopBarLabel(text: String(localized: "lifeStoryPlay.topBar.label", defaultValue: "Life Story"))

                    Spacer()

                    if !manager.isComplete {
                        Menu {
                            Button(String(localized: "lifeStoryPlay.button.startOver", defaultValue: "Start Over")) {
                                showResetConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        Color.clear.frame(width: AppIcon.navSize, height: AppIcon.navSize)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.topBarTop)

                if !manager.isComplete {

                    // MARK: - Progress

                    SessionProgressBar(
                        progress: manager.progress,
                        depthLabel: manager.chapterProgress,
                        positionLabel: String(format: String(localized: "sessionPlay.progress.position", defaultValue: "%1$lld of %2$lld"), manager.currentIndex + 1, manager.totalPrompts),
                        tintColor: Intensity.honest.toneColor.opacity(0.45)
                    )

                    // MARK: - Prompt

                    GeometryReader { proxy in
                        ScrollViewReader { scrollProxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 0) {
                                    Color.clear
                                        .frame(height: 1)
                                        .id(ScrollAnchor.top)

                                    Spacer(minLength: 40)

                                    if let prompt = manager.currentPrompt {
                                        VStack(spacing: 0) {
                                            Text(prompt.text)
                                                .promptTextStyle()

                                            if followUpsShown >= 1 {
                                                VStack(spacing: 14) {
                                                    followUpRow(prompt.followUp1)
                                                    if followUpsShown >= 2 {
                                                        followUpRow(prompt.followUp2)
                                                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                                                    }
                                                }
                                                .padding(.top, 28)
                                                .padding(.horizontal, AppSpacing.promptHorizontal)
                                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                            }
                                        }
                                        .id(promptTransitionID)
                                        .opacity(promptVisible ? 1 : 0)
                                        .offset(y: promptVisible ? 0 : 12)
                                    }

                                    Spacer(minLength: 24)

                                    Color.clear
                                        .frame(height: 1)
                                        .id(ScrollAnchor.bottom)
                                }
                                .frame(minHeight: proxy.size.height)
                            }
                            .onChange(of: followUpsShown) { _, count in
                                guard count > 0 else { return }
                                scrollToPromptBottom(scrollProxy)
                            }
                            .onChange(of: promptTransitionID) { _, _ in
                                resetPromptScroll(scrollProxy)
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {

                    // MARK: - Actions

                    VStack(spacing: 0) {
                        if followUpsShown < 2 {
                            Button {
                                HapticsManager.lightImpact()
                                withAnimation(.easeOut(duration: 0.25)) {
                                    followUpsShown += 1
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
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 16)
                            .transition(.opacity)
                        }

                        Button {
                            advanceWithTransition()
                        } label: {
                            Text(String(localized: "sessionPlay.button.next", defaultValue: "Next"))
                                .font(.system(.callout, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                        }

                        HStack {
                            if manager.canGoBack {
                                Button {
                                    goBackWithTransition()
                                } label: {
                                    Text(String(localized: "fallInLovePlay.button.previous", defaultValue: "Previous"))
                                        .font(.system(.footnote, weight: .medium))
                                        .foregroundStyle(.tertiary)
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer()

                            heartButton
                        }
                        .padding(.top, 14)
                    }
                    .padding(.horizontal, AppSpacing.contentHorizontal)
                    .padding(.bottom, 48)
                    .animation(.easeOut(duration: 0.2), value: manager.canGoBack)
                    .animation(.easeOut(duration: 0.2), value: followUpsShown)

                    } // safeAreaInset

                } else {

                    // MARK: - Completion

                    ScrollView(.vertical, showsIndicators: false) {
                        completeContent
                            .padding(.top, 32)
                            .padding(.bottom, 16)
                    }

                    VStack(spacing: 0) {
                        Button {
                            dismiss()
                        } label: {
                            Text(String(localized: "common.button.done", defaultValue: "Done"))
                                .font(AppFont.buttonSecondary())
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                        }

                        Button {
                            showResetConfirmation = true
                        } label: {
                            Text(String(localized: "lifeStoryPlay.button.startOver", defaultValue: "Start Over"))
                                .font(AppFont.detail())
                                .fontWeight(.medium)
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 14)
                    }
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .padding(.bottom, AppSpacing.bottomPadding)
                }
            }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert(String(localized: "lifeStoryPlay.alert.startOver.title", defaultValue: "Start Over?"), isPresented: $showResetConfirmation) {
            Button(String(localized: "lifeStoryPlay.alert.startOver.confirm", defaultValue: "Reset"), role: .destructive) {
                transitionGeneration &+= 1
                manager.reset()
                isTransitioning = false
                followUpsShown = 0
                promptTransitionID = UUID()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
            Button(String(localized: "common.button.cancel", defaultValue: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "lifeStoryPlay.alert.startOver.message", defaultValue: "This will reset your progress back to Question 1."))
        }
        .animation(.easeInOut(duration: 0.4), value: manager.isComplete)
        .onChange(of: manager.isComplete) { _, complete in
            if complete { HapticsManager.success() }
        }
        .onAppear {
            manager.resume()
        }
    }

    // MARK: - Follow-Up Row

    private func followUpRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("·")
                .font(.system(.title3, design: .serif, weight: .light))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Text(text)
                .font(.system(.title3, design: .serif, weight: .regular))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    private func scrollToPromptBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(ScrollAnchor.bottom, anchor: .bottom)
            }
        }
    }

    private func resetPromptScroll(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            proxy.scrollTo(ScrollAnchor.top, anchor: .top)
        }
    }

    // MARK: - Transition Helpers

    private func advanceWithTransition() {
        guard !isTransitioning else { return }
        isTransitioning = true
        let generation = transitionGeneration
        HapticsManager.lightImpact()
        withAnimation(.easeOut(duration: 0.2)) {
            promptVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard transitionGeneration == generation else { return }
            manager.advance()
            followUpsShown = 0
            promptTransitionID = UUID()
            isTransitioning = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                promptVisible = true
            }
        }
    }

    private func goBackWithTransition() {
        guard !isTransitioning else { return }
        isTransitioning = true
        let generation = transitionGeneration
        HapticsManager.lightImpact()
        withAnimation(.easeOut(duration: 0.2)) {
            promptVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard transitionGeneration == generation else { return }
            manager.goBack()
            followUpsShown = 0
            promptTransitionID = UUID()
            isTransitioning = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                promptVisible = true
            }
        }
    }

    // MARK: - Heart Button

    private var heartButton: some View {
        let prompt = manager.currentPrompt
        let isFavorited = prompt.map { session.isLifeStoryFavorited($0) } ?? false
        return Button {
            guard !isTransitioning, let prompt = manager.currentPrompt else { return }
            HapticsManager.lightImpact()
            session.toggleLifeStoryFavorite(prompt)
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: AppIcon.favoriteSize))
                .foregroundStyle(isFavorited ? Color.red : Color.secondary.opacity(0.4))
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isFavorited)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorited
            ? String(localized: "shareExperience.heart.removeAccessibilityLabel", defaultValue: "Remove from favorites")
            : String(localized: "shareExperience.heart.addAccessibilityLabel", defaultValue: "Add to favorites"))
    }

    // MARK: - Complete Content

    private var completeContent: some View {
        VStack(spacing: 12) {
            Text(String(localized: "lifeStoryPlay.complete.title", defaultValue: "A life, listened to"))
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text(String(localized: "lifeStoryPlay.complete.subtitle", defaultValue: "You stayed for all 50 questions"))
                .font(AppFont.caption())
                .foregroundStyle(.tertiary)

            Text(String(localized: "lifeStoryPlay.complete.body", defaultValue: "The conversations that matter most are the ones we almost didn't have."))
                .font(AppFont.caption())
                .fontDesign(.serif)
                .foregroundStyle(.secondary)
                .italic()
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppSpacing.promptHorizontal)
    }
}

#Preview {
    NavigationStack {
        LifeStoryPlayView()
            .environment(SessionManager())
    }
}
