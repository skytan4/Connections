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
    private let previewPrompts: [LifeStoryPrompt]?

    var currentPrompt: LifeStoryPrompt? {
        if let previewPrompts {
            guard currentIndex >= 0 && currentIndex < previewPrompts.count else { return nil }
            return previewPrompts[currentIndex]
        }
        return LifeStoryBank.shared.prompt(at: currentIndex)
    }

    var totalPrompts: Int {
        previewPrompts?.count ?? LifeStoryBank.shared.count
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

    init(previewPrompts: [LifeStoryPrompt]? = nil) {
        self.previewPrompts = previewPrompts
        self.currentIndex = previewPrompts == nil ? Self.loadProgress() : 0
    }

    var isPreview: Bool {
        previewPrompts != nil
    }

    // MARK: - Navigation

    var canGoBack: Bool {
        currentIndex > 0 && !isComplete
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        saveProgressIfNeeded(currentIndex)
    }

    func advance() {
        let nextIndex = currentIndex + 1
        if nextIndex >= totalPrompts {
            isComplete = true
            saveProgressIfNeeded(nextIndex)
        } else {
            currentIndex = nextIndex
            saveProgressIfNeeded(currentIndex)
        }
    }

    func resume() {
        isComplete = currentIndex >= totalPrompts
    }

    func reset() {
        currentIndex = 0
        isComplete = false
        saveProgressIfNeeded(0)
    }

    // MARK: - Persistence

    private static let storageKey = "layers_life_story_progress"

    private static func loadProgress() -> Int {
        UserDefaults.standard.integer(forKey: storageKey)
    }

    private static func saveProgress(_ index: Int) {
        UserDefaults.standard.set(index, forKey: storageKey)
    }

    private func saveProgressIfNeeded(_ index: Int) {
        guard !isPreview else { return }
        Self.saveProgress(index)
    }
}
