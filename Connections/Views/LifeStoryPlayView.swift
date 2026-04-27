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
    @State private var showFollowUps = false

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {
                    CloseButton { dismiss() }

                    Spacer()

                    TopBarLabel(text: "Life Story")

                    Spacer()

                    if !manager.isComplete {
                        Menu {
                            Button("Start Over") {
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
                        positionLabel: "\(manager.currentIndex + 1) of \(manager.totalPrompts)",
                        tintColor: Intensity.honest.toneColor.opacity(0.45)
                    )

                    // MARK: - Prompt

                    Spacer(minLength: 40)

                    if let prompt = manager.currentPrompt {
                        VStack(spacing: 0) {
                            Text(prompt.text)
                                .promptTextStyle()

                            if showFollowUps {
                                VStack(spacing: 14) {
                                    followUpRow(prompt.followUp1)
                                    followUpRow(prompt.followUp2)
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

                    Spacer()

                    // MARK: - Actions

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            if !showFollowUps {
                                Button {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showFollowUps = true
                                    }
                                    HapticsManager.lightImpact()
                                } label: {
                                    Text("Go deeper")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(AppColor.surface(colorScheme), in: .capsule)
                                }
                            }

                            Button {
                                advanceWithTransition()
                            } label: {
                                Text("Next")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                            }
                        }

                        HStack {
                            if manager.canGoBack {
                                Button {
                                    goBackWithTransition()
                                } label: {
                                    Text("Previous")
                                        .font(.system(size: 14, weight: .medium))
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
                    .animation(.easeOut(duration: 0.2), value: showFollowUps)

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
                            Text("Done")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                        }

                        Button {
                            showResetConfirmation = true
                        } label: {
                            Text("Start Over")
                                .font(.system(size: 14, weight: .medium))
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
        .alert("Start Over?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                transitionGeneration &+= 1
                manager.reset()
                isTransitioning = false
                showFollowUps = false
                promptTransitionID = UUID()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset your progress back to Question 1.")
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
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundStyle(.tertiary)

            Text(text)
                .font(.system(size: 19, weight: .regular, design: .serif))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
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
            showFollowUps = false
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
            showFollowUps = false
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
    }

    // MARK: - Complete Content

    private var completeContent: some View {
        VStack(spacing: 12) {
            Text("A life, listened to")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)

            Text("You stayed for all 50 questions")
                .font(.system(size: 15))
                .foregroundStyle(.tertiary)

            Text("The conversations that matter most are the ones we almost didn't have.")
                .font(.system(size: 15, weight: .regular, design: .serif))
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
