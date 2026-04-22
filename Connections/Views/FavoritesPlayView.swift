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
    @State private var justUnfavorited = false
    @State private var isTransitioning = false

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
                        CloseButton { dismiss() }

                        Spacer()

                        TopBarLabel(text: "Favorites")

                        Spacer()

                        heartButton
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.topBarTop)

                    // MARK: - Progress

                    VStack(spacing: 4) {
                        ProgressView(value: progress)
                            .tint(currentEntry?.intensity.toneColor.opacity(0.45) ?? Color.primary.opacity(0.12))

                        HStack {
                            if let entry = currentEntry {
                                Text(contextLabel(for: entry))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            Text("\(currentIndex + 1) of \(localFavorites.count)")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.horizontal, AppSpacing.progressHorizontal)
                    .padding(.top, 10)

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
                    .padding(.horizontal, AppSpacing.contentHorizontal)
                    .padding(.vertical, 44)
                    .id(promptTransitionID)
                    .opacity(promptVisible ? 1 : 0)
                    .offset(y: promptVisible ? 0 : 12)

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
                    .transition(.opacity.combined(with: .offset(y: 8)))
                    .padding(.bottom, 24)
                    .opacity(followUpVisible ? 1 : 0)
                    .offset(y: followUpVisible ? 0 : 8)
                }
            }
        }
    }

    // MARK: - Heart Button

    private var heartButton: some View {
        Button {
            guard !justUnfavorited, !isTransitioning, let entry = currentEntry else { return }
            isTransitioning = true
            justUnfavorited = true
            HapticsManager.lightImpact()

            // Prompt fades out after a beat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.2)) {
                    promptVisible = false
                    followUpVisible = false
                }
            }

            // Remove and advance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeOut(duration: 0.3)) {
                    session.removeFavorite(id: entry.id)
                    localFavorites.removeAll { $0.id == entry.id }
                    shownFollowUps = []
                    showGoDeeperHint = true
                    justUnfavorited = false
                }

                isTransitioning = false

                if !localFavorites.isEmpty {
                    if currentIndex >= localFavorites.count {
                        currentIndex = localFavorites.count - 1
                    }
                    promptTransitionID = UUID()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        promptVisible = true
                        followUpVisible = true
                    }
                }
            }
        } label: {
            Image(systemName: justUnfavorited ? "heart" : "heart.fill")
                .font(.system(size: 22))
                .foregroundStyle(justUnfavorited ? Color.primary.opacity(0.2) : .red)
                .scaleEffect(justUnfavorited ? 0.85 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: justUnfavorited)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 0) {

            // Go deeper
            if hasMoreFollowUps {
                Button {
                    guard !isTransitioning else { return }
                    goDeeperPressed = true
                    HapticsManager.mediumImpact()
                    withAnimation(.easeOut(duration: 0.15)) {
                        followUpVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        revealNextFollowUp()
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
                        Text("Go deeper")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(currentEntry?.intensity.cardTint.opacity(0.12) ?? Color.primary.opacity(0.06))
                    )
                    .scaleEffect(goDeeperPressed ? 0.96 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
                .transition(.opacity)
            }

            // Next / Done
            if currentIndex < localFavorites.count - 1 {
                Button {
                    guard !isTransitioning else { return }
                    isTransitioning = true
                    HapticsManager.lightImpact()
                    if !shownFollowUps.isEmpty { showGoDeeperHint = false }
                    withAnimation(.easeOut(duration: 0.2)) {
                        promptVisible = false
                        followUpVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        currentIndex += 1
                        shownFollowUps = []
                        showGoDeeperHint = true
                        promptTransitionID = UUID()
                        isTransitioning = false
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            promptVisible = true
                            followUpVisible = true
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
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                }
            }

            // Back
            if currentIndex > 0 {
                Button {
                    guard !isTransitioning else { return }
                    isTransitioning = true
                    HapticsManager.lightImpact()
                    withAnimation(.easeOut(duration: 0.2)) {
                        promptVisible = false
                        followUpVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        currentIndex -= 1
                        shownFollowUps = []
                        showGoDeeperHint = true
                        promptTransitionID = UUID()
                        isTransitioning = false
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            promptVisible = true
                            followUpVisible = true
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
        .animation(.easeOut(duration: 0.2), value: shownFollowUps.count)
        .animation(.easeOut(duration: 0.2), value: currentIndex > 0)
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
                .font(AppFont.caption())
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

    private func contextLabel(for entry: FavoritesStore.FavoriteEntry) -> String {
        switch entry.source {
        case "shareExperience":
            return "Share Experience · \(entry.intensity.rawValue)"
        case "fallInLove":
            return "36 Questions · \(entry.depth.title)"
        default:
            return "\(entry.mode.rawValue) · \(entry.intensity.rawValue) · \(entry.depth.title)"
        }
    }

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
