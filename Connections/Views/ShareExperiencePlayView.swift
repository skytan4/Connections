//
//  ShareExperiencePlayView.swift
//  Connections
//

import SwiftUI

struct ShareExperiencePlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(ReviewPromptStore.self) private var reviewPromptStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var manager: ShareExperienceSessionManager
    @State private var promptTransitionID = UUID()
    @State private var promptVisible = true
    @State private var isTransitioning = false
    @State private var showAboutSheet = false
    @State private var paywallVariant: PaywallVariant?

    private let isPreview: Bool

    init() {
        self.isPreview = false
        _manager = State(initialValue: ShareExperienceSessionManager())
    }

    init(previewExperiences: [ShareExperience]) {
        self.isPreview = true
        _manager = State(initialValue: ShareExperienceSessionManager(previewExperiences: previewExperiences))
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: manager.backgroundIntensity)

            VStack(spacing: 0) {

                // MARK: - Top Bar

                HStack {
                    CloseButton { dismiss() }

                    Spacer()

                    TopBarLabel(text: String(localized: "shareExperience.topBar.label", defaultValue: "Share an Experience"))

                    Spacer()

                    HStack(spacing: 16) {
                        Button {
                            showAboutSheet = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                                .foregroundStyle(.tertiary)
                        }
                        .accessibilityLabel(String(localized: "shareExperience.about.accessibilityLabel", defaultValue: "About this mode"))

                        if !manager.isComplete {
                            heartButton
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.topBarTop)

                // MARK: - Intensity Filter

                if !isPreview && !manager.isComplete {
                    HStack(spacing: 10) {
                        filterPill(label: String(localized: "shareExperience.filter.all", defaultValue: "All"), intensity: nil)
                        ForEach(Intensity.concrete) { intensity in
                            filterPill(label: intensity.localizedTitle, intensity: intensity)
                        }
                    }
                    .padding(.top, 24)
                }

                // MARK: - Experience Content

                Spacer()

                if manager.isComplete {
                    completionContent
                } else if let experience = manager.currentExperience {
                    VStack(spacing: 16) {
                        Text(experience.fullText)
                            .font(AppFont.promptText())
                            .dynamicTypeSize(.xSmall...DynamicTypeSize.accessibility2)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, AppSpacing.promptHorizontal)
                            .accessibilityIdentifier("shareExperienceText")

                        Text(experience.topic.localizedDisplayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .id(promptTransitionID)
                    .opacity(promptVisible ? 1 : 0)
                    .offset(y: promptVisible ? 0 : 12)
                } else {
                    Text(String(localized: "shareExperience.emptyFilter", defaultValue: "No experiences match this filter"))
                        .font(AppFont.subtitle())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // MARK: - Actions

                if manager.isComplete {
                    completionButtons
                } else {
                    VStack(spacing: 0) {
                        Button {
                            guard !isTransitioning else { return }
                            isTransitioning = true
                            HapticsManager.lightImpact()
                            withAnimation(.easeOut(duration: 0.2)) {
                                promptVisible = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                advanceExperience()
                                promptTransitionID = UUID()
                                isTransitioning = false
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    promptVisible = true
                                }
                            }
                        } label: {
                            Text(String(localized: "sessionPlay.button.next", defaultValue: "Next"))
                                .font(.system(.callout, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                        }

                        if manager.canGoBack {
                            Button {
                                guard !isTransitioning else { return }
                                isTransitioning = true
                                HapticsManager.lightImpact()
                                withAnimation(.easeOut(duration: 0.2)) {
                                    promptVisible = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    goBackExperience()
                                    promptTransitionID = UUID()
                                    isTransitioning = false
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        promptVisible = true
                                    }
                                }
                            } label: {
                                Text(String(localized: "common.button.back", defaultValue: "Back"))
                                    .font(.system(.footnote, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 14)
                        }
                    }
                    .padding(.horizontal, AppSpacing.contentHorizontal)
                    .padding(.bottom, 48)
                    .animation(.easeOut(duration: 0.2), value: manager.canGoBack)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAboutSheet) {
            ShareExperienceAboutSheet()
        }
        .sheet(item: $paywallVariant) { variant in
            PremiumPaywallView(variant: variant)
                .environment(entitlements)
                .environment(reviewPromptStore)
        }
        .animation(.easeInOut(duration: 0.4), value: manager.isComplete)
        .onChange(of: manager.isComplete) { _, complete in
            if complete {
                HapticsManager.success()
                if isPreview {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        paywallVariant = .shareExperience
                    }
                }
            }
        }
    }

    // MARK: - Heart Button

    private var heartButton: some View {
        let isFavorited = manager.currentExperience.map { session.isExperienceFavorited($0) } ?? false
        return Button {
            guard !isTransitioning, let experience = manager.currentExperience else { return }
            HapticsManager.lightImpact()
            session.toggleExperienceFavorite(experience)
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: AppIcon.favoriteSize))
                .foregroundStyle(isFavorited ? Color.red : Color.secondary.opacity(0.4))
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isFavorited)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorited
            ? String(localized: "shareExperience.heart.removeAccessibilityLabel", defaultValue: "Remove from favorites")
            : String(localized: "shareExperience.heart.addAccessibilityLabel", defaultValue: "Add to favorites"))
    }

    // MARK: - Filter Pill

    private func filterPill(label: String, intensity: Intensity?) -> some View {
        let isSelected = manager.selectedIntensity == intensity
        return Button {
            guard manager.selectedIntensity != intensity, !isTransitioning else { return }
            isTransitioning = true
            HapticsManager.lightImpact()
            withAnimation(.easeOut(duration: 0.2)) {
                promptVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                manager.setIntensity(intensity)
                promptTransitionID = UUID()
                isTransitioning = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected
                              ? (intensity?.selectedTint ?? Color.primary.opacity(0.10))
                              : AppColor.surface(colorScheme))
                )
                .animation(.easeOut(duration: 0.2), value: manager.selectedIntensity?.rawValue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(intensity.map {
            String(format: String(localized: "shareExperience.filter.intensityAccessibilityLabel", defaultValue: "%1$@ intensity filter"), $0.localizedTitle)
        } ?? String(localized: "shareExperience.filter.allAccessibilityLabel", defaultValue: "All intensities filter"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Helpers

    private func advanceExperience() {
        manager.advance()
    }

    private func goBackExperience() {
        manager.goBack()
    }

    private func replayPreview() {
        HapticsManager.lightImpact()
        manager.restart()
        promptTransitionID = UUID()
        promptVisible = true
        isTransitioning = false
    }

    private var completionContent: some View {
        VStack(spacing: 12) {
            Text(String(localized: "shareExperience.preview.complete.title", defaultValue: "You tried a few selected experiences."))
                .font(AppFont.promptText())
                .multilineTextAlignment(.center)

            Text(String(localized: "shareExperience.preview.complete.subtitle", defaultValue: "Full Access unlocks the complete Share Experiences library."))
                .font(AppFont.caption())
                .foregroundStyle(.tertiary)

            Text(String(localized: "shareExperience.preview.complete.body", defaultValue: "Continue with the full deck when you want more range, depth, and surprise."))
                .font(AppFont.caption())
                .fontDesign(.serif)
                .foregroundStyle(.secondary)
                .italic()
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppSpacing.promptHorizontal)
    }

    private var completionButtons: some View {
        VStack(spacing: 10) {
            Button {
                HapticsManager.mediumImpact()
                paywallVariant = .shareExperience
            } label: {
                Text(String(localized: "shareExperience.preview.button.unlock", defaultValue: "Unlock Full Access"))
                    .font(AppFont.buttonSecondary())
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }

            Button {
                replayPreview()
            } label: {
                Text(String(localized: "shareExperience.preview.button.replay", defaultValue: "Replay preview"))
                    .font(AppFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.buttonHorizontal)
        .padding(.top, 12)
        .padding(.bottom, AppSpacing.bottomPadding)
        .background(.ultraThinMaterial)
    }
}

// MARK: - About Sheet

private struct ShareExperienceAboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                Text(String(localized: "shareExperience.about.title", defaultValue: "About this mode"))
                    .font(AppFont.promptText())
                    .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 14) {
                    BulletPoint(String(localized: "shareExperience.about.bullet1", defaultValue: "These prompts follow a structured progression — starting with lighter sharing and moving gradually toward deeper vulnerability — designed to build closeness naturally between two people"))
                    BulletPoint(String(localized: "shareExperience.about.bullet2", defaultValue: "This format is based on a well-studied model of interpersonal closeness that has shown consistent results in increasing connection, even between people who have just met"))
                    BulletPoint(String(localized: "shareExperience.about.bullet3", defaultValue: "It works because closeness isn't random — it follows from mutual honesty, genuine attention, and a willingness to be present with each other"))
                    BulletPoint(String(localized: "shareExperience.about.bullet4", defaultValue: "The deeper prompts can be unexpectedly powerful. Approach them with care and intention — this works best when both people feel safe enough to be honest"))
                }
                .padding(.horizontal, AppSpacing.buttonHorizontal)

                Text(String(localized: "shareExperience.about.footer", defaultValue: "This isn't small talk.\nTreat it like it matters, and it will."))
                    .font(AppFont.subtitle())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, AppSpacing.buttonHorizontal)
                    .padding(.top, 28)

                Spacer(minLength: 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                dismiss()
            } label: {
                Text(String(localized: "shareExperience.about.button.gotIt", defaultValue: "Got it"))
                    .font(AppFont.buttonPrimary())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundStyle(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .padding(.horizontal, AppSpacing.buttonHorizontal)
            .padding(.top, 12)
            .padding(.bottom, AppSpacing.bottomPadding)
            .background(.ultraThinMaterial)
        }
        .presentationDragIndicator(.visible)
    }
}

private struct BulletPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(AppFont.subtitle())
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            Text(text)
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    NavigationStack {
        ShareExperiencePlayView()
            .environment(SessionManager())
            .environment(EntitlementStore())
            .environment(ReviewPromptStore())
    }
}
