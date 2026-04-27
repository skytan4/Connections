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
    // 34pt at default — serif heading, scales with Dynamic Type
    static func screenTitle() -> Font {
        .system(.largeTitle, design: .serif, weight: .regular)
    }
    // 50pt fixed — decorative display; HomeView uses minimumScaleFactor for small screens
    static func heroTitle() -> Font {
        .system(size: 50, weight: .regular, design: .serif)
    }
    // 28pt at default (.title) — exact match, now scales with Dynamic Type
    static func promptText() -> Font {
        .system(.title, design: .serif, weight: .regular)
    }
    // 20pt at default (.title3) — exact match, now scales
    static func buttonPrimary() -> Font {
        .system(.title3, weight: .semibold)
    }
    // 17pt at default (.body) — exact match, now scales
    static func buttonSecondary() -> Font {
        .system(.body, weight: .medium)
    }
    // 17pt at default
    static func subtitle() -> Font { .body }
    // 16pt at default (.callout) — exact match, now scales
    static func label() -> Font {
        .system(.callout, weight: .medium)
    }
    // 15pt at default (.subheadline) — exact match, now scales
    static func caption() -> Font { .subheadline }
    // 13pt at default (.footnote) — was 14pt; 1pt difference acceptable
    static func detail() -> Font { .footnote }
    // 13pt at default
    static func fine() -> Font { .footnote }
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
    static let navSize: CGFloat = 25
    static let favoriteSize: CGFloat = 25
    static let favoritePlaybackSize: CGFloat = 25
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
            .dynamicTypeSize(.xSmall...DynamicTypeSize.accessibility2)
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
        .accessibilityLabel("Back")
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
        .accessibilityLabel("Close")
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
    var tintColor: Color? = nil

    var body: some View {
        VStack(spacing: 4) {
            ProgressView(value: progress)
                .tint(tintColor ?? Color.primary.opacity(0.12))

            HStack {
                Text(depthLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)

                Spacer()

                Text(positionLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, AppSpacing.progressHorizontal)
        .padding(.top, 10)
    }
}
