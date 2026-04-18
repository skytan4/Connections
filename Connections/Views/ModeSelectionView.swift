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

            VStack(spacing: 8) {
                Text("Choose a mode")
                    .font(.system(size: 28, weight: .regular, design: .serif))

                Text("Who is this session for?")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 48)
            .padding(.bottom, 28)

            // MARK: - Mode Cards

            VStack(spacing: 12) {
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
            .padding(.horizontal, 24)

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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 4)
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
