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
        VStack(spacing: 0) {

            // MARK: - Header

            VStack(spacing: 8) {
                Text("Set the tone")
                    .font(.system(size: 28, weight: .regular, design: .serif))

                Text("How deep do you want to go?")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 48)
            .padding(.bottom, 28)

            // MARK: - Intensity Cards

            VStack(spacing: 12) {
                ForEach(Intensity.allCases) { intensity in
                    SelectionCard(
                        title: intensity.rawValue,
                        subtitle: intensity.description,
                        tintColor: intensity.toneColor
                    ) {
                        session.selectedIntensity = intensity
                        navigateToSetup = true
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSetup) {
            SessionSetupView()
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
        IntensitySelectionView()
            .environment(SessionManager())
    }
}
