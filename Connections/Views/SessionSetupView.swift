//
//  SessionSetupView.swift
//  Connections
//

import SwiftUI

struct SessionSetupView: View {
    @Environment(SessionManager.self) private var session
    @Environment(SettingsStore.self) private var settings
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var availableTopics: [Topic] {
        guard let mode = session.selectedMode, let intensity = session.selectedIntensity else {
            return Topic.allCases.map { $0 }
        }
        return PromptBank.shared.availableTopics(for: mode, intensity: intensity)
    }

    private enum SetupRoute: Hashable, Identifiable {
        case session
        case fallInLove
        case fallInLoveIntro

        var id: Self { self }
    }

    @State private var selectedLength: SessionLength = .medium
    @State private var selectedTopic: Topic? = nil
    @State private var followUps: Bool = true
    @State private var didApplyDefaults = false
    @State private var route: SetupRoute?
    @State private var showAgeConfirmation = false
    @State private var ageConfirmed = false
    @State private var paywallVariant: PaywallVariant? = nil

    var body: some View {
        @Bindable var session = session

        ZStack {
            AtmosphericBackground(intensity: session.selectedIntensity)

        VStack(spacing: 0) {

            // MARK: - Header

            VStack(spacing: 8) {
                Text(String(localized: "sessionSetup.header.title", defaultValue: "Set up your session"))
                    .font(.system(size: 28, weight: .regular, design: .serif))

                if let mode = session.selectedMode, let intensity = session.selectedIntensity {
                    Text(String(format: String(localized: "sessionSetup.header.subtitle", defaultValue: "%1$@ · %2$@"), mode.localizedTitle, intensity.localizedTitle))
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 48)
            .padding(.bottom, 36)

            // MARK: - Session Length

            if selectedTopic != .fallInLove {
                VStack(alignment: .leading, spacing: 14) {
                    Text(String(localized: "sessionSetup.questionCount.label", defaultValue: "Question count"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)

                    HStack(spacing: 10) {
                        ForEach(SessionLength.allCases) { length in
                            LengthOption(
                                label: "\(length.rawValue)",
                                isSelected: selectedLength == length
                            ) {
                                if length == .long && !entitlements.canUseLongSessions {
                                    paywallVariant = .general
                                    return
                                }
                                selectedLength = length
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // MARK: - Topic

            VStack(alignment: .leading, spacing: 14) {
                Text(String(localized: "sessionSetup.topic.label", defaultValue: "Topic"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

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
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            // MARK: - Follow-Ups Toggle

            if selectedTopic != .fallInLove {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(String(localized: "sessionSetup.followUps.title", defaultValue: "Follow-up prompts"))
                            .font(.system(size: 16, weight: .medium))

                        Text(String(localized: "sessionSetup.followUps.subtitle", defaultValue: "Adds optional prompts to go deeper during the session"))
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: $followUps)
                        .labelsHidden()
                        .tint(AppColor.toggleTint)
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)
            } else {
                // Fall in Love description
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "sessionSetup.fallInLove.title", defaultValue: "36 questions designed to build closeness"))
                        .font(.system(size: 15, weight: .medium))

                    Text(String(localized: "sessionSetup.fallInLove.body", defaultValue: "Questions progress from casual to deeply personal. Your progress is saved so you can pause and return anytime."))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)
            }

            Spacer()

            // MARK: - Start Button

            Button {
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
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundColor(.white)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 52)
        }
        } // ZStack
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $route) { route in
            switch route {
            case .session:
                SessionPlayView()
            case .fallInLove:
                FallInLovePlayView()
            case .fallInLoveIntro:
                FallInLoveIntroView()
            }
        }
        .alert(String(localized: "sessionSetup.ageAlert.title", defaultValue: "Age Confirmation"), isPresented: $showAgeConfirmation) {
            Button(String(localized: "sessionSetup.ageAlert.confirm", defaultValue: "I'm 18 or older")) {
                ageConfirmed = true
                selectedTopic = .sex
            }
            Button(String(localized: "common.button.cancel", defaultValue: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "sessionSetup.ageAlert.message", defaultValue: "Sex prompts contain mature content. Please confirm you are 18 years or older to continue."))
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
            }
        }
        .onChange(of: session.selectedMode) { _, _ in selectedTopic = nil }
        .onChange(of: session.selectedIntensity) { _, _ in selectedTopic = nil }
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
    }
}

// MARK: - Length Option

struct LengthOption: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? AppColor.primaryButtonBg(colorScheme) : AppColor.surface(colorScheme))
                )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Topic Selector

struct TopicSelector: View {
    @Binding var selectedTopic: Topic?
    let availableTopics: [Topic]
    var mode: Mode? = nil
    var onSelectTopic: ((Topic) -> Void)? = nil

    var body: some View {
        FlowLayout(spacing: 8) {
            TopicChip(label: String(localized: "sessionSetup.topic.allTopics", defaultValue: "All Topics"), state: selectedTopic == nil ? .selected : .available) {
                selectedTopic = nil
            }

            ForEach(availableTopics) { topic in
                let state: TopicChipState = selectedTopic == topic ? .selected : .available

                TopicChip(label: topic.localizedDisplayName(for: mode), state: state) {
                    if let onSelectTopic {
                        onSelectTopic(topic)
                    } else {
                        selectedTopic = topic
                    }
                }
            }
        }
    }
}

// MARK: - Topic Chip

enum TopicChipState {
    case selected, available, locked
}

struct TopicChip: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: String
    let state: TopicChipState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                if state == .locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                }
            }
            .font(.system(size: 13, weight: state == .selected ? .semibold : .regular))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
        }
        .buttonStyle(.plain)
        .disabled(state == .locked)
        .animation(.easeOut(duration: 0.15), value: state == .selected)
    }

    private var foregroundColor: Color {
        switch state {
        case .selected: return .white
        case .available: return .primary
        case .locked: return .primary.opacity(0.25)
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .selected: return AppColor.primaryButtonBg(colorScheme)
        case .available: return AppColor.surface(colorScheme)
        case .locked: return AppColor.surfaceSubtle(colorScheme)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.enumerated().reduce(CGFloat.zero) { total, item in
            let (index, row) = item
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            return total + rowHeight + (index > 0 ? spacing : 0)
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            var x = bounds.minX

            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }

            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if !rows[rows.count - 1].isEmpty && currentWidth + spacing + size.width > maxWidth {
                rows.append([])
                currentWidth = 0
            }
            if !rows[rows.count - 1].isEmpty {
                currentWidth += spacing
            }
            rows[rows.count - 1].append(subview)
            currentWidth += size.width
        }

        return rows
    }
}

#Preview {
    NavigationStack {
        SessionSetupView()
            .environment({
                let s = SessionManager()
                s.selectedMode = .couples
                s.selectedIntensity = .honest
                return s
            }())
            .environment(SettingsStore())
            .environment(EntitlementStore())
    }
}
