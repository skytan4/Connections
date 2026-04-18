//
//  HomeView.swift
//  Connections
//

import SwiftUI

struct HomeView: View {
    @Environment(SessionManager.self) private var session
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {

                // MARK: - Header

                VStack(spacing: 16) {
                    Text("Layers")
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
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                // MARK: - Secondary

                HStack(spacing: 36) {
                    Button {
                        // Favorites — next step
                    } label: {
                        Label("Favorites", systemImage: "heart")
                            .font(AppFont.label())
                    }

                    Button {
                        // Settings — next step
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                            .font(AppFont.label())
                    }
                }
                .foregroundStyle(.secondary)
                .padding(.top, 24)
                .padding(.bottom, max(geo.safeAreaInsets.bottom + 16, AppSpacing.bottomPadding))
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionManager())
}
