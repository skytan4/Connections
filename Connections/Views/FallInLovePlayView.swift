//
//  FallInLovePlayView.swift
//  Connections
//

import SwiftUI

struct FallInLovePlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var manager = FallInLoveManager()

    private var isFriends: Bool { session.selectedMode == .friends }
    @State private var promptTransitionID = UUID()
    @State private var promptVisible = true
    @State private var isTransitioning = false
    @State private var transitionGeneration: UInt = 0
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {
                    CloseButton { dismiss() }

                    Spacer()

                    TopBarLabel(text: isFriends
                        ? String(localized: "fallInLovePlay.topBar.friends", defaultValue: "Get Closer")
                        : String(localized: "fallInLovePlay.topBar.couples", defaultValue: "Fall in Love"))

                    Spacer()

                    if !manager.isComplete {
                        Menu {
                            Button(String(localized: "fallInLovePlay.button.startOver", defaultValue: "Start Over")) {
                                showResetConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        // Balance the close button during completion
                        Color.clear.frame(width: AppIcon.navSize, height: AppIcon.navSize)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.topBarTop)

                if !manager.isComplete {

                    // MARK: - Progress

                    SessionProgressBar(
                        progress: manager.progress,
                        depthLabel: manager.currentPrompt?.depth.localizedTitle ?? DepthLevel.warmUp.localizedTitle,
                        positionLabel: String(format: String(localized: "sessionPlay.progress.position", defaultValue: "%1$lld of %2$lld"), manager.currentIndex + 1, manager.totalPrompts),
                        tintColor: Intensity.honest.toneColor.opacity(0.45)
                    )

                    // MARK: - Prompt

                    GeometryReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                Spacer(minLength: 40)

                                if let prompt = manager.currentPrompt {
                                    Text(prompt.text)
                                        .promptTextStyle()
                                        .id(promptTransitionID)
                                        .opacity(promptVisible ? 1 : 0)
                                        .offset(y: promptVisible ? 0 : 12)
                                }

                                Spacer(minLength: 24)
                            }
                            .frame(minHeight: proxy.size.height)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {

                    // MARK: - Actions

                    VStack(spacing: 0) {
                        Button {
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
                                promptTransitionID = UUID()
                                isTransitioning = false
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    promptVisible = true
                                }
                            }
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
                                        promptTransitionID = UUID()
                                        isTransitioning = false
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            promptVisible = true
                                        }
                                    }
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
                            Text(String(localized: "fallInLovePlay.button.startOver", defaultValue: "Start Over"))
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
        .alert(String(localized: "fallInLovePlay.alert.startOver.title", defaultValue: "Start Over?"), isPresented: $showResetConfirmation) {
            Button(String(localized: "fallInLovePlay.alert.startOver.confirm", defaultValue: "Reset"), role: .destructive) {
                transitionGeneration &+= 1
                manager.reset()
                isTransitioning = false
                promptTransitionID = UUID()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
            Button(String(localized: "common.button.cancel", defaultValue: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "fallInLovePlay.alert.startOver.message", defaultValue: "This will reset your progress back to Question 1. This is useful when starting with a new person."))
        }
        .animation(.easeInOut(duration: 0.4), value: manager.isComplete)
        .onChange(of: manager.isComplete) { _, complete in
            if complete { HapticsManager.success() }
        }
        .onAppear {
            manager.resume()
        }
    }

    // MARK: - Heart Button

    private var heartButton: some View {
        let prompt = manager.currentPrompt
        let isFavorited = prompt.map { session.isFallInLoveFavorited($0) } ?? false
        return Button {
            guard !isTransitioning, let prompt = manager.currentPrompt else { return }
            HapticsManager.lightImpact()
            session.toggleFallInLoveFavorite(prompt)
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
            Text(isFriends
                 ? String(localized: "fallInLovePlay.complete.title.friends", defaultValue: "Something shifted")
                 : String(localized: "fallInLovePlay.complete.title.couples", defaultValue: "Something was built here"))
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text(String(localized: "fallInLovePlay.complete.subtitle", defaultValue: "You stayed for all 36 questions"))
                .font(AppFont.caption())
                .foregroundStyle(.tertiary)

            Text(isFriends
                 ? String(localized: "fallInLovePlay.complete.body.friends", defaultValue: "You made space for a deeper kind of conversation.")
                 : String(localized: "fallInLovePlay.complete.body.couples", defaultValue: "Take a moment to appreciate the connection you've built."))
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
        FallInLovePlayView()
            .environment(SessionManager())
    }
}
