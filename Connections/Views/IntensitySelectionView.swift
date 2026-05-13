//
//  IntensitySelectionView.swift
//  Connections
//

import SwiftUI

struct IntensitySelectionView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var navigateToSetup = false

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: session.selectedIntensity)

            VStack(spacing: 0) {

                // MARK: - Header

                ScreenHeader(
                    title: String(localized: "intensitySelection.header.title", defaultValue: "Set the tone"),
                    subtitle: String(localized: "intensitySelection.header.subtitle", defaultValue: "How deep do you want to go?")
                )

                // MARK: - Intensity Cards

                VStack(spacing: AppSpacing.cardSpacing) {
                    ForEach(Intensity.allCases) { intensity in
                        SelectionCard(
                            title: intensity.localizedTitle,
                            subtitle: intensity.localizedDescription,
                            tintColor: intensity.toneColor,
                            isSelected: session.selectedIntensity == intensity,
                            glassEffect: true
                        ) {
                            session.selectedIntensity = intensity
                            navigateToSetup = true
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)

                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: session.selectedIntensity)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSetup) {
            SessionSetupView()
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
        IntensitySelectionView()
            .environment(SessionManager())
    }
}
