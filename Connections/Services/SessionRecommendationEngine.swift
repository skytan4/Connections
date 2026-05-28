//
//  SessionRecommendationEngine.swift
//  Connections
//

import Foundation

// MARK: - Recommendation Output

enum RecommendationStrength {
    case strong
    case suggested

    var label: String {
        switch self {
        case .strong:    return String(localized: "recommendation.strength.strong",    defaultValue: "Strong next step")
        case .suggested: return String(localized: "recommendation.strength.suggested", defaultValue: "Possible next step")
        }
    }
}

struct SessionRecommendation {
    let topic: Topic?
    let intensity: Intensity
    let followUpsEnabled: Bool
    let sessionLength: SessionLength
    let explanation: String
    let strength: RecommendationStrength
}

// MARK: - Engine

struct SessionRecommendationEngine {

    struct Signals {
        let interactions: [String: PromptInteraction]
        let responses: [PromptResponse]
        let selectedMode: Mode
        let selectedIntensity: Intensity
        let selectedSessionLength: SessionLength
        let selectedTopic: Topic?
        let maxDepthReached: DepthLevel
        let goDeeperCount: Int
        let followUpsWereEnabled: Bool
        let isPremium: Bool

        var continuedCount: Int {
            responses.filter { $0.action == .continued }.count
        }

        var skipRatio: Double {
            guard !responses.isEmpty else { return 1.0 }
            let skipped = responses.filter { $0.action == .skipped }.count
            return Double(skipped) / Double(responses.count)
        }
    }

    // MARK: - Adjacent-Topic Map

    private static let adjacentTopics: [Topic: [Topic]] = [
        .communication: [.emotions, .conflict],
        .emotions:      [.communication, .intimacy],
        .conflict:      [.communication, .appreciation],
        .appreciation:  [.intimacy, .dailyLife],
        .past:          [.growth, .values],
        .growth:        [.identity, .values],
        .intimacy:      [.emotions, .communication],
        .values:        [.growth, .past],
        .identity:      [.growth, .values],
        .dailyLife:     [.appreciation, .communication],
        .sex:           [.intimacy, .emotions],
        .parenting:     [.intimacy, .conflict],
    ]

    // MARK: - Generate

    static func generate(from s: Signals) -> SessionRecommendation? {
        // Shared confidence gates
        guard s.continuedCount >= 3 else { return nil }
        guard s.skipRatio <= 0.6 else { return nil }

        let totalEngagement = s.interactions.values.reduce(0.0) { $0 + engagementScore($1) }
        guard totalEngagement > 0 else { return nil }

        var (intensity, intensityExplanation) = recommendIntensity(from: s)
        let followUps = recommendFollowUps(from: s)
        var length = recommendLength(from: s)
        let strength = computeStrength(from: s)

        if !s.isPremium {
            if intensity == .unfiltered { intensity = .honest; intensityExplanation = nil }
            if length == .long { length = .medium }
        }

        if let selectedTopic = s.selectedTopic {
            // Topic-filtered session: recommend an adjacent topic, never echo the same one back.
            guard selectedTopic != .fallInLove else { return nil }
            guard totalEngagement >= 8 else { return nil }

            let candidates = adjacentTopics[selectedTopic] ?? []
            let adjacent = candidates.first(where: { topic in
                if !s.isPremium && topic == .sex { return false }
                return true
            })
            guard let adjacent else { return nil }

            let explanation = adjacentExplanation(from: selectedTopic, to: adjacent)

            return SessionRecommendation(
                topic: adjacent,
                intensity: intensity,
                followUpsEnabled: followUps,
                sessionLength: length,
                explanation: explanation,
                strength: strength
            )
        } else {
            // All Topics session: discover top topic from behavior.
            var scores = topicScores(from: s.interactions)
            if !s.isPremium { scores.removeValue(forKey: .sex) }
            guard scores.values.contains(where: { $0 > 0 }) else { return nil }

            let (topic, topicExplanation) = recommendTopic(scores: scores, interactions: s.interactions)
            let explanation = topicExplanation ?? intensityExplanation ?? String(
                localized: "recommendation.explanation.fallback",
                defaultValue: "You stayed present throughout."
            )

            return SessionRecommendation(
                topic: topic,
                intensity: intensity,
                followUpsEnabled: followUps,
                sessionLength: length,
                explanation: explanation,
                strength: strength
            )
        }
    }

    /// Explanation connecting the selected topic to the adjacent recommendation.
    private static func adjacentExplanation(from selected: Topic, to adjacent: Topic) -> String {
        let fmt = String(
            localized: "recommendation.explanation.adjacentTopic",
            defaultValue: "You stayed with prompts about %1$@. %2$@ might be worth exploring next.",
            comment: "Recommendation when user explored a specific topic and an adjacent one is suggested. Arg 1: the topic they stayed with. Arg 2: the adjacent topic being recommended."
        )
        return String(format: fmt, selected.localizedDisplayName, adjacent.localizedDisplayName)
    }

    // MARK: - Per-Interaction Scoring

    private static func engagementScore(_ interaction: PromptInteraction) -> Double {
        var score: Double = 0

        if interaction.wasFavorited { score += 5 }

        score += Double(interaction.goDeeperCount) * 4

        score += timeBucketScore(for: interaction.totalTimeSpent)

        return score
    }

    private static func timeBucketScore(for seconds: TimeInterval) -> Double {
        switch seconds {
        case 300...:
            return 5
        case 240...:
            return 4
        case 120...:
            return 3
        case 60...:
            return 2
        case 30...:
            return 1
        default:
            return 0
        }
    }

    // MARK: - Topic Aggregation

    private static func topicScores(from interactions: [String: PromptInteraction]) -> [Topic: Double] {
        var scores: [Topic: Double] = [:]
        for interaction in interactions.values {
            guard interaction.topic != .fallInLove else { continue }
            scores[interaction.topic, default: 0] += engagementScore(interaction)
        }
        return scores
    }

    // MARK: - Topic Recommendation

    private static func recommendTopic(
        scores: [Topic: Double],
        interactions: [String: PromptInteraction]
    ) -> (Topic?, String?) {
        let sorted = scores.sorted { $0.value > $1.value }
        guard let first = sorted.first, first.value > 0 else {
            return (nil, nil)
        }

        let second = sorted.dropFirst().first

        let hasMinimumEngagement = first.value >= 8
        let hasSeparation: Bool
        if let second {
            hasSeparation = first.value >= second.value * 1.5
        } else {
            hasSeparation = true
        }

        guard hasMinimumEngagement && hasSeparation else {
            return (nil, nil)
        }

        let reason = explanationFor(topic: first.key, in: interactions)
        return (first.key, reason)
    }

    /// Builds a behavior-grounded explanation based on the dominant engagement signal for a topic.
    private static func explanationFor(topic: Topic, in interactions: [String: PromptInteraction]) -> String {
        let topicInteractions = interactions.values.filter { $0.topic == topic }

        let favoriteCount = topicInteractions.filter { $0.wasFavorited }.count
        let goDeeperTotal = topicInteractions.reduce(0) { $0 + $1.goDeeperCount }
        let avgTime = topicInteractions.isEmpty ? 0 :
            topicInteractions.reduce(0.0) { $0 + $1.totalTimeSpent } / Double(topicInteractions.count)

        let name = topic.localizedDisplayName
        let fmt: String

        if favoriteCount >= 2 {
            fmt = String(
                localized: "recommendation.explanation.topic.favorited",
                defaultValue: "You saved several prompts about %1$@.",
                comment: "Recommendation explanation when the user favorited multiple prompts in a topic. Arg 1: localized topic name."
            )
        } else if goDeeperTotal >= 2 {
            fmt = String(
                localized: "recommendation.explanation.topic.deeper",
                defaultValue: "You kept going deeper on prompts about %1$@.",
                comment: "Recommendation explanation when the user used Go Deeper on a topic repeatedly. Arg 1: localized topic name."
            )
        } else if avgTime > 9 {
            fmt = String(
                localized: "recommendation.explanation.topic.lingered",
                defaultValue: "You lingered on prompts about %1$@.",
                comment: "Recommendation explanation when the user spent extra time on a topic. Arg 1: localized topic name."
            )
        } else {
            fmt = String(
                localized: "recommendation.explanation.topic.drawn",
                defaultValue: "You seemed drawn to prompts about %1$@.",
                comment: "Default recommendation explanation when a topic shows mild engagement. Arg 1: localized topic name."
            )
        }
        return String(format: fmt, name)
    }

    // MARK: - Intensity Recommendation

    private static func recommendIntensity(from s: Signals) -> (Intensity, String?) {
        let current = s.selectedIntensity

        // Step up
        if let next = current.next {
            if s.maxDepthReached == .deepDive && s.goDeeperCount >= 2 {
                let fmt = String(
                    localized: "recommendation.explanation.intensity.stepUp.deep",
                    defaultValue: "You went deep — %1$@ has more to offer.",
                    comment: "Intensity step-up explanation after deep engagement. Arg 1: localized name of the recommended (higher) intensity."
                )
                return (next, String(format: fmt, next.localizedTitle))
            }
            if s.goDeeperCount >= 3 && s.skipRatio < 0.2 {
                let fmt = String(
                    localized: "recommendation.explanation.intensity.stepUp.lean",
                    defaultValue: "You kept leaning in — try %1$@.",
                    comment: "Intensity step-up explanation when user repeatedly used Go Deeper. Arg 1: localized name of the recommended (higher) intensity."
                )
                return (next, String(format: fmt, next.localizedTitle))
            }
        }

        // Step down
        if let previous = current.previous {
            if s.skipRatio > 0.4 {
                return (previous, String(
                    localized: "recommendation.explanation.intensity.stepDown.lighter",
                    defaultValue: "A lighter pace might feel better next time."
                ))
            }
            if s.maxDepthReached == .warmUp && s.goDeeperCount == 0 && s.continuedCount >= 3 {
                let fmt = String(
                    localized: "recommendation.explanation.intensity.stepDown.natural",
                    defaultValue: "%1$@ might feel more natural.",
                    comment: "Intensity step-down explanation when the session stayed shallow. Arg 1: localized name of the recommended (lower) intensity."
                )
                return (previous, String(format: fmt, previous.localizedTitle))
            }
        }

        return (current, nil)
    }

    // MARK: - Follow-Ups

    private static func recommendFollowUps(from s: Signals) -> Bool {
        if s.goDeeperCount > 0 { return true }
        return s.followUpsWereEnabled
    }

    // MARK: - Session Length

    private static func recommendLength(from s: Signals) -> SessionLength {
        let current = s.selectedSessionLength

        if current == .short && s.skipRatio < 0.15 {
            return .medium
        }

        if current == .long && s.skipRatio > 0.35 {
            return .medium
        }

        if current == .long {
            return .medium
        }

        return current
    }

    // MARK: - Strength

    /// Determines recommendation strength from explicit engagement signals (favorites, go-deeper).
    /// Time is excluded because its thresholds are tuned low for testing.
    private static func computeStrength(from s: Signals) -> RecommendationStrength {
        let favoriteCount = s.interactions.values.filter { $0.wasFavorited }.count
        let goDeeperCount = s.goDeeperCount

        // Strong: multiple explicit signals of different kinds, or deep commitment to one.
        if favoriteCount >= 2 && goDeeperCount >= 2 { return .strong }
        if favoriteCount >= 3 { return .strong }
        if goDeeperCount >= 4 { return .strong }

        return .suggested
    }
}
