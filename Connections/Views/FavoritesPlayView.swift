//
//  FavoritesPlayView.swift
//  Connections
//

import SwiftUI

struct FavoritesPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var promptTransitionID = UUID()
    @State private var shownFollowUps: [FollowUp] = []
    @State private var showGoDeeperHint = true
    @State private var goDeeperPressed = false

    private var favorites: [FavoritesStore.FavoriteEntry] {
        session.favorites.allFavorites
    }

    private var currentEntry: FavoritesStore.FavoriteEntry? {
        guard !favorites.isEmpty, currentIndex < favorites.count else { return nil }
        return favorites[currentIndex]
    }

    private var hasMoreFollowUps: Bool {
        guard let entry = currentEntry else { return false }
        return shownFollowUps.count < entry.followUps.count
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: nil)

            if favorites.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {

                    // MARK: - Top Bar

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                        }
                        .tint(.secondary)

                        Spacer()

                        Text("Favorites")
                            .font(AppFont.caption())
                            .foregroundStyle(.tertiary)

                        Spacer()

                        heartButton
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.topBarTop)

                    // MARK: - Progress

                    HStack {
                        Spacer()

                        Text("Card \(currentIndex + 1) of \(favorites.count)")
                            .font(AppFont.detail())
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, AppSpacing.progressHorizontal)
                    .padding(.top, AppSpacing.progressTop)

                    // MARK: - Prompt + Follow-ups

                    Spacer()

                    promptContent

                    Spacer()

                    // MARK: - Actions

                    actionButtons
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Prompt Content

    @ViewBuilder
    private var promptContent: some View {
        if let entry = currentEntry {
            VStack(spacing: 0) {
                Text(entry.promptText)
                    .font(AppFont.promptText())
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, AppSpacing.promptHorizontal)
                    .padding(.vertical, 40)
                    .id(promptTransitionID)

                if !shownFollowUps.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(shownFollowUps) { followUp in
                            Text(followUp.text)
                                .font(AppFont.subtitle())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.primary.opacity(0.04))
                                )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - Heart Button

    private var heartButton: some View {
        Button {
            guard let entry = currentEntry else { return }
            session.removeFavorite(id: entry.id)
            shownFollowUps = []
            if !favorites.isEmpty && currentIndex >= favorites.count {
                currentIndex = max(0, favorites.count - 1)
            }
            withAnimation(.easeInOut(duration: 0.25)) {
                promptTransitionID = UUID()
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

            // MARK: Go Deeper

            if hasMoreFollowUps {
                VStack(spacing: 6) {
                    Button {
                        goDeeperPressed = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeOut(duration: 0.25)) {
                            revealNextFollowUp()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            goDeeperPressed = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .medium))
                            Text("Follow-up questions")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(.primary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.primary.opacity(0.04))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .scaleEffect(goDeeperPressed ? 0.95 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: goDeeperPressed)
                    }
                    .buttonStyle(.plain)

                    if showGoDeeperHint {
                        Text("Adds deeper follow-up questions")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.bottom, 20)
                .transition(.opacity)
            }

            // MARK: Back / Next / Done

            HStack(spacing: 12) {
                if currentIndex > 0 {
                    Button {
                        currentIndex -= 1
                        shownFollowUps = []
                        withAnimation(.easeInOut(duration: 0.25)) {
                            promptTransitionID = UUID()
                        }
                    } label: {
                        Text("Back")
                            .font(AppFont.buttonSecondary())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primary.opacity(0.04), in: .capsule)
                    }
                }

                if currentIndex < favorites.count - 1 {
                    Button {
                        currentIndex += 1
                        shownFollowUps = []
                        if !shownFollowUps.isEmpty { showGoDeeperHint = false }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            promptTransitionID = UUID()
                        }
                    } label: {
                        Text("Next")
                            .font(AppFont.buttonPrimary())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.darkGray), in: .capsule)
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(AppFont.buttonPrimary())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.darkGray), in: .capsule)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.contentHorizontal)
        .padding(.bottom, AppSpacing.bottomPadding)
        .animation(.easeOut(duration: 0.2), value: shownFollowUps.count)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)

            Text("No favorites yet")
                .font(AppFont.screenTitle())
                .foregroundStyle(.secondary)

            Text("Tap the heart on any prompt to save it here")
                .font(AppFont.subtitle())
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("Go Back")
                    .font(AppFont.buttonSecondary())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.primary.opacity(0.04), in: .capsule)
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
