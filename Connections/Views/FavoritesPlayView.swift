//
//  FavoritesPlayView.swift
//  Connections
//

import SwiftUI

struct FavoritesPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var localFavorites: [FavoritesStore.FavoriteEntry] = []
    @State private var currentIndex = 0
    @State private var promptTransitionID = UUID()
    @State private var shownFollowUps: [FollowUp] = []
    @State private var showGoDeeperHint = true
    @State private var goDeeperPressed = false
    @State private var promptVisible = true
    @State private var followUpVisible = true

    private var currentEntry: FavoritesStore.FavoriteEntry? {
        guard !localFavorites.isEmpty, currentIndex < localFavorites.count else { return nil }
        return localFavorites[currentIndex]
    }

    private var hasMoreFollowUps: Bool {
        guard let entry = currentEntry else { return false }
        return shownFollowUps.count < entry.followUps.count
    }

    private var progress: Double {
        guard !localFavorites.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(localFavorites.count)
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: currentEntry?.intensity)

            if localFavorites.isEmpty {
                emptyState
            } else {
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

                        Text("Favorites")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)

                        Spacer()

                        heartButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    // MARK: - Progress

                    VStack(spacing: 6) {
                        ProgressView(value: progress)
                            .tint(currentEntry?.intensity.toneColor ?? AppColor.primaryButtonBg(colorScheme))

                        HStack {
                            if let entry = currentEntry {
                                Text("\(entry.mode.rawValue) · \(entry.intensity.rawValue) · \(entry.depth.title)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("Card \(currentIndex + 1) of \(localFavorites.count)")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                    // MARK: - Content Area

                    Spacer(minLength: 40)

                    promptContent

                    Spacer()

                    // MARK: - Actions

                    actionButtons
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            localFavorites = session.favorites.allFavorites.shuffled()
        }
    }

    // MARK: - Prompt Content

    @ViewBuilder
    private var promptContent: some View {
        if let entry = currentEntry {
            VStack(spacing: 0) {
                Text(entry.promptText)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 44)
                    .id(promptTransitionID)
                    .opacity(promptVisible ? 1 : 0)
                    .offset(y: promptVisible ? 0 : 10)
                    .animation(.easeInOut(duration: 0.2), value: promptVisible)

                if !shownFollowUps.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(shownFollowUps) { followUp in
                            Text(followUp.text)
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(entry.intensity.cardTint)
                                )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 24)
                    .opacity(followUpVisible ? 1 : 0)
                    .offset(y: followUpVisible ? 0 : 8)
                    .animation(.easeInOut(duration: 0.2), value: followUpVisible)
                }
            }
        }
    }

    // MARK: - Heart Button

    private var heartButton: some View {
        Button {
            guard let entry = currentEntry else { return }
            HapticsManager.lightImpact()

            withAnimation(.easeOut(duration: 0.16)) {
                promptVisible = false
                followUpVisible = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                session.removeFavorite(id: entry.id)
                localFavorites.removeAll { $0.id == entry.id }
                shownFollowUps = []
                showGoDeeperHint = true

                if localFavorites.isEmpty {
                    // allow empty state to render
                } else if currentIndex >= localFavorites.count {
                    currentIndex = max(0, localFavorites.count - 1)
                    promptTransitionID = UUID()
                    promptVisible = true
                    followUpVisible = true
                } else {
                    promptTransitionID = UUID()
                    promptVisible = true
                    followUpVisible = true
                }
            }
        } label: {
            Image(systemName: "heart.fill")
                .font(.system(size: 22))
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 0) {

            // MARK: Follow-up questions

            if hasMoreFollowUps {
                VStack(spacing: 6) {
                    Button {
                        goDeeperPressed = true
                        HapticsManager.mediumImpact()
                        withAnimation(.easeOut(duration: 0.12)) {
                            followUpVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            revealNextFollowUp()
                            withAnimation(.easeIn(duration: 0.2)) {
                                followUpVisible = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            goDeeperPressed = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Go deeper")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill((currentEntry?.intensity.cardTint ?? Color.primary).opacity(0.18))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder((currentEntry?.intensity.cardTint ?? Color.primary).opacity(0.35), lineWidth: 1)
                        )
                        .scaleEffect(goDeeperPressed ? 0.95 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                    }
                    .buttonStyle(.plain)

                    if showGoDeeperHint {
                        Text("Adds deeper follow-up questions")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 20)
                .transition(.opacity)
            }

            // MARK: Back / Next / Done

            HStack(spacing: 12) {
                if currentIndex > 0 {
                    Button {
                        HapticsManager.lightImpact()

                        withAnimation(.easeOut(duration: 0.16)) {
                            promptVisible = false
                            followUpVisible = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                            currentIndex -= 1
                            shownFollowUps = []
                            showGoDeeperHint = true
                            promptTransitionID = UUID()
                            promptVisible = true
                            followUpVisible = true
                        }
                    } label: {
                        Text("Back")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.surface(colorScheme), in: .capsule)
                    }
                }

                if currentIndex < localFavorites.count - 1 {
                    Button {
                        HapticsManager.lightImpact()
                        if !shownFollowUps.isEmpty { showGoDeeperHint = false }

                        withAnimation(.easeOut(duration: 0.16)) {
                            promptVisible = false
                            followUpVisible = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                            currentIndex += 1
                            shownFollowUps = []
                            showGoDeeperHint = true
                            promptTransitionID = UUID()
                            promptVisible = true
                            followUpVisible = true
                        }
                    } label: {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                    }
                }
            }

        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
        .animation(.easeOut(duration: 0.2), value: shownFollowUps.count)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No favorites yet")
                .font(.system(size: 28, weight: .regular, design: .serif))

            Text("Tap the heart on any prompt to save it here for later.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("Return Home")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColor.surface(colorScheme), in: .capsule)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Helpers

    private func revealNextFollowUp() {
        guard let entry = currentEntry else { return }
        let shown = Set(shownFollowUps.map(\.id))
        let remaining = entry.followUps.filter { !shown.contains($0.id) }
        guard let next = remaining.first else { return }
        shownFollowUps.append(next)
        showGoDeeperHint = false
    }
}

#Preview {
    NavigationStack {
        FavoritesPlayView()
            .environment(SessionManager())

    }
}
