//
//  SessionBuilderView.swift
//  Connections
//

import SwiftUI

struct SessionBuilderView: View {
    @Environment(SessionManager.self) private var session
    @Environment(SettingsStore.self) private var settings
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Stage

    private enum SetupStage: Int, Comparable {
        case mode, intensity, details
        static func < (lhs: SetupStage, rhs: SetupStage) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    private enum BuilderRoute: Hashable, Identifiable {
        case session
        case fallInLove
        case fallInLoveIntro
        case share
        case favorites
        case lifeStory
        case lifeStoryIntro
        case settings

        var id: Self { self }
    }

    @State private var currentStage: SetupStage = .mode
    @Namespace private var cardNamespace

    // MARK: - Detail State

    @State private var selectedLength: SessionLength = .medium
    @State private var selectedTopic: Topic? = nil
    @State private var followUps: Bool = true
    @State private var didApplyDefaults = false
    @State private var hasCustomizedLength = false
    @State private var hasCustomizedTopic = false
    @State private var hasCustomizedFollowUps = false

    // MARK: - Navigation

    @State private var route: BuilderRoute?

    // MARK: - Alerts

    @State private var paywallVariant: PaywallVariant? = nil

    // MARK: - Animation

    private let stageSpring = Animation.spring(response: 0.42, dampingFraction: 0.86)

    // MARK: - Computed

    private var availableTopics: [Topic] {
        guard let mode = session.selectedMode, let intensity = session.selectedIntensity else {
            return Topic.allCases.map { $0 }
        }
        return PromptBank.shared.availableTopics(for: mode, intensity: intensity)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: session.selectedIntensity)
                .animation(.easeInOut(duration: 0.5), value: session.selectedIntensity)

            VStack(spacing: 0) {
                headerSection
                summarySection

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        stageContent

                        if currentStage == .details {
                            Spacer().frame(height: 188)
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if currentStage == .details {
                        startButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .animation(stageSpring, value: currentStage)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    switch currentStage {
                    case .mode:
                        dismiss()
                    case .intensity:
                        withAnimation(stageSpring) {
                            currentStage = .mode
                            session.selectedMode = nil
                            session.selectedIntensity = nil
                        }
                    case .details:
                        withAnimation(stageSpring) {
                            currentStage = .intensity
                            session.selectedIntensity = nil
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(String(localized: "common.button.back", defaultValue: "Back"))
                .padding(.leading, 4)
            }

            if currentStage == .mode {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        route = .settings
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel(String(localized: "common.label.settings", defaultValue: "Settings"))
                }
            }
        }
        .navigationDestination(item: $route) { route in
            switch route {
            case .session:
                SessionPlayView()
            case .fallInLove:
                FallInLovePlayView()
            case .fallInLoveIntro:
                FallInLoveIntroView()
            case .share:
                ShareExperiencePlayView()
            case .favorites:
                FavoritesPlayView()
            case .lifeStory:
                LifeStoryPlayView()
            case .lifeStoryIntro:
                LifeStoryIntroView()
            case .settings:
                SettingsView()
            }
        }
        .sheet(item: $paywallVariant) { variant in
            PremiumPaywallView(variant: variant)
        }
        .onAppear {
            if !didApplyDefaults {
                let loaded = settings.defaultSessionLength
                selectedLength = (loaded == .long && !entitlements.canUseLongSessions) ? .medium : loaded
                followUps = settings.followUpsByDefault
                didApplyDefaults = true
                resetBuilderState()
            }
        }
        .onChange(of: session.selectedMode) { _, _ in selectedTopic = nil }
        .onChange(of: session.selectedIntensity) { _, _ in selectedTopic = nil }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(headerTitle)
                .font(AppFont.promptText())
                .contentTransition(.interpolate)
                .id(headerTitle)

            if !headerSubtitle.isEmpty {
                Text(headerSubtitle)
                    .font(AppFont.caption())
                    .foregroundStyle(.secondary)
                    .contentTransition(.interpolate)
                    .id(headerSubtitle)
            }
        }
        .padding(.top, 44)
        .padding(.bottom, summarySectionVisible ? 16 : 32)
    }

    private var headerTitle: String {
        switch currentStage {
        case .mode: return String(localized: "modeSelection.header.title", defaultValue: "Choose a mode")
        case .intensity: return String(localized: "intensitySelection.header.title", defaultValue: "Set the tone")
        case .details: return String(localized: "sessionBuilder.header.details", defaultValue: "Your session")
        }
    }

    private var headerSubtitle: String {
        switch currentStage {
        case .mode: return String(localized: "modeSelection.header.subtitle", defaultValue: "Who is this session for?")
        case .intensity: return String(localized: "intensitySelection.header.subtitle", defaultValue: "How deep do you want to go?")
        case .details: return ""
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        if summarySectionVisible {
            VStack(spacing: 8) {
                if let mode = session.selectedMode, currentStage != .mode {
                    SummaryRow(
                        icon: mode.iconName,
                        title: mode.localizedTitle,
                        subtitle: mode.localizedDescription
                    ) {
                        withAnimation(stageSpring) {
                            currentStage = .mode
                            session.selectedMode = nil
                            session.selectedIntensity = nil
                            selectedTopic = nil
                        }
                    }
                    .matchedGeometryEffect(id: "mode-\(mode.rawValue)", in: cardNamespace)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.94).combined(with: .opacity),
                        removal: .scale(scale: 0.98).combined(with: .opacity)
                    ))
                }

                if let intensity = session.selectedIntensity, currentStage == .details {
                    SummaryRow(
                        icon: nil,
                        title: intensity.localizedTitle,
                        subtitle: intensity.localizedDescription,
                        tintColor: intensity.toneColor
                    ) {
                        withAnimation(stageSpring) {
                            currentStage = .intensity
                            session.selectedIntensity = nil
                            selectedTopic = nil
                        }
                    }
                    .matchedGeometryEffect(id: "intensity-\(intensity.rawValue)", in: cardNamespace)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.94).combined(with: .opacity),
                        removal: .scale(scale: 0.98).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var stageContent: some View {
        switch currentStage {
        case .mode:
            modeSection
        case .intensity:
            intensitySection
        case .details:
            detailsSection
        }
    }

    private var summarySectionVisible: Bool {
        currentStage != .mode
    }

    // MARK: - Mode Section

    @ViewBuilder
    private var modeSection: some View {
        VStack(spacing: AppSpacing.cardSpacing) {
            if currentStage == .mode {
                ForEach(Mode.allCases) { mode in
                    SelectionCard(title: mode.localizedTitle, subtitle: mode.localizedDescription) {
                        session.selectedMode = mode
                        hasCustomizedLength = false
                        hasCustomizedTopic = false
                        hasCustomizedFollowUps = false
                        HapticsManager.lightImpact()
                        withAnimation(stageSpring) {
                            currentStage = .intensity
                        }
                    }
                    .matchedGeometryEffect(id: "mode-\(mode.rawValue)", in: cardNamespace)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .accessibilityIdentifier("mode.\(mode.rawValue)")
                }

                SelectionCard(
                    title: String(localized: "modeSelection.share.title", defaultValue: "Share"),
                    subtitle: String(localized: "modeSelection.share.subtitle", defaultValue: "Take turns sharing real experiences")
                ) {
                    if entitlements.canUseShareExperience {
                        route = .share
                    } else {
                        paywallVariant = .general
                    }
                }
                .transition(.opacity)
                .accessibilityIdentifier("mode.ShareExperiences")

                SelectionCard(
                    title: String(localized: "sessionBuilder.lifeStory.title", defaultValue: "Life Story"),
                    subtitle: String(localized: "sessionBuilder.lifeStory.subtitle", defaultValue: "A guided conversation across a lifetime")
                ) {
                    if entitlements.canUseLifeStory {
                        if settings.skipLifeStoryIntro {
                            route = .lifeStory
                        } else {
                            route = .lifeStoryIntro
                        }
                    } else {
                        paywallVariant = .lifeStory
                    }
                }
                .transition(.opacity)
                .accessibilityIdentifier("mode.LifeStory")

                if !session.favorites.allFavorites.isEmpty {
                    SelectionCard(
                        title: String(localized: "sessionBuilder.favorites.title", defaultValue: "Play Favorites"),
                        subtitle: session.favorites.allFavorites.count == 1
                            ? String(localized: "sessionBuilder.favorites.subtitle.one", defaultValue: "1 saved prompt from past sessions")
                            : String(format: String(localized: "sessionBuilder.favorites.subtitle.other", defaultValue: "%1$lld saved prompts from past sessions"), session.favorites.allFavorites.count)
                    ) {
                        route = .favorites
                    }
                    .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .id(SetupStage.mode)
    }

    // MARK: - Intensity Section

    @ViewBuilder
    private var intensitySection: some View {
        VStack(spacing: AppSpacing.cardSpacing) {
            ForEach(Intensity.concrete) { intensity in
                SelectionCard(
                    title: intensity.localizedTitle,
                    subtitle: intensity.localizedDescription,
                    tintColor: intensity.toneColor,
                    isSelected: session.selectedIntensity == intensity,
                    glassEffect: true
                ) {
                    if intensity == .unfiltered && !entitlements.canUseUnfiltered {
                        paywallVariant = .general
                        return
                    }
                    session.selectedIntensity = intensity
                    hasCustomizedLength = false
                    hasCustomizedTopic = false
                    hasCustomizedFollowUps = false
                    applyRecommendedDetails()
                    HapticsManager.lightImpact()
                    withAnimation(stageSpring) {
                        currentStage = .details
                    }
                }
                .matchedGeometryEffect(id: "intensity-\(intensity.rawValue)", in: cardNamespace)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .accessibilityIdentifier("intensity.\(intensity.rawValue)")
            }

            SelectionCard(
                title: Intensity.mixed.localizedTitle,
                subtitle: Intensity.mixed.localizedDescription,
                tintColor: Intensity.mixed.toneColor,
                isSelected: session.selectedIntensity == .mixed,
                glassEffect: true
            ) {
                session.selectedIntensity = .mixed
                hasCustomizedLength = false
                hasCustomizedTopic = false
                hasCustomizedFollowUps = false
                applyRecommendedDetails()
                HapticsManager.lightImpact()
                withAnimation(stageSpring) {
                    currentStage = .details
                }
            }
            .matchedGeometryEffect(id: "intensity-Mixed", in: cardNamespace)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
            .accessibilityIdentifier("intensity.Mixed")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .transition(.asymmetric(
            insertion: .offset(y: 20).combined(with: .opacity),
            removal: .opacity
        ))
        .id(SetupStage.intensity)
    }

    // MARK: - Details Section

    @ViewBuilder
    private var detailsSection: some View {
        if currentStage == .details {
            VStack(spacing: 0) {
                compositionBlock
                refinementsSection
            }
            .padding(.top, 4)
            .transition(.asymmetric(
                insertion: .offset(y: 16).combined(with: .opacity),
                removal: .opacity
            ))
            .id(SetupStage.details)
        }
    }

    // MARK: - Composition Block

    private var compositionBlock: some View {
        VStack(spacing: 10) {
            VStack(spacing: 4) {
                if selectedTopic == .fallInLove {
                    Text(String(localized: "sessionBuilder.composition.guidedSession", defaultValue: "Guided session"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text(String(localized: "sessionBuilder.composition.fallInLoveCount", defaultValue: "36 questions"))
                        .font(.system(.title3, design: .serif, weight: .medium))

                    Text(String(localized: "sessionBuilder.composition.fallInLoveSubtitle", defaultValue: "designed to build closeness"))
                        .font(AppFont.detail())
                        .foregroundStyle(.secondary)
                } else {
                    Text(selectedLength.localizedLabel)
                        .contentTransition(.interpolate)
                        .font(.system(.title3, design: .serif, weight: .medium))

                    Text(compositionSubline)
                        .font(AppFont.detail())
                        .foregroundStyle(.secondary)
                        .contentTransition(.interpolate)
                        .id(compositionSubline)
                }
            }
            .multilineTextAlignment(.center)

            if selectedTopic != .fallInLove {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 8) {
                        ForEach(SessionLength.allCases) { length in
                            Button {
                                if length == .long && !entitlements.canUseLongSessions {
                                    paywallVariant = .general
                                    return
                                }
                                selectedLength = length
                                hasCustomizedLength = true
                            } label: {
                                Text("\(length.rawValue)")
                                    .font(AppFont.caption())
                                    .fontWeight(selectedLength == length ? .semibold : .regular)
                                    .foregroundStyle(selectedLength == length ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(selectedLength == length
                                                ? AppColor.primaryButtonBg(colorScheme)
                                                : AppColor.surface(colorScheme))
                                    )
                            }
                            .buttonStyle(.plain)
                            .animation(.easeOut(duration: 0.15), value: selectedLength)
                            .accessibilityLabel(length.localizedLabel)
                            .accessibilityAddTraits(selectedLength == length ? .isSelected : [])
                            .accessibilityIdentifier("sessionLength.\(length.rawValue)")
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        ForEach(SessionLength.allCases) { length in
                            Button {
                                if length == .long && !entitlements.canUseLongSessions {
                                    paywallVariant = .general
                                    return
                                }
                                selectedLength = length
                                hasCustomizedLength = true
                            } label: {
                                VStack(spacing: 3) {
                                    Text("\(length.rawValue)")
                                        .font(AppFont.caption())
                                        .fontWeight(selectedLength == length ? .semibold : .regular)
                                        .foregroundStyle(selectedLength == length ? .white : .primary)
                                }
                                .frame(width: 52, height: 36)
                                .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(selectedLength == length
                                                ? AppColor.primaryButtonBg(colorScheme)
                                                : AppColor.surface(colorScheme))
                                    )
                            }
                            .buttonStyle(.plain)
                            .animation(.easeOut(duration: 0.15), value: selectedLength)
                            .accessibilityLabel(length.localizedLabel)
                            .accessibilityAddTraits(selectedLength == length ? .isSelected : [])
                            .accessibilityIdentifier("sessionLength.\(length.rawValue)")
                        }
                    }
                }
            } else {
                Text(String(localized: "sessionBuilder.composition.fallInLoveProgress", defaultValue: "Your progress is saved between sessions"))
                    .font(AppFont.detail())
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(compositionFill)
        )
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .animation(.easeInOut(duration: 0.2), value: selectedLength)
        .animation(.easeInOut(duration: 0.2), value: followUps)
    }

    private var compositionSubline: String {
        var parts: [String] = []
        if let topic = selectedTopic {
            parts.append(topic.localizedDisplayName(for: session.selectedMode))
        } else {
            parts.append(String(localized: "sessionBuilder.composition.allTopics", defaultValue: "All topics"))
        }
        if followUps {
            parts.append(String(localized: "sessionBuilder.composition.followUpsIncluded", defaultValue: "follow-ups included"))
        }
        return parts.joined(separator: " · ")
    }

    private var compositionFill: Color {
        if let intensity = session.selectedIntensity {
            return intensity.toneColor.opacity(colorScheme == .dark ? 0.10 : 0.07)
        }
        return AppColor.surface(colorScheme)
    }

    // MARK: - Refinements

    private var refinementsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                TopicSelector(
                    selectedTopic: $selectedTopic,
                    availableTopics: availableTopics,
                    mode: session.selectedMode,
                    onSelectTopic: { topic in
                        if topic == .sex && !entitlements.canUseSex {
                            paywallVariant = .general
                            return
                        }
                        if topic == .fallInLove && !entitlements.canUseFallInLove {
                            paywallVariant = .general
                            return
                        }
                        selectedTopic = topic
                        hasCustomizedTopic = true
                    }
                )

                if selectedTopic != .fallInLove {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "sessionBuilder.followUps.title", defaultValue: "Follow-up questions"))
                                .font(AppFont.caption())
                                .fontWeight(.medium)

                            Text(String(localized: "sessionBuilder.followUps.subtitle", defaultValue: "Adds gentle prompts to help you go deeper."))
                                .font(AppFont.detail())
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $followUps)
                            .labelsHidden()
                            .tint(AppColor.toggleTint)
                            .onChange(of: followUps) { _, _ in
                                hasCustomizedFollowUps = true
                            }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.surface(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.05), lineWidth: 0.5)
            )
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Start Button

    @ViewBuilder
    private var startButton: some View {
        VStack(spacing: 0) {
            Button {
                HapticsManager.mediumImpact()
                if selectedTopic == .fallInLove {
                    let skip = session.selectedMode == .friends
                        ? settings.skipFallInLoveIntroFriends
                        : settings.skipFallInLoveIntroCouples
                    if skip {
                        route = .fallInLove
                    } else {
                        route = .fallInLoveIntro
                    }
                } else {
                    if selectedLength == .long && !entitlements.canUseLongSessions {
                        paywallVariant = .general
                        return
                    }
                    session.selectedSessionLength = selectedLength
                    session.selectedTopic = selectedTopic
                    session.followUpsEnabled = followUps
                    if session.selectedIntensity == .mixed {
                        session.mixedIntensities = entitlements.mixedIntensities
                    }
                    route = .session
                }
            } label: {
                Text(selectedTopic == .fallInLove
                     ? String(localized: "sessionSetup.button.begin", defaultValue: "Begin")
                     : String(localized: "sessionSetup.button.start", defaultValue: "Start Session"))
                    .font(AppFont.buttonSecondary())
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundStyle(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .accessibilityIdentifier("startSessionButton")
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }

    private func resetBuilderState() {
        currentStage = .mode
        session.selectedMode = nil
        session.selectedIntensity = nil
        session.selectedSessionLength = nil
        session.selectedTopic = nil
        session.followUpsEnabled = settings.followUpsByDefault
        let loaded = settings.defaultSessionLength
        selectedLength = (loaded == .long && !entitlements.canUseLongSessions) ? .medium : loaded
        followUps = settings.followUpsByDefault
        selectedTopic = nil
        hasCustomizedLength = false
        hasCustomizedTopic = false
        hasCustomizedFollowUps = false
    }

    private var recommendedLength: SessionLength {
        guard let mode = session.selectedMode, let intensity = session.selectedIntensity else {
            return settings.defaultSessionLength
        }

        switch (mode, intensity) {
        case (.couples, .light), (.friends, .light), (.family, .light):
            return .medium
        case (.couples, .honest), (.friends, .honest), (.family, .honest):
            return .medium
        case (.soloReflection, .light):
            return .medium
        case (.soloReflection, .honest), (.soloReflection, .unfiltered):
            return .short
        case (_, .mixed):
            return .medium
        case (_, .unfiltered):
            return .short
        }
    }

    private var recommendedFollowUps: Bool {
        guard let mode = session.selectedMode, let intensity = session.selectedIntensity else {
            return settings.followUpsByDefault
        }

        switch (mode, intensity) {
        case (.friends, .light), (.family, .light):
            return false
        case (.soloReflection, .light):
            return false
        case (.soloReflection, .honest), (.soloReflection, .unfiltered):
            return true
        case (_, .mixed):
            return true
        case (_, .honest), (_, .unfiltered), (.couples, .light):
            return true
        }
    }

    private var recommendationNote: String {
        guard let mode = session.selectedMode, let intensity = session.selectedIntensity else {
            return "These defaults are designed to work well."
        }

        switch (mode, intensity) {
        case (.couples, .light):
            return "A steady pace with room to warm up and get closer."
        case (.couples, .honest):
            return "Enough room to open up without it feeling heavy."
        case (.couples, .unfiltered):
            return "Shorter keeps it brave without becoming exhausting."
        case (.couples, .mixed):
            return "Room for the conversation to find its own depth."
        case (.friends, .light):
            return "Low pressure, natural rhythm."
        case (.friends, .honest):
            return "Room to get real without losing ease."
        case (.friends, .unfiltered):
            return "Short and direct works best here."
        case (.friends, .mixed):
            return "A blend of tones — see where it takes you."
        case (.family, .light):
            return "Room for stories to unfold naturally."
        case (.family, .honest):
            return "A little structure, a little patience."
        case (.family, .unfiltered):
            return "Shorter keeps it direct and usable."
        case (.family, .mixed):
            return "A gentle mix with room to go deeper."
        case (.soloReflection, .light):
            return "A gentle stretch of reflection."
        case (.soloReflection, .honest):
            return "Focused, with room to go deeper."
        case (.soloReflection, .unfiltered):
            return "Short and honest. Easier to sit with."
        case (.soloReflection, .mixed):
            return "A varied pace for reflection."
        }
    }

    private func applyRecommendedDetails() {
        if !hasCustomizedLength {
            selectedLength = recommendedLength
        }
        if !hasCustomizedFollowUps {
            followUps = recommendedFollowUps
        }
        if !hasCustomizedTopic {
            selectedTopic = nil
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SessionBuilderView()
            .environment(SessionManager())
            .environment(SettingsStore())
            .environment(EntitlementStore())
    }
}
