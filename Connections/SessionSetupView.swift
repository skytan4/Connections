//
//  SessionSetupView.swift
//  Connections
//

import SwiftUI

struct SessionSetupView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss

    private var availableTopics: [Topic] {
        guard let mode = session.selectedMode, let intensity = session.selectedIntensity else {
            return Topic.allCases.map { $0 }
        }
        return PromptBank.shared.availableTopics(for: mode, intensity: intensity)
    }

    @State private var selectedLength: SessionLength = .medium
    @State private var selectedTopic: Topic? = nil
    @State private var followUps: Bool = true
    @State private var navigateToSession = false
    @State private var showAgeConfirmation = false
    @State private var ageConfirmed = false

    var body: some View {
        @Bindable var session = session

        VStack(spacing: 0) {

            // MARK: - Header

            VStack(spacing: 8) {
                Text("Set up your session")
                    .font(.system(size: 28, weight: .regular, design: .serif))

                if let mode = session.selectedMode, let intensity = session.selectedIntensity {
                    Text("\(mode.rawValue) · \(intensity.rawValue)")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 48)
            .padding(.bottom, 36)

            // MARK: - Session Length

            VStack(alignment: .leading, spacing: 14) {
                Text("Session length")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                HStack(spacing: 10) {
                    ForEach(SessionLength.allCases) { length in
                        LengthOption(
                            label: "\(length.rawValue)",
                            isSelected: selectedLength == length
                        ) {
                            selectedLength = length
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // MARK: - Topic

            VStack(alignment: .leading, spacing: 14) {
                Text("Topic")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                TopicSelector(
                    selectedTopic: $selectedTopic,
                    availableTopics: availableTopics,
                    onSelectTopic: { topic in
                        if topic == .sex && !ageConfirmed {
                            showAgeConfirmation = true
                            return
                        }
                        selectedTopic = topic
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            // MARK: - Follow-Ups Toggle

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Follow-up prompts")
                        .font(.system(size: 16, weight: .medium))

                    Text("Adds optional prompts to go deeper during the session")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $followUps)
                    .labelsHidden()
                    .tint(Color(red: 0.45, green: 0.42, blue: 0.38))
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)

            Spacer()

            // MARK: - Start Button

            Button {
                session.selectedSessionLength = selectedLength
                session.selectedTopic = selectedTopic
                session.followUpsEnabled = followUps
                session.startSession()
                navigateToSession = true
            } label: {
                Text("Start Session")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundColor(.white)
                    .background(Color(.darkGray), in: .capsule)
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 52)
        }
        .background((session.selectedIntensity?.backgroundTint ?? Color.clear).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSession) {
            SessionPlayView()
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
                .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Length Option

private struct LengthOption: View {
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
                        .fill(isSelected ? Color(.darkGray) : Color.primary.opacity(0.04))
                )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Topic Selector

private struct TopicSelector: View {
    @Binding var selectedTopic: Topic?
    let availableTopics: [Topic]
    var onSelectTopic: ((Topic) -> Void)? = nil

    /// All topics, with free ones that have prompts first, then locked ones.
    private var allDisplayTopics: [Topic] {
        let available = Set(availableTopics)
        let free = Topic.allCases.filter { $0.isFree && available.contains($0) }
        let locked = Topic.allCases.filter { !$0.isFree || !available.contains($0) }
        return free + locked
    }

    private var hasLockedTopics: Bool {
        allDisplayTopics.contains { !$0.isFree || !Set(availableTopics).contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            FlowLayout(spacing: 8) {
                TopicChip(label: "All Topics", state: selectedTopic == nil ? .selected : .available) {
                    selectedTopic = nil
                }

                ForEach(allDisplayTopics) { topic in
                    let isAvailable = topic.isFree && Set(availableTopics).contains(topic)
                    let state: TopicChipState = !isAvailable ? .locked
                        : selectedTopic == topic ? .selected
                        : .available

                    TopicChip(label: topic.displayName, state: state) {
                        if isAvailable {
                            if let onSelectTopic {
                                onSelectTopic(topic)
                            } else {
                                selectedTopic = topic
                            }
                        }
                    }
                }
            }

            if hasLockedTopics {
                Text("More topics available in Full Version")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 4)
                    .padding(.top, 2)
            }
        }
    }
}

// MARK: - Topic Chip

private enum TopicChipState {
    case selected, available, locked
}

private struct TopicChip: View {
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
        case .selected: return Color(.darkGray)
        case .available: return Color.primary.opacity(0.04)
        case .locked: return Color.primary.opacity(0.02)
        }
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
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
    }
}
