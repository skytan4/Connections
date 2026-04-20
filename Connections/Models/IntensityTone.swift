//
//  IntensityTone.swift
//  Connections
//

import SwiftUI

extension Intensity {

    /// The base tone color for this intensity level.
    /// Use at low opacities to create subtle atmospheric tints.
    var toneColor: Color {
        switch self {
        case .light:      return Color(red: 0.95, green: 0.78, blue: 0.42)
        case .honest:     return Color(red: 0.42, green: 0.62, blue: 0.78)
        case .unfiltered: return Color(red: 0.52, green: 0.40, blue: 0.72)
        }
    }

    /// Subtle full-screen background wash.
    var backgroundTint: Color {
        toneColor.opacity(0.09)
    }

    /// More visible tint for card and section fills.
    var cardTint: Color {
        toneColor.opacity(0.14)
    }

    /// Visible but restrained tint for selected/active states.
    var selectedTint: Color {
        toneColor.opacity(0.20)
    }
}
