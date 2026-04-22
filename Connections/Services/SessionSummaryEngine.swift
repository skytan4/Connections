//
//  SessionSummaryEngine.swift
//  Connections
//

import Foundation

// MARK: - Session Summary

struct SessionSummary {
    let title: String
    let supportingLine: String
    let reflectionLines: [String]
    let nextStep: String?
}

// MARK: - Session Summary Engine

struct SessionSummaryEngine {

    struct Signals {
        let responses: [PromptResponse]
        let feelings: [Feeling]
        let connectionLevel: ConnectionLevel
        let maxDepthReached: DepthLevel
        let goDeeperCount: Int
        let mode: Mode
        let intensity: Intensity

        var continuedCount: Int {
            responses.filter { $0.action == .continued }.count
        }

        var skippedCount: Int {
            responses.filter { $0.action == .skipped }.count
        }

        var totalCount: Int {
            responses.count
        }

        var skipRatio: Double {
            guard totalCount > 0 else { return 0 }
            return Double(skippedCount) / Double(totalCount)
        }

        var dominantFeeling: Feeling? {
            let counts = Dictionary(grouping: feelings, by: { $0 }).mapValues(\.count)
            return counts.max(by: { $0.value < $1.value })?.key
        }

        var hardCount: Int {
            feelings.filter { $0 == .hard }.count
        }

        var deepCount: Int {
            feelings.filter { $0 == .deep }.count
        }

        var lightCount: Int {
            feelings.filter { $0 == .light }.count
        }

        var mostlyLight: Bool {
            guard !feelings.isEmpty else { return false }
            return Double(lightCount) / Double(feelings.count) >= 0.7
        }

        var depthTrending: DepthTrend {
            guard feelings.count >= 2 else { return .steady }
            let midpoint = feelings.count / 2
            let firstHalf = feelings.prefix(midpoint)
            let secondHalf = feelings.suffix(from: midpoint)
            let firstAvg = firstHalf.map(\.weight).reduce(0, +) / Double(firstHalf.count)
            let secondAvg = secondHalf.map(\.weight).reduce(0, +) / Double(secondHalf.count)
            let diff = secondAvg - firstAvg
            if diff > 0.5 { return .deepening }
            if diff < -0.5 { return .lightening }
            return .steady
        }
    }

    enum DepthTrend {
        case deepening, steady, lightening
    }

    // MARK: - Generate

    static func generate(from signals: Signals) -> SessionSummary {
        let title = pickTitle(signals)
        let supporting = pickSupportingLine(signals)
        let reflections = pickReflections(signals)
        let nextStep = pickNextStep(signals)
        return SessionSummary(title: title, supportingLine: supporting, reflectionLines: reflections, nextStep: nextStep)
    }

    // MARK: - Title

    private static func pickTitle(_ s: Signals) -> String {
        // High engagement + deep connection
        if s.connectionLevel == .deeplyConnected && s.goDeeperCount >= 2 {
            return "You went there."
        }
        if s.connectionLevel == .deeplyConnected {
            return "Something real happened."
        }

        // Depth trending
        if s.depthTrending == .deepening {
            return "It got deeper as you went."
        }

        // High skip ratio
        if s.skipRatio > 0.4 {
            return "You were selective tonight."
        }

        // Mostly hard feelings
        if s.hardCount >= 2 {
            return "That took courage."
        }

        // Mostly light session
        if s.mostlyLight {
            return "A gentle start."
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return "You kept leaning in."
        }

        // Connected level
        if s.connectionLevel == .connected {
            return "You found a rhythm."
        }

        // Deep dive reached
        if s.maxDepthReached == .deepDive {
            return "You made it to the deep end."
        }

        // Default by mode
        switch s.mode {
        case .couples: return "A moment between you."
        case .friends: return "More than small talk."
        case .family: return "A bridge was built."
        case .soloReflection: return "Time well spent with yourself."
        }
    }

    // MARK: - Reflection Lines

    private static func pickReflections(_ s: Signals) -> [String] {
        var lines: [String] = []

        // Line 1: What happened (factual + warm)
        switch s.depthTrending {
        case .deepening:
            lines.append("The conversation opened up as you went along.")
        case .lightening:
            lines.append("You eased into a gentler space as the session went on.")
        case .steady:
            if s.connectionLevel == .deeplyConnected {
                lines.append("You stayed open throughout.")
            } else if s.mostlyLight {
                lines.append("You kept things light and easy.")
            } else {
                lines.append("You stayed present with each prompt.")
            }
        }

        // Line 2: Emotional texture
        if s.hardCount >= 2 {
            lines.append("Some of those weren't easy to sit with.")
        } else if let dominant = s.dominantFeeling {
            switch dominant {
            case .deep:
                lines.append("There was real honesty in this one.")
            case .meaningful:
                lines.append("Something in there landed.")
            case .hard:
                lines.append("You stayed with a hard moment.")
            case .light:
                if s.feelings.count >= 2 {
                    lines.append("Nothing wrong with keeping it easy.")
                } else {
                    lines.append("A calm, low-key session.")
                }
            }
        } else if s.feelings.isEmpty {
            // No check-ins happened
            lines.append("You moved through the prompts at your own pace.")
        }

        return Array(lines.prefix(2))
    }

    // MARK: - Next Step

    private static func pickNextStep(_ s: Signals) -> String? {
        // High skips — gentle encouragement
        if s.skipRatio > 0.4 {
            return "Next time, try staying with a prompt that makes you pause."
        }

        // Mostly light — nudge toward depth
        if s.mostlyLight && s.intensity == .light {
            return "When you're ready, Honest mode has more to offer."
        }

        if s.mostlyLight && s.intensity != .light {
            return "Try lingering on the ones that surprise you."
        }

        // Hard feelings — validate
        if s.hardCount >= 2 {
            return "It's okay to come back to something lighter next time."
        }

        // Deeply connected — affirm
        if s.connectionLevel == .deeplyConnected {
            return nil // No nudge needed — let it land.
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return "You like to go deep. Unfiltered mode might be your speed."
        }

        // Reached deep dive depth
        if s.maxDepthReached == .deepDive && s.connectionLevel != .deeplyConnected {
            return "You reached the deep end. Give yourself credit for that."
        }

        return nil
    }

    // MARK: - Supporting Line

    /// A warm one-liner that complements the title — never repeats it.
    private static func pickSupportingLine(_ s: Signals) -> String {
        // Deeply connected + engaged
        if s.connectionLevel == .deeplyConnected && s.goDeeperCount >= 2 {
            return modeAnchor(s.mode, deep: true)
        }
        if s.connectionLevel == .deeplyConnected {
            return modeAnchor(s.mode, deep: true)
        }

        // Deepening
        if s.depthTrending == .deepening {
            return "You let the conversation lead."
        }

        // High skip ratio
        if s.skipRatio > 0.4 {
            return "You trusted your instincts on what to stay with."
        }

        // Hard feelings
        if s.hardCount >= 2 {
            return "You sat with things that weren't easy."
        }

        // Mostly light
        if s.mostlyLight {
            return "Not every conversation needs to go deep to matter."
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return "You wanted more from each moment."
        }

        // Connected
        if s.connectionLevel == .connected {
            return modeAnchor(s.mode, deep: false)
        }

        // Deep dive reached
        if s.maxDepthReached == .deepDive {
            return "That's further than most conversations go."
        }

        // Default
        return modeAnchor(s.mode, deep: false)
    }

    private static func modeAnchor(_ mode: Mode, deep: Bool) -> String {
        if deep {
            switch mode {
            case .couples: return "You stayed with what opened up between you."
            case .friends: return "That's the kind of conversation that changes things."
            case .family: return "Something shifted in how you see each other."
            case .soloReflection: return "You were honest with yourself."
            }
        } else {
            switch mode {
            case .couples: return "The conversation found its own rhythm."
            case .friends: return "You went further than most people do."
            case .family: return "You made space for something real."
            case .soloReflection: return "You showed up for yourself."
            }
        }
    }
}
