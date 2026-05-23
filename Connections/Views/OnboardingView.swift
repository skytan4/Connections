//
//  OnboardingView.swift
//  Connections
//

import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct OnboardingView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(\.colorScheme) private var colorScheme

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: String(localized: "onboarding.page1.title", defaultValue: "Go beyond small talk"),
            body: String(localized: "onboarding.page1.body", defaultValue: "Some conversations stay on the surface.\nThis helps you get to something more real.")
        ),
        OnboardingPage(
            title: String(localized: "onboarding.page2.title", defaultValue: "Built for connection"),
            body: String(localized: "onboarding.page2.body", defaultValue: "Thoughtful prompts help people slow down, open up, and understand each other more honestly.")
        ),
        OnboardingPage(
            title: String(localized: "onboarding.page3.title", defaultValue: "Start where you are"),
            body: String(localized: "onboarding.page3.body", defaultValue: "With a partner, a friend, your family, or just yourself.\nThere's no perfect way to begin.")
        ),
        OnboardingPage(
            title: String(localized: "onboarding.page4.title", defaultValue: "Simple by design"),
            body: String(localized: "onboarding.page4.body", defaultValue: "Choose who it's for.\nSet the tone.\nStart talking.")
        )
    ]

    var body: some View {
        ZStack {
            NeutralBackground()

            VStack(spacing: 0) {

                // MARK: - Skip

                HStack {
                    Spacer()

                    if currentPage < pages.count - 1 {
                        Button(String(localized: "onboarding.button.skip", defaultValue: "Skip")) {
                            settings.hasSeenOnboarding = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // MARK: - Pages

                ZStack {
                    VStack(spacing: 20) {
                        Text(pages[currentPage].title)
                            .font(AppFont.screenTitle())
                            .multilineTextAlignment(.center)

                        Text(pages[currentPage].body)
                            .font(AppFont.subtitle())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: 520)
                    .id(currentPage)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 12)),
                        removal: .opacity
                    ))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 30, coordinateSpace: .local)
                        .onEnded { value in
                            withAnimation(.easeOut(duration: 0.4)) {
                                if value.translation.width < -50, currentPage < pages.count - 1 {
                                    currentPage += 1
                                } else if value.translation.width > 50, currentPage > 0 {
                                    currentPage -= 1
                                }
                            }
                        }
                )

                // MARK: - Page Indicators

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(
                                index == currentPage
                                ? AppColor.primaryButtonBg(colorScheme)
                                : AppColor.surface(colorScheme)
                            )
                            .frame(width: index == currentPage ? 20 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 28)

                // MARK: - Button

                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeOut(duration: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        settings.hasSeenOnboarding = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1
                         ? String(localized: "onboarding.button.next", defaultValue: "Next")
                         : String(localized: "onboarding.button.begin", defaultValue: "Begin"))
                        .contentTransition(.interpolate)
                        .font(AppFont.buttonPrimary())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundStyle(.white)
                        .background(AppColor.primaryButtonBg(colorScheme), in: .capsule)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 52)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(SettingsStore())
}
