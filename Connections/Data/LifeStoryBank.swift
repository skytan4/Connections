//
//  LifeStoryBank.swift
//  Connections
//

import Foundation

// MARK: - Chapter

enum LifeStoryChapter: Int, CaseIterable, Identifiable, Codable {
    case childhood = 1
    case schoolAndGrowingUp
    case workAndEarlyAdulthood
    case loveAndPartnership
    case parentingAndFamilyLife
    case hardshipAndResilience
    case beliefsAndValues
    case lookingBack
    case legacy

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .childhood: return "Childhood"
        case .schoolAndGrowingUp: return "School and Growing Up"
        case .workAndEarlyAdulthood: return "Work and Early Adulthood"
        case .loveAndPartnership: return "Love and Partnership"
        case .parentingAndFamilyLife: return "Parenting and Family Life"
        case .hardshipAndResilience: return "Hardship and Resilience"
        case .beliefsAndValues: return "Beliefs and Values"
        case .lookingBack: return "Looking Back"
        case .legacy: return "Legacy"
        }
    }
}

// MARK: - Prompt

struct LifeStoryPrompt: Identifiable, Codable {
    let id: UUID
    let text: String
    let chapter: LifeStoryChapter
    let order: Int
    let followUp1: String
    let followUp2: String

    init(id: UUID = UUID(), text: String, chapter: LifeStoryChapter, order: Int, followUp1: String, followUp2: String) {
        self.id = id
        self.text = text
        self.chapter = chapter
        self.order = order
        self.followUp1 = followUp1
        self.followUp2 = followUp2
    }
}

// MARK: - Bank

struct LifeStoryBank {
    static let shared = LifeStoryBank()

    let prompts: [LifeStoryPrompt]

    private init() {
        prompts = Self.buildPrompts()
    }

    var count: Int { prompts.count }

    func prompt(at index: Int) -> LifeStoryPrompt? {
        guard index >= 0 && index < prompts.count else { return nil }
        return prompts[index]
    }

    func chapter(for index: Int) -> LifeStoryChapter? {
        prompt(at: index)?.chapter
    }

    func promptsInChapter(_ chapter: LifeStoryChapter) -> [LifeStoryPrompt] {
        prompts.filter { $0.chapter == chapter }
    }

    // MARK: - Build

    private static func buildPrompts() -> [LifeStoryPrompt] {
        let all: [LifeStoryPrompt] = [

            // MARK: Childhood

            LifeStoryPrompt(
                text: "What do you remember loving most about being a child?",
                chapter: .childhood, order: 1,
                followUp1: "What about that still stays with you now?",
                followUp2: "Do you think that part of childhood still lives somewhere in you?"
            ),
            LifeStoryPrompt(
                text: "What kind of play made you happiest when you were young?",
                chapter: .childhood, order: 2,
                followUp1: "What did that kind of play let you feel?",
                followUp2: "Do you think that part of you still shows up now?"
            ),
            LifeStoryPrompt(
                text: "What do you remember most clearly about the house you grew up in?",
                chapter: .childhood, order: 3,
                followUp1: "What feeling comes back first when you picture it?",
                followUp2: "What did that home give you, and what did it not give you?"
            ),
            LifeStoryPrompt(
                text: "Which family member felt safest to you when you were little?",
                chapter: .childhood, order: 4,
                followUp1: "What made them feel safe?",
                followUp2: "Do you think they knew what they were to you?"
            ),
            LifeStoryPrompt(
                text: "What did an ordinary afternoon feel like when you were young?",
                chapter: .childhood, order: 5,
                followUp1: "What details come back most easily?",
                followUp2: "What do you miss, if anything, about that pace of life?"
            ),
            LifeStoryPrompt(
                text: "What scared you when you were a child?",
                chapter: .childhood, order: 6,
                followUp1: "Did anyone know how afraid you were?",
                followUp2: "Do you think that fear shaped you in ways that still last?"
            ),
            LifeStoryPrompt(
                text: "What did you think adulthood was going to be like?",
                chapter: .childhood, order: 7,
                followUp1: "What did you get right?",
                followUp2: "What turned out to be completely different?"
            ),
            LifeStoryPrompt(
                text: "Did you have a pet or animal you especially loved when you were young?",
                chapter: .childhood, order: 8,
                followUp1: "What do you still remember about that bond?",
                followUp2: "What did loving that animal teach you, if anything?"
            ),

            // MARK: School and Growing Up

            LifeStoryPrompt(
                text: "What were you like in school?",
                chapter: .schoolAndGrowingUp, order: 9,
                followUp1: "What did people tend to notice about you first?",
                followUp2: "Do you think that was the real you, or just one version of you?"
            ),
            LifeStoryPrompt(
                text: "Which teacher do you still remember, and why?",
                chapter: .schoolAndGrowingUp, order: 10,
                followUp1: "What did they see in you or awaken in you?",
                followUp2: "Did they affect the way you saw yourself?"
            ),
            LifeStoryPrompt(
                text: "What kind of friends did you have growing up?",
                chapter: .schoolAndGrowingUp, order: 11,
                followUp1: "What did those friendships give you then?",
                followUp2: "What do you think they revealed about who you were becoming?"
            ),
            LifeStoryPrompt(
                text: "When you were young, what did you imagine you would become?",
                chapter: .schoolAndGrowingUp, order: 12,
                followUp1: "What part of that dream stayed with you?",
                followUp2: "What part had to change as life became real?"
            ),
            LifeStoryPrompt(
                text: "What did you love most about being young?",
                chapter: .schoolAndGrowingUp, order: 13,
                followUp1: "What feeling from that time do you still miss?",
                followUp2: "Have you found any version of it again later in life?"
            ),
            LifeStoryPrompt(
                text: "What did you find hardest about growing up?",
                chapter: .schoolAndGrowingUp, order: 14,
                followUp1: "Did anyone really understand that at the time?",
                followUp2: "What did it ask of you too early?"
            ),
            LifeStoryPrompt(
                text: "How was conflict between siblings or friends handled when you were growing up?",
                chapter: .schoolAndGrowingUp, order: 15,
                followUp1: "What did that teach you about conflict at the time?",
                followUp2: "Do you think you still handle conflict in some of those same ways now?"
            ),

            // MARK: Work and Early Adulthood

            LifeStoryPrompt(
                text: "What was your first job?",
                chapter: .workAndEarlyAdulthood, order: 16,
                followUp1: "What did it teach you about people or responsibility?",
                followUp2: "How did earning money for yourself first feel?"
            ),
            LifeStoryPrompt(
                text: "What job taught you the most about people?",
                chapter: .workAndEarlyAdulthood, order: 17,
                followUp1: "What did it show you that stayed with you?",
                followUp2: "Did it change how you saw yourself too?"
            ),
            LifeStoryPrompt(
                text: "What responsibility came into your life earlier than you were ready for?",
                chapter: .workAndEarlyAdulthood, order: 18,
                followUp1: "How did you carry it?",
                followUp2: "What do you think it changed in you?"
            ),
            LifeStoryPrompt(
                text: "What was a turning point in your early adult life?",
                chapter: .workAndEarlyAdulthood, order: 19,
                followUp1: "Did you know it was a turning point at the time?",
                followUp2: "How did life divide before and after it?"
            ),
            LifeStoryPrompt(
                text: "What did work mean to you at different stages of life?",
                chapter: .workAndEarlyAdulthood, order: 20,
                followUp1: "Did it mean survival, pride, duty, identity, or something else?",
                followUp2: "How did that meaning change over time?"
            ),
            LifeStoryPrompt(
                text: "Was there a job you loved more than people would expect?",
                chapter: .workAndEarlyAdulthood, order: 21,
                followUp1: "What made it feel meaningful to you?",
                followUp2: "Do you think that job revealed something true about you?"
            ),
            LifeStoryPrompt(
                text: "If you served in the military, what do you wish people understood about that part of your life?",
                chapter: .workAndEarlyAdulthood, order: 22,
                followUp1: "What did that experience ask of you?",
                followUp2: "How do you think it stayed with you afterward?"
            ),

            // MARK: Love and Partnership

            LifeStoryPrompt(
                text: "How did you meet your spouse or partner?",
                chapter: .loveAndPartnership, order: 23,
                followUp1: "What was your first real impression of them?",
                followUp2: "When did you know this relationship mattered?"
            ),
            LifeStoryPrompt(
                text: "What was love like for you when you were young?",
                chapter: .loveAndPartnership, order: 24,
                followUp1: "How did that understanding change as you got older?",
                followUp2: "What did love teach you that nothing else could?"
            ),
            LifeStoryPrompt(
                text: "What made your marriage or partnership easier?",
                chapter: .loveAndPartnership, order: 25,
                followUp1: "What kind of habits or qualities helped most?",
                followUp2: "What do you think held you together in hard seasons?"
            ),
            LifeStoryPrompt(
                text: "What made it harder?",
                chapter: .loveAndPartnership, order: 26,
                followUp1: "What do you understand now that you didn't understand then?",
                followUp2: "What do you wish younger people knew about lasting love?"
            ),
            LifeStoryPrompt(
                text: "What did you first admire about the person you chose to build a life with?",
                chapter: .loveAndPartnership, order: 27,
                followUp1: "Did that admiration change over time, or deepen?",
                followUp2: "What do you think they brought out in you?"
            ),

            // MARK: Parenting and Family Life

            LifeStoryPrompt(
                text: "What surprised you most about becoming a parent?",
                chapter: .parentingAndFamilyLife, order: 28,
                followUp1: "What part of it changed you most?",
                followUp2: "What did you not understand until you were living it?"
            ),
            LifeStoryPrompt(
                text: "What part of parenting brought you the most joy?",
                chapter: .parentingAndFamilyLife, order: 29,
                followUp1: "What kind of moments stay with you most now?",
                followUp2: "What did those moments reveal about you?"
            ),
            LifeStoryPrompt(
                text: "What part of parenting felt loneliest or hardest?",
                chapter: .parentingAndFamilyLife, order: 30,
                followUp1: "Did you feel understood in that difficulty?",
                followUp2: "What did you need more of at the time?"
            ),
            LifeStoryPrompt(
                text: "Is there anything you wish you had done differently as a parent?",
                chapter: .parentingAndFamilyLife, order: 31,
                followUp1: "What do you understand about that now?",
                followUp2: "What do you hope your children understand about you, even there?"
            ),
            LifeStoryPrompt(
                text: "What do you think your children understood well about you, and what do you think they missed?",
                chapter: .parentingAndFamilyLife, order: 32,
                followUp1: "What do you wish they had seen more clearly?",
                followUp2: "Do you think they understand it better now?"
            ),

            // MARK: Hardship and Resilience

            LifeStoryPrompt(
                text: "What was one of the hardest seasons of your life?",
                chapter: .hardshipAndResilience, order: 33,
                followUp1: "What got you through it when you didn't know how you would?",
                followUp2: "What did that season ask of you?"
            ),
            LifeStoryPrompt(
                text: "Was there a loss that changed you permanently?",
                chapter: .hardshipAndResilience, order: 34,
                followUp1: "How did it shape the way you live or love now?",
                followUp2: "What does that loss still ask of you today?"
            ),
            LifeStoryPrompt(
                text: "What sacrifice did you make that people didn't fully see?",
                chapter: .hardshipAndResilience, order: 35,
                followUp1: "Did you feel it was recognized enough?",
                followUp2: "Would you make it again?"
            ),
            LifeStoryPrompt(
                text: "What made you keep going when things felt very heavy?",
                chapter: .hardshipAndResilience, order: 36,
                followUp1: "Was it duty, love, faith, stubbornness, hope, or something else?",
                followUp2: "Do you think that strength changed you?"
            ),

            // MARK: Beliefs and Values

            LifeStoryPrompt(
                text: "What value has guided your life the most?",
                chapter: .beliefsAndValues, order: 37,
                followUp1: "Where do you think that value came from?",
                followUp2: "How did it shape the choices you made?"
            ),
            LifeStoryPrompt(
                text: "What belief did you have to let go of over time?",
                chapter: .beliefsAndValues, order: 38,
                followUp1: "What changed it?",
                followUp2: "What did letting it go make possible?"
            ),
            LifeStoryPrompt(
                text: "What do you think makes someone a good person?",
                chapter: .beliefsAndValues, order: 39,
                followUp1: "Has your answer changed with age?",
                followUp2: "What taught you that most deeply?"
            ),
            LifeStoryPrompt(
                text: "What do you believe now that your younger self might not have understood?",
                chapter: .beliefsAndValues, order: 40,
                followUp1: "What would your younger self have resisted hearing?",
                followUp2: "Why does it feel true to you now?"
            ),
            LifeStoryPrompt(
                text: "What did your own parents or grandparents teach you that stayed with you the longest?",
                chapter: .beliefsAndValues, order: 41,
                followUp1: "Was it something they said, or something they modeled?",
                followUp2: "Do you think you passed it on too?"
            ),

            // MARK: Looking Back

            LifeStoryPrompt(
                text: "Is there something you wish you had asked your own parents before they were gone?",
                chapter: .lookingBack, order: 42,
                followUp1: "What do you think you were really wanting to know?",
                followUp2: "Do you still feel that absence now?"
            ),
            LifeStoryPrompt(
                text: "What do you wish you had known earlier in life?",
                chapter: .lookingBack, order: 43,
                followUp1: "Would knowing it earlier really have changed things?",
                followUp2: "How did you finally learn it?"
            ),
            LifeStoryPrompt(
                text: "What do you wish you had been brave enough to do?",
                chapter: .lookingBack, order: 44,
                followUp1: "What stopped you at the time?",
                followUp2: "How do you feel about it now?"
            ),
            LifeStoryPrompt(
                text: "What decision are you proud you made?",
                chapter: .lookingBack, order: 45,
                followUp1: "What did that decision protect or create?",
                followUp2: "How did it shape the life that followed?"
            ),
            LifeStoryPrompt(
                text: "What question do you wish someone had asked you sooner in life?",
                chapter: .lookingBack, order: 46,
                followUp1: "Why do you think nobody asked it?",
                followUp2: "What becomes possible when someone finally does?"
            ),

            // MARK: Legacy

            LifeStoryPrompt(
                text: "What do you hope people remember about how you loved?",
                chapter: .legacy, order: 47,
                followUp1: "What matters most to you in that memory?",
                followUp2: "Do you think the people closest to you know that now?"
            ),
            LifeStoryPrompt(
                text: "What do you hope outlives you?",
                chapter: .legacy, order: 48,
                followUp1: "Is it something you built, taught, gave, or embodied?",
                followUp2: "Where do you hope it keeps living?"
            ),
            LifeStoryPrompt(
                text: "What lesson do you hope your family carries forward?",
                chapter: .legacy, order: 49,
                followUp1: "What taught you that lesson?",
                followUp2: "Why does it matter so much to you?"
            ),
            LifeStoryPrompt(
                text: "If someone in your family listened closely to your life, what would you most want them to understand?",
                chapter: .legacy, order: 50,
                followUp1: "What do you hope they never miss about who you were?",
                followUp2: "What would it mean to feel truly understood in that way?"
            ),
        ]
        return all.sorted { $0.order < $1.order }
    }
}
