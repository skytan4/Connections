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

                    TopBarLabel(text: isFriends ? "Get Closer" : "Fall in Love")

                    Spacer()

                    Menu {
                        Button("Start Over") {
                            showResetConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.topBarTop)

                if !manager.isComplete {

                    // MARK: - Progress

                    SessionProgressBar(
                        progress: manager.progress,
                        depthLabel: manager.depthLabel,
                        positionLabel: "\(manager.currentIndex + 1) of \(manager.totalPrompts)"
                    )

                    // MARK: - Prompt

                    Spacer(minLength: 40)

                    if let prompt = manager.currentPrompt {
                        Text(prompt.text)
                            .promptTextStyle()
                            .id(promptTransitionID)
                            .opacity(promptVisible ? 1 : 0)
                            .offset(y: promptVisible ? 0 : 12)
                    }

                    Spacer()

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
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                        }

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
                                Text("Previous")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 14)
                        }
                    }
                    .padding(.horizontal, AppSpacing.contentHorizontal)
                    .padding(.bottom, 48)
                    .animation(.easeOut(duration: 0.2), value: manager.canGoBack)

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
                promptTransitionID = UUID()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset your progress back to Question 1. This is useful when starting with a new person.")
        }
        .animation(.easeInOut(duration: 0.4), value: manager.isComplete)
        .onChange(of: manager.isComplete) { _, complete in
            if complete { HapticsManager.success() }
        }
        .onAppear {
            manager.resume()
        }
    }

    // MARK: - Complete Content

    private var completeContent: some View {
        VStack(spacing: 12) {
            Text(isFriends ? "Something shifted" : "Something was built here")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)

            Text("You stayed for all 36 questions")
                .font(.system(size: 15))
                .foregroundStyle(.tertiary)

            Text(isFriends
                 ? "You made space for a deeper kind of conversation."
                 : "Take a moment to appreciate the connection you've built.")
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
        FallInLovePlayView()
            .environment(SessionManager())
    }
}
