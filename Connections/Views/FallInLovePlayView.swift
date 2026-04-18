//
//  FallInLovePlayView.swift
//  Connections
//

import SwiftUI

struct FallInLovePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager = FallInLoveManager()
    @State private var promptTransitionID = UUID()
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Top Bar

            HStack {
                CloseButton { dismiss() }

                Spacer()

                TopBarLabel(text: "Fall in Love")

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

            // MARK: - Progress

            if !manager.isComplete {
                SessionProgressBar(
                    progress: manager.progress,
                    depthLabel: manager.depthLabel,
                    positionLabel: "Question \(manager.currentIndex + 1) of \(manager.totalPrompts)"
                )
            }

            // MARK: - Content

            Spacer()

            if manager.isComplete {
                completeContent
            } else if let prompt = manager.currentPrompt {
                Text(prompt.text)
                    .promptTextStyle()
                    .id(promptTransitionID)
            }

            Spacer()

            // MARK: - Actions

            if manager.isComplete {
                VStack(spacing: 12) {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        Text("Start Over")
                            .secondaryButtonStyle()
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .primaryButtonStyle()
                    }
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)
                .padding(.bottom, AppSpacing.bottomPadding)
            } else {
                HStack(spacing: 12) {
                    if manager.canGoBack {
                        Button {
                            manager.goBack()
                            withAnimation(AppAnimation.transition) {
                                promptTransitionID = UUID()
                            }
                        } label: {
                            Text("Previous")
                                .font(AppFont.buttonSecondary())
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColor.surfaceElevated, in: .capsule)
                        }
                    }

                    Button {
                        manager.advance()
                        withAnimation(AppAnimation.transition) {
                            promptTransitionID = UUID()
                        }
                    } label: {
                        Text("Next")
                            .primaryButtonStyle()
                    }
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)
                .padding(.bottom, AppSpacing.bottomPadding)
                .animation(AppAnimation.standard, value: manager.canGoBack)
            }
        }
        .background(Intensity.honest.backgroundTint.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Start Over?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                manager.reset()
                withAnimation(AppAnimation.transition) {
                    promptTransitionID = UUID()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset your progress back to Question 1. This is useful when starting with a new person.")
        }
        .onAppear {
            manager.resume()
        }
    }

    // MARK: - Complete Content

    private var completeContent: some View {
        VStack(spacing: 16) {
            Text("You've completed all 36 questions")
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text("Take a moment to appreciate the connection you've built.")
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppSpacing.promptHorizontal)
    }
}

#Preview {
    NavigationStack {
        FallInLovePlayView()
    }
}
