//
//  SettingsView.swift
//  Connections
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showInstructions = false
    @State private var showPurpose = false
    @State private var showWhyThisMatters = false
    @State private var showResetConfirmation = false
    @State private var paywallVariant: PaywallVariant? = nil

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            NeutralBackground()

            ScrollView {
                VStack(spacing: 32) {

                    // MARK: - Session

                    SettingsSection(title: "Session") {
                        VStack(spacing: 0) {
                            // Default Session Length
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Default question count")
                                    .font(AppFont.label())

                                HStack(spacing: 10) {
                                    ForEach(SessionLength.allCases) { length in
                                        Button {
                                            if length == .long && !entitlements.canUseLongSessions {
                                                paywallVariant = .general
                                                return
                                            }
                                            settings.defaultSessionLength = length
                                        } label: {
                                            Text("\(length.rawValue)")
                                                .font(.system(size: 15, weight: settings.defaultSessionLength == length ? .semibold : .regular))
                                                .foregroundStyle(settings.defaultSessionLength == length ? .white : .primary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .fill(settings.defaultSessionLength == length ? AppColor.primaryButtonBg(colorScheme) : AppColor.surface(colorScheme))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                            Divider().padding(.leading, 16)

                            // Follow-up Questions
                            SettingsToggleRow(
                                title: "Follow-up questions",
                                subtitle: "Show \"Go Deeper\" prompts during sessions",
                                isOn: $settings.followUpsByDefault
                            )
                        }
                    }

                    // MARK: - Experience

                    SettingsSection(title: "Experience") {
                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                title: "Avoid repeats",
                                subtitle: "Try not to show the same prompt twice in a session",
                                isOn: $settings.avoidRepeats
                            )

                            Divider().padding(.leading, 16)

                            SettingsToggleRow(
                                title: "Haptics",
                                subtitle: "Vibration feedback on interactions",
                                isOn: $settings.hapticsEnabled
                            )
                        }
                    }

                    // MARK: - About

                    SettingsSection(title: "About") {
                        VStack(spacing: 0) {
                            SettingsNavRow(title: "Instructions") {
                                showInstructions = true
                            }

                            Divider().padding(.leading, 16)

                            SettingsNavRow(title: "Purpose") {
                                showPurpose = true
                            }

                            Divider().padding(.leading, 16)

                            SettingsNavRow(title: "Why this matters") {
                                showWhyThisMatters = true
                            }
                        }
                    }

                    // MARK: - Reset

                    SettingsSection(title: "Reset") {
                        Button {
                            showResetConfirmation = true
                        } label: {
                            HStack {
                                Text("Reset to Defaults")
                                    .font(AppFont.label())
                                    .foregroundStyle(.red)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    #if DEBUG
                    // MARK: - Debug

                    SettingsSection(title: "Debug") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Premium Override")
                                .font(AppFont.label())

                            Picker("Premium Override", selection: Binding(
                                get: { entitlements.debugOverride },
                                set: { entitlements.debugOverride = $0 }
                            )) {
                                ForEach(EntitlementStore.DebugOverride.allCases, id: \.self) { override in
                                    Text(override.rawValue).tag(override)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text(entitlements.isPremium ? "Status: Premium" : "Status: Free")
                                .font(AppFont.detail())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    #endif
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 16)
                .padding(.bottom, AppSpacing.bottomPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(AppFont.label())
            }
        }
        .sheet(isPresented: $showInstructions) {
            InstructionsSheet()
        }
        .sheet(isPresented: $showPurpose) {
            PurposeSheet()
        }
        .sheet(isPresented: $showWhyThisMatters) {
            WhyThisMattersSheet()
        }
        .alert("Reset settings?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                settings.resetToDefaults()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will restore your preferences to their default values.")
        }
        .sheet(item: $paywallVariant) { variant in
            PremiumPaywallView(variant: variant)
        }
    }
}

// MARK: - Section Container

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
                .padding(.leading, 4)

            content
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Toggle Row

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFont.label())

                Text(subtitle)
                    .font(AppFont.fine())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColor.toggleTint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Nav Row

private struct SettingsNavRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppFont.label())

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Instructions Sheet

private struct InstructionsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                NeutralBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How to use the app")
                            .font(AppFont.screenTitle())
                            .padding(.bottom, 4)

                        VStack(alignment: .leading, spacing: 12) {
                            InstructionStep(number: "1", text: "Choose a mode")
                            InstructionStep(number: "2", text: "Choose the tone you want for the conversation")
                            InstructionStep(number: "3", text: "Pick a session length")
                            InstructionStep(number: "4", text: "Read the prompt out loud or reflect on it silently")
                            InstructionStep(number: "5", text: "Use Go Deeper if you want a more specific follow-up")
                            InstructionStep(number: "6", text: "Tap the heart to save favorite prompts for later")
                        }

                        Text("Best experience")
                            .font(AppFont.label())
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("Answer honestly")
                            BulletPoint("Don't rush")
                            BulletPoint("Let silence happen")
                            BulletPoint("Skip anything that doesn't fit")
                            BulletPoint("Revisit favorites when you want a different kind of session")
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 16)
                    .padding(.bottom, AppSpacing.bottomPadding)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(AppFont.label())
                }
            }
        }
    }
}

// MARK: - Purpose Sheet

private struct PurposeSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                NeutralBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Connection through guided conversation")
                            .font(AppFont.screenTitle())
                            .padding(.bottom, 4)

                        Text("This app is designed to help people move beyond surface-level talk and into more meaningful connection. Whether you're using it with a partner, friend, family member, or for solo reflection, the prompts are meant to create honesty, curiosity, and emotional presence.")
                            .font(AppFont.subtitle())
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 16)
                    .padding(.bottom, AppSpacing.bottomPadding)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(AppFont.label())
                }
            }
        }
    }
}

// MARK: - Why This Matters Sheet

private struct WhyThisMattersSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                NeutralBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Why this matters")
                            .font(AppFont.screenTitle())
                            .padding(.bottom, 4)

                        Text("Good relationships shape how we feel, how we handle stress, and how supported we feel in daily life. This app is built around the idea that thoughtful conversation can help people know each other better, respond more honestly, and grow closer over time.")
                            .font(AppFont.subtitle())
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)

                        VStack(alignment: .leading, spacing: 24) {
                            FAQItem(
                                question: "Why does the app focus on meaningful conversation?",
                                answer: "Because closeness usually grows through attention, honesty, and responsiveness. Questions can help people slow down, say what they mean more clearly, and notice what matters."
                            )

                            FAQItem(
                                question: "Why do depth and follow-up matter?",
                                answer: "Surface-level conversation has its place, but depth often comes from staying with something a little longer. Follow-up questions can help people move past the first easy answer and get to what is more true, more specific, or more important."
                            )

                            FAQItem(
                                question: "Can conversations really strengthen relationships?",
                                answer: "Often, yes. Feeling heard, understood, and responded to can strengthen trust and emotional safety. A good conversation does not solve everything, but it can make people feel more known to one another."
                            )

                            FAQItem(
                                question: "Why does relationship quality matter so much?",
                                answer: "Strong relationships are closely tied to wellbeing. They can help people feel less alone, more supported, and more able to handle stress. Over time, social connection is also linked with better health and longer life."
                            )

                            FAQItem(
                                question: "Why does the app sometimes suggest another session?",
                                answer: "Patterns like lingering, favoriting, or going deeper can suggest that something meaningful was opening up. When that happens, another session may be worth continuing while the thread is still alive."
                            )

                            FAQItem(
                                question: "Is this a replacement for therapy or medical care?",
                                answer: "No. This app is for conversation and reflection. It can support connection, but it is not a substitute for therapy, medical care, or crisis support."
                            )
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 16)
                    .padding(.bottom, AppSpacing.bottomPadding)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(AppFont.label())
                }
            }
        }
    }
}

// MARK: - Helpers

private struct FAQItem: View {
    let question: String
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(AppFont.label())

            Text(answer)
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Other Helpers

private struct InstructionStep: View {
    let number: String
    let text: String

    init(number: String, text: String) {
        self.number = number
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            Text(text)
                .font(AppFont.subtitle())
                .foregroundStyle(.primary)
        }
    }
}

private struct BulletPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("·")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.tertiary)

            Text(text)
                .font(AppFont.subtitle())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(SettingsStore())
    }
}
