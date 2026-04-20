//
//  ShareExperiencePlayView.swift
//  Connections
//

import SwiftUI

struct ShareExperiencePlayView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIntensity: Intensity?
    @State private var currentExperience: ShareExperience?
    @State private var experienceHistory: [ShareExperience] = []
    @State private var transitionID = UUID()

    private let bank = ShareExperienceBank.shared

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

                Text("Share an Experience")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)

                Spacer()

                Color.clear.frame(width: 15, height: 15)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            // MARK: - Intensity Filter

            HStack(spacing: 10) {
                filterPill(label: "All", intensity: nil)
                ForEach(Intensity.allCases) { intensity in
                    filterPill(label: intensity.rawValue, intensity: intensity)
                }
            }
            .padding(.top, 24)

            // MARK: - Experience Card

            Spacer()

            if let experience = currentExperience {
                VStack(spacing: 16) {
                    Text("Share an experience that was...")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    Text(experience.text)
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                        .id(transitionID)
                        .transition(.opacity)

                    Text(experience.topic.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
            } else {
                Text("No experiences match this filter")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // MARK: - Back / Next

            HStack(spacing: 12) {
                if !experienceHistory.isEmpty {
                    Button {
                        goBackExperience()
                    } label: {
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.primary.opacity(0.04), in: .capsule)
                    }
                }

                Button {
                    nextExperience()
                } label: {
                    Text("Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(.darkGray), in: .capsule)
                }
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 52)
        }
        .background((selectedIntensity?.backgroundTint ?? Color.clear).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            nextExperience()
        }
    }

    // MARK: - Filter Pill

    private func filterPill(label: String, intensity: Intensity?) -> some View {
        let isSelected = selectedIntensity == intensity
        return Button {
            selectedIntensity = intensity
            experienceHistory = []
            nextExperience()
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
                              : Color.primary.opacity(0.04))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func nextExperience() {
        if let current = currentExperience {
            experienceHistory.append(current)
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentExperience = bank.getRandomExperience(intensity: selectedIntensity)
            transitionID = UUID()
        }
    }

    private func goBackExperience() {
        guard let previous = experienceHistory.popLast() else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentExperience = previous
            transitionID = UUID()
        }
    }
}

#Preview {
    NavigationStack {
        ShareExperiencePlayView()
    }
}
