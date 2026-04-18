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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                }
                .tint(.secondary)

                Spacer()

                Text("Fall in Love")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)

                Spacer()

                Menu {
                    Button("Start Over") {
                        showResetConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // MARK: - Progress

            if !manager.isComplete {
                VStack(spacing: 6) {
                    ProgressView(value: manager.progress)
                        .tint(Color(.darkGray))

                    HStack {
                        Text(manager.depthLabel)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("Question \(manager.currentIndex + 1) of \(manager.totalPrompts)")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
            }

            // MARK: - Content

            Spacer()

            if manager.isComplete {
                completeContent
            } else if let prompt = manager.currentPrompt {
                Text(prompt.text)
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
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
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primary.opacity(0.04), in: .capsule)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(.darkGray), in: .capsule)
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 52)
            } else {
                HStack(spacing: 12) {
                    if manager.canGoBack {
                        Button {
                            manager.goBack()
                            withAnimation(.easeInOut(duration: 0.25)) {
                                promptTransitionID = UUID()
                            }
                        } label: {
                            Text("Previous")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.primary.opacity(0.06), in: .capsule)
                        }
                    }

                    Button {
                        manager.advance()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            promptTransitionID = UUID()
                        }
                    } label: {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.darkGray), in: .capsule)
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 52)
                .animation(.easeOut(duration: 0.15), value: manager.canGoBack)
            }
        }
        .background(Intensity.honest.backgroundTint.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Start Over?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                manager.reset()
                withAnimation(.easeInOut(duration: 0.25)) {
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
                .font(.system(size: 24, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)

            Text("Take a moment to appreciate the connection you've built.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    NavigationStack {
        FallInLovePlayView()
    }
}
