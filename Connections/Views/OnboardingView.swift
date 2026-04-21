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
            title: "Go deeper",
            body: "Most conversations stay on the surface.\nThis helps you move into something more honest, meaningful, and real."
        ),
        OnboardingPage(
            title: "Built for connection",
            body: "Thoughtful questions help you slow down, open up, and discover what's underneath the usual answers."
        ),
        OnboardingPage(
            title: "Simple by design",
            body: "Choose a mode\nSet the tone\nAnswer honestly\nGo deeper when it feels right"
        ),
        OnboardingPage(
            title: "Start where you are",
            body: "With a partner, a friend, family — or just yourself.\nThere's no right way to begin."
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
                        Button("Skip") {
                            settings.hasSeenOnboarding = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // MARK: - Pages

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 0) {
                            Spacer()

                            VStack(spacing: 24) {
                                Text(page.title)
                                    .font(.system(size: 32, weight: .regular, design: .serif))
                                    .multilineTextAlignment(.center)

                                Text(page.body)
                                    .font(.system(size: 17))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                                    .padding(.horizontal, 36)
                            }
                            .frame(maxWidth: 520)

                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

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
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentPage += 1
                        }
                    } else {
                        settings.hasSeenOnboarding = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Start")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundColor(.white)
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
