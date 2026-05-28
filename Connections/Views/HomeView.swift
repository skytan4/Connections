//
//  HomeView.swift
//  Connections
//

import SwiftUI

struct HomeView: View {
    @State private var navigateToSettings = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                NeutralBackground()

            VStack(spacing: 0) {

                // MARK: - Header

                VStack(spacing: 16) {
                    Text(String(localized: "Deeper Conversations", defaultValue: "Deeper Conversations"))
                        .font(AppFont.heroTitle())
                        .tracking(1)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(String(localized: "home.subtitle", defaultValue: "Questions that bring you closer"))
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Actions

                VStack(spacing: 16) {
                    NavigationLink {
                        SessionBuilderView()
                    } label: {
                        Text(String(localized: "home.button.startSession", defaultValue: "Start a session"))
                            .primaryButtonStyle()
                    }
                    .accessibilityIdentifier("home.startSession")

                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Text(String(localized: "home.hint", defaultValue: "Choose a tone. Follow the prompts.\nSee where it goes."))
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                // MARK: - Secondary

                HStack(spacing: 36) {
                    Button {
                        navigateToSettings = true
                    } label: {
                        Label(String(localized: "common.label.settings", defaultValue: "Settings"), systemImage: "gearshape")
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
}
