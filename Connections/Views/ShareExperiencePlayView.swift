//
//  ShareExperiencePlayView.swift
//  Connections
//

import SwiftUI

struct ShareExperiencePlayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedIntensity: Intensity?
    @State private var currentExperience: ShareExperience?
    @State private var experienceHistory: [ShareExperience] = []
    @State private var promptTransitionID = UUID()
    @State private var promptVisible = true
    @State private var isTransitioning = false

    private let bank = ShareExperienceBank.shared

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: selectedIntensity)

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {
                    CloseButton { dismiss() }

                    Spacer()

                    TopBarLabel(text: "Share an Experience")

                    Spacer()

                    // Balance the close button width
                    Color.clear.frame(width: AppIcon.navSize, height: AppIcon.navSize)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.topBarTop)

                // MARK: - Intensity Filter

                HStack(spacing: 10) {
                    filterPill(label: "All", intensity: nil)
                    ForEach(Intensity.allCases) { intensity in
                        filterPill(label: intensity.rawValue, intensity: intensity)
                    }
                }
                .padding(.top, 24)

                // MARK: - Experience Content

                Spacer()

                if let experience = currentExperience {
                    VStack(spacing: 16) {
                        Text("Share an experience that was...")
                            .font(AppFont.caption())
                            .foregroundStyle(.secondary)

                        Text(experience.text)
                            .font(.system(size: 32, weight: .regular, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, AppSpacing.promptHorizontal)

                        Text(experience.topic.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .id(promptTransitionID)
                    .opacity(promptVisible ? 1 : 0)
                    .offset(y: promptVisible ? 0 : 12)
                } else {
                    Text("No experiences match this filter")
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // MARK: - Actions

                VStack(spacing: 0) {
                    Button {
                        guard !isTransitioning else { return }
                        isTransitioning = true
                        HapticsManager.lightImpact()
                        withAnimation(.easeOut(duration: 0.2)) {
                            promptVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            advanceExperience()
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

                    if !experienceHistory.isEmpty {
                        Button {
                            guard !isTransitioning else { return }
                            isTransitioning = true
                            HapticsManager.lightImpact()
                            withAnimation(.easeOut(duration: 0.2)) {
                                promptVisible = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                goBackExperience()
                                promptTransitionID = UUID()
                                isTransitioning = false
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    promptVisible = true
                                }
                            }
                        } label: {
                            Text("Back")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 14)
                    }
                }
                .padding(.horizontal, AppSpacing.contentHorizontal)
                .padding(.bottom, 48)
                .animation(.easeOut(duration: 0.2), value: experienceHistory.isEmpty)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            currentExperience = bank.getRandomExperience(intensity: selectedIntensity)
        }
    }

    // MARK: - Filter Pill

    private func filterPill(label: String, intensity: Intensity?) -> some View {
        let isSelected = selectedIntensity == intensity
        return Button {
            guard selectedIntensity != intensity, !isTransitioning else { return }
            isTransitioning = true
            HapticsManager.lightImpact()
            withAnimation(.easeOut(duration: 0.2)) {
                promptVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                selectedIntensity = intensity
                experienceHistory = []
                currentExperience = bank.getRandomExperience(intensity: intensity)
                promptTransitionID = UUID()
                isTransitioning = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected
                              ? (intensity?.selectedTint ?? Color.primary.opacity(0.10))
                              : AppColor.surface(colorScheme))
                )
                .animation(.easeOut(duration: 0.2), value: selectedIntensity?.rawValue)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func advanceExperience() {
        if let current = currentExperience {
            experienceHistory.append(current)
        }
        currentExperience = bank.getRandomExperience(intensity: selectedIntensity)
    }

    private func goBackExperience() {
        guard let previous = experienceHistory.popLast() else { return }
        currentExperience = previous
    }
}

#Preview {
    NavigationStack {
        ShareExperiencePlayView()
    }
}
