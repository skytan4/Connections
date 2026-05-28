//
//  MortalityConversationPlayView.swift
//  Connections
//

import SwiftUI

struct MortalityConversationPlayView: View {
    @Environment(SessionManager.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var manager: MortalityConversationSessionManager
    @State private var promptTransitionID = UUID()
    @State private var promptVisible = true
    @State private var showResetConfirmation = false
    @State private var sessionFavoriteIDs: Set<String> = []

    private let length: SessionLength
    private let topics: Set<MortalityConversationTopic>

    private enum ScrollAnchor {
        static let top = "mortalityPromptTop"
        static let bottom = "mortalityPromptBottom"
    }

    init(length: SessionLength, topics: Set<MortalityConversationTopic>) {
        self.length = length
        self.topics = topics
        _manager = State(initialValue: MortalityConversationSessionManager(length: length, topics: topics))
    }

    var body: some View {
        ZStack {
            AtmosphericBackground(intensity: .honest)

            VStack(spacing: 0) {
                topBar

                if !manager.isComplete {
                    SessionProgressBar(
                        progress: manager.progress,
                        depthLabel: currentTopicLabel,
                        positionLabel: String(format: String(localized: "sessionPlay.progress.position", defaultValue: "%1$lld of %2$lld"), min(manager.currentIndex + 1, manager.totalPrompts), manager.totalPrompts),
                        tintColor: Intensity.honest.toneColor.opacity(0.45)
                    )

                    GeometryReader { proxy in
                        ScrollViewReader { scrollProxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 0) {
                                    Color.clear
                                        .frame(height: 1)
                                        .id(ScrollAnchor.top)

                                    Spacer(minLength: 40)

                                    if let prompt = manager.currentPrompt {
                                        promptContent(prompt)
                                    }

                                    Spacer(minLength: 24)

                                    Color.clear
                                        .frame(height: 1)
                                        .id(ScrollAnchor.bottom)
                                }
                                .frame(minHeight: proxy.size.height)
                            }
                            .onChange(of: promptTransitionID) { _, _ in
                                DispatchQueue.main.async {
                                    scrollProxy.scrollTo(ScrollAnchor.top, anchor: .top)
                                }
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        actionButtons
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        completionContent
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                    }
                    .safeAreaInset(edge: .bottom) {
                        completionButtons
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert(String(localized: "mortalityPlay.alert.startOver.title", defaultValue: "Start Over?"), isPresented: $showResetConfirmation) {
            Button(String(localized: "lifeStoryPlay.alert.startOver.confirm", defaultValue: "Reset"), role: .destructive) {
                manager.restart()
                sessionFavoriteIDs = []
                promptTransitionID = UUID()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    promptVisible = true
                }
            }
            Button(String(localized: "common.button.cancel", defaultValue: "Cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "mortalityPlay.alert.startOver.message", defaultValue: "This will start a new random session from the same topics."))
        }
        .animation(.easeInOut(duration: 0.4), value: manager.isComplete)
        .onChange(of: manager.isComplete) { _, complete in
            if complete { HapticsManager.success() }
        }
    }

    private var topBar: some View {
        HStack {
            CloseButton {
                dismiss()
            }

            Spacer()

            TopBarLabel(text: String(localized: "sessionBuilder.mortality.title", defaultValue: "Mortality Conversations"))

            Spacer()

            if let prompt = manager.currentPrompt, !manager.isComplete {
                ShareLink(item: prompt.text) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: AppIcon.navSize, weight: AppIcon.navWeight))
                        .foregroundStyle(.tertiary)
                }
                .accessibilityLabel(String(localized: "sessionPlay.share.accessibilityLabel", defaultValue: "Share this prompt"))
            } else {
                Color.clear.frame(width: AppIcon.navSize, height: AppIcon.navSize)
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.topBarTop)
    }

    private var currentTopicLabel: String {
        manager.currentPrompt?.topic.localizedTitle ?? ""
    }

    private func promptContent(_ prompt: MortalityConversationPrompt) -> some View {
        Text(prompt.text)
            .font(AppFont.promptText())
            .multilineTextAlignment(.center)
            .lineSpacing(8)
            .padding(.horizontal, 28)
            .padding(.vertical, 44)
            .dynamicTypeSize(.xSmall...DynamicTypeSize.accessibility2)
            .id(promptTransitionID)
            .opacity(promptVisible ? 1 : 0)
            .offset(y: promptVisible ? 0 : 12)
            .accessibilityIdentifier("mortalityPromptText")
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {
            Button {
                HapticsManager.lightImpact()
                advanceWithTransition()
            } label: {
                Text(String(localized: "sessionPlay.button.next", defaultValue: "Next"))
                    .font(.system(.title3, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }
            .accessibilityIdentifier("nextMortalityPromptButton")

            HStack {
                if manager.canGoBack {
                    Button {
                        HapticsManager.lightImpact()
                        goBackWithTransition()
                    } label: {
                        Text(String(localized: "common.button.back", defaultValue: "Back"))
                            .font(AppFont.buttonSecondary())
                            .fontWeight(.medium)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if let prompt = manager.currentPrompt {
                    Button {
                        if !session.isMortalityConversationFavorited(prompt) {
                            HapticsManager.lightImpact()
                            sessionFavoriteIDs.insert(prompt.id)
                        } else {
                            sessionFavoriteIDs.remove(prompt.id)
                        }
                        session.toggleMortalityConversationFavorite(prompt)
                    } label: {
                        Image(systemName: session.isMortalityConversationFavorited(prompt) ? "heart.fill" : "heart")
                            .font(.system(size: 25))
                            .foregroundStyle(session.isMortalityConversationFavorited(prompt) ? Color.red : Color.secondary.opacity(0.4))
                            .scaleEffect(session.isMortalityConversationFavorited(prompt) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: session.isMortalityConversationFavorited(prompt))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("favoriteMortalityPromptButton")
                }
            }
            .padding(.top, 14)
        }
        .padding(.horizontal, AppSpacing.contentHorizontal)
        .padding(.bottom, 48)
    }

    private var completionContent: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text(String(localized: "mortalityPlay.complete.title", defaultValue: "You stayed with what matters."))
                    .font(AppFont.promptText())
                    .multilineTextAlignment(.center)

                Text(String(localized: "mortalityPlay.complete.subtitle", defaultValue: "Some conversations deserve room, honesty, and care."))
                    .font(AppFont.caption())
                    .fontDesign(.serif)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.promptHorizontal)

            HStack(spacing: 0) {
                VStack(spacing: 3) {
                    Text("\(manager.totalPrompts)")
                        .font(.system(size: 14, weight: .medium))
                    Text(String(localized: "sessionPlay.stats.prompts", defaultValue: "Prompts"))
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                Text("·")
                    .font(.system(size: 11))
                    .foregroundStyle(.quaternary)
                    .padding(.horizontal, 14)

                VStack(spacing: 3) {
                    Text("\(topics.count)")
                        .font(.system(size: 14, weight: .medium))
                    Text(String(localized: "mortalityPlay.stats.topics", defaultValue: "Topics"))
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            let moments = manager.prompts.filter { sessionFavoriteIDs.contains($0.id) }
            if !moments.isEmpty {
                VStack(spacing: 14) {
                    Text(String(localized: "sessionPlay.moments.title", defaultValue: "Moments that stayed with you"))
                        .font(AppFont.label())
                        .fontDesign(.serif)

                    VStack(spacing: 10) {
                        ForEach(moments) { prompt in
                            Text(prompt.text)
                                .font(AppFont.detail())
                                .fontDesign(.serif)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .italic()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Intensity.honest.cardTint)
                                )
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.contentHorizontal)
            }
        }
        .padding(.horizontal, 4)
        .accessibilityIdentifier("mortalitySessionSummary")
    }

    private var completionButtons: some View {
        VStack(spacing: 10) {
            Button {
                HapticsManager.mediumImpact()
                manager.restart()
                sessionFavoriteIDs = []
                promptTransitionID = UUID()
                promptVisible = true
            } label: {
                Text(String(localized: "mortalityPlay.button.startAnother", defaultValue: "Start another session"))
                    .font(AppFont.buttonSecondary())
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
            }

            Button {
                dismiss()
            } label: {
                Text(String(localized: "common.button.close", defaultValue: "Close"))
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

    private func advanceWithTransition() {
        withAnimation(.easeOut(duration: 0.2)) {
            promptVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            manager.advance()
            promptTransitionID = UUID()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                promptVisible = true
            }
        }
    }

    private func goBackWithTransition() {
        withAnimation(.easeOut(duration: 0.2)) {
            promptVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            manager.goBack()
            promptTransitionID = UUID()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                promptVisible = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        MortalityConversationPlayView(length: .short, topics: [.legacy, .ordinaryMoments])
            .environment(SessionManager())
    }
}
