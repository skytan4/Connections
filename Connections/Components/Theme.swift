//
//  Theme.swift
//  Connections
//
//  Centralized design tokens and reusable view modifiers.
//  Change values here to update the entire app's visual style.
//

import SwiftUI

// MARK: - Design Tokens

enum AppFont {
    static func screenTitle(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func heroTitle(_ size: CGFloat = 50) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func promptText(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func buttonPrimary(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold)
    }
    static func buttonSecondary(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .medium)
    }
    static func subtitle(_ size: CGFloat = 17) -> Font {
        .system(size: size)
    }
    static func label(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium)
    }
    static func caption(_ size: CGFloat = 15) -> Font {
        .system(size: size)
    }
    static func detail(_ size: CGFloat = 14) -> Font {
        .system(size: size)
    }
    static func fine(_ size: CGFloat = 13) -> Font {
        .system(size: size)
    }
}

enum AppColor {
    // Semantic surface colors
    static let surfacePrimary = Color.primary.opacity(0.04)
    static let surfacePressed = Color.primary.opacity(0.08)
    static let surfaceElevated = Color.primary.opacity(0.06)
    static let surfaceMuted = Color.primary.opacity(0.02)

    // Accent / interactive
    static let accent = Color(.darkGray)
    static let accentText = Color.white
    static let toggleTint = Color.blue

    // Borders and shadows
    static let subtleStroke = Color.primary.opacity(0.06)
    static let cardShadowColor = Color.black.opacity(0.04)
    static let cardShadowRadius: CGFloat = 4
    static let cardShadowY: CGFloat = 2

    // Legacy convenience aliases (maps to semantic names)
    static let primaryButton = accent
    static let primaryButtonText = accentText
    static let secondaryButtonFill = surfacePrimary
    static let secondaryButtonFillPressed = surfacePressed
    static let cardFill = surfacePrimary
    static let cardFillPressed = surfacePressed
    static let progressTint = accent
    static let chipSelected = accent
    static let chipAvailable = surfacePrimary
    static let chipLocked = surfaceMuted

    // MARK: - Dark-mode adaptive helpers

    /// Primary button background — dark gray in light, subtle white in dark.
    static func primaryButtonBg(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color(.darkGray)
    }

    /// Secondary/card surface — slightly more visible in dark mode.
    static func surface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.07) : Color.primary.opacity(0.04)
    }

    /// Subtle surface for muted elements in dark mode.
    static func surfaceSubtle(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.04) : Color.primary.opacity(0.02)
    }
}

enum AppSpacing {
    static let screenHorizontal: CGFloat = 24
    static let buttonHorizontal: CGFloat = 36
    static let promptHorizontal: CGFloat = 32
    static let progressHorizontal: CGFloat = 28
    static let contentHorizontal: CGFloat = 28
    static let bottomPadding: CGFloat = 52
    static let cardSpacing: CGFloat = 12
    static let headerTop: CGFloat = 48
    static let headerBottom: CGFloat = 28
    static let topBarTop: CGFloat = 12
    static let progressTop: CGFloat = 16
    static let sectionGap: CGFloat = 32
}

enum AppRadius {
    static let card: CGFloat = 14
    static let lengthOption: CGFloat = 12
    static let chip: CGFloat = .infinity // capsule
}

enum AppIcon {
    static let navWeight: Font.Weight = .medium
    static let navSize: CGFloat = 15
}

enum AppAnimation {
    static let standard = Animation.easeOut(duration: 0.15)
    static let transition = Animation.easeInOut(duration: 0.25)
    static let slow = Animation.easeInOut(duration: 0.3)
}

// MARK: - Reusable View Modifiers

struct PrimaryButtonStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        content
            .font(AppFont.buttonPrimary())
            .foregroundColor(AppColor.primaryButtonText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
    }
}

struct SecondaryButtonStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        content
            .font(AppFont.buttonSecondary())
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColor.surface(colorScheme), in: .capsule)
    }
}

struct ScreenBackgroundModifier: ViewModifier {
    var tint: Color?

    func body(content: Content) -> some View {
        content
            .background((tint ?? Color.clear).ignoresSafeArea())
    }
}

struct CardSurfaceModifier: ViewModifier {
    var fill: Color = AppColor.cardFill
    var radius: CGFloat = AppRadius.card
    var addShadow: Bool = false
    var addStroke: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .overlay(
                        addStroke
                            ? RoundedRectangle(cornerRadius: radius, style: .continuous)
                                .strokeBorder(AppColor.subtleStroke, lineWidth: 0.5)
                            : nil
                    )
                    .shadow(
                        color: addShadow ? AppColor.cardShadowColor : .clear,
                        radius: AppColor.cardShadowRadius,
                        y: AppColor.cardShadowY
                    )
            )
    }
}

struct PromptTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.promptText())
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, AppSpacing.promptHorizontal)
    }
}

// MARK: - View Extensions

extension View {
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }

    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonStyle())
    }

    func screenBackground(tint: Color? = nil) -> some View {
        modifier(ScreenBackgroundModifier(tint: tint))
    }

    func promptTextStyle() -> some View {
        modifier(PromptTextStyle())
    }
}

// MARK: - Reusable Components

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppFont.screenTitle())

            if let subtitle {
                Text(subtitle)
                    .font(AppFont.subtitle())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, AppSpacing.headerTop)
        .padding(.bottom, AppSpacing.headerBottom)
    }
}

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
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

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .medium))
        }
        .tint(.secondary)
    }
}

struct TopBarLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.caption())
            .foregroundStyle(.tertiary)
    }
}

struct SessionProgressBar: View {
    let progress: Double
    let depthLabel: String
    let positionLabel: String

    var body: some View {
        VStack(spacing: 6) {
            ProgressView(value: progress)
                .tint(AppColor.progressTint)

            HStack {
                Text(depthLabel)
                    .font(AppFont.detail())
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(positionLabel)
                    .font(AppFont.detail())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, AppSpacing.progressHorizontal)
        .padding(.top, AppSpacing.progressTop)
    }
}
