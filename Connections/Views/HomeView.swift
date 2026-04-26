//
//  HomeView.swift
//  Connections
//

import SwiftUI

struct HomeView: View {
    @Environment(SessionManager.self) private var session
    @State private var navigateToSettings = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                NeutralBackground()

            VStack(spacing: 0) {

                // MARK: - Header

                VStack(spacing: 16) {
                    Text("Deeper Conversations")
                        .font(AppFont.heroTitle())
                        .tracking(1)

                    Text("Questions that bring you closer")
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Actions

                VStack(spacing: 16) {
                    NavigationLink {
                        SessionBuilderView()
                    } label: {
                        Text("Start a session")
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

                Text("Choose a tone. Follow the prompts.\nSee where it goes.")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

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
