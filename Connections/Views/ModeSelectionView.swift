//
//  ModeSelectionView.swift
//  Connections
//

import SwiftUI

struct ModeSelectionView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var navigateToIntensity = false
    @State private var navigateToShare = false

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header

            ScreenHeader(title: "Choose a mode", subtitle: "Who is this session for?")

            // MARK: - Mode Cards

            VStack(spacing: AppSpacing.cardSpacing) {
                ForEach(Mode.allCases) { mode in
                    SelectionCard(title: mode.rawValue, subtitle: mode.description) {
                        session.selectedMode = mode
                        navigateToIntensity = true
                    }
                }

                // MARK: - Share an Experience

                SelectionCard(title: "Share", subtitle: "Take turns sharing real experiences") {
                    navigateToShare = true
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToIntensity) {
            IntensitySelectionView()
        }
        .navigationDestination(isPresented: $navigateToShare) {
            ShareExperiencePlayView()
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
    }
}
