//
//  LifeStoryManager.swift
//  Connections
//

import Foundation

@Observable
final class LifeStoryManager {

    // MARK: - State

    private(set) var currentIndex: Int
    private(set) var isComplete: Bool = false

    var currentPrompt: LifeStoryPrompt? {
        LifeStoryBank.shared.prompt(at: currentIndex)
    }

    var totalPrompts: Int {
        LifeStoryBank.shared.count
    }

    var progress: Double {
        guard totalPrompts > 0 else { return 0 }
        return Double(currentIndex) / Double(totalPrompts)
    }

    // MARK: - Chapter

    var currentChapter: LifeStoryChapter? {
        currentPrompt?.chapter
    }

    var chapterProgress: String {
        guard let chapter = currentChapter else { return "" }
        let format = String(
            localized: "lifeStoryChapter.progress",
            defaultValue: "Chapter %1$lld of %2$lld · %3$@",
            comment: "Chapter progress label. Arg 1: chapter number (1–9). Arg 2: total chapters (9). Arg 3: localized chapter title."
        )
        return String(format: format, chapter.rawValue, LifeStoryChapter.allCases.count, chapter.localizedTitle)
    }

    // MARK: - Init

    init() {
        self.currentIndex = Self.loadProgress()
    }

    // MARK: - Navigation

    var canGoBack: Bool {
        currentIndex > 0 && !isComplete
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        Self.saveProgress(currentIndex)
    }

    func advance() {
        let nextIndex = currentIndex + 1
        if nextIndex >= totalPrompts {
            isComplete = true
            Self.saveProgress(nextIndex)
        } else {
            currentIndex = nextIndex
            Self.saveProgress(currentIndex)
        }
    }

    func resume() {
        isComplete = currentIndex >= totalPrompts
    }

    func reset() {
        currentIndex = 0
        isComplete = false
        Self.saveProgress(0)
    }

    // MARK: - Persistence

    private static let storageKey = "layers_life_story_progress"

    private static func loadProgress() -> Int {
        UserDefaults.standard.integer(forKey: storageKey)
    }

    private static func saveProgress(_ index: Int) {
        UserDefaults.standard.set(index, forKey: storageKey)
    }
}
