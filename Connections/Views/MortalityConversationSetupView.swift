//
//  MortalityConversationSetupView.swift
//  Connections
//

import SwiftUI

struct MortalityConversationSetupView: View {
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(ReviewPromptStore.self) private var reviewPromptStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private struct PlayConfig: Hashable, Identifiable {
        let length: SessionLength
        let topics: Set<MortalityConversationTopic>

        var id: String {
            let topicIDs = topics.map(\.rawValue).sorted().joined(separator: "-")
            return "\(length.rawValue)-\(topicIDs)"
        }
    }

    @State private var selectedLength: SessionLength = .medium
    @State private var selectedTopics: Set<MortalityConversationTopic> = []
    @State private var route: PlayConfig?
    @State private var validationMessage: String?
    @State private var paywallVariant: PaywallVariant?

    private var allTopicsSelected: Bool {
        selectedTopics.count == MortalityConversationTopic.allCases.count
    }

    private var compositionSubline: String {
        if selectedTopics.isEmpty {
            return String(localized: "mortalitySetup.composition.chooseTopics", defaultValue: "Choose one or more topics")
        }
        if allTopicsSelected {
            return String(localized: "mortalitySetup.composition.allTopics", defaultValue: "All topics")
        }
        let format = selectedTopics.count == 1
            ? String(localized: "mortalitySetup.composition.topicCount.one", defaultValue: "1 topic selected")
            : String(localized: "mortalitySetup.composition.topicCount.other", defaultValue: "%1$lld topics selected")
        return String(format: format, selectedTopics.count)
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        compositionBlock
                        topicSection
                        Spacer().frame(height: 188)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    startButton
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(String(localized: "common.button.back", defaultValue: "Back"))
                .padding(.leading, 4)
            }
        }
        .navigationDestination(item: $route) { config in
            MortalityConversationPlayView(length: config.length, topics: config.topics)
        }
        .alert(
            String(localized: "mortalitySetup.alert.title", defaultValue: "Choose topics"),
            isPresented: Binding(
                get: { validationMessage != nil },
                set: { if !$0 { validationMessage = nil } }
            )
        ) {
            Button(String(localized: "common.button.ok", defaultValue: "OK"), role: .cancel) { }
        } message: {
            Text(validationMessage ?? "")
        }
        .sheet(item: $paywallVariant) { variant in
            PremiumPaywallView(variant: variant)
                .environment(entitlements)
                .environment(reviewPromptStore)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(String(localized: "sessionBuilder.mortality.title", defaultValue: "Mortality Conversations"))
                .font(AppFont.promptText())

            Text(String(localized: "sessionBuilder.mortality.subtitle", defaultValue: "Talk honestly about death, grief, and what matters"))
                .font(AppFont.caption())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppSpacing.promptHorizontal)
        .padding(.top, 44)
        .padding(.bottom, 20)
    }

    private var compositionBlock: some View {
        VStack(spacing: 10) {
            VStack(spacing: 4) {
                Text(selectedLength.localizedLabel)
                    .font(.system(.title3, design: .serif, weight: .medium))
                    .contentTransition(.interpolate)

                Text(compositionSubline)
                    .font(AppFont.detail())
                    .foregroundStyle(.secondary)
                    .contentTransition(.interpolate)
                    .id(compositionSubline)
            }
            .multilineTextAlignment(.center)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 8) {
                    ForEach(SessionLength.allCases) { length in
                        lengthButton(length, fillsWidth: true)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(SessionLength.allCases) { length in
                        lengthButton(length, fillsWidth: false)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Intensity.honest.toneColor.opacity(colorScheme == .dark ? 0.10 : 0.07))
        )
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .animation(.easeInOut(duration: 0.2), value: selectedLength)
        .animation(.easeInOut(duration: 0.2), value: selectedTopics)
    }

    private func lengthButton(_ length: SessionLength, fillsWidth: Bool) -> some View {
        Button {
            if length == .long && !entitlements.canUseLongSessions {
                paywallVariant = .general
                return
            }
            selectedLength = length
        } label: {
            Text("\(length.rawValue)")
                .font(AppFont.caption())
                .fontWeight(selectedLength == length ? .semibold : .regular)
                .foregroundStyle(selectedLength == length ? .white : .primary)
                .frame(width: fillsWidth ? nil : 52, height: fillsWidth ? nil : 36)
                .frame(maxWidth: fillsWidth ? .infinity : nil)
                .padding(.vertical, fillsWidth ? 10 : 2)
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
        .accessibilityIdentifier("mortalitySessionLength.\(length.rawValue)")
    }

    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            FlowLayout(spacing: 8) {
                TopicChip(
                    label: String(localized: "sessionSetup.topic.allTopics", defaultValue: "All Topics"),
                    state: allTopicsSelected ? .selected : .available
                ) {
                    if allTopicsSelected {
                        selectedTopics = []
                    } else {
                        selectedTopics = Set(MortalityConversationTopic.allCases)
                    }
                }

                ForEach(MortalityConversationTopic.allCases) { topic in
                    TopicChip(
                        label: topic.localizedTitle,
                        state: selectedTopics.contains(topic) ? .selected : .available
                    ) {
                        if selectedTopics.contains(topic) {
                            selectedTopics.remove(topic)
                        } else {
                            selectedTopics.insert(topic)
                        }
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
        .padding(.top, 16)
    }

    private var startButton: some View {
        Button {
            HapticsManager.mediumImpact()
            guard !selectedTopics.isEmpty else {
                validationMessage = String(
                    localized: "mortalitySetup.validation.noTopics",
                    defaultValue: "Select one or more topics before starting your session."
                )
                return
            }
            guard selectedLength != .long || selectedTopics.count >= 2 else {
                validationMessage = String(
                    localized: "mortalitySetup.validation.longNeedsTwoTopics",
                    defaultValue: "For 20 prompts, choose at least two topics so the session has enough variety."
                )
                return
            }
            route = PlayConfig(length: selectedLength, topics: selectedTopics)
        } label: {
            Text(String(localized: "sessionSetup.button.start", defaultValue: "Start Session"))
                .font(AppFont.buttonSecondary())
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.white)
                .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
        }
        .accessibilityIdentifier("startMortalitySessionButton")
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        MortalityConversationSetupView()
            .environment(EntitlementStore())
            .environment(ReviewPromptStore())
    }
}
