//
//  FallInLoveManager.swift
//  Connections
//

import Foundation

@Observable
final class FallInLoveManager {

    // MARK: - State

    private(set) var currentIndex: Int
    private(set) var isComplete: Bool = false

    var currentPrompt: FallInLovePrompt? {
        FallInLoveBank.shared.prompt(at: currentIndex)
    }

    var totalPrompts: Int {
        FallInLoveBank.shared.count
    }

    var progress: Double {
        guard totalPrompts > 0 else { return 0 }
        return Double(currentIndex) / Double(totalPrompts)
    }

    var depthLabel: String {
        currentPrompt?.depth.title ?? "Warm Up"
    }

    // MARK: - Init

    init() {
        self.currentIndex = Self.loadProgress()
    }

    // MARK: - Navigation

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

    private static let storageKey = "layers_fallInLove_progress"

    private static func loadProgress() -> Int {
        UserDefaults.standard.integer(forKey: storageKey)
    }

    private static func saveProgress(_ index: Int) {
        UserDefaults.standard.set(index, forKey: storageKey)
    }
}
