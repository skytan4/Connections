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
        // High engagement + deep depth
        if s.maxDepthReached == .deepDive && s.goDeeperCount >= 2 {
            return "You went there."
        }

        // High skip ratio — they were choosy
        if s.skipRatio > 0.4 {
            return "You were selective tonight."
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return "You kept leaning in."
        }

        // Deep dive reached
        if s.maxDepthReached == .deepDive {
            return "You made it to the deep end."
        }

        // Real talk reached
        if s.maxDepthReached == .realTalk {
            return "Something real happened."
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
        if s.maxDepthReached == .deepDive {
            lines.append("The conversation opened up as you went along.")
        } else if s.goDeeperCount >= 2 {
            lines.append("You stayed curious and kept leaning in.")
        } else if s.skipRatio > 0.3 {
            lines.append("You trusted your instincts on what to stay with.")
        } else {
            lines.append("You stayed present with each prompt.")
        }

        // Line 2: Texture from engagement signals
        if s.goDeeperCount >= 3 && s.maxDepthReached == .deepDive {
            lines.append("There was real honesty in this one.")
        } else if s.continuedCount >= 8 {
            lines.append("You gave this one time. That matters.")
        }

        return Array(lines.prefix(2))
    }

    // MARK: - Next Step

    private static func pickNextStep(_ s: Signals) -> String? {
        // High skips — gentle encouragement
        if s.skipRatio > 0.4 {
            return "Next time, try staying with a prompt that makes you pause."
        }

        // Light intensity — nudge toward depth
        if s.maxDepthReached == .warmUp && s.intensity == .light {
            return "When you're ready, Honest mode has more to offer."
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return "You like to go deep. Unfiltered mode might be your speed."
        }

        // Reached deep dive depth
        if s.maxDepthReached == .deepDive {
            return "You reached the deep end. Give yourself credit for that."
        }

        return nil
    }

    // MARK: - Supporting Line

    /// A warm one-liner that complements the title — never repeats it.
    private static func pickSupportingLine(_ s: Signals) -> String {
        // Deep engagement
        if s.maxDepthReached == .deepDive && s.goDeeperCount >= 2 {
            return modeAnchor(s.mode, deep: true)
        }

        // High skip ratio
        if s.skipRatio > 0.4 {
            return "You trusted your instincts on what to stay with."
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return "You wanted more from each moment."
        }

        // Deep dive reached
        if s.maxDepthReached == .deepDive {
            return "That's further than most conversations go."
        }

        // Real talk reached
        if s.maxDepthReached == .realTalk {
            return "You let the conversation lead."
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
