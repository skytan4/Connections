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
                        .font(.system(size: 44, weight: .regular, design: .serif))
                        .tracking(1)

                    Text("Guided prompts for meaningful conversation")
                        .font(.system(size: 15))
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
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .foregroundColor(.white)
                            .background(Color(.darkGray), in: .capsule)
                    }

                    if session.isSessionActive {
                        Button {
                            // Continue session — next step
                        } label: {
                            Text("Continue Session")
                                .font(.system(size: 15, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(.primary)
                                .background(Color.primary.opacity(0.06), in: .capsule)
                        }
                    }
                }
                .padding(.horizontal, 36)

                // MARK: - Secondary

                HStack(spacing: 36) {
                    Button {
                        // Favorites — next step
                    } label: {
                        Label("Favorites", systemImage: "heart")
                            .font(.system(size: 14))
                    }

                    Button {
                        // Settings — next step
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(.secondary)
                .padding(.top, 24)
                .padding(.bottom, max(geo.safeAreaInsets.bottom + 16, 52))
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(SessionManager())
}
