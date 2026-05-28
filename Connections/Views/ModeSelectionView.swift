//
//  ModeSelectionView.swift
//  Connections
//

import SwiftUI

struct ModeSelectionView: View {
    @Environment(SessionManager.self) private var session
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(ReviewPromptStore.self) private var reviewPromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var navigateToIntensity = false
    @State private var navigateToShare = false
    @State private var paywallVariant: PaywallVariant? = nil

    var body: some View {
        ZStack {
            NeutralBackground()

        VStack(spacing: 0) {

            // MARK: - Header

            ScreenHeader(
                title: String(localized: "modeSelection.header.title", defaultValue: "Choose a mode"),
                subtitle: String(localized: "modeSelection.header.subtitle", defaultValue: "Who is this session for?")
            )

            // MARK: - Mode Cards

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.cardSpacing) {
                    ForEach(Mode.allCases) { mode in
                        SelectionCard(title: mode.localizedTitle, subtitle: mode.localizedDescription) {
                            session.selectedMode = mode
                            navigateToIntensity = true
                        }
                    }

                    // MARK: - Share an Experience

                    SelectionCard(
                        title: String(localized: "modeSelection.share.title", defaultValue: "Share"),
                        subtitle: String(localized: "modeSelection.share.subtitle", defaultValue: "Take turns sharing real experiences")
                    ) {
                        if entitlements.canUseShareExperience {
                            navigateToShare = true
                        } else {
                            paywallVariant = .general
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
        }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToIntensity) {
            IntensitySelectionView()
        }
        .navigationDestination(isPresented: $navigateToShare) {
            ShareExperiencePlayView()
        }
        .sheet(item: $paywallVariant) { variant in
            PremiumPaywallView(variant: variant)
                .environment(entitlements)
                .environment(reviewPromptStore)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModeSelectionView()
            .environment(SessionManager())
            .environment(EntitlementStore())
            .environment(ReviewPromptStore())
    }
}
