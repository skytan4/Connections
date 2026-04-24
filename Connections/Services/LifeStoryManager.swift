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
        return "Chapter \(chapter.rawValue) of \(LifeStoryChapter.allCases.count) · \(chapter.title)"
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
