//
//  ShareExperienceSessionManager.swift
//  Connections
//

import Foundation

@Observable
final class ShareExperienceSessionManager {

    private let bank: ShareExperienceBank
    private let previewExperiences: [ShareExperience]?

    private(set) var selectedIntensity: Intensity?
    private(set) var currentExperience: ShareExperience?
    private(set) var experienceHistory: [ShareExperience] = []
    private(set) var isComplete = false

    private var previewIndex = 0

    init(bank: ShareExperienceBank = .shared) {
        self.bank = bank
        self.previewExperiences = nil
        self.currentExperience = bank.getRandomExperience()
    }

    init(previewExperiences: [ShareExperience], bank: ShareExperienceBank = .shared) {
        self.bank = bank
        self.previewExperiences = previewExperiences
        self.currentExperience = previewExperiences.first
    }

    var isPreview: Bool {
        previewExperiences != nil
    }

    var canGoBack: Bool {
        !experienceHistory.isEmpty && !isComplete
    }

    var backgroundIntensity: Intensity? {
        isPreview ? currentExperience?.intensity : selectedIntensity
    }

    func setIntensity(_ intensity: Intensity?) {
        guard !isPreview, selectedIntensity != intensity else { return }
        selectedIntensity = intensity
        experienceHistory = []
        currentExperience = bank.getRandomExperience(intensity: intensity)
    }

    func advance() {
        guard !isComplete else { return }
        if isPreview {
            advancePreview()
        } else {
            advanceRandom()
        }
    }

    func goBack() {
        guard let previous = experienceHistory.popLast() else { return }
        if isPreview {
            previewIndex = max(0, previewIndex - 1)
        }
        currentExperience = previous
    }

    func restart() {
        experienceHistory = []
        isComplete = false

        if let previewExperiences {
            previewIndex = 0
            currentExperience = previewExperiences.first
        } else {
            currentExperience = bank.getRandomExperience(intensity: selectedIntensity)
        }
    }

    private func advanceRandom() {
        if let currentExperience {
            experienceHistory.append(currentExperience)
        }
        currentExperience = bank.getRandomExperience(intensity: selectedIntensity)
    }

    private func advancePreview() {
        guard let previewExperiences else { return }

        if let currentExperience {
            experienceHistory.append(currentExperience)
        }

        let nextIndex = previewIndex + 1
        guard nextIndex < previewExperiences.count else {
            isComplete = true
            return
        }

        previewIndex = nextIndex
        currentExperience = previewExperiences[nextIndex]
    }
}
