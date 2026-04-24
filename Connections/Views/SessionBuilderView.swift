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

    // MARK: - Stage

    private enum SetupStage: Int, Comparable {
        case mode, intensity, details
        static func < (lhs: SetupStage, rhs: SetupStage) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
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

    @State private var navigateToSession = false
    @State private var navigateToFallInLove = false
    @State private var navigateToFallInLoveIntro = false
    @State private var navigateToShare = false
    @State private var navigateToFavorites = false
    @State private var navigateToLifeStory = false
    @State private var navigateToLifeStoryIntro = false
    @State private var navigateToSettings = false

    // MARK: - Alerts

    @State private var showAgeConfirmation = false
    @State private var ageConfirmed = false
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
                .padding(.leading, 4)
            }

            if currentStage == .mode {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        navigateToSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToSession) {
            SessionPlayView()
        }
        .navigationDestination(isPresented: $navigateToFallInLove) {
            FallInLovePlayView()
        }
        .navigationDestination(isPresented: $navigateToFallInLoveIntro) {
            FallInLoveIntroView()
        }
        .navigationDestination(isPresented: $navigateToShare) {
            ShareExperiencePlayView()
        }
        .navigationDestination(isPresented: $navigateToFavorites) {
            FavoritesPlayView()
        }
        .navigationDestination(isPresented: $navigateToLifeStory) {
            LifeStoryPlayView()
        }
        .navigationDestination(isPresented: $navigateToLifeStoryIntro) {
            LifeStoryIntroView()
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView()
        }
        .alert("Age Confirmation", isPresented: $showAgeConfirmation) {
            Button("I'm 18 or older") {
                ageConfirmed = true
                selectedTopic = .sex
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Sex prompts contain mature content. Please confirm you are 18 years or older to continue.")
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
                .font(.system(size: 28, weight: .regular, design: .serif))
                .contentTransition(.interpolate)
                .id(headerTitle)

            if !headerSubtitle.isEmpty {
                Text(headerSubtitle)
                    .font(.system(size: 15))
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
        case .mode: return "Choose a mode"
        case .intensity: return "Set the tone"
        case .details: return "Your session"
        }
    }

    private var headerSubtitle: String {
        switch currentStage {
        case .mode: return "Who is this session for?"
        case .intensity: return "How deep do you want to go?"
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
                        title: mode.rawValue,
                        subtitle: mode.description
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
                        title: intensity.rawValue,
                        subtitle: intensity.description,
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
                    SelectionCard(title: mode.rawValue, subtitle: mode.description) {
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
                }

                SelectionCard(title: "Share", subtitle: "Take turns sharing real experiences") {
                    if entitlements.canUseShareExperience {
                        navigateToShare = true
                    } else {
                        paywallVariant = .general
                    }
                }
                .transition(.opacity)

                SelectionCard(title: "Life Story", subtitle: "A guided conversation across a lifetime") {
                    if entitlements.canUseLifeStory {
                        if settings.skipLifeStoryIntro {
                            navigateToLifeStory = true
                        } else {
                            navigateToLifeStoryIntro = true
                        }
                    } else {
                        paywallVariant = .lifeStory
                    }
                }
                .transition(.opacity)

                if !session.favorites.allFavorites.isEmpty {
                    SelectionCard(
                        title: "Play Favorites",
                        subtitle: "\(session.favorites.allFavorites.count) saved prompts from past sessions"
                    ) {
                        navigateToFavorites = true
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
            ForEach(Intensity.allCases) { intensity in
                SelectionCard(
                    title: intensity.rawValue,
                    subtitle: intensity.description,
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
            }
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
                    Text("Guided session")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text("36 questions")
                        .font(.system(size: 20, weight: .medium, design: .serif))

                    Text("designed to build closeness")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 0) {
                        Text("\(selectedLength.rawValue)")
                            .contentTransition(.numericText())
                        Text(" prompts")
                    }
                    .font(.system(size: 20, weight: .medium, design: .serif))

                    Text(compositionSubline)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .contentTransition(.interpolate)
                        .id(compositionSubline)
                }
            }
            .multilineTextAlignment(.center)

            if selectedTopic != .fallInLove {
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
                                    .font(.system(size: 15, weight: selectedLength == length ? .semibold : .regular))
                                    .foregroundStyle(selectedLength == length ? .white : .primary)

                                if recommendedLength == length {
                                    Circle()
                                        .fill(selectedLength == length ? Color.white.opacity(0.7) : Color.secondary.opacity(0.35))
                                        .frame(width: 4, height: 4)
                                }
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
                    }
                }
            } else {
                Text("Your progress is saved between sessions")
                    .font(.system(size: 13))
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
            parts.append(topic.displayName(for: session.selectedMode))
        } else {
            parts.append("All topics")
        }
        if followUps {
            parts.append("follow-ups included")
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
                        if topic == .sex && !ageConfirmed {
                            showAgeConfirmation = true
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
                            Text("Follow-up questions")
                                .font(.system(size: 15, weight: .medium))

                            Text("Adds gentle prompts to help you go deeper.")
                                .font(.system(size: 13))
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
                        navigateToFallInLove = true
                    } else {
                        navigateToFallInLoveIntro = true
                    }
                } else {
                    if selectedLength == .long && !entitlements.canUseLongSessions {
                        paywallVariant = .general
                        return
                    }
                    session.selectedSessionLength = selectedLength
                    session.selectedTopic = selectedTopic
                    session.followUpsEnabled = followUps
                    session.startSession()
                    navigateToSession = true
                }
            } label: {
                Text(selectedTopic == .fallInLove ? "Begin" : "Start Session")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundStyle(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
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
        ageConfirmed = false
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
        case (.friends, .light):
            return "Low pressure, natural rhythm."
        case (.friends, .honest):
            return "Room to get real without losing ease."
        case (.friends, .unfiltered):
            return "Short and direct works best here."
        case (.family, .light):
            return "Room for stories to unfold naturally."
        case (.family, .honest):
            return "A little structure, a little patience."
        case (.family, .unfiltered):
            return "Shorter keeps it direct and usable."
        case (.soloReflection, .light):
            return "A gentle stretch of reflection."
        case (.soloReflection, .honest):
            return "Focused, with room to go deeper."
        case (.soloReflection, .unfiltered):
            return "Short and honest. Easier to sit with."
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
