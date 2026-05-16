//
//  ContentView.swift
//  Connections
//
//  Created by John Tanner on 4/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var session = SessionManager()
    @State private var settings = SettingsStore()
    @State private var entitlements = EntitlementStore()
    @State private var reviewPromptStore = ReviewPromptStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if settings.hasSeenOnboarding || ProcessInfo.processInfo.arguments.contains("-SkipOnboarding") {
                NavigationStack {
                    HomeView()
                }
                .environment(session)
                .environment(settings)
                .environment(entitlements)
                .environment(reviewPromptStore)
            } else {
                OnboardingView()
                    .environment(settings)
            }
        }
        .task {
            entitlements.startTransactionListener()
            await entitlements.loadProduct()
            await entitlements.refreshEntitlements()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                reviewPromptStore.recordAppOpen()
            }
        }
    }
}

#Preview {
    ContentView()
}
