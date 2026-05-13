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
        if s.maxDepthReached == .deepDive && s.goDeeperCount >= 2 {
            return String(localized: "summary.title.deepDivePlusGoDeeper", defaultValue: "You went there.")
        }
        if s.skipRatio > 0.4 {
            return String(localized: "summary.title.selective", defaultValue: "You were selective tonight.")
        }
        if s.goDeeperCount >= 3 {
            return String(localized: "summary.title.leaningIn", defaultValue: "You kept leaning in.")
        }
        if s.maxDepthReached == .deepDive {
            return String(localized: "summary.title.deepDive", defaultValue: "You made it to the deep end.")
        }
        if s.maxDepthReached == .realTalk {
            return String(localized: "summary.title.realTalk", defaultValue: "Something real happened.")
        }
        switch s.mode {
        case .couples:        return String(localized: "summary.title.default.couples",        defaultValue: "A moment between you.")
        case .friends:        return String(localized: "summary.title.default.friends",        defaultValue: "More than small talk.")
        case .family:         return String(localized: "summary.title.default.family",         defaultValue: "A bridge was built.")
        case .soloReflection: return String(localized: "summary.title.default.soloReflection", defaultValue: "Time well spent with yourself.")
        }
    }

    // MARK: - Reflection Lines

    private static func pickReflections(_ s: Signals) -> [String] {
        var lines: [String] = []

        // Line 1: What happened (factual + warm)
        if s.maxDepthReached == .deepDive {
            lines.append(String(localized: "summary.reflection.openedUp",  defaultValue: "The conversation opened up as you went along."))
        } else if s.goDeeperCount >= 2 {
            lines.append(String(localized: "summary.reflection.curious",   defaultValue: "You stayed curious and kept leaning in."))
        } else if s.skipRatio > 0.3 {
            lines.append(String(localized: "summary.reflection.instincts", defaultValue: "You trusted your instincts on what to stay with."))
        } else {
            lines.append(String(localized: "summary.reflection.present",   defaultValue: "You stayed present with each prompt."))
        }

        // Line 2: Texture from engagement signals
        if s.goDeeperCount >= 3 && s.maxDepthReached == .deepDive {
            lines.append(String(localized: "summary.reflection.honesty", defaultValue: "There was real honesty in this one."))
        } else if s.continuedCount >= 8 {
            lines.append(String(localized: "summary.reflection.time",    defaultValue: "You gave this one time. That matters."))
        }

        return Array(lines.prefix(2))
    }

    // MARK: - Next Step

    private static func pickNextStep(_ s: Signals) -> String? {
        // High skips — gentle encouragement
        if s.skipRatio > 0.4 {
            return String(localized: "summary.nextStep.selective",
                          defaultValue: "Next time, try staying with a prompt that makes you pause.")
        }

        // Light intensity — nudge toward depth
        if s.maxDepthReached == .warmUp && s.intensity == .light {
            let fmt = String(
                localized: "summary.nextStep.lightToHonest",
                defaultValue: "When you're ready, %1$@ mode has more to offer.",
                comment: "Next-step nudge after a light, shallow session. Arg 1: localized name of the Honest intensity setting."
            )
            return String(format: fmt, Intensity.honest.localizedTitle)
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            let fmt = String(
                localized: "summary.nextStep.deepToUnfiltered",
                defaultValue: "You like to go deep. %1$@ mode might be your speed.",
                comment: "Next-step nudge after high go-deeper engagement. Arg 1: localized name of the Unfiltered intensity setting."
            )
            return String(format: fmt, Intensity.unfiltered.localizedTitle)
        }

        // Reached deep dive depth
        if s.maxDepthReached == .deepDive {
            return String(localized: "summary.nextStep.deepDive",
                          defaultValue: "You reached the deep end. Give yourself credit for that.")
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
            return String(localized: "summary.supportingLine.instincts",
                          defaultValue: "You trusted your instincts on what to stay with.")
        }

        // Go deeper engagement
        if s.goDeeperCount >= 3 {
            return String(localized: "summary.supportingLine.wantedMore",
                          defaultValue: "You wanted more from each moment.")
        }

        // Deep dive reached
        if s.maxDepthReached == .deepDive {
            return String(localized: "summary.supportingLine.furtherThanMost",
                          defaultValue: "That's further than most conversations go.")
        }

        // Real talk reached
        if s.maxDepthReached == .realTalk {
            return String(localized: "summary.supportingLine.conversationLed",
                          defaultValue: "You let the conversation lead.")
        }

        // Default
        return modeAnchor(s.mode, deep: false)
    }

    private static func modeAnchor(_ mode: Mode, deep: Bool) -> String {
        if deep {
            switch mode {
            case .couples:        return String(localized: "summary.supportingLine.deep.couples",        defaultValue: "You stayed with what opened up between you.")
            case .friends:        return String(localized: "summary.supportingLine.deep.friends",        defaultValue: "That's the kind of conversation that changes things.")
            case .family:         return String(localized: "summary.supportingLine.deep.family",         defaultValue: "Something shifted in how you see each other.")
            case .soloReflection: return String(localized: "summary.supportingLine.deep.soloReflection", defaultValue: "You were honest with yourself.")
            }
        } else {
            switch mode {
            case .couples:        return String(localized: "summary.supportingLine.default.couples",        defaultValue: "The conversation found its own rhythm.")
            case .friends:        return String(localized: "summary.supportingLine.default.friends",        defaultValue: "You went further than most people do.")
            case .family:         return String(localized: "summary.supportingLine.default.family",         defaultValue: "You made space for something real.")
            case .soloReflection: return String(localized: "summary.supportingLine.default.soloReflection", defaultValue: "You showed up for yourself.")
            }
        }
    }
}
