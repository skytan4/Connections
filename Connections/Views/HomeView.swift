//
//  HomeView.swift
//  Connections
//

import SwiftUI

struct HomeView: View {
    @Environment(SessionManager.self) private var session
    @State private var navigateToFavorites = false
    @State private var navigateToSettings = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                NeutralBackground()

            VStack(spacing: 0) {

                // MARK: - Header

                VStack(spacing: 16) {
                    Text("Connections")
                        .font(AppFont.heroTitle())
                        .tracking(1)

                    Text("Guided prompts for meaningful conversation")
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Actions

                VStack(spacing: 16) {
                    NavigationLink {
                        ModeSelectionView()
                    } label: {
                        Text("Start Session")
                            .primaryButtonStyle()
                    }

                    if session.isSessionActive {
                        Button {
                            // Continue session — next step
                        } label: {
                            Text("Continue Session")
                                .secondaryButtonStyle()
                        }
                    }

                    if !session.favorites.allFavorites.isEmpty {
                        Button {
                            navigateToFavorites = true
                        } label: {
                            Text("Play Favorites (\(session.favorites.allFavorites.count))")
                                .secondaryButtonStyle()
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                // MARK: - Secondary

                HStack(spacing: 36) {
                    Button {
                        navigateToSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                            .font(AppFont.label())
                    }
                }
                .foregroundStyle(.secondary)
                .padding(.top, 24)
                .padding(.bottom, max(geo.safeAreaInsets.bottom + 16, AppSpacing.bottomPadding))
            }
            .navigationDestination(isPresented: $navigateToFavorites) {
                FavoritesPlayView()
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
            } // ZStack
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionManager())
}
