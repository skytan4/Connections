//
//  PromptBank.swift
//  Connections
//

import Foundation

struct PromptBank {
    static let shared = PromptBank()

    let prompts: [Prompt]

    private init() {
        prompts = Self.buildPrompts()
    }

    /// Returns prompts matching the given criteria.
    func prompts(for mode: Mode, intensity: Intensity, depthLevel: DepthLevel) -> [Prompt] {
        prompts.filter { $0.mode == mode && $0.intensity == intensity && $0.depthLevel == depthLevel }
    }

    /// Returns prompts for the given mode and intensity across all unlocked depth levels.
    func prompts(for mode: Mode, intensity: Intensity, unlockedThrough depthLevel: DepthLevel) -> [Prompt] {
        prompts.filter { $0.mode == mode && $0.intensity == intensity && $0.depthLevel <= depthLevel }
    }

    /// Returns topics that have at least one prompt for the given mode and intensity,
    /// plus any guided-flow topics available for that mode.
    func availableTopics(for mode: Mode, intensity: Intensity) -> [Topic] {
        let present = Set(prompts.filter { $0.mode == mode && $0.intensity == intensity }.map(\.topic))
        return Topic.availableFor(mode: mode).filter { $0.isGuidedFlow || present.contains($0) }
    }
}

// MARK: - Prompt Data

private extension PromptBank {

    static let defaultFollowUps = [
        FollowUp(text: "Why that?", style: .origin),
        FollowUp(text: "Has that always been true?", style: .meaning),
        FollowUp(text: "What changed?", style: .impact)
    ]

    static func buildPrompts() -> [Prompt] {
        var all: [Prompt] = []

        // MARK: Couples

        all += couples_light_warmUp()
        all += couples_light_realTalk()
        all += couples_light_deepDive()
        all += couples_honest_warmUp()
        all += couples_honest_realTalk()
        all += couples_honest_deepDive()
        all += couples_unfiltered_warmUp()
        all += couples_unfiltered_realTalk()
        all += couples_unfiltered_deepDive()

        // MARK: Couples · Parenting

        all += couples_parenting_light_warmUp()
        all += couples_parenting_light_realTalk()
        all += couples_parenting_light_deepDive()
        all += couples_parenting_honest_warmUp()
        all += couples_parenting_honest_realTalk()
        all += couples_parenting_honest_deepDive()
        all += couples_parenting_unfiltered_warmUp()
        all += couples_parenting_unfiltered_realTalk()
        all += couples_parenting_unfiltered_deepDive()

        // MARK: Friends

        all += friends_light_warmUp()
        all += friends_light_realTalk()
        all += friends_light_deepDive()
        all += friends_honest_warmUp()
        all += friends_honest_realTalk()
        all += friends_honest_deepDive()
        all += friends_unfiltered_warmUp()
        all += friends_unfiltered_realTalk()
        all += friends_unfiltered_deepDive()

        // MARK: Family

        all += family_light_warmUp()
        all += family_light_realTalk()
        all += family_light_deepDive()
        all += family_honest_warmUp()
        all += family_honest_realTalk()
        all += family_honest_deepDive()
        all += family_unfiltered_warmUp()
        all += family_unfiltered_realTalk()
        all += family_unfiltered_deepDive()

        // MARK: Solo Reflection

        all += solo_light_warmUp()
        all += solo_light_realTalk()
        all += solo_light_deepDive()
        all += solo_honest_warmUp()
        all += solo_honest_realTalk()
        all += solo_honest_deepDive()
        all += solo_unfiltered_warmUp()
        all += solo_unfiltered_realTalk()
        all += solo_unfiltered_deepDive()

        return all
    }

    static func make(_ entries: [(String, Topic)], mode: Mode, intensity: Intensity, depth: DepthLevel) -> [Prompt] {
        entries.map { Prompt(text: $0.0, mode: mode, intensity: intensity, depthLevel: depth, topic: $0.1, followUps: defaultFollowUps) }
    }

    /// Overload that accepts per-prompt follow-up strings instead of using the global defaults.
    /// Auto-assigns styles cycling through: origin, impact, meaning, need, tension.
    static func make(_ entries: [(String, Topic, [String])], mode: Mode, intensity: Intensity, depth: DepthLevel) -> [Prompt] {
        let autoStyles: [FollowUpStyle] = [.origin, .impact, .meaning, .need, .tension]
        return entries.map { entry in
            let followUps = entry.2.enumerated().map { (i, text) in
                FollowUp(text: text, style: autoStyles[i % autoStyles.count])
            }
            return Prompt(text: entry.0, mode: mode, intensity: intensity, depthLevel: depth, topic: entry.1, followUps: followUps)
        }
    }

    // MARK: - Couples · Light · Warm Up

    static func couples_light_warmUp() -> [Prompt] {
        make([
            ("If you could know one thing about your future, what would you want to find out?", .dailyLife, [
                "Why that answer, specifically?",
                "How do you think knowing it would change the way you live now?",
            ]),
            ("What's something you're unreasonably stubborn about?", .identity, [
                "What makes that one so hard for you to budge on?",
                "What do you think it protects in you?",
            ]),
            ("What's something you know you're completely irrational about?", .identity, [
                "What usually triggers that reaction in you?",
                "Do you think it's tied to something older or deeper?",
            ]),
            ("What's a tiny personal preference you feel surprisingly passionate about?", .dailyLife, [
                "Why do you think that one matters so much to you?",
                "What does it reveal about the way you like life to feel?",
            ]),
            ("What do you spend a lot of money on without any regrets?", .dailyLife, [
                "What does spending on that give you beyond the thing itself?",
                "What would be hard to replace if you gave that up?",
            ]),
            ("What do you get more excited about than you probably should?", .communication, [
                "What does it touch in you that makes it feel bigger than it is?",
                "What does that excitement seem to wake up in you?",
            ]),
            ("What would you love to be able to spend more freely on?", .dailyLife, [
                "How would that change things for you or in your life?",
                "What feeling are you hoping this would give you more of?",
            ]),
            ("Do you like being the host, or would you rather be the guest?", .dailyLife, [
                "What part of that role feels most natural to you?",
                "What does that role make easier for you?",
            ]),
            ("If you were stuck at home for months, what three things would you absolutely need?", .dailyLife, [
                "What do those choices tell you about what keeps you steady?",
                "Which one would be the hardest to go without, and why?",
            ]),
            ("What's your go-to midnight snack?", .dailyLife, [
                "What mood are you usually in when that craving hits?",
                "What does that choice say about the kind of comfort you reach for?",
            ]),
            ("Who or what have you been quietly fascinated by lately?", .intimacy, [
                "What is it about them or it that attracts you?",
                "Does it energize you, comfort you, or just pull you in?",
            ]),
            ("What's the most disastrous date you've ever been on?", .dailyLife, [
                "What made it go wrong so fast?",
                "What did that experience teach you about yourself or dating?",
            ]),
            ("What's your favorite real love story — yours or someone else's?", .intimacy, [
                "What part of that story moves you the most?",
                "Do you see any pieces of that kind of love in us?",
            ]),
            ("What do you need most from me when you're not feeling well?", .communication, [
                "What helps you feel cared for instead of just looked after?",
                "What's easy for me to miss in those moments that would help you feel better?",
            ]),
            ("What's something about you that takes a little extra care?", .dailyLife, [
                "What makes that one thing worth the extra effort for you?",
                "Do you think it's about comfort, control, or feeling cared for?",
            ]),
            ("Where do you like to have a lot of control?", .identity, [
                "What feels at risk when you're not in control?",
                "Why do you think you need so much control there?",
            ]),
            ("What's the one thing you absolutely do not like being teased about?", .communication, [
                "What about that one lands badly for you?",
                "Does it touch something older or more tender in you?",
            ]),
            ("What or who is it basically impossible for you to say no to?", .communication, [
                "Is that a guilty pleasure, a soft spot, or something else?",
                "Do you feel pressure to always say yes?",
            ]),
            ("What's something about your partner that you fell in love with all over again recently?", .appreciation, [
                "What was it about that moment that hit you so strongly?",
                "What did it remind you of about why you chose them?",
            ]),
            ("What kind of attention from me makes you feel most sensual?", .sex, [
                "What helps that attention land in your body instead of just in your head?",
                "Is there anything I do that tends to pull you away from that feeling?",
            ]),
            ("What kind of attention from me makes you feel most attractive?", .sex, [
                "When was the last time my attention really reached you that way?",
                "Can you help me notice when I'm getting it right?",
            ]),
            ("What's a song that always makes you think of us?", .appreciation, [
                "What memory or feeling does it bring back first?",
                "What part of our relationship does that song seem to capture?",
            ]),
            ("What's the best surprise you've ever gotten from someone you love?", .appreciation, [
                "What made that surprise feel so meaningful to you?",
                "What did it show you about how that person knew you?",
            ]),
            ("What's your idea of a perfect lazy vacation day together?", .dailyLife, [
                "What can I do to make those days feel most nourishing to you?",
                "Do we do enough of these days? Should we do more?",
            ]),
            ("What's something small I do that always makes you smile?", .appreciation, [
                "Why do you think that tiny thing means so much to you?",
                "What does it make you feel in that moment?",
            ]),
            ("If we could travel anywhere tomorrow, where would you want to go?", .dailyLife, [
                "Why do you want to go there with me?",
                "What are you hoping we'd feel there together?",
            ]),
            ("What's a hobby or skill you've always wanted us to try together?", .growth, [
                "How do you imagine that bringing us closer?",
                "Why do you think doing it together matters more than doing it alone?",
            ]),
            ("What's the most fun we've ever had doing something totally unplanned?", .past, [
                "What do you think made that spontaneity work so well for us?",
                "Do you wish we made more room for that side of us?",
            ]),
            ("What's a movie or show that reminds you of our relationship?", .dailyLife, [
                "What part of it feels most like us?",
                "What does that say about how you experience our relationship?",
            ]),
            ("What's your love language when you're stressed versus when you're happy?", .communication, [
                "What does that look like in real life when you're stressed versus happy?",
                "What do you most want from me when you're in each state?",
            ]),
            ("What's a tradition you'd love for us to start?", .values, [
                "What do you think that tradition would create between us over time?",
                "Is there anything in your life that makes that kind of ritual important to you?",
            ]),
            ("What's a small thing that can instantly shift your mood for the better?", .emotions, [
                "Do I know that about you already?",
                "What's the opposite — the tiny thing that can ruin a good mood?",
            ]),
            ("What's the silliest thing we've ever actually disagreed about?", .conflict, [
                "What made it feel like a bigger deal in the moment?",
                "Can you laugh about it now?",
            ]),
        ], mode: .couples, intensity: .light, depth: .warmUp)
    }

    // MARK: - Couples · Light · Real Talk

    static func couples_light_realTalk() -> [Prompt] {
        make([
            ("What's the most unexpected compliment you've ever received?", .appreciation, [
                "Why do you think that one surprised you so much?",
                "What did it make you feel about yourself in that moment?",
            ]),
            ("When was the last time you were completely lost in a great experience?", .dailyLife, [
                "What was it about that moment that pulled you all the way in?",
                "How often do you let yourself get that absorbed in something?",
            ]),
            ("What's the funniest thing that's happened to us that we never get tired of retelling?", .dailyLife, [
                "Why do you think that story is so endearing to us?",
                "What does the reason we laugh about it say about us?",
            ]),
            ("Something that tends to shut me down a little is…", .sex, [
                "What about that takes you out of the moment?",
                "Would you want to talk it through together, or just have it understood?",
            ]),
            ("What kind of energy or attention tends to wake desire up in you?", .sex, [
                "When did you first notice that about yourself?",
                "What is it about that that really lands for you?",
            ]),
            ("One of the most sensual experiences I've had that didn't involve sex was…", .sex, [
                "What made that moment feel so charged?",
                "What does that tell you about what sensuality means to you?",
            ]),
            ("I still remember a time I felt deeply desired when…", .sex, [
                "What about that moment made you feel so wanted?",
                "What opens up in you when you feel that desired?",
            ]),
            ("An intimate memory that still makes me cringe a little is…", .sex, [
                "What makes it cringeworthy — and do you laugh about it now?",
                "Did it change anything about what helps you feel at ease?",
            ]),
            ("What kind of intimate moment stays in your body long after it's over?", .sex, [
                "What made that one stay with you so vividly?",
                "What do you think made it feel so connected?",
            ]),
            ("What do you do that helps intimacy feel more alive instead of automatic?", .sex, [
                "How did you figure that out about yourself?",
                "What does it feel like when that effort lands?",
            ]),
            ("An embarrassing intimate moment I've experienced was…", .sex, [
                "How did you recover from it in the moment?",
                "Did it leave you feeling closer, awkward, or a little of both?",
            ]),
            ("What makes me feel most desired by you is…", .sex, [
                "What is it about that gesture that gets through to you?",
                "Do you think I know how much that matters to you?",
            ]),
            ("A moment I felt truly connected to you physically was…", .sex, [
                "What made the emotional and physical feel so aligned?",
                "What do you think helps create that kind of connection between us?",
            ]),
        ], mode: .couples, intensity: .light, depth: .realTalk)
    }

    // MARK: - Couples · Light · Deep Dive

    static func couples_light_deepDive() -> [Prompt] {
        make([
            ("What moment made you think — okay, this person really gets me?", .intimacy, [
                "What did I do differently that helped you feel understood?",
                "How did that moment change the way you saw me?",
            ]),
            ("What's something about us you'd never want to change?", .appreciation, [
                "What would it feel like if that thing started to shift?",
                "Do you think we both see that the same way?",
            ]),
            ("How do you think we've changed each other for the better?", .growth, [
                "Is there a version of yourself before us that you don't miss?",
                "What growth in me are you most proud of?",
            ]),
            ("What's your favorite chapter of our story so far?", .past, [
                "What made that chapter feel so special compared to the rest?",
                "What kind of chapter do you hope comes next?",
            ]),
        ], mode: .couples, intensity: .light, depth: .deepDive)
    }

    // MARK: - Couples · Honest · Warm Up

    static func couples_honest_warmUp() -> [Prompt] {
        make([
            ("What thought keeps finding you when everything finally gets quiet?", .emotions, [
                "What keeps pulling your mind back there?",
                "What would help that thought loosen its hold a little?",
            ]),
            ("What feels heaviest in you right now that I may not fully see?", .emotions, [
                "How long have you been carrying that mostly on your own?",
                "What would help that weight feel lighter, even a little?",
            ]),
            ("When did something hit you harder than it seemed like it should?", .conflict, [
                "What do you think was really underneath that reaction?",
                "Did you realize it in the moment or only after?",
            ]),
            ("I feel most sensual when…", .sex, [
                "What helps you settle into that feeling most naturally?",
                "What tends to pull you away from it?",
            ]),
            ("I feel most attractive when…", .sex, [
                "What is it about that moment that makes you feel seen that way?",
                "How much of that feeling comes from you versus someone else's response?",
            ]),
            ("What's something you wish I understood better about you?", .communication, [
                "What's the part of it that's hardest to explain?",
                "How would things feel different for you if I understood this better?",
            ]),
            ("What's a fear you haven't told me about?", .emotions, [
                "What's kept you from saying it out loud?",
                "What would it be like for you if I knew that about you?",
            ]),
            ("When do you feel most disconnected from me?", .intimacy, [
                "What's happening in you during those moments?",
                "What helps you start to feel your way back toward me?",
            ]),
            ("What's something I do that makes you feel truly seen?", .appreciation, [
                "What is it about that gesture that reaches you?",
                "Do you think I know how much it matters?",
            ]),
            ("What's a part of your day you wish we could share more?", .dailyLife, [
                "What would it give you to have me in that part of your life?",
                "What keeps us from sharing it now?",
            ]),
            ("What's a habit of mine that quietly frustrates you?", .conflict, [
                "What does it bring up in you when it happens?",
                "What makes it hard to bring up with me directly?",
            ]),
            ("What's something you've been meaning to apologize for?", .conflict, [
                "What's been holding the apology back?",
                "What do you imagine might shift if you said it out loud?",
            ]),
            ("When do you feel the safest with me?", .intimacy, [
                "What is it about those moments that lets your guard down?",
                "How does that safety change the way you show up?",
            ]),
            ("What kind of stress changes you in ways I might not fully see?", .emotions, [
                "What starts to shift in you when that stress builds?",
                "How would you want me to notice it sooner?",
            ]),
            ("What's something you admire about the way I love you?", .appreciation, [
                "When do you notice it the most?",
                "Is there something about it you wish you could mirror back?",
            ]),
            ("What's a conversation we had that stuck with you?", .communication, [
                "What about it kept echoing after it ended?",
                "Did it change anything about how you see us?",
            ]),
            ("What's something between us that feels a little avoided right now?", .communication, [
                "What makes that topic feel so untouchable?",
                "What do you think would happen if we actually went there?",
            ]),
            ("When life gets heavy, what do you need from me that I often miss?", .communication, [
                "What does that need feel like before you put words to it?",
                "What would help me recognize it sooner?",
            ]),
            ("What's a way I've helped you grow that you haven't mentioned?", .growth, [
                "What part of you shifted because of it?",
                "Do you think I even realize I had that effect?",
            ]),
            ("What do you miss doing with me that you don't want us to quietly lose?", .dailyLife, [
                "What do you think that gave us when it was more alive between us?",
                "What's been getting in the way of it lately?",
            ]),
            ("What's something about our early days that you miss?", .past, [
                "What made that time feel so different?",
                "Is there a way to bring some of that energy back?",
            ]),
            ("How do you know when stress is starting to harden you a little?", .emotions, [
                "What tends to harden first — your tone, your patience, or something else?",
                "What helps you soften again?",
            ]),
            ("What's a boundary you need me to respect more?", .communication, [
                "What happens inside you when it gets crossed?",
                "What would it feel like if I consistently honored it?",
            ]),
            ("What's something you're proud of us for getting through?", .growth, [
                "What did that challenge reveal about who we are together?",
                "Did it change the way you trust us?",
            ]),
            ("When do you feel most like yourself around me?", .identity, [
                "What is it about those moments that lets you drop the act?",
                "Are there times you feel less like yourself with me?",
            ]),
            ("What's an insecurity that still shows up in our relationship?", .emotions, [
                "When does it tend to surface the most?",
                "What would help you feel more settled about it?",
            ]),
            ("What's something I said recently that meant more than I probably realized?", .appreciation, [
                "What did it touch in you that stayed with you?",
                "Do you wish I said things like that more often?",
            ]),
            ("What do you need from me that you find hard to ask for?", .communication, [
                "What makes that request feel so difficult to voice?",
                "What would it mean to you if I knew to offer it without being asked?",
            ]),
            ("What's a small moment between us that you keep replaying?", .intimacy, [
                "What is it about that moment that holds so much weight?",
                "Does replaying it bring you comfort or longing?",
            ]),
            ("What part of getting older has made you feel more tender with me?", .intimacy, [
                "What do you think that tenderness has opened in you?",
                "How has it changed the way you love me?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Couples · Honest · Real Talk

    static func couples_honest_realTalk() -> [Prompt] {
        make([
            ("What does money make you feel in this relationship that you don't always say out loud?", .values, [
                "Where do you think that feeling around money first took shape for you?",
                "How does it affect the way you move with me when money comes up?",
            ]),
            ("What part of our life together do you want us to protect more fiercely?", .values, [
                "What feels most at risk there right now?",
                "What would protecting it ask more of from us?",
            ]),
            ("When was the last time something in you gave way, and I may not have fully understood it?", .emotions, [
                "What was happening inside you that I might have missed?",
                "What do you wish I had understood more clearly in that moment?",
            ]),
            ("What have you told yourself was fine between us when it actually wasn't?", .conflict, [
                "What made it easier to minimize than to name directly?",
                "What has that silence been costing you?",
            ]),
            ("When was the last time you held back tears and pretended you were fine?", .emotions, [
                "What were you protecting yourself from by holding it in?",
                "What do you imagine might have happened if you had let yourself cry?",
            ]),
            ("What part of getting older has made you more guarded?", .emotions, [
                "What are you trying to protect when that guard goes up?",
                "What helps you feel safe enough to let it down with me?",
            ]),
            ("What's a conversation you know you need to have but keep putting off?", .communication, [
                "What are you most afraid of hearing in return?",
                "What would finally push you to have it?",
            ]),
            ("Is there anything about the way I'm changing with age that scares you?", .emotions, [
                "What change do you notice most clearly?",
                "What does seeing that change bring up in you?",
            ]),
            ("What's something you really want from me but haven't been able to ask for?", .communication, [
                "What makes that request feel so vulnerable?",
                "How do you think I'd respond if you asked?",
            ]),
            ("Where do you feel the most friction between us right now?", .conflict, [
                "What do you think is underneath that friction?",
                "What would resolution actually look like to you?",
            ]),
            ("When do you feel me responding to stress instead of responding to you?", .communication, [
                "What happens between us in those moments?",
                "What would help you feel more met by me then?",
            ]),
            ("What have you softened or left out because you were afraid of how I'd hear it?", .communication, [
                "What felt too risky to say plainly?",
                "What do you imagine would happen if you said it without editing it?",
            ]),
            ("When was the last time jealousy really got under your skin?", .emotions, [
                "What was the deeper fear underneath it?",
                "How did you handle it, and how do you feel about that now?",
            ]),
            ("What do you admire most about the way your partner handles hard things?", .appreciation, [
                "Is there a specific moment that showed you that strength?",
                "What does watching them handle it bring up in you?",
            ]),
            ("I wish someone had prepared me better for sex by telling me…", .sex, [
                "How did figuring that out on your own affect you?",
                "What would you want someone younger to know?",
            ]),
            ("I tend to lose interest during intimacy when…", .sex, [
                "What do you think is happening emotionally in those moments?",
                "What helps you stay present and connected instead?",
            ]),
            ("A sexual message I sometimes want to send you but hold back is…", .sex, [
                "What stops you from actually sending it?",
                "What kind of response are you hoping for when you imagine it?",
            ]),
            ("A message from you that would make me feel deeply wanted is…", .sex, [
                "What would reading that message do to you?",
                "What need would it speak to?",
            ]),
            ("In intimacy, do I tend to lead, follow, soften, tease, hold back, or something else entirely?", .sex, [
                "Has that always been the case, or did it develop over time?",
                "What does that tendency give you?",
            ]),
            ("When I want intimacy, what usually happens inside me before I make a move?", .sex, [
                "What makes initiating feel easy or hard for you?",
                "What response do you need to feel safe taking that step?",
            ]),
            ("What taught you to want what you want sexually — and what taught you to hold back?", .sex, [
                "Which lessons still feel true to you, and which ones no longer do?",
                "What have you had to unlearn to feel more like yourself?",
            ]),
            ("One sexual truth I wish we talked about more openly is…", .sex, [
                "What makes that topic feel hard to bring up?",
                "What would it give us if we could go there together?",
            ]),
            ("Something I'd like us to explore together that feels exciting and a little vulnerable to name is…", .sex, [
                "What draws you to that idea?",
                "What would you need from me to feel safe trying it?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Couples · Honest · Deep Dive

    static func couples_honest_deepDive() -> [Prompt] {
        make([
            ("What does your heart need to hear from me right now?", .emotions, [
                "How long have you been needing to hear that?",
                "What would shift in you if I said it?",
            ]),
            ("What changed the way you trust love most deeply?", .intimacy, [
                "What were you believing about love before that shift?",
                "How does that change still show up in the way you love me now?",
            ]),
            ("What about our future excites you and scares you at the same time?", .emotions, [
                "Which feeling is stronger right now — the excitement or the fear?",
                "What would help the excitement win?",
            ]),
            ("How has commitment changed what intimacy means to you?", .sex, [
                "Where do you think that understanding of commitment and intimacy took shape for you?",
                "How does it affect what you need from me now?",
            ]),
            ("During intimacy, everything else fades away when…", .sex, [
                "What do you think creates that level of presence?",
                "What helps you get there more easily?",
            ]),
            ("A sexual question or uncertainty I still think about is…", .sex, [
                "What makes that question hard to settle?",
                "What would help it feel safer to talk about or explore?",
            ]),
            ("What fear about aging feels harder to carry out loud than in your head?", .emotions, [
                "What makes that fear easier to hold silently than to share with me?",
                "What would help it feel safer to name together?",
            ]),
            ("How has time made us stronger, and how has it made us more fragile?", .growth, [
                "Where do you feel our strength most clearly now?",
                "Where do you feel our fragility most sharply?",
            ]),
            ("My sex life changed in a meaningful way after…", .sex, [
                "What shifted inside you because of that experience?",
                "How did it change what you look for in intimacy?",
            ]),
            ("An early experience that shaped how I think about sex was…", .sex, [
                "How did that experience color the way you approach intimacy now?",
                "Does any part of it still stay with you now?",
            ]),
            ("What do you think we will need from each other more and more as we age?", .values, [
                "What kind of care do you think will matter most to you?",
                "What do you hope we grow better at giving each other?",
            ]),
            ("When do you feel most aware that our time together is not unlimited?", .past, [
                "What does that awareness make you want to protect or change?",
                "How does it affect the way you love me in that moment?",
            ]),
            ("Sex feels most meaningful to me when…", .sex, [
                "What makes the difference between meaningful and just physical?",
                "What helps create that deeper meaning for you?",
            ]),
            ("Growing up, the message I got about sex was…", .sex, [
                "How has that message stayed with you or been rewritten?",
                "What message would you want to pass on instead?",
            ]),
            ("What makes me feel most safe during intimacy is…", .sex, [
                "What does safety in that context actually feel like in your body?",
                "What tends to help that sense of safety stay intact?",
            ]),
            ("What helps me fully relax and be present with you is…", .sex, [
                "What usually gets in the way of that presence?",
                "How can I make that easier for you?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Couples · Unfiltered · Warm Up

    static func couples_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What part of yourself have you been hiding from the people closest to you?", .emotions, [
                "What are you afraid would happen if they saw it?",
                "How does hiding it affect the way you show up?",
            ]),
            ("What's something about us that you've never quite figured out?", .communication, [
                "Does that still bother you, or have you made some peace with it?",
                "What do you think would shift if it made more sense to you?",
            ]),
            ("How honest do you think we really are with each other?", .communication, [
                "Where do you think the gaps are?",
                "What would full honesty between us actually look like?",
            ]),
            ("I feel most sensual when…", .sex, [
                "What helps you settle into that feeling most naturally?",
                "What tends to pull you away from it?",
            ]),
            ("I feel most attractive when…", .sex, [
                "What is it about that moment that makes you feel seen that way?",
                "How much of that feeling comes from you versus someone else's response?",
            ]),
            ("What's a thought about us you've never said out loud?", .intimacy, [
                "What's kept you from voicing it until now?",
                "What do you think I'd feel hearing it?",
            ]),
            ("What's something you need from this relationship that you're not getting?", .communication, [
                "How long have you been sitting with that unmet need?",
                "What would it look like if that need were fully met?",
            ]),
            ("When have you felt the most misunderstood by me?", .conflict, [
                "What did you need me to see that I missed?",
                "Did that moment change anything between us?",
            ]),
            ("What's something about me that you've had to learn to accept?", .growth, [
                "Was the accepting gradual or did something shift it?",
                "What was hard about getting there?",
            ]),
            ("What's a version of yourself you only show to me?", .identity, [
                "What is it about us that makes that version feel safe?",
                "Do you like that version of yourself?",
            ]),
            ("Do you feel appreciated by me in the ways that matter most to you?", .appreciation, [
                "Where do you feel it clearly, and where does it still feel thin?",
                "What kind of appreciation lands hardest for you: words, help, attention, or something else?",
            ]),
            ("What scares you most about our future together?", .emotions, [
                "Is that fear rooted in us or in something older?",
                "What would help quiet that fear?",
            ]),
            ("What's a pattern in our relationship you think we should break?", .conflict, [
                "How does that pattern usually start?",
                "What do you think it would take for us to actually stop it?",
            ]),
            ("What do you wish you could be more honest about with me?", .communication, [
                "What feels at risk if you say it?",
                "What kind of response would make honesty feel safe?",
            ]),
            ("What's something I do that triggers something deeper in you?", .emotions, [
                "What's the deeper thing it's actually touching?",
                "Do you think I have any idea it lands that way?",
            ]),
            ("When did you last question whether we were on the same page?", .communication, [
                "What made you doubt it?",
                "Did you say something or keep it to yourself?",
            ]),
            ("What's something about love that nobody warned you about?", .growth, [
                "How did finding that out change you?",
                "What would you tell someone who's about to learn it?",
            ]),
            ("What's a resentment you've been carrying that you haven't voiced?", .conflict, [
                "What's it been doing to you to hold onto it?",
                "What would you need to feel safe letting it out?",
            ]),
            ("What's the most vulnerable you've ever felt with me?", .intimacy, [
                "What was it about that moment that stripped your guard away?",
                "Did that vulnerability bring us closer or leave you exposed?",
            ]),
            ("What do you think is our biggest blind spot as a couple?", .growth, [
                "What do you think is hardest for us to see clearly from the inside?",
                "What might change if we could see it more honestly?",
            ]),
            ("What's a truth about yourself that you're afraid would change how I see you?", .emotions, [
                "What's the worst version of how you imagine I'd react?",
                "What would it mean if I heard it and nothing changed?",
            ]),
            ("Have you ever felt like you sacrificed too much of yourself for this relationship?", .values, [
                "Did you realize it was too much at the time or only after?",
                "What do you wish had happened differently from your point of view?",
            ]),
            ("What's a fight we had that actually changed something for the better?", .conflict, [
                "What broke through in that fight that might not have surfaced otherwise?",
                "Did it change anything about the way you see conflict between us?",
            ]),
            ("What's something about my past that still sits with you?", .past, [
                "What about it keeps pulling at you?",
                "Have you made peace with it or is it still unresolved?",
            ]),
            ("What would you change about how we communicate when things get hard?", .communication, [
                "What does our worst communication pattern look like?",
                "What would the better version feel like in the moment?",
            ]),
            ("What's an expectation you've placed on me that might not be fair?", .conflict, [
                "Where do you think that expectation comes from?",
                "What would it mean to release it?",
            ]),
            ("When was the last time you felt completely alone even though we were together?", .emotions, [
                "What was happening between us in that moment?",
                "What would have made you feel less alone?",
            ]),
            ("What's something you've forgiven me for that I don't know about?", .conflict, [
                "What did the forgiving cost you?",
                "Is there a part of it that's still not fully resolved?",
            ]),
            ("What do you think we each avoid feeling the most?", .emotions, [
                "How does that avoidance show up in the way we treat each other?",
                "What would happen if we stopped avoiding it?",
            ]),
            ("Is there any way you've changed since being with me that worries you?", .identity, [
                "Is it a change you chose or one that happened to you?",
                "What would the old version of you think?",
            ]),
            ("What's something about us that you'd be embarrassed for others to know?", .intimacy, [
                "What do you think the embarrassment is protecting?",
                "What feels most exposed about it?",
            ]),
            ("What's a household habit of mine that quietly drives you crazy?", .dailyLife, [
                "Have you ever tried to bring it up, or do you just absorb it?",
                "What would it mean if I actually changed it?",
            ]),
            ("Do I show enough appreciation for what you quietly carry at home?", .appreciation, [
                "Which things feel most invisible to you right now?",
                "What kind of acknowledgment would actually reach you?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Couples · Unfiltered · Real Talk

    static func couples_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What's something you've been pretending is fine when it really isn't?", .emotions, [
                "How long have you been holding that performance together?",
                "What do you think might happen if you stopped pretending?",
            ]),
            ("When did you hurt someone without meaning to, and what happened after?", .conflict, [
                "Did you realize it right away or did it take time?",
                "What did that teach you about the gap between intention and impact?",
            ]),
            ("What's something about you that can be hard to live with — if you're being honest?", .conflict, [
                "How do you think that part of you affects the people closest to you?",
                "Is that something you're trying to change, or something you're still learning about yourself?",
            ]),
            ("When did you last feel genuinely lost, and what was happening?", .emotions, [
                "What did you reach for to try to find your footing?",
                "Did anyone know how lost you were?",
            ]),
            ("In what situations are you your own worst enemy?", .growth, [
                "What does your self-sabotage usually look like in those moments?",
                "What do you think you're really trying to protect?",
            ]),
            ("How do you tend to withdraw your love or attention when you're upset?", .conflict, [
                "Are you always aware you're doing it?",
                "What would help you stay present instead of pulling back?",
            ]),
            ("Do I thank you enough for what you do to keep our life running?", .appreciation, [
                "What do you do that feels most taken for granted?",
                "When do you feel most like your effort disappears into the background?",
            ]),
            ("When was a time you admitted you were wrong — and how did that feel?", .conflict, [
                "What made that admission so hard?",
                "Did it change anything in the relationship?",
            ]),
            ("Something I've always been curious to explore sexually is…", .sex, [
                "What draws you to that, and what holds you back?",
                "What would you need to feel safe enough to bring it up?",
            ]),
            ("What part of desire feels hardest to admit out loud, even to yourself?", .sex, [
                "What is it about that edge that pulls you in or makes you hesitate?",
                "What feeling comes with having that thought?",
            ]),
            ("What's an invisible expectation you carry at home that I've never acknowledged?", .dailyLife, [
                "How long have you been holding that without saying anything?",
                "What would it look like if I actually saw it?",
            ]),
            ("Do I say I love you often enough for it to still feel real to you?", .appreciation, [
                "When does hearing it land most deeply for you?",
                "What makes it feel meaningful instead of automatic?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Couples · Unfiltered · Deep Dive

    static func couples_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something you used to dream about but have quietly given up on?", .emotions, [
                "When did you stop believing it was possible?",
                "Is there a part of you that still wants it?",
            ]),
            ("What would you give up everything for if you had to choose?", .values, [
                "What does that choice reveal about what you value most?",
                "Has that answer changed over time?",
            ]),
            ("Is there someone you think of as the one who got away?", .intimacy, [
                "What do you think you're really missing — the person or the possibility?",
                "How does that memory affect the way you love now?",
            ]),
            ("What's the hardest lesson love has ever taught you?", .intimacy, [
                "How did that lesson change what you need from a partner?",
                "Are you still learning it, or have you made peace with it?",
            ]),
            ("Do I show appreciation for you in front of other people in a way you can actually feel?", .appreciation, [
                "When do you feel publicly cherished by me, and when do you not?",
                "What would make that appreciation feel more visible and more true?",
            ]),
            ("What's the heartbreak that hit you the hardest?", .emotions, [
                "What part of you did it break open?",
                "How did it reshape the way you protect your heart?",
            ]),
            ("When was the last time you felt truly lonely, even if you weren't alone?", .emotions, [
                "What was missing in that moment?",
                "What do you think would have helped you feel less alone?",
            ]),
            ("What's something you don't think you could forgive in a relationship?", .conflict, [
                "What does that boundary protect in you?",
                "Has anything ever come close to testing it?",
            ]),
            ("What's a sexual truth about yourself that would be hardest to say to a partner who loves you?", .sex, [
                "What makes that truth feel so exposing?",
                "What do you imagine it would change if it were fully known?",
            ]),
            ("What have you felt after intimacy that was harder to admit than the desire itself?", .sex, [
                "What made that feeling hard to name?",
                "Did it change anything about how you handled closeness afterward?",
            ]),
            ("A fantasy I have mixed feelings about is…", .sex, [
                "What's the tension between the part that wants it and the part that resists?",
                "What do you think that fantasy is reaching for underneath?",
            ]),
            ("Something I haven't been fully honest about in my sexual past is…", .sex, [
                "What's kept you from sharing it until now?",
                "What do you imagine it would feel like to have someone know?",
            ]),
            ("A recurring fantasy I've had is…", .sex, [
                "What do you think that fantasy is really reaching for?",
                "How do you feel about the fact that it keeps coming back?",
            ]),
            ("What part of our daily life together feels like it's slowly wearing you down?", .dailyLife, [
                "When did you first notice the weight of it?",
                "What would need to change for it to feel sustainable again?",
            ]),
            ("What could I do more consistently to make you feel deeply appreciated, not just loved?", .appreciation, [
                "What kind of appreciation do you hunger for that I may still miss?",
                "What would change in you if you felt that more often from me?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Couples · Parenting · Light · Warm Up

    static func couples_parenting_light_warmUp() -> [Prompt] {
        make([
            ("When do you feel most like a team with me as parents?", .parenting, [
                "What is it about those moments that makes us feel aligned?",
                "What do you wish we protected more often from daily chaos?",
            ]),
            ("What's something about the way you parent that makes me easy to love?", .parenting, [
                "What do you think that quality gives our family?",
                "Do you feel fully seen by me in that part of yourself?",
            ]),
            ("What's a small parenting moment between us that still makes you smile?", .parenting, [
                "Why do you think that moment stayed with you?",
                "What does it say about us at our best?",
            ]),
        ], mode: .couples, intensity: .light, depth: .warmUp)
    }

    // MARK: - Couples · Parenting · Light · Real Talk

    static func couples_parenting_light_realTalk() -> [Prompt] {
        make([
            ("What part of parenting has brought out a side of me you didn't expect?", .parenting, [
                "Did that surprise make you feel closer to me or more uncertain?",
                "What have you learned about me through that side?",
            ]),
            ("Where do you think we work well together as parents without giving ourselves enough credit?", .parenting, [
                "What do we handle better than we tend to notice?",
                "Why is it hard for us to see that clearly when we're in it?",
            ]),
        ], mode: .couples, intensity: .light, depth: .realTalk)
    }

    // MARK: - Couples · Parenting · Light · Deep Dive

    static func couples_parenting_light_deepDive() -> [Prompt] {
        make([
            ("What has parenting made you appreciate about me more than before?", .parenting, [
                "When did you first start noticing that quality more deeply?",
                "What does that appreciation stir in you now?",
            ]),
        ], mode: .couples, intensity: .light, depth: .deepDive)
    }

    // MARK: - Couples · Parenting · Honest · Warm Up

    static func couples_parenting_honest_warmUp() -> [Prompt] {
        make([
            ("What part of parenting leaves you feeling most unseen by me?", .parenting, [
                "What do you wish I understood about that burden?",
                "What kind of acknowledgment would actually reach you?",
            ]),
            ("When life gets heavy, what do you need from me as a parent and partner that I often miss?", .parenting, [
                "What makes that need easy for me to overlook?",
                "How would you want me to show up differently?",
            ]),
            ("What has parenting changed about the way you need me?", .parenting, [
                "Which change feels hardest to explain out loud?",
                "What have you been hoping I would notice on my own?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Couples · Parenting · Honest · Real Talk

    static func couples_parenting_honest_realTalk() -> [Prompt] {
        make([
            ("Where does parenting feel most unequal between us right now?", .parenting, [
                "Is the imbalance mostly about time, emotional load, or something else?",
                "What would fairer feel like to you in real life, not just in theory?",
            ]),
            ("What part of yourself have you had to fight hardest to hold onto since becoming a parent?", .parenting, [
                "When do you feel that part of you slipping furthest away?",
                "What do you need from me to help protect it?",
            ]),
            ("When do you feel me responding as a co-parent instead of as your partner?", .parenting, [
                "What gets lost between us in those moments?",
                "What helps you feel like my partner again, not just my teammate?",
            ]),
            ("Where do our differences around discipline create the most tension between us?", .parenting, [
                "What do you think each of us is trying to protect in the way we respond?",
                "What would help us disagree without turning against each other?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Couples · Parenting · Honest · Deep Dive

    static func couples_parenting_honest_deepDive() -> [Prompt] {
        make([
            ("What part of parenting has made you grieve something about who we used to be together?", .parenting, [
                "What do you miss most that still feels hard to admit?",
                "What would it mean to honor that grief without turning away from the life we have now?",
            ]),
            ("What fear do you carry about the kind of parent we might become under too much stress?", .parenting, [
                "What do you think that fear is trying to protect against?",
                "What would help you trust us more under pressure?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Couples · Parenting · Unfiltered · Warm Up

    static func couples_parenting_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What resentment about parenting have you been trying not to admit?", .parenting, [
                "What has it been doing to you to keep that resentment edited down?",
                "What would help it come out without becoming a fight?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Couples · Parenting · Unfiltered · Real Talk

    static func couples_parenting_unfiltered_realTalk() -> [Prompt] {
        make([
            ("Where do you think I lean on you in ways that no longer feel fair?", .parenting, [
                "How long have you been carrying that without naming it plainly?",
                "What would need to change for you to stop feeling that pressure?",
            ]),
            ("What part of parenting has taken something from you that you still haven't made peace with?", .parenting, [
                "What feels hardest to admit you lost?",
                "Do you think I understand the cost of that loss to you?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Couples · Parenting · Unfiltered · Deep Dive

    static func couples_parenting_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What are you most afraid we are quietly passing on without meaning to?", .parenting, [
                "Where do you think that pattern first took root in you or in me?",
                "What would it take for us to interrupt it instead of repeating it?",
            ]),
            ("What truth about parenting us feels too dangerous to say casually?", .parenting, [
                "What feels most at risk if you say it plainly?",
                "What would help you believe we could survive hearing the full truth?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Friends · Light · Warm Up

    static func friends_light_warmUp() -> [Prompt] {
        make([
            ("How do you wish people would describe you when they introduce you?", .identity, [
                "What does that description say about what matters most to you?",
                "How far off is that from how you think people actually see you?",
            ]),
            ("What's a book you find yourself recommending to everyone?", .dailyLife, [
                "What about it hit you so hard?",
                "What kind of person do you usually recommend it to?",
            ]),
            ("Is there a contact in your phone you know you should probably delete?", .conflict, [
                "What keeps you from doing it?",
                "What would deleting it actually mean for you?",
            ]),
            ("If your life was a movie, who would you cast to play you?", .dailyLife, [
                "What is it about that person that captures your energy?",
                "What part of you do you think they'd struggle to get right?",
            ]),
            ("What's the last time you got caught doing something you shouldn't have been doing?", .dailyLife, [
                "How did you handle getting caught?",
                "Would you do it again if you knew you wouldn't get caught?",
            ]),
            ("What's the most embarrassing moment you can actually laugh about now?", .dailyLife, [
                "How long did it take before you could laugh about it?",
                "What made it shift from embarrassing to funny?",
            ]),
            ("What's the last truly generous thing you did for someone without being asked?", .appreciation, [
                "What moved you to do it?",
                "Did they ever find out it was you?",
            ]),
            ("What's a rule you secretly enjoy breaking?", .identity, [
                "What does breaking it give you?",
                "Do you think anyone has noticed?",
            ]),
            ("If you got fired tomorrow, what would it probably be for?", .dailyLife, [
                "Is that something you're proud of or trying to fix?",
                "What does that say about how you operate?",
            ]),
            ("If you could be known for one thing, what would it be?", .values, [
                "Why that above everything else?",
                "Are you actively building toward that or is it more of a wish?",
            ]),
            ("What's something you've always wondered if everyone secretly does too?", .identity, [
                "What would it mean to you if they did?",
                "How would it feel if you were the only one?",
            ]),
            ("What could you talk about for hours that most people wouldn't expect?", .values, [
                "How did that interest develop?",
                "Who in your life actually knows about this side of you?",
            ]),
            ("What would you happily do for a living if money didn't matter at all?", .dailyLife, [
                "What draws you to that over everything else?",
                "What's stopping you from moving toward it even now?",
            ]),
            ("If you could start a completely different career tomorrow, what would you pick?", .dailyLife, [
                "What need would that career satisfy that your current one doesn't?",
                "What's the one thing holding you back from that leap?",
            ]),
            ("If you wrote a book about your life so far, what would you call it?", .values, [
                "What chapter are you in right now?",
                "What would the tone of the book be — funny, heavy, hopeful?",
            ]),
            ("What brings out your competitive side more than anything else?", .identity, [
                "Where do you think that drive comes from?",
                "Is your competitiveness something you like about yourself?",
            ]),
            ("At a party, where would someone most likely find you?", .dailyLife, [
                "What does that spot say about your social energy?",
                "Are you there by choice or by habit?",
            ]),
            ("What do people consistently get wrong about you?", .communication, [
                "What do you think creates that misconception?",
                "Does it bother you, or have you stopped correcting it?",
            ]),
            ("What's something you pretend to know way more about than you actually do?", .identity, [
                "What made you start faking it?",
                "Has anyone ever called you out?",
            ]),
            ("What's the weirdest dream you've ever had?", .dailyLife, [
                "Did it linger with you after you woke up?",
                "Do you think it meant something or was it just chaos?",
            ]),
            ("What's a quality in your closest friend that you genuinely admire?", .appreciation, [
                "Is it a quality you see in yourself too?",
                "Have you ever told them you admire that about them?",
            ]),
            ("When was the last time someone made your day without even trying?", .appreciation, [
                "What did they do that landed so perfectly?",
                "Did they know the effect they had?",
            ]),
            ("What's the most random thing on your bucket list?", .dailyLife, [
                "Where did that idea come from?",
                "What's been keeping you from doing it?",
            ]),
            ("What's a hill you will die on that nobody else seems to care about?", .values, [
                "Why does that one matter so much to you?",
                "Has defending it ever gotten you into trouble?",
            ]),
            ("What's the best meal you've ever had and where was it?", .dailyLife, [
                "What made that meal so unforgettable?",
                "Was it the food or the moment around it?",
            ]),
            ("What's something you're weirdly good at that has no practical use?", .identity, [
                "How did you discover that talent?",
                "Has it ever come in handy in an unexpected way?",
            ]),
            ("What's the last thing you stayed up way too late doing?", .dailyLife, [
                "Was it worth the lost sleep?",
                "What made it so hard to stop?",
            ]),
            ("What's a trend you absolutely refuse to get on board with?", .values, [
                "What is it about that trend that rubs you the wrong way?",
                "Do people give you a hard time about it?",
            ]),
            ("What's the most thoughtful thing a friend has ever done for you?", .appreciation, [
                "What made it feel so meaningful?",
                "How did it change the way you see that friendship?",
            ]),
            ("What's something you only do when nobody's watching?", .identity, [
                "Why do you keep it private?",
                "What do you think someone would misunderstand about it?",
            ]),
            ("What's a feeling you've had recently that caught you off guard?", .emotions, [
                "What do you think triggered it?",
                "Did you tell anyone about it or just sit with it?",
            ]),
        ], mode: .friends, intensity: .light, depth: .warmUp)
    }

    // MARK: - Friends · Light · Real Talk

    static func friends_light_realTalk() -> [Prompt] {
        make([
            ("Who's someone who had a huge impact on your life without ever realizing it?", .appreciation, [
                "What did they do that changed things for you?",
                "Have you ever considered telling them?",
            ]),
            ("When did you completely flip your perspective on something you used to believe?", .growth, [
                "What finally made it click?",
                "How did that shift change the way you move through the world?",
            ]),
            ("Who do you owe a long-overdue thank you?", .appreciation, [
                "What's been stopping you from saying it?",
                "What would you want them to know?",
            ]),
            ("What's something friendship taught you about being chosen that nothing else really could have?", .growth, [
                "Who or what taught you that lesson?",
                "How does that lesson shape the way you show up with people now?",
            ]),
        ], mode: .friends, intensity: .light, depth: .realTalk)
    }

    // MARK: - Friends · Light · Deep Dive

    static func friends_light_deepDive() -> [Prompt] {
        make([
            ("How do you think we've rubbed off on each other over time?", .growth, [
                "Is there something you picked up from me that surprised you?",
                "What part of that influence are you most grateful for?",
            ]),
            ("What do you think keeps our friendship going through everything?", .appreciation, [
                "Has there been a moment where that bond was tested?",
                "What would you never want to lose about what we have?",
            ]),
            ("What's a value you think we share that really matters to you?", .values, [
                "When did you first notice we shared that?",
                "How does that shared value show up in the way we treat each other?",
            ]),
            ("What's a moment where you felt like I really got you?", .intimacy, [
                "What had you been needing in that moment?",
                "How did it change the way you see our friendship?",
            ]),
        ], mode: .friends, intensity: .light, depth: .deepDive)
    }

    // MARK: - Friends · Honest · Warm Up

    static func friends_honest_warmUp() -> [Prompt] {
        make([
            ("What's a story people tell about you that isn't quite right — but you never bother to correct?", .communication, [
                "Why do you let it stand?",
                "What would the real version sound like?",
            ]),
            ("What does a close friend do that quietly gets under your skin — something you've never actually said out loud?", .conflict, [
                "What stops you from saying something?",
                "Do you think they'd be surprised to hear it?",
            ]),
            ("What truth have you been making easier for friends to hold than it really is?", .communication, [
                "What have you been softening or editing for their sake?",
                "What feels risky about letting a friend hold the fuller version?",
            ]),
            ("What's a friendship you let fade that you sometimes regret?", .past, [
                "What got in the way of keeping it alive?",
                "What would you say to them if you reconnected?",
            ]),
            ("What do you wish your friends understood about your life right now?", .communication, [
                "What's the biggest gap between how it looks and how it feels?",
                "Why is that hard to explain?",
            ]),
            ("When was the last time you felt left out by people you care about?", .emotions, [
                "What made that sting so much?",
                "Did you say anything about it?",
            ]),
            ("What's something a friend sees in you that you still struggle to believe about yourself?", .appreciation, [
                "Why is that quality harder for you to trust in yourself than it is for them to see?",
                "What would change if you let their view in a little more?",
            ]),
            ("What do you find hardest about staying woven into your friends' lives as you get older?", .communication, [
                "What do you think has changed the most?",
                "What would your ideal friendship look like at this stage?",
            ]),
            ("When's the last time you felt genuinely jealous of a friend?", .emotions, [
                "What was it about their situation that got to you?",
                "What does that jealousy tell you about what you want?",
            ]),
            ("What's a topic you avoid with certain friends and why?", .communication, [
                "What are you afraid would happen if you brought it up?",
                "Does avoiding it create distance between you?",
            ]),
            ("What's the hardest part about being honest with the people closest to you?", .communication, [
                "What are you usually trying to protect — them or yourself?",
                "When has honesty actually brought you closer?",
            ]),
            ("What do you wish your friends would ask you instead of assuming they already know?", .emotions, [
                "What's behind the thing you wish they'd ask about?",
                "What would it mean to you if someone actually asked?",
            ]),
            ("What's an opinion you hold that you know your friends would push back on?", .values, [
                "What makes you hold onto it anyway?",
                "Have you ever tested it out loud?",
            ]),
            ("When did a friend disappoint you in a way they probably don't know about?", .conflict, [
                "Why didn't you say anything?",
                "Has it changed the way you see them?",
            ]),
            ("What's a part of your personality that only comes out around certain people?", .identity, [
                "What is it about those people that brings it out?",
                "Do you like that version of yourself?",
            ]),
            ("What's been harder lately than you've let your friends see?", .emotions, [
                "What are you protecting them from — or protecting yourself from?",
                "What would it feel like to stop holding that alone?",
            ]),
            ("Where do you think you fall short as a friend — not in theory, but with someone specific?", .growth, [
                "What gets in the way of being better in that spot?",
                "Do you think they notice?",
            ]),
            ("What's a conversation you had recently that left you thinking for days?", .communication, [
                "What was it about that conversation that stuck?",
                "Did it change your mind about anything?",
            ]),
            ("When was the last time you really showed up for someone in a meaningful way?", .appreciation, [
                "What made you step up in that moment?",
                "How did it feel to be that person for them?",
            ]),
            ("How much effort does it actually take to keep your friendships going right now?", .dailyLife, [
                "Which ones feel easy and which ones feel like work?",
                "What does that effort say about where you are in life?",
            ]),
        ], mode: .friends, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Friends · Honest · Real Talk

    static func friends_honest_realTalk() -> [Prompt] {
        make([
            ("When were you harder on a friend than the moment actually called for?", .conflict, [
                "What was really going on underneath?",
                "Did you ever make it right?",
            ]),
            ("What do you hold back from saying around friends because you're worried it would change how they see you?", .identity, [
                "What do you think you're protecting by staying quiet?",
                "Has holding it back changed how you see yourself?",
            ]),
            ("Which of your friendships asks the most of you right now?", .conflict, [
                "What makes it so demanding?",
                "Is the effort making the friendship stronger or wearing it thin?",
            ]),
            ("Is there a friend you admire so much it's hard to feel like an equal around them?", .identity, [
                "What is it about them that has that effect on you?",
                "Do you think they'd be surprised to hear that?",
            ]),
            ("What's something only the people who've known you a long time really see about you?", .intimacy, [
                "Why do you think that part of you only comes out in that kind of history?",
                "What does it change to be known that way by only a few people?",
            ]),
            ("What's something from your past that you hope the friends who know about it have forgotten?", .past, [
                "What about it still sits with you?",
                "Would it change things if they brought it up now?",
            ]),
            ("What's the kindest thing a friend has done for you that you never properly acknowledged?", .appreciation, [
                "What kept you from saying something at the time?",
                "Do you think they know what it meant to you?",
            ]),
            ("Think of a recent moment when a friend wasn't really there when it mattered — what happened?", .dailyLife, [
                "Did you say anything or just let it go?",
                "How did it change what you expect from that friendship?",
            ]),
            ("What's something you've come to understand about a friend that made closeness feel harder?", .intimacy, [
                "What shifted in you once you saw that more clearly?",
                "Have you found a way to stay honest about it with yourself?",
            ]),
            ("Have you ever stayed in a friendship mostly out of loyalty rather than genuine closeness?", .values, [
                "What keeps you showing up even when the feeling isn't really there?",
                "What would it take to honestly let it go?",
            ]),
            ("When has a friend's honesty actually hurt, even though they were probably right?", .conflict, [
                "What made it land so hard?",
                "Did it change anything about how you see yourself?",
            ]),
            ("What do you think you'd lose if your friends saw every part of you clearly?", .identity, [
                "Which part feels most risky to show?",
                "Is it really about them, or about how you see yourself?",
            ]),
        ], mode: .friends, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Friends · Honest · Deep Dive

    static func friends_honest_deepDive() -> [Prompt] {
        make([
            ("What's something you've never told a close friend because you're afraid of how they'd see you after?", .intimacy, [
                "What do you think it would cost you to say it?",
                "Is there anyone you trust enough to try?",
            ]),
            ("Is there a friend you owe something — an apology, a thank-you, an explanation — that you've been putting off?", .conflict, [
                "What's stopped you from giving it?",
                "What do you think it would change between you?",
            ]),
            ("Who's a friend you haven't shown up for the way you wish you had?", .conflict, [
                "What got in the way?",
                "If you could go back to that moment, what would you do differently?",
            ]),
            ("How do you decide which friendships are worth the effort when life gets overwhelming?", .dailyLife, [
                "Have you ever let a friendship slip away that you now regret?",
                "What helps you know which friendships you want to keep tending?",
            ]),
            ("What have you forgiven a friend for without ever feeling fully repaired?", .conflict, [
                "What part of it still feels unfinished in you?",
                "What would repair have needed that never really happened?",
            ]),
            ("What kind of loneliness can still exist inside a long friendship?", .intimacy, [
                "When do you feel it most clearly?",
                "What do you think makes that kind of loneliness hard to admit?",
            ]),
            ("Where have you accepted less care from a friend than you know you deserved?", .conflict, [
                "What made you settle for that version of the friendship?",
                "What would it take to want more without feeling unreasonable?",
            ]),
            ("Which friendship has changed who you are the most, and what did it ask you to become?", .growth, [
                "What did that friendship draw out of you that might have stayed hidden otherwise?",
                "Do you like who it helped you become?",
            ]),
        ], mode: .friends, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Friends · Unfiltered · Warm Up

    static func friends_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What's something you pretend doesn't bother you but absolutely does?", .emotions, [
                "What makes you keep pretending?",
                "What might shift if you admitted it out loud?",
            ]),
            ("What do people get wrong about you the most?", .communication, [
                "What do you think creates that impression?",
                "Have you ever tried to correct it?",
            ]),
            ("What opinion do you hold that most of your friends would disagree with?", .values, [
                "What makes you so sure you're right about it?",
                "Have you ever tested it in conversation?",
            ]),
            ("What's the worst advice you've ever followed?", .growth, [
                "What made you trust it at the time?",
                "What did the fallout teach you?",
            ]),
            ("What's a part of yourself you've had to fight to accept?", .identity, [
                "What made the acceptance so hard?",
                "Are you fully there, or still working on it?",
            ]),
            ("What's something you've done that you'll never fully explain to anyone?", .past, [
                "What would someone need to understand to make sense of it?",
                "Does keeping it to yourself feel like protection or a burden?",
            ]),
            ("When have you been the villain in someone else's story?", .conflict, [
                "Do you agree with their version of it?",
                "What would your side of the story sound like?",
            ]),
            ("What's a belief you held strongly that completely fell apart?", .values, [
                "What caused it to collapse?",
                "What do you believe now in its place?",
            ]),
            ("What's something about the way you were raised that you've had to unlearn?", .growth, [
                "When did you first realize it wasn't serving you?",
                "What did you replace it with?",
            ]),
            ("What's the loneliest you've ever felt in a room full of people?", .emotions, [
                "What was happening around you that made it worse?",
                "What would have made you feel less alone?",
            ]),
            ("What's a side of yourself that only comes out when you're angry?", .identity, [
                "Are you afraid of that side or do you trust it?",
                "What does it usually look like when it shows up?",
            ]),
            ("What's something you've said that you can never take back?", .conflict, [
                "Do you wish you could, or do you stand by it?",
                "How did it change things between you and that person?",
            ]),
            ("What's a truth about yourself that most people couldn't handle?", .identity, [
                "What makes you think they couldn't handle it?",
                "Who in your life could?",
            ]),
            ("When was the last time you seriously considered cutting someone off?", .conflict, [
                "What brought you to that edge?",
                "Did you go through with it?",
            ]),
            ("What's something you judge other people for that you're also guilty of?", .values, [
                "Why is it easier to see the flaw in others than in yourself?",
                "What would change if you applied the same standard to yourself?",
            ]),
            ("What's the most selfish thing you've done that you don't regret?", .values, [
                "What did putting yourself first give you?",
                "Would you make the same choice again?",
            ]),
            ("What's a feeling you've been suppressing for way too long?", .emotions, [
                "What are you afraid would happen if you let it surface?",
                "What's it costing you to keep it down?",
            ]),
            ("What's something you've never been able to forgive yourself for?", .emotions, [
                "What would forgiving yourself actually require?",
                "What's made that forgiveness so hard to give yourself?",
            ]),
            ("What do you wish people would stop pretending to care about?", .values, [
                "What does the performance bother you about specifically?",
                "What would genuine care look like instead?",
            ]),
            ("What's a moment where you realized a friendship was one-sided?", .conflict, [
                "What made it suddenly clear?",
                "What did you do with that realization?",
            ]),
            ("What's something dark you've thought about that you'd never say out loud?", .emotions, [
                "What do you think that thought is really pointing to?",
                "Does having it scare you, or does it feel more human than you expected?",
            ]),
            ("What's the most honest thing you've ever said to someone's face?", .communication, [
                "How did they take it?",
                "Would you say it again?",
            ]),
            ("What's an experience that hardened you in a way others don't see?", .past, [
                "What part of you did it close off?",
                "Does that hardening feel more like protection, loss, or both?",
            ]),
            ("When did you last feel truly ashamed of yourself?", .emotions, [
                "What triggered the shame?",
                "What has helped you move through any of it, if at all?",
            ]),
            ("What's a secret you've kept from your closest friends?", .intimacy, [
                "What would change in those friendships if they knew?",
                "What's kept you from sharing it?",
            ]),
            ("What's a way you've manipulated a situation that you're not proud of?", .conflict, [
                "What were you trying to get out of it?",
                "Would you handle it differently now?",
            ]),
            ("What's a double standard you hold that you know isn't fair?", .values, [
                "What makes it hard to let go of?",
                "Has anyone ever called you on it?",
            ]),
            ("What's something you lost respect for someone over?", .conflict, [
                "Was it one moment or a slow build?",
                "Did you ever tell them?",
            ]),
            ("When's the last time you cried and what set it off?", .emotions, [
                "Did you let yourself fully go there or try to hold it together?",
                "What did the cry release in you?",
            ]),
            ("What's a question you're afraid someone might ask you?", .emotions, [
                "What's the honest answer you'd have to give?",
                "What makes that truth feel so dangerous?",
            ]),
            ("What's something you do in your daily routine that you know is avoidance?", .dailyLife, [
                "What are you actually avoiding when you do it?",
                "What would your day look like if you stopped?",
            ]),
        ], mode: .friends, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Friends · Unfiltered · Real Talk

    static func friends_unfiltered_realTalk() -> [Prompt] {
        make([
            ("When's a time you knew you were wrong but couldn't bring yourself to admit it?", .conflict, [
                "What was at stake that made the admission feel impossible?",
                "Do you think the other person knew you were wrong?",
            ]),
            ("What's something you've never really told anyone how you feel about?", .emotions, [
                "What has keeping it inside done to you?",
                "What would finally saying it change?",
            ]),
            ("What's something you really hope certain people never find out about?", .intimacy, [
                "What are you most afraid they'd think?",
                "What do you imagine would change if they knew?",
            ]),
            ("Who was the last person who really pushed you past your breaking point?", .conflict, [
                "What did your breaking point look like?",
                "What helped you come back from it?",
            ]),
            ("What's a grudge you've been carrying longer than you want to?", .conflict, [
                "What would it take to finally set it down?",
                "What does holding onto it give you?",
            ]),
            ("What's a friendship you damaged that you sometimes still think about?", .conflict, [
                "What do you think you would have done differently?",
                "Do you think repair is still possible?",
            ]),
            ("What does loyalty actually mean to you when it gets tested?", .values, [
                "When has your loyalty been tested the hardest?",
                "Where do you draw the line between loyalty and self-respect?",
            ]),
            ("How honest are you about how much emotional effort your friendships take from you?", .dailyLife, [
                "Who tends to get the most from you, and do they know it?",
                "What do you imagine would happen if you stopped carrying quite so much of it?",
            ]),
        ], mode: .friends, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Friends · Unfiltered · Deep Dive

    static func friends_unfiltered_deepDive() -> [Prompt] {
        make([
            ("Is there a friendship you've outgrown but haven't walked away from yet?", .conflict, [
                "What's keeping you in it?",
                "What would walking away actually cost you?",
            ]),
            ("What's a story you've told before but never the complete, honest version?", .intimacy, [
                "What's the part you always leave out?",
                "What do you think the full version would reveal about you?",
            ]),
            ("When did someone break your trust in a way that changed how you operate?", .conflict, [
                "What kind of protection did you build because of it?",
                "Has anyone since earned the kind of trust you lost?",
            ]),
            ("What's a way you've quietly stopped making effort in a friendship without ever saying why?", .dailyLife, [
                "Was it a conscious decision or did it just happen?",
                "Do you think they noticed, and does that matter to you?",
            ]),
        ], mode: .friends, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Family · Light · Warm Up

    static func family_light_warmUp() -> [Prompt] {
        make([
            ("What's a value from your culture or background that really matters to you?", .values, [
                "How do you try to live that value out day to day?",
                "Is it something you want to pass on?",
            ]),
            ("What's a moment from your younger years you can't believe you walked away from?", .past, [
                "What do you think kept you safe?",
                "How did it change the risks you take now?",
            ]),
            ("What's a story you know you've told way too many times?", .dailyLife, [
                "What is it about that story that keeps pulling you back?",
                "Does anyone in your life finish it for you at this point?",
            ]),
            ("What's a smell that instantly takes you back to a specific moment?", .past, [
                "What's the memory tied to it?",
                "How does it make you feel when it hits you unexpectedly?",
            ]),
            ("What's something you genuinely can't believe you got away with growing up?", .past, [
                "How do you feel about that version of yourself now?",
                "Who still knows that story besides you?",
            ]),
            ("What completely breaks your willpower every single time?", .dailyLife, [
                "What is it about that thing that makes you cave?",
                "Have you ever successfully resisted, and how?",
            ]),
            ("What's something you miss being able to do that you used to take for granted?", .past, [
                "When did you stop being able to do it?",
                "What would it mean to get it back?",
            ]),
            ("What do you wish you could still get away with?", .past, [
                "What made it possible back then?",
                "What changed?",
            ]),
            ("What's your most irrational fear — the one that makes no logical sense?", .emotions, [
                "How do you deal with it when it comes up?",
                "Do you have any idea where it started?",
            ]),
            ("What's the best prank you've ever managed to pull off?", .dailyLife, [
                "How did the person react?",
                "Did it become a legendary family story?",
            ]),
            ("What's a totally normal thing that makes you weirdly self-conscious?", .dailyLife, [
                "When did you first notice it bothered you?",
                "Do other people pick up on it?",
            ]),
            ("What's the most uncomfortable gathering you've ever had to sit through?", .dailyLife, [
                "What made it so painful?",
                "How did you survive it?",
            ]),
            ("What did you used to daydream about for hours as a kid?", .past, [
                "Is any part of that daydream still alive in you?",
                "What does it say about what you wanted most?",
            ]),
            ("What's the last thing you saw or read that you definitely weren't supposed to?", .dailyLife, [
                "How did it affect you?",
                "Did you tell anyone about it?",
            ]),
            ("What's the most meaningful gift anyone has ever given you?", .appreciation, [
                "What made it so special?",
                "What does it still hold for you now?",
            ]),
            ("What makes you feel proudest about your family?", .appreciation, [
                "Is that something your family knows you feel?",
                "What do you think built that quality?",
            ]),
            ("What's a guilty pleasure you will always defend?", .dailyLife, [
                "Why does it bring you so much joy?",
                "Who gives you the hardest time about it?",
            ]),
            ("What's a family recipe or tradition you never want to lose?", .values, [
                "What memory is attached to it?",
                "Are you the one keeping it alive?",
            ]),
            ("What's the funniest thing that ever happened at a family gathering?", .dailyLife, [
                "Who was at the center of it?",
                "Does it still come up at every gathering?",
            ]),
            ("What's something you still do because of the way a family member taught you?", .appreciation, [
                "Were they teaching you on purpose or was it just by example?",
                "Have you ever thanked them for it?",
            ]),
            ("What's a nickname from your childhood and how did you get it?", .past, [
                "Do you love it or wish it would die?",
                "Does anyone still call you that?",
            ]),
            ("What's a family trip or vacation you'll never forget?", .past, [
                "What made it so memorable — something that went right or hilariously wrong?",
                "Who do you associate that trip with most?",
            ]),
            ("What did you get in trouble for the most as a kid?", .past, [
                "Were you actually guilty most of the time?",
                "Do you see any of that same behavior in yourself now?",
            ]),
            ("What's a song or movie that always reminds you of your family?", .appreciation, [
                "What feeling does it bring up?",
                "Is it a happy association or a complicated one?",
            ]),
            ("What's something your family is surprisingly competitive about?", .dailyLife, [
                "Who's the worst competitor in the family?",
                "Has it ever gotten out of hand?",
            ]),
            ("What's a family joke that an outsider would never understand?", .dailyLife, [
                "What's the story behind it?",
                "Who started it?",
            ]),
            ("What's a skill you picked up from watching a family member?", .growth, [
                "Did they know you were learning from them?",
                "How has that skill shaped your life?",
            ]),
            ("What's a piece of advice from a family member that still stays with you?", .values, [
                "When did you first realize they were right?",
                "Has it held up over time?",
            ]),
            ("What holiday tradition means the most to you and why?", .values, [
                "What would it feel like if that tradition stopped?",
                "What does it represent to you beyond the tradition itself?",
            ]),
            ("Who in your family has always known how to make you feel a little better?", .appreciation, [
                "What do they do that works so well?",
                "Do they know they have that power?",
            ]),
            ("What's something your family always talks about at every gathering?", .communication, [
                "Is it something everyone enjoys or just a habit at this point?",
                "What topic do you wish would come up more instead?",
            ]),
            ("What's something your family playfully argues about every time you get together?", .conflict, [
                "Does anyone actually get heated or is it all in good fun?",
                "Which side are you always on?",
            ]),
        ], mode: .family, intensity: .light, depth: .warmUp)
    }

    // MARK: - Family · Light · Real Talk

    static func family_light_realTalk() -> [Prompt] {
        make([
            ("What's a story about you that you'd love to see passed down in your family?", .values, [
                "What does that story capture about who you are?",
                "Who would you want to be the one telling it?",
            ]),
            ("What's one day in your life you know you'll never forget?", .past, [
                "What made that day burn itself into your memory?",
                "How did it change you?",
            ]),
            ("How did you see the world when you were young, and when did that change?", .past, [
                "What experience was the turning point?",
                "Do you miss seeing things that way?",
            ]),
            ("What's the kindest thing anyone has ever done for you?", .appreciation, [
                "What made it feel so deeply kind?",
                "Did it change what you believe people are capable of?",
            ]),
            ("What's something your family does that you didn't appreciate until you were older?", .appreciation, [
                "What made you finally see it differently?",
                "Have you ever let them know you see it that way now?",
            ]),
            ("What's something about your family that felt ordinary growing up but now feels special to you?", .appreciation, [
                "When did you start seeing it differently?",
                "What does it mean to you now?",
            ]),
        ], mode: .family, intensity: .light, depth: .realTalk)
    }

    // MARK: - Family · Light · Deep Dive

    static func family_light_deepDive() -> [Prompt] {
        make([
            ("How has your idea of what family means changed over the years?", .values, [
                "What experience shifted it the most?",
                "What does family mean to you now that it didn't before?",
            ]),
            ("What do you hope the next generation picks up from how we are?", .values, [
                "What's the one thing you'd want them to carry forward?",
                "What would you hope they leave behind?",
            ]),
            ("What moment brought us closer than anything else?", .intimacy, [
                "What was it about that moment that broke through?",
                "How did things feel different after?",
            ]),
            ("What's your favorite thing about being part of this family?", .appreciation, [
                "When do you feel that the strongest?",
                "Is there anything you'd add to make it even better?",
            ]),
        ], mode: .family, intensity: .light, depth: .deepDive)
    }

    // MARK: - Family · Honest · Warm Up

    static func family_honest_warmUp() -> [Prompt] {
        make([
            ("What feelings come up for you around family gatherings?", .emotions, [
                "Is it more anticipation, dread, or something in between?",
                "How do you usually cope with whatever comes up?",
            ]),
            ("What's something you think this family avoids talking about?", .communication, [
                "What do you think would happen if someone finally brought it up?",
                "How does the silence around it affect everyone?",
            ]),
            ("What's something that's changed in this family that you're still adjusting to?", .emotions, [
                "What part of the change has been hardest?",
                "What would help you adjust?",
            ]),
            ("What's a family expectation you've struggled to live up to?", .values, [
                "Do you want to meet that expectation, or let it go?",
                "What kind of pressure does it put on you?",
            ]),
            ("What's something you wish you had said to a family member sooner?", .communication, [
                "What stopped you from saying it when it mattered?",
                "Is there still time?",
            ]),
            ("When did you first realize your family wasn't like everyone else's?", .past, [
                "How did that realization hit you?",
                "Did it change the way you felt about your family?",
            ]),
            ("What's a way your family shows love that took you a while to recognize?", .appreciation, [
                "What did you think it was before you understood it as love?",
                "How do you feel about it now?",
            ]),
            ("What role do you play in your family and how do you feel about it?", .identity, [
                "Did you choose that role or did it choose you?",
                "What would happen if you stopped playing it?",
            ]),
            ("What's something you've inherited from your parents — a habit or trait — that surprises you?", .identity, [
                "When did you first notice it in yourself?",
                "Is it something you want to keep or let go of?",
            ]),
            ("What's one thing you still love about your childhood?", .past, [
                "What do you miss most about that version of life?",
                "Have you found anything in adulthood that gives you a similar feeling?",
            ]),
            ("What's something your parents kept getting wrong about what you needed?", .past, [
                "How did you adapt to not getting it from them?",
                "Do you think they understand it any better now?",
            ]),
            ("What's a sacrifice a family member made for you that you think about often?", .appreciation, [
                "Do they know how much it meant to you?",
                "How did it shape the way you show up for others?",
            ]),
            ("What's something about your upbringing you didn't question until you were older?", .growth, [
                "What made you start questioning it?",
                "How did the new perspective change you?",
            ]),
            ("Who in your family do you understand differently now that you're older?", .growth, [
                "What changed your understanding of them?",
                "Has that made closeness easier or more complicated?",
            ]),
            ("What did your family teach you to do when trust gets broken?", .values, [
                "Was that lesson spoken out loud or learned by watching?",
                "Is it still how you handle hurt now?",
            ]),
            ("What's a misunderstanding in your family that was never properly cleared up?", .conflict, [
                "Does it still affect how you relate to each other?",
                "What would it take to finally clear the air?",
            ]),
            ("What do you think your family worries about most when it comes to you?", .emotions, [
                "Does any part of that worry feel true to you?",
                "How do you feel knowing they carry that concern?",
            ]),
            ("When has your family been at its best, and what made that version possible?", .appreciation, [
                "What was different about everyone then?",
                "Do you think that version of your family is still reachable?",
            ]),
            ("What's something about the role everyone plays in your family that outsiders wouldn't understand?", .communication, [
                "Does it work for you, or do you wish it were different?",
                "What would you want someone outside to know?",
            ]),
            ("When did your family show up in a way that made you feel less alone?", .appreciation, [
                "What about the way they showed up actually landed with you?",
                "Did it change what you believed they were capable of giving?",
            ]),
            ("What's a conversation you keep having with family that never goes anywhere?", .conflict, [
                "Why do you think it keeps stalling?",
                "What would a breakthrough actually look like?",
            ]),
            ("What's something you appreciate about your family that you rarely say?", .appreciation, [
                "What makes it hard to say out loud?",
                "What do you think it would mean to them to hear it?",
            ]),
            ("What's a lesson your family taught you through their mistakes?", .growth, [
                "How did watching that mistake affect you growing up?",
                "Has it changed the way you handle similar situations?",
            ]),
            ("What's a way you've tried to break a family pattern?", .growth, [
                "How has that effort gone?",
                "What makes the pattern so hard to break?",
            ]),
            ("What emotion do you associate most with your childhood home?", .emotions, [
                "Is that emotion something you carry with you still?",
                "How does it color the way you think about home now?",
            ]),
            ("What's something you've forgiven a family member for that took a lot out of you?", .conflict, [
                "What did that forgiveness ask of you?",
                "Did the forgiveness change the relationship?",
            ]),
            ("What does your family do well that still feels worth protecting?", .appreciation, [
                "When does that best part of your family show up most clearly?",
                "What would you hate to see your family lose?",
            ]),
            ("What's a story about your parents' early life that changed how you see them?", .past, [
                "What did it help you understand about who they are?",
                "Did it make you feel closer to them or more complicated about them?",
            ]),
            ("What's something your family knows but keeps acting like it doesn't?", .communication, [
                "How does everyone help keep that truth unspoken?",
                "What do you think would change if someone named it plainly?",
            ]),
            ("When have you felt torn between loving your family and needing distance from them?", .emotions, [
                "What was happening that made both feelings true at once?",
                "How do you usually handle that tension?",
            ]),
            ("What's a family obligation you show up for even though it drains you?", .dailyLife, [
                "What keeps you going through the motions?",
                "What would happen if you were honest about how it feels?",
            ]),
        ], mode: .family, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Family · Honest · Real Talk

    static func family_honest_realTalk() -> [Prompt] {
        make([
            ("What's a conversation with your parents that's been waiting for its moment?", .communication, [
                "What's been holding it back?",
                "How do you imagine it going?",
            ]),
            ("What's a choice someone in your family made that you're still living inside of?", .past, [
                "How much say did you have in it at the time?",
                "Does it still feel like their choice, or is it yours now too?",
            ]),
            ("Who tends to hold the most power in your family, and how does that shape everyone else?", .communication, [
                "Is that power dynamic acknowledged or unspoken?",
                "How has it shaped your own relationship with authority?",
            ]),
            ("What part of the way you were parented are you most afraid to repeat?", .emotions, [
                "When do you feel that pattern most close to the surface?",
                "What would it take to interrupt it?",
            ]),
            ("What did your family make feel normal that took you years to question?", .past, [
                "What helped you finally see it differently?",
                "How did that realization change the way you saw your upbringing?",
            ]),
            ("What's something about your family that people misread unless they've lived close enough to see it?", .values, [
                "What do outsiders usually get wrong?",
                "What does that misunderstanding miss about what it was actually like?",
            ]),
            ("How was conflict between siblings handled in your family, and do you still handle conflict that way now?", .conflict, [
                "How is that way of handling conflict working for you these days?",
                "What do you wish you had learned instead?",
            ]),
            ("What's something your family still holds against you that you no longer think defines you?", .values, [
                "What do they still seem to see when they look at that part of your past?",
                "What would it mean for them to let you be more current than that story?",
            ]),
            ("Who in your family carries a lot of invisible labor, and does it get acknowledged?", .dailyLife, [
                "How did that role get assigned?",
                "What would change if they stopped doing it for a week?",
            ]),
        ], mode: .family, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Family · Honest · Deep Dive

    static func family_honest_deepDive() -> [Prompt] {
        make([
            ("What do you wish someone had told you when you were growing up?", .past, [
                "How would hearing it have changed things for you?",
                "Who do you wish had been the one to say it?",
            ]),
            ("What's something that happened in your family that shaped you more than most people know?", .past, [
                "Why do you think you don't talk about it much?",
                "What would people understand differently about you if they knew?",
            ]),
            ("What did your parents teach you about love — whether they meant to or not?", .intimacy, [
                "Was it a lesson you had to unlearn or one you're grateful for?",
                "How does it show up in your relationships now?",
            ]),
            ("Who in your family taught you the most about what love looks like in real life?", .intimacy, [
                "What did they do that made the lesson stick?",
                "Was it a lesson you wanted to keep, or one you had to revise for yourself?",
            ]),
            ("If you could change one thing about the way you were raised, what would it be?", .past, [
                "How do you think that one change might have rippled through your life?",
                "Have you been able to talk to your parents about it?",
            ]),
            ("What would you say to the version of you who was trying to survive your family as a kid?", .past, [
                "What did that younger version of you need that they weren't getting?",
                "What do you still carry from the way they learned to cope?",
            ]),
            ("What's a routine your family had that shaped you more than anyone realizes?", .dailyLife, [
                "Was it something intentional or just the way things were?",
                "How does it still show up in your life now?",
            ]),
        ], mode: .family, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Family · Unfiltered · Warm Up

    static func family_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What role do you play in your family, and how did that happen?", .identity, [
                "Is it a role you want, or one that was assigned to you?",
                "Who might you be if you didn't have to carry that role?",
            ]),
            ("What conversation are you dreading that you know needs to happen?", .conflict, [
                "What's the worst outcome you're imagining?",
                "What would waiting any longer cost you?",
            ]),
            ("What would change if everyone in this family said what they actually meant?", .communication, [
                "Would it bring you closer or blow things apart?",
                "Who has the most they're holding back?",
            ]),
            ("What's a family secret that shaped you more than anyone realizes?", .past, [
                "How did you find out about it?",
                "What did carrying that knowledge do to you?",
            ]),
            ("What's the biggest lie your family tells itself?", .communication, [
                "Who benefits from keeping that lie alive?",
                "What do you think the truth would ask of everyone?",
            ]),
            ("What's something from your childhood in this family that still catches up with you?", .emotions, [
                "When does it usually come back to the surface?",
                "What do you think it still wants from you now?",
            ]),
            ("What's a wound from your family that still hasn't healed?", .emotions, [
                "What keeps it from healing?",
                "What would healing actually look like for you?",
            ]),
            ("When did you stop trying to earn a family member's approval?", .growth, [
                "What was the final straw?",
                "How did letting go of it change you?",
            ]),
            ("What's something you resent about how responsibilities are divided in your family?", .conflict, [
                "Have you ever brought it up?",
                "What would fair actually look like to you?",
            ]),
            ("What's a part of your family history that feels heavy to carry?", .past, [
                "Do you feel responsible for that weight?",
                "Who else in the family carries it with you?",
            ]),
            ("What's something a family member did that you've never really been able to forgive?", .conflict, [
                "What do you think forgiveness would require from you?",
                "What keeps the wound open?",
            ]),
            ("What do you wish your parents really knew about your life right now?", .communication, [
                "What's stopped you from telling them?",
                "How do you think they'd react?",
            ]),
            ("What's a way your family made you feel small without realizing it?", .emotions, [
                "Does it still happen?",
                "How has that feeling shaped the way you see yourself?",
            ]),
            ("What's a harmful pattern in your family that you're trying not to repeat?", .growth, [
                "When do you catch yourself falling into it?",
                "What are you trying to practice instead?",
            ]),
            ("What's the hardest thing about loving someone in your family?", .emotions, [
                "What makes the love complicated?",
                "How do you make sense of that difficulty now?",
            ]),
            ("What's a part of your identity that your family still doesn't fully accept?", .identity, [
                "How does their lack of acceptance affect you day to day?",
                "Have you stopped trying to get them to see it?",
            ]),
            ("What would your younger self think about your relationship with your family now?", .past, [
                "Would they be relieved, confused, or heartbroken?",
                "What would you want to explain to them?",
            ]),
            ("What's a boundary with family that you had to fight to set?", .conflict, [
                "What did it cost you to hold that line?",
                "Has it been respected since?",
            ]),
            ("What's something you've never confronted a family member about but may need to?", .communication, [
                "What's held you back?",
                "What would you say if you finally did?",
            ]),
            ("What's a way your family dealt with conflict that you've had to unlearn?", .conflict, [
                "What did you replace it with?",
                "Was the unlearning gradual or forced by a specific moment?",
            ]),
            ("What's the most painful thing a family member has ever said to you?", .emotions, [
                "Do you think they knew how much it hurt?",
                "How did it change the way you relate to them?",
            ]),
            ("When have you felt like the black sheep of your family?", .identity, [
                "Was it something you did or just who you are?",
                "Have you made peace with that outsider feeling?",
            ]),
            ("What's something about your parents' relationship that affected how you see love?", .intimacy, [
                "Was it something you wanted to replicate or avoid?",
                "How does it show up in your own relationships?",
            ]),
            ("What's an unfair expectation that was placed on you growing up?", .values, [
                "Who put it there?",
                "Have you been able to let it go, or does it still drive you?",
            ]),
            ("What's a truth about your family that nobody outside would believe?", .communication, [
                "What would someone need to see to understand?",
                "How do you hold that truth and the public version at the same time?",
            ]),
            ("What do you carry from your family that you wish you could put down?", .emotions, [
                "What keeps you holding onto it?",
                "What would your life look like without that weight?",
            ]),
            ("What's a sacrifice you made for your family that went unnoticed?", .appreciation, [
                "How did it feel to give that without recognition?",
                "Would you do it again?",
            ]),
            ("What's something you swore you'd never do as a parent that you catch yourself doing?", .growth, [
                "How does it feel when you notice it?",
                "What are you trying to do differently in spite of it?",
            ]),
            ("When did you first realize you were repeating a family pattern?", .growth, [
                "What tipped you off?",
                "Have you been able to interrupt it?",
            ]),
            ("What's the thing your family is most in denial about?", .communication, [
                "What would acknowledging it require from everyone?",
                "Do you think anyone else in the family sees it too?",
            ]),
            ("What's a family gathering tradition that feels more like a performance than a real connection?", .dailyLife, [
                "Who is the performance really for?",
                "What would it look like if everyone just dropped the act?",
            ]),
        ], mode: .family, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Family · Unfiltered · Real Talk

    static func family_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What subject could split your family wide open if someone finally named it plainly?", .communication, [
                "Who has the most to lose if it gets said out loud?",
                "Do you think the fallout would be temporary, or would it change the family for good?",
            ]),
            ("Who in your family gets protected from the truth the most?", .communication, [
                "How does everyone help keep that protection in place?",
                "What does it cost the rest of the family to keep doing that?",
            ]),
            ("What's something you're afraid your kids — or future kids — might inherit from your family through you?", .past, [
                "When do you feel that inheritance most strongly in yourself?",
                "What are you doing, if anything, to keep it from passing through you unchanged?",
            ]),
            ("What's a question you've always wanted to ask your parents but never have?", .communication, [
                "What are you afraid the answer might be?",
                "What would it change if you finally asked?",
            ]),
            ("What household role were you assigned growing up that you never actually agreed to?", .dailyLife, [
                "How did it shape the way you show up in your family now?",
                "Have you ever tried to set it down or hand it back?",
            ]),
        ], mode: .family, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Family · Unfiltered · Deep Dive

    static func family_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something your family took from you that still shapes the way you live?", .past, [
                "How did losing it change who you became in that family?",
                "Do you think you can reclaim any part of it now?",
            ]),
            ("How did losing someone in your family affect you then, and how does it affect you now?", .emotions, [
                "What part of that loss still shows up in you today?",
                "Has the way it lives in you changed over time, or just gone quieter?",
            ]),
            ("What trait of your parents are you most afraid of seeing in yourself?", .past, [
                "When do you catch glimpses of it?",
                "What do you do when you see it surface?",
            ]),
            ("How was death explained in your family when you were growing up, and does that explanation still comfort you now?", .past, [
                "Did that explanation actually comfort you then, or did you just learn to live inside it?",
                "What do you believe about death now that feels different from what you were taught?",
            ]),
            ("What's something you've never told your parents?", .communication, [
                "What would it mean for them to finally know?",
                "What's kept you from saying it all this time?",
            ]),
            ("What's a conversation with a family member you still ache to have one more time?", .communication, [
                "What would you finally say if you had that chance?",
                "What do you still wish they had said back?",
            ]),
            ("What's a practical tension in your family that everyone works around instead of really addressing?", .dailyLife, [
                "What would it take to actually address it?",
                "Who benefits most from leaving it unresolved?",
            ]),
        ], mode: .family, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Solo Reflection · Light · Warm Up

    static func solo_light_warmUp() -> [Prompt] {
        make([
            ("What do you spend too much time doing that you probably shouldn't?", .dailyLife, [
                "What does it give you that keeps you coming back?",
                "What would you do with that time if you reclaimed it?",
            ]),
            ("What are you feeling genuinely proud of right now?", .appreciation, [
                "What did it take to get there?",
                "Have you let yourself fully enjoy it?",
            ]),
            ("What keeps showing up in your dreams lately?", .emotions, [
                "Do you think it's trying to tell you something?",
                "How does it leave you feeling when you wake up?",
            ]),
            ("What have you been quietly getting better at without anyone noticing?", .appreciation, [
                "What's been driving that quiet improvement?",
                "Does it matter to you whether people notice?",
            ]),
            ("What do you do when you're completely alone and nobody can see?", .dailyLife, [
                "What does that behavior say about who you really are?",
                "Is it something you enjoy or just a habit?",
            ]),
            ("What do you catch yourself complaining about the most?", .dailyLife, [
                "What's underneath the complaint?",
                "Is it something you can change, or do you just need to vent?",
            ]),
            ("What's a skill you used to have that you miss more than you expected?", .past, [
                "What did it let you feel or express when it was still part of your life?",
                "Do you want it back, or did it have its time and you've moved on?",
            ]),
            ("What's a small win you had recently that you didn't celebrate enough?", .appreciation, [
                "Why did you let it pass without acknowledgment?",
                "What would celebrating it have felt like?",
            ]),
            ("What's the last thing that genuinely surprised you about yourself?", .identity, [
                "Was it a good surprise or an unsettling one?",
                "What do you think it reveals about where you're headed?",
            ]),
            ("What's a comfort food that always makes everything a little better?", .dailyLife, [
                "What's the memory or feeling attached to it?",
                "Is it the taste or the ritual that comforts you?",
            ]),
            ("What's a place that always makes you feel calm?", .emotions, [
                "What is it about that place that settles you?",
                "When was the last time you went there?",
            ]),
            ("What's something you're looking forward to right now?", .dailyLife, [
                "What about it excites you the most?",
                "How does having something to look forward to change your mood?",
            ]),
            ("What would you do with an entire day with zero obligations?", .dailyLife, [
                "Would you plan it or let it unfold?",
                "What does your ideal version of that day say about what you need?",
            ]),
            ("What's something you've been meaning to get back into?", .growth, [
                "What pulled you away from it in the first place?",
                "What would it give you to pick it up again?",
            ]),
            ("What's the best compliment you've ever received?", .appreciation, [
                "Why did that one land so deeply?",
                "Do you believe it about yourself?",
            ]),
            ("What's a simple pleasure that never gets old for you?", .dailyLife, [
                "What makes it feel fresh every time?",
                "When did you first discover how much it means to you?",
            ]),
            ("What's something you're grateful for that you rarely think about?", .appreciation, [
                "What would your life look like without it?",
                "Why do you think it's so easy to overlook?",
            ]),
            ("What's a skill you picked up that changed your daily life?", .growth, [
                "How did you come to learn it?",
                "What difference does it make on a regular day?",
            ]),
            ("What's your go-to way to recharge when you're running on empty?", .dailyLife, [
                "Does it actually restore you, or just distract you?",
                "How do you know when you've hit empty?",
            ]),
            ("What's the last thing you learned that genuinely excited you?", .growth, [
                "What about it sparked that excitement?",
                "Have you done anything with it since?",
            ]),
            ("What's a childhood memory that always makes you smile?", .past, [
                "What about it still feels so warm?",
                "Who's in that memory with you?",
            ]),
            ("What's something about your morning routine that sets the tone for your day?", .dailyLife, [
                "What happens to your day when you skip it?",
                "How did it become a ritual for you?",
            ]),
            ("What's a personal rule you live by that most people don't know about?", .values, [
                "Where did that rule come from?",
                "Has it ever been tested?",
            ]),
            ("What's something you've gotten more patient about as you've gotten older?", .growth, [
                "What taught you that patience?",
                "Is there something you're still impatient about?",
            ]),
            ("What's a song that always puts you in a good mood?", .emotions, [
                "What memory or feeling does it tap into?",
                "When do you reach for it most?",
            ]),
            ("What's the last thing you did that felt truly spontaneous?", .dailyLife, [
                "What pushed you to just go for it?",
                "How did it feel compared to your usual planned approach?",
            ]),
            ("What's a quality about yourself that you've come to appreciate?", .appreciation, [
                "Did you always see it as a strength, or did that take time?",
                "How does that quality show up in your daily life?",
            ]),
            ("What's something you collect — physically or mentally?", .identity, [
                "What draws you to collecting it?",
                "What does the collection mean to you?",
            ]),
            ("What's a place you've been that left a lasting impression on you?", .past, [
                "What made it hit so hard?",
                "Do you want to go back, or is the memory enough?",
            ]),
            ("What's something you do purely for the joy of it, with no goal attached?", .dailyLife, [
                "How did you find that thing?",
                "What does it give you that goal-driven things don't?",
            ]),
            ("Who have you been carrying unsaid words for lately?", .communication, [
                "What's making it hard to bring up?",
                "How do you think you'd feel once you finally said it?",
            ]),
            ("What's a small disagreement you had recently that stuck with you longer than it should have?", .conflict, [
                "What do you think it was really about underneath?",
                "Did you resolve it or just let it fade?",
            ]),
        ], mode: .soloReflection, intensity: .light, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Light · Real Talk

    static func solo_light_realTalk() -> [Prompt] {
        make([
            ("What do you hope people remember about you?", .values, [
                "Are you living in a way that builds toward that?",
                "What would you need to change to get closer to it?",
            ]),
            ("When was the last time you felt completely and totally free?", .emotions, [
                "What created that feeling?",
                "How often do you give yourself permission to feel that way?",
            ]),
            ("What's something you lost that you still think about?", .past, [
                "What did that loss teach you about what matters?",
                "Have you found anything that fills that space?",
            ]),
            ("When was the last time you felt like everything was going your way?", .emotions, [
                "What was different about that stretch?",
                "What do you think made it possible?",
            ]),
            ("What's something you used to care deeply about that barely matters to you now?", .growth, [
                "What caused the shift?",
                "Do you see letting go of it as growth or loss?",
            ]),
            ("What's something you've started to see more realistically over time?", .growth, [
                "What helped you begin to see it differently?",
                "Do you feel better or worse having that clearer view?",
            ]),
        ], mode: .soloReflection, intensity: .light, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Light · Deep Dive

    static func solo_light_deepDive() -> [Prompt] {
        make([
            ("What does a good life actually look like to you — not what anyone told you it should be?", .values, [
                "How close are you to living that version?",
                "What's the biggest gap between where you are and where you want to be?",
            ]),
            ("What's a belief that's shaped who you are more than anything?", .values, [
                "Where did that belief take root?",
                "Has it ever been challenged?",
            ]),
            ("What's something you've built — a habit, a relationship, a mindset — that you're really proud of?", .growth, [
                "What did it take to build it?",
                "What does it give you that you didn't have before?",
            ]),
            ("What's a part of your life that feels exactly right?", .appreciation, [
                "What makes it feel so aligned?",
                "How did you get it to that place?",
            ]),
        ], mode: .soloReflection, intensity: .light, depth: .deepDive)
    }

    // MARK: - Solo Reflection · Honest · Warm Up

    static func solo_honest_warmUp() -> [Prompt] {
        make([
            ("When you catch your reflection, what's the first thought that tends to show up?", .emotions, [
                "Is that thought kind or critical?",
                "Has the voice in your head always said that?",
            ]),
            ("What's a bad habit you've tried to break but keep coming back to?", .growth, [
                "What does the habit give you that makes it so sticky?",
                "What would breaking it actually require from you?",
            ]),
            ("What kind of stress changes you in ways you might not fully see?", .emotions, [
                "What starts to shift in you when that stress builds?",
                "What usually helps you notice it sooner?",
            ]),
            ("What do you find surprisingly hard to say yes to?", .communication, [
                "What's underneath that hesitation?",
                "What are you protecting by holding back?",
            ]),
            ("Where does your life feel most out of sync with who you thought you'd be by now?", .identity, [
                "Does that gap feel motivating or discouraging?",
                "What would closing it require?",
            ]),
            ("What's something you keep putting off that's actually important to you?", .growth, [
                "What's the real reason you keep delaying?",
                "What would it feel like to finally do it?",
            ]),
            ("What emotion do you have the hardest time sitting with?", .emotions, [
                "What do you usually do to escape it?",
                "What do you think it's trying to tell you?",
            ]),
            ("What's a standard you hold yourself to that might be too high?", .values, [
                "Where did that standard come from?",
                "What would ease up in your life if you lowered it?",
            ]),
            ("What's something you've been telling yourself that might not be true?", .growth, [
                "How long have you been repeating that story?",
                "What would change if you let it go?",
            ]),
            ("What's a relationship in your life that's asking for more attention?", .intimacy, [
                "What's been getting in the way?",
                "What would showing up for it a little more actually look like?",
            ]),
            ("What's something you're carrying that you haven't shared with anyone?", .emotions, [
                "What would it take for you to share it?",
                "How is carrying it alone affecting you?",
            ]),
            ("What do you think people assume about you that's wrong?", .identity, [
                "What creates that false impression?",
                "Does it bother you enough to correct it?",
            ]),
            ("What's a decision you made recently that you're still second-guessing?", .emotions, [
                "What's the version of events where you made the right call?",
                "What would put the second-guessing to rest?",
            ]),
            ("When life gets heavy, what do you need that you often fail to give yourself?", .emotions, [
                "Why do you think you miss that need when you're under pressure?",
                "What would make it easier to offer it to yourself?",
            ]),
            ("What's an area of your life where you've been coasting?", .growth, [
                "What would it look like if you started trying again?",
                "What let you start coasting in the first place?",
            ]),
            ("How do you know when stress is starting to harden you a little?", .emotions, [
                "What tends to harden first — your tone, your patience, or something else?",
                "What helps you soften again?",
            ]),
            ("What would change in your life if you stopped trying to please everyone?", .growth, [
                "Who would you disappoint first?",
                "What would you gain by being honest instead?",
            ]),
            ("What's something you used to be sure about that you're not sure about anymore?", .values, [
                "What made the certainty crack?",
                "Is the uncertainty uncomfortable or freeing?",
            ]),
            ("What do you think your biggest distraction in life is right now?", .dailyLife, [
                "What is it distracting you from?",
                "What would you have to face without it?",
            ]),
            ("What's a part of your personality you've been hiding lately?", .identity, [
                "What made you decide to tuck it away?",
                "Do you miss that part of yourself?",
            ]),
            ("What's a compliment you struggle to accept about yourself?", .identity, [
                "Why is it so hard to let in?",
                "What would it mean if you believed it?",
            ]),
            ("What's something you need to forgive yourself for?", .emotions, [
                "What's been standing in the way of that forgiveness?",
                "What would letting it go free you to do?",
            ]),
            ("When was the last time you were truly honest with yourself about something uncomfortable?", .growth, [
                "What did you admit?",
                "How did it feel once you stopped avoiding it?",
            ]),
            ("What's a boundary you need to set but haven't?", .communication, [
                "What's been holding you back from drawing that line?",
                "What would change once it's in place?",
            ]),
            ("What's the gap between how you present yourself and how you actually feel?", .identity, [
                "Who in your life sees closest to the real version?",
                "What would it take to close that gap?",
            ]),
            ("What motivates you more — fear of failure or desire for something better?", .values, [
                "How does that motivator shape the way you take risks?",
                "Which one do you wish drove you more?",
            ]),
            ("What part of getting older has made you feel more tender toward yourself?", .growth, [
                "What do you think that tenderness is teaching you?",
                "Where do you still resist offering it to yourself?",
            ]),
            ("What's a way you've grown in the last year that you haven't acknowledged?", .growth, [
                "Why is it so hard to give yourself credit?",
                "What does that growth mean for who you're becoming?",
            ]),
            ("What's something you keep avoiding because it would mean real change?", .growth, [
                "What's the change you're most afraid of?",
                "What would life look like on the other side of it?",
            ]),
            ("What part of getting older has made you more guarded?", .emotions, [
                "What are you trying to protect when that guard goes up?",
                "What helps you feel safe enough to soften?",
            ]),
        ], mode: .soloReflection, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Honest · Real Talk

    static func solo_honest_realTalk() -> [Prompt] {
        make([
            ("What's something you're slowly becoming unable to unsee about yourself?", .growth, [
                "What helped you start to notice it?",
                "How has recognizing it changed anything in your life?",
            ]),
            ("What's a decision you keep avoiding even though you know it matters?", .growth, [
                "What makes the avoidance feel safer than deciding?",
                "What's the cost of continuing to delay?",
            ]),
            ("How does it feel when you're the one holding the power in a situation?", .values, [
                "Are you comfortable with power, or does it make you uneasy?",
                "How do you handle the responsibility that comes with it?",
            ]),
            ("When do you feel yourself responding from stress instead of from your actual feelings?", .emotions, [
                "What usually gets lost in you when stress takes over?",
                "What would help you respond more truthfully in those moments?",
            ]),
            ("What fear about aging feels harder to carry out loud than in your head?", .emotions, [
                "What makes that fear easier to hold silently than to say out loud?",
                "What would change if you let yourself name it more honestly?",
            ]),
            ("When are you most proud of having stood up for yourself?", .growth, [
                "What gave you the courage to do it?",
                "How did it change what you expect from yourself?",
            ]),
            ("What have you been carrying longer than it still deserves space in you?", .past, [
                "What would happen if you finally let it go?",
                "What has holding onto it been doing for you?",
            ]),
            ("When was the last time you bent the rules in a way that still sits with you?", .conflict, [
                "Do you feel guilty about it or justified?",
                "Would you do it again?",
            ]),
            ("What kind of people make you feel the most envious, and why?", .emotions, [
                "What does the envy reveal about what you want?",
                "Is it something you could actually pursue?",
            ]),
            ("How has time made you stronger, and how has it made you more fragile?", .growth, [
                "Where do you feel your strength most clearly now?",
                "Where do you feel your fragility most sharply?",
            ]),
            ("What's a boundary you've set recently that felt like real progress?", .growth, [
                "What made you finally draw the line?",
                "How has life been different since?",
            ]),
            ("When did you start to feel that perfect justice might not exist?", .growth, [
                "What experience made that idea feel less real?",
                "How has that changed the way you see fairness or people?",
            ]),
            ("What's something you once believed would always work out, but now you're not so sure about?", .emotions, [
                "What caused that belief to shift?",
                "How do you feel holding that uncertainty now?",
            ]),
        ], mode: .soloReflection, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Honest · Deep Dive

    static func solo_honest_deepDive() -> [Prompt] {
        make([
            ("What do you think you will need more and more as you age?", .values, [
                "What kind of care or steadiness do you think will matter most to you?",
                "What part of you still struggles to admit that need?",
            ]),
            ("When do you feel most aware that your time is not unlimited?", .past, [
                "What does that awareness make you want to protect or change?",
                "How does it affect the way you want to live right now?",
            ]),
            ("What do you know you need to let go of but can't seem to release?", .growth, [
                "What would your life look like without it?",
                "What keeps your grip so tight?",
            ]),
            ("What's the gap between who you are and who you want to be — and what lives in that gap?", .growth, [
                "What fills that space right now — fear, habit, or something else?",
                "What's the first step toward closing that gap?",
            ]),
        ], mode: .soloReflection, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Solo Reflection · Unfiltered · Warm Up

    static func solo_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What do you have a complicated relationship with that's hard to explain?", .emotions, [
                "What makes it so hard to put into words?",
                "Does the complication bother you, or have you accepted it?",
            ]),
            ("When are you most tempted to break your own rules?", .values, [
                "What does giving in usually cost you?",
                "Is the temptation about the thing itself or the rebellion?",
            ]),
            ("What's a feeling you've been swallowing instead of expressing?", .emotions, [
                "What are you afraid would happen if you let it out?",
                "How is holding it in affecting you?",
            ]),
            ("When negative thoughts about yourself start to take hold, how do you usually respond?", .emotions, [
                "Do you know how to comfort yourself in those moments?",
                "What kind of response from yourself actually helps?",
            ]),
            ("What's a part of your past you'd erase if you could?", .past, [
                "What would be different about you without that experience?",
                "Is there any part of it that made you who you are in a way you value?",
            ]),
            ("What's a way you self-sabotage that you're fully aware of?", .growth, [
                "What do you think you're trying to avoid by doing it?",
                "What would it take to stop the cycle?",
            ]),
            ("What's a truth about your life that you dress up when you talk about it?", .identity, [
                "What's the undressed version?",
                "Why does the real version feel too vulnerable to share?",
            ]),
            ("What's something you pretend to have figured out but really haven't?", .identity, [
                "What would it mean to admit you're still lost on it?",
                "Who would you go to for help if you could?",
            ]),
            ("What's a coping mechanism you rely on that isn't actually healthy?", .growth, [
                "What does it numb or avoid?",
                "What might a healthier replacement give you instead?",
            ]),
            ("What's something your inner life knows about you that your outer life still won't admit?", .emotions, [
                "What keeps that truth from making it into the open?",
                "How is that split between what you know and how you live affecting you?",
            ]),
            ("What's the most painful thing you've realized about yourself?", .growth, [
                "How did that realization land?",
                "What have you done with that knowledge?",
            ]),
            ("What's a desire you have that you feel ashamed of?", .emotions, [
                "Where does the shame come from — you or someone else's voice?",
                "What would it feel like to want it without the guilt?",
            ]),
            ("What's a version of yourself you've buried that sometimes still surfaces?", .identity, [
                "When does it tend to come back?",
                "Is it a version you miss or one you're trying to outgrow?",
            ]),
            ("What's one of the hardest parts of being you that nobody really sees?", .emotions, [
                "What would it mean for someone to finally see it?",
                "How do you carry that alone?",
            ]),
            ("What's a promise you've broken to yourself more than once?", .values, [
                "What gets in the way every time?",
                "What would it take to finally keep it?",
            ]),
            ("What's a relationship you stayed in too long and why?", .past, [
                "What kept you there past the expiration?",
                "What did leaving — or not leaving — teach you?",
            ]),
            ("What's something you're afraid to want because you might not get it?", .emotions, [
                "What would it cost you to want it fully?",
                "What's worse — not getting it, or never trying?",
            ]),
            ("What do you think your life would look like if you stopped performing for others?", .identity, [
                "Who would you lose?",
                "Who would you finally attract?",
            ]),
            ("What's a memory that still makes you feel shame when it surfaces?", .past, [
                "What exactly triggers the shame?",
                "Have you been able to talk to anyone about it?",
            ]),
            ("What's the most honest thing you could say about where you are in life right now?", .growth, [
                "How does that honesty feel?",
                "What would you change first if you could?",
            ]),
            ("What's something you need that you've convinced yourself you don't?", .emotions, [
                "When did you start telling yourself you didn't need it?",
                "What would admitting the need change for you?",
            ]),
            ("What keeps you up at night that you've never told anyone?", .emotions, [
                "What makes it feel too heavy to share?",
                "What would you need from someone to feel safe telling them?",
            ]),
            ("What's a pattern in your relationships that you can't seem to break?", .growth, [
                "When did you first notice it repeating?",
                "What do you think it's trying to resolve?",
            ]),
            ("What's the thing you're most afraid of other people finding out about you?", .identity, [
                "What feels most at risk if other people knew?",
                "What do you imagine would actually happen if it came to light?",
            ]),
            ("What's something you've numbed yourself to that you know you need to eventually face?", .emotions, [
                "How are you avoiding it?",
                "What do you think would happen if you addressed it?",
            ]),
            ("What's a part of your story you've rewritten to make it easier to tell?", .past, [
                "What did you leave out and why?",
                "What would the unedited version reveal about you?",
            ]),
            ("What's one thing about the way you're living right now that you know isn't really working anymore?", .growth, [
                "Why have you kept trying to make it work anyway?",
                "What would changing it force you to face?",
            ]),
            ("What's something you keep calling selflessness that may actually be self-erasure?", .growth, [
                "What does it let you avoid having to ask for directly?",
                "What has it cost you to keep disappearing that way?",
            ]),
            ("Do you like yourself, or do you mostly like yourself under certain conditions?", .identity, [
                "What are those conditions?",
                "How steady is that feeling, really?",
            ]),
            ("Is there a hurt in you that never seems to fully heal?", .emotions, [
                "Is this something you can tend on your own, or do you need help from someone else?",
                "What do you think healing would actually require?",
            ]),
            ("What's a habit you keep returning to that you know isn't good for you?", .dailyLife, [
                "What does it give you in the moment that's hard to get elsewhere?",
                "What would your life actually look like if you finally stopped?",
            ]),
            ("What's something you've wanted to say to someone for a long time but know you probably never will?", .communication, [
                "What would saying it actually cost you?",
                "What does keeping it inside cost you instead?",
            ]),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Unfiltered · Real Talk

    static func solo_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What's something you wish you'd never had to see?", .past, [
                "How did seeing it change you?",
                "Have you been able to process it?",
            ]),
            ("Where in your life do you quietly fear that if people looked closer, they'd find less than you present?", .identity, [
                "What are you working so hard to make sure they don't see?",
                "How much of that fear feels earned, and how much of it feels old?",
            ]),
            ("How would you honestly describe your relationship with your body?", .identity, [
                "When is that relationship at its hardest?",
                "What would a healthier version of it look like?",
            ]),
            ("What's a truth about yourself you've been circling without fully letting it land?", .growth, [
                "What would have to change if you let it become fully real?",
                "What keeps you hovering around it instead of stepping into it?",
            ]),
            ("What have you been faking lately that you're tired of keeping up?", .growth, [
                "Who are you performing for?",
                "What would dropping the act actually cost you?",
            ]),
            ("What's a lie you told once that you still think about?", .conflict, [
                "Why does it still have a hold on you?",
                "If you wanted to make it right now, what might that look like?",
            ]),
            ("When did you first really realize you would die one day?", .emotions, [
                "How old were you, and what made that realization land?",
                "Does that awareness change how you think about your life now?",
            ]),
            ("How much of your daily life is shaped around avoiding what you don't want to feel?", .dailyLife, [
                "What feelings are you most skilled at dodging?",
                "What would a day without that avoidance actually look like?",
            ]),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Unfiltered · Deep Dive

    static func solo_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something you've been putting off being honest with yourself about?", .identity, [
                "What would the honest version sound like if you said it out loud?",
                "What feels most likely to shift once you admit it?",
            ]),
            ("Is there a relationship in your life that you know has run its course?", .conflict, [
                "What's keeping you from walking away?",
                "What would you grieve if you let it go?",
            ]),
            ("What's a part of yourself that you know you need to outgrow?", .growth, [
                "What's that part been protecting you from?",
                "Who would you become without it?",
            ]),
            ("What's something you still carry guilt about?", .emotions, [
                "What would it take to finally put it down?",
                "What makes it so hard to offer yourself any forgiveness?",
            ]),
            ("What's a belief you hold deeply but have never actually said out loud?", .values, [
                "What makes it feel too risky to share?",
                "What would it mean to own it publicly?",
            ]),
            ("What's something that hurt you that you still minimize when you tell the story?", .emotions, [
                "What feels safer about making it sound smaller than it was?",
                "What would the fuller version reveal about what it actually did to you?",
            ]),
            ("If you could erase one memory completely, which would you choose?", .past, [
                "What would life feel like without it?",
                "Is there anything that memory gave you that you'd lose too?",
            ]),
            ("What's the worst thing you've done to someone that still weighs on you?", .conflict, [
                "Have you tried to make it right?",
                "What would you say to them now?",
            ]),
            ("When have you felt the most humiliated in your life?", .emotions, [
                "How did that experience shape the way you protect yourself?",
                "Have you healed from it, or does it still sting?",
            ]),
            ("If you got to choose how your life story ends, what would it look like?", .values, [
                "What would the last chapter be about?",
                "Are you living in a way that moves toward that ending?",
            ]),
            ("How did being treated badly by someone shape the way you see yourself?", .past, [
                "Do you still carry their version of you?",
                "What would it take to replace it with your own?",
            ]),
            ("What's something that happened that permanently changed who you are?", .past, [
                "Was the change something you chose or something that happened to you?",
                "Do you recognize yourself on both sides of it?",
            ]),
            ("When was a time you felt rejected that really stung?", .emotions, [
                "What did the rejection make you believe about yourself?",
                "Have you been able to separate the rejection from your worth?",
            ]),
            ("Where are you still waiting for a kind of closure that may never come?", .emotions, [
                "What keeps you waiting for it instead of grieving it?",
                "What would it mean to stop making your peace dependent on that ending?",
            ]),
            ("What principle would you never compromise on, no matter what?", .values, [
                "When has that principle been tested the hardest?",
                "What does it protect in you that nothing else can?",
            ]),
            ("What part of your daily routine is actually a coping mechanism you've never examined?", .dailyLife, [
                "When did it start, and what were you going through at the time?",
                "What would you have to face if you took it away?",
            ]),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .deepDive)
    }
}
