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
            ("What do you spend way too much money on without any regret?", .dailyLife, [
                "What does spending on that give you beyond the thing itself?",
                "What would it be hard to replace that feeling with?",
            ]),
            ("What do you know you make a bigger deal about than you should?", .communication, [
                "What does it touch in you that makes it feel bigger than it is?",
                "What are you usually needing in those moments?",
            ]),
            ("What would you love to be able to spend more freely on?", .dailyLife, [
                "What would that say about the kind of life you want?",
                "What feeling are you hoping more freedom there would give you?",
            ]),
            ("Are you more of a host or a guest — and what does that say about you?", .dailyLife, [
                "What part of that role feels most natural to you?",
                "What does that role let you avoid or enjoy most?",
            ]),
            ("If you were stuck at home for months, what three things would you absolutely need?", .dailyLife, [
                "What do those choices tell you about what keeps you steady?",
                "Which one would be the hardest to go without, and why?",
            ]),
            ("What's your go-to midnight snack raid?", .dailyLife, [
                "What mood are you usually in when that craving hits?",
                "What do you think you're really reaching for in that moment?",
            ]),
            ("Who or what have you been quietly fascinated by lately?", .intimacy, [
                "What is it about them or it that keeps pulling you in?",
                "Do you think it connects to something you're wanting more of in your own life?",
            ]),
            ("What's the most disastrous date you've ever been on?", .dailyLife, [
                "What made it go wrong so fast?",
                "What did that experience teach you about yourself or dating?",
            ]),
            ("What's your favorite real love story — yours or someone else's?", .intimacy, [
                "What part of that story moves you the most?",
                "What does it reveal about the kind of love you believe in?",
            ]),
            ("What do you need most from me when you're not feeling well?", .communication, [
                "What helps you feel cared for instead of just looked after?",
                "What's easy for me to miss in those moments?",
            ]),
            ("What are you surprisingly high-maintenance about?", .dailyLife, [
                "What makes that one worth the extra fuss to you?",
                "Do you think it's more about comfort, control, or feeling cared for?",
            ]),
            ("What are you a complete control freak about?", .identity, [
                "What feels at risk when you're not in control there?",
                "Where do you think that need for control comes from?",
            ]),
            ("What's the one thing you absolutely cannot be teased about?", .communication, [
                "What makes that one land differently than other jokes?",
                "What does it touch in you that's still tender?",
            ]),
            ("What's basically impossible for you to say no to?", .communication, [
                "What makes it so hard to resist?",
                "What need in you does saying yes satisfy?",
            ]),
            ("What's something about your partner that you fell in love with all over again recently?", .appreciation, [
                "What was it about that moment that hit you so strongly?",
                "What did it remind you of about why you chose them?",
            ]),
            ("I feel most sensual when…", .sex, [
                "What helps you settle into that feeling most naturally?",
                "What tends to pull you away from it?",
            ]),
            ("I feel most attractive when…", .sex, [
                "What is it about that moment that makes you feel seen that way?",
                "How much of that feeling comes from you versus someone else's response?",
            ]),
            ("What's a song that always makes you think of us?", .appreciation, [
                "What memory or feeling does it bring back first?",
                "What part of us does that song seem to capture?",
            ]),
            ("What's the best surprise you've ever gotten from someone you love?", .appreciation, [
                "What made that surprise feel so meaningful to you?",
                "What did it show you about how that person knew you?",
            ]),
            ("What's your idea of a perfect lazy Sunday together?", .dailyLife, [
                "What part of that day feels most nourishing to you?",
                "What does that version of Sunday give you that everyday life doesn't?",
            ]),
            ("What's something small I do that always makes you smile?", .appreciation, [
                "Why do you think that tiny thing means so much to you?",
                "What does it make you feel in that moment?",
            ]),
            ("If we could travel anywhere tomorrow, where would you want to go?", .dailyLife, [
                "What about that place feels right for us?",
                "What are you hoping we'd feel there together?",
            ]),
            ("What's a hobby or skill you've always wanted us to try together?", .growth, [
                "What do you imagine that bringing out in us?",
                "What makes doing it together matter more than doing it alone?",
            ]),
            ("What's the most fun we've ever had doing something totally unplanned?", .past, [
                "What do you think made that moment feel so alive?",
                "What does it tell you about us at our best?",
            ]),
            ("What's a movie or show that reminds you of our relationship?", .dailyLife, [
                "What dynamic or moment in it feels most like us?",
                "Is that comparison sweet, funny, or a little too accurate?",
            ]),
            ("What's your love language when you're stressed versus when you're happy?", .communication, [
                "How can someone tell which version of you they're getting?",
                "What do you most want from me when you're in each state?",
            ]),
            ("What's a tradition you'd love for us to start?", .values, [
                "What do you think that tradition would create between us over time?",
                "Why does that kind of ritual matter to you?",
            ]),
        ], mode: .couples, intensity: .light, depth: .warmUp)
    }

    // MARK: - Couples · Light · Real Talk

    static func couples_light_realTalk() -> [Prompt] {
        make([
            ("What's the most unexpected compliment you've ever received?", .appreciation, [
                "Why do you think that one suprised you so much?",
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
            ("Something I do that turns me off is…", .sex, [
                "Why do you think it turns you off?",
                "Is that something you'd want to talk through or just have me know?",
            ]),
            ("Something that tends to turn me on is…", .sex, [
                "When did you first notice that about yourself?",
                "What is it about that thing that gets to you?",
            ]),
            ("One of the most sensual experiences I've had that didn't involve sex was…", .sex, [
                "What made that moment feel so charged?",
                "What does sensuality mean to you outside the bedroom?",
            ]),
            ("I still remember a time I felt deeply desired when…", .sex, [
                "What about that moment made you feel so wanted?",
                "How does feeling desired change the way you show up?",
            ]),
            ("An intimate memory that still makes me cringe a little is…", .sex, [
                "What makes it cringeworthy — and do you laugh about it now?",
                "Did it change anything about how you approach intimacy?",
            ]),
            ("One of the most memorable intimate moments I've had was…", .sex, [
                "What made that one stand out above the rest?",
                "What do you think made the connection feel so strong?",
            ]),
            ("Something I do that helps make intimacy more engaging is…", .sex, [
                "How did you figure that out about yourself?",
                "What does it feel like when that effort lands?",
            ]),
            ("An embarrassing intimate moment I've experienced was…", .sex, [
                "How did you recover from it in the moment?",
                "Did it end up bringing you closer or making things awkward?",
            ]),
            ("What makes me feel most desired by you is…", .sex, [
                "What is it about that gesture that gets through to you?",
                "Do you think I know how much that matters to you?",
            ]),
            ("A moment I felt truly connected to you physically was…", .sex, [
                "What made the emotional and physical feel so aligned?",
                "What do you think creates that kind of connection between us?",
            ]),
        ], mode: .couples, intensity: .light, depth: .realTalk)
    }

    // MARK: - Couples · Light · Deep Dive

    static func couples_light_deepDive() -> [Prompt] {
        make([
            ("What moment made you think — okay, this person really gets me?", .intimacy, [
                "What did I do different from others that made you feel like that?",
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
            ("What's been on your mind late at night recently?", .emotions, [
                "What keeps pulling your thoughts back there?",
                "What would help quiet that for you?",
            ]),
            ("What's weighing on you the most right now?", .emotions, [
                "How long have you been carrying that?",
                "What would it take for that weight to lift even a little?",
            ]),
            ("When was the last time you got way more upset than the situation deserved?", .conflict, [
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
                "How would things feel different for you if I could understood this better?",
            ]),
            ("What's a fear you haven't told me about?", .emotions, [
                "What's kept you from saying it out loud?",
                "What would it mean for you if I knew?",
            ]),
            ("When do you feel most disconnected from me?", .intimacy, [
                "What's happening in you during those moments?",
                "What would help you feel like we're back on the same page?",
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
                "Have you ever tried to say something about it? If not why not?",
            ]),
            ("What's something you've been meaning to apologize for?", .conflict, [
                "What's been holding the apology back?",
                "What do you think it would change if you said it?",
            ]),
            ("When do you feel the safest with me?", .intimacy, [
                "What is it about those moments that lets your guard down?",
                "How does that safety change the way you show up?",
            ]),
            ("What's something about our relationship that surprised you?", .growth, [
                "Was it a good surprise or something you had to sit with?",
                "How did it change what you expected from us?",
            ]),
            ("What's something you admire about the way I love you?", .appreciation, [
                "When do you notice it the most?",
                "Is there something about it you wish you could mirror back?",
            ]),
            ("What's a conversation we had that stuck with you?", .communication, [
                "What about it kept echoing after it ended?",
                "Did it change anything about how you see us?",
            ]),
            ("What do you think we're both avoiding right now?", .communication, [
                "What makes that topic feel so untouchable?",
                "What do you think would happen if we actually went there?",
            ]),
            ("When was the last time I really made you laugh?", .appreciation, [
                "What was it about that moment that got you?",
                "How important is laughter to you in a relationship?",
            ]),
            ("What's a way I've helped you grow that you haven't mentioned?", .growth, [
                "What part of you shifted because of it?",
                "Do you think I even realize I had that effect?",
            ]),
            ("What do you wish we did more of together?", .dailyLife, [
                "What do you think we'd discover about each other if we did?",
                "What's been getting in the way?",
            ]),
            ("What's something about our early days that you miss?", .past, [
                "What made that time feel so different?",
                "Is there a way to bring some of that energy back?",
            ]),
            ("How do you feel about how we handle money together?", .values, [
                "Where does the tension show up the most?",
                "What would your ideal version of that look like?",
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
                "What nerve did it touch in a good way?",
                "Do you wish I said things like that more often?",
            ]),
            ("What do you need from me that you find hard to ask for?", .communication, [
                "What makes that request feel so difficult to voice?",
                "What would it mean to you if I just knew to offer it?",
            ]),
            ("What's a small moment between us that you keep replaying?", .intimacy, [
                "What is it about that moment that holds so much weight?",
                "Does replaying it bring you comfort or longing?",
            ]),
            ("What's something you've learned about love from being with me?", .growth, [
                "How is that different from what you believed before us?",
                "Has it changed what you want going forward?",
            ]),
        ], mode: .couples, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Couples · Honest · Real Talk

    static func couples_honest_realTalk() -> [Prompt] {
        make([
            ("What does money actually mean to you — beyond the obvious?", .values, [
                "Where did that relationship with money come from?",
                "How does it shape the choices you make day to day?",
            ]),
            ("What's something in your life that's worth fighting harder for?", .values, [
                "What's been holding you back from fighting for it?",
                "What would it look like if you went all in?",
            ]),
            ("When was the last time you really cried, and what brought it on?", .emotions, [
                "Did you let yourself fully feel it or try to hold back?",
                "What did it release in you?",
            ]),
            ("What's the last promise you broke, and does it still bother you?", .conflict, [
                "What got in the way of keeping it?",
                "What would you do differently if you could?",
            ]),
            ("When was the last time you held back tears and pretended you were fine?", .emotions, [
                "What were you protecting yourself from by holding it in?",
                "What would have happened if you had let yourself cry?",
            ]),
            ("Who would you most want to show the person you've become?", .appreciation, [
                "What would you want them to see in you now?",
                "What do you think they'd say?",
            ]),
            ("What's a conversation you know you need to have but keep putting off?", .communication, [
                "What are you most afraid of hearing in return?",
                "What would finally push you to have it?",
            ]),
            ("How do you feel when you notice yourself getting older?", .emotions, [
                "What part of aging unsettles you the most?",
                "Is there anything about it that quietly excites you?",
            ]),
            ("What's something you really want from me but haven't been able to ask for?", .communication, [
                "What makes that request feel so vulnerable?",
                "How do you think I'd respond if you asked?",
            ]),
            ("Where do you feel the most friction between us right now?", .conflict, [
                "What do you think is underneath that friction?",
                "What would resolution actually look like to you?",
            ]),
            ("What would you change about how you handle conflict with the people you love?", .conflict, [
                "Where did you learn that pattern?",
                "What would the healthier version look like for you?",
            ]),
            ("When do you wish you had spoken up instead of staying quiet?", .communication, [
                "What stopped you from saying it?",
                "What do you think would have changed if you had?",
            ]),
            ("When was the last time jealousy really got under your skin?", .emotions, [
                "What was the deeper fear underneath it?",
                "How did you handle it — and was that the right call?",
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
                "What would help you stay present instead?",
            ]),
            ("A message I sometimes imagine sending you is…", .sex, [
                "What stops you from actually sending it?",
                "What response are you hoping for in your imagination?",
            ]),
            ("A message I secretly wish I'd receive from you is…", .sex, [
                "What would reading that message do to you?",
                "What need would it speak to?",
            ]),
            ("In terms of energy or dynamic, I tend to lean more toward…", .sex, [
                "Has that always been the case, or did it develop over time?",
                "What does leaning into that side give you?",
            ]),
            ("When it comes to initiating intimacy, I usually…", .sex, [
                "What makes initiating feel easy or hard for you?",
                "What response do you need to feel safe taking that step?",
            ]),
            ("Most of what I've learned about sex has come from…", .sex, [
                "How do you feel about those sources looking back?",
                "What have you had to unlearn along the way?",
            ]),
            ("One thing I wish we talked about more openly is…", .sex, [
                "What makes that topic feel hard to bring up?",
                "What would it give us if we could go there together?",
            ]),
            ("Something I'd like us to explore together is…", .sex, [
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
            ("What moment completely changed how you think about love?", .intimacy, [
                "What were you believing about love before that moment?",
                "How does it shape the way you love now?",
            ]),
            ("What about our future excites you and scares you at the same time?", .emotions, [
                "Which feeling is stronger right now — the excitement or the fear?",
                "What would help the excitement win?",
            ]),
            ("I think the idea of marriage, when it comes to intimacy, is…", .sex, [
                "Where did that belief take shape for you?",
                "How does that idea affect what you expect from a partner?",
            ]),
            ("During intimacy, everything else fades away when…", .sex, [
                "What do you think creates that level of presence?",
                "How often do you reach that state?",
            ]),
            ("A sexual question or uncertainty I still think about is…", .sex, [
                "What makes that question hard to settle?",
                "Who would you trust enough to explore it with?",
            ]),
            ("A belief about sex I've had to rethink over time is…", .sex, [
                "What experience pushed you to rethink it?",
                "What do you believe now in its place?",
            ]),
            ("Something I don't fully understand about desire is…", .sex, [
                "What part of it feels the most confusing?",
                "What would understanding it better give you?",
            ]),
            ("My sex life changed in a meaningful way after…", .sex, [
                "What shifted inside you because of that experience?",
                "How did it change what you look for in intimacy?",
            ]),
            ("An early experience that shaped how I think about sex was…", .sex, [
                "How did that experience color the way you approach intimacy now?",
                "Is there a part of it you're still working through?",
            ]),
            ("The difference between emotional intimacy and physical intimacy feels like…", .sex, [
                "Which one do you reach for first when you need to feel close?",
                "Has there been a moment where one surprised you by turning into the other?",
            ]),
            ("Sex feels most meaningful to me when…", .sex, [
                "What makes the difference between meaningful and just physical?",
                "How often do you feel that deeper meaning?",
            ]),
            ("Growing up, the message I got about sex was…", .sex, [
                "How has that message stayed with you or been rewritten?",
                "What message would you want to pass on instead?",
            ]),
            ("What makes me feel most safe during intimacy is…", .sex, [
                "What does safety in that context actually feel like in your body?",
                "What's the quickest way that safety can be broken?",
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
                "Does not understanding it bother you or have you made peace with it?",
                "What opens up if you finally understand it?",
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
                "What did that acceptance cost you?",
            ]),
            ("What's a version of yourself you only show to me?", .identity, [
                "What is it about us that makes that version feel safe?",
                "Do you like that version of yourself?",
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
            ("What do you think our biggest blind spot as a couple is?", .growth, [
                "What would someone on the outside probably see that we can't?",
                "What becomes possible if we finally face it?",
            ]),
            ("What's a truth about yourself that you're afraid would change how I see you?", .emotions, [
                "What's the worst version of how you imagine I'd react?",
                "What would it mean if I heard it and nothing changed?",
            ]),
            ("When have you sacrificed too much of yourself for this relationship?", .values, [
                "Did you realize it was too much at the time or only after?",
                "What part of yourself did you lose in the process?",
            ]),
            ("What's a fight we had that actually changed something for the better?", .conflict, [
                "What broke through in that fight that couldn't have come out any other way?",
                "How did it change the way you see conflict between us?",
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
            ("What's a way you've changed since being with me that worries you?", .identity, [
                "Is it a change you chose or one that happened to you?",
                "What would the old version of you think?",
            ]),
            ("What's something about us that you'd be embarrassed for others to know?", .intimacy, [
                "What does the embarrassment protect?",
                "Would telling someone actually change anything?",
            ]),
        ], mode: .couples, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Couples · Unfiltered · Real Talk

    static func couples_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What's something you've been pretending is fine when it really isn't?", .emotions, [
                "How long have you been holding that performance together?",
                "What would happen if you stopped pretending?",
            ]),
            ("When did you hurt someone without meaning to, and what happened after?", .conflict, [
                "Did you realize it right away or did it take time?",
                "What did that teach you about the gap between intention and impact?",
            ]),
            ("What makes you the hardest to live with — if you're being honest?", .conflict, [
                "How do you think that quality affects the people closest to you?",
                "Have you tried to change it or accepted it as part of who you are?",
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
                "What would it take for you to stay present instead of pulling back?",
            ]),
            ("When was a time you admitted you were wrong — and how did that feel?", .conflict, [
                "What made that admission so hard?",
                "Did it change anything in the relationship?",
            ]),
            ("Something I've always been curious to explore sexually is…", .sex, [
                "What draws you to that, and what holds you back?",
                "What would you need to feel safe enough to bring it up?",
            ]),
            ("The word \u{201C}forbidden\u{201D} makes me think of…", .sex, [
                "What is it about that edge that pulls you in?",
                "How do you feel about having that thought?",
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
            ("What's the heartbreak that hit you the hardest?", .emotions, [
                "What part of you did it break open?",
                "How did it reshape the way you protect your heart?",
            ]),
            ("When was the last time you felt truly lonely, even if you weren't alone?", .emotions, [
                "What was missing in that moment?",
                "What would it take to not feel that way again?",
            ]),
            ("What would be something you could never forgive in a relationship?", .conflict, [
                "What does that boundary protect in you?",
                "Has anything ever come close to testing it?",
            ]),
            ("If my partner had an affair, I think I would…", .sex, [
                "What does your gut reaction tell you about what you value most?",
                "Do you think your actual response would match what you imagine?",
            ]),
            ("One of the most awkward or uncomfortable moments I've had after intimacy was…", .sex, [
                "What made that moment land so uncomfortably?",
                "Did it change anything about how you handle vulnerability after sex?",
            ]),
            ("A fantasy I have mixed feelings about is…", .sex, [
                "What's the tension between the part that wants it and the part that resists?",
                "What do you think the fantasy is really about underneath?",
            ]),
            ("Something I haven't been fully honest about in my sexual past is…", .sex, [
                "What's kept you from sharing it until now?",
                "What would it feel like to finally have someone know?",
            ]),
            ("A recurring fantasy I've had is…", .sex, [
                "What do you think that fantasy is really reaching for?",
                "How do you feel about the fact that it keeps coming back?",
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
                "What would happen if someone caught you?",
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
            ("How do you honestly feel when a friend is always running late?", .conflict, [
                "What does it bring up in you beyond the inconvenience?",
                "Have you ever said something about it?",
            ]),
            ("Who gets under your skin more than anyone, and why do you think that is?", .conflict, [
                "What is it about them that gets to you specifically?",
                "Do you think it says more about them or about you?",
            ]),
            ("What was the last lie you told, and why did you tell it?", .communication, [
                "What were you trying to protect by lying?",
                "Do you think the person believed you?",
            ]),
            ("What are you the most judgmental about, even if you'd never admit it?", .values, [
                "Where do you think that judgment comes from?",
                "Do you hold yourself to the same standard?",
            ]),
            ("What's something you've always been a little bit embarrassed about?", .emotions, [
                "What makes that one stick with you?",
                "Has anyone ever made you feel worse about it?",
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
            ("What's something you've noticed about yourself that you don't love?", .growth, [
                "Is it something you want to change or learn to accept?",
                "When does it show up the most?",
            ]),
            ("What's a compliment you received that caught you off guard?", .appreciation, [
                "Why do you think it surprised you?",
                "Did it change how you see yourself at all?",
            ]),
            ("What's something you keep doing even though you know it's not great for you?", .growth, [
                "What does that thing give you that keeps you coming back?",
                "What would have to change for you to stop?",
            ]),
            ("What do you find hardest about maintaining friendships as you get older?", .communication, [
                "What do you think has changed the most?",
                "What would your ideal friendship look like at this stage?",
            ]),
            ("What's a promise you made to yourself that you've actually kept?", .values, [
                "What made you stick with that one when so many others slip?",
                "What does keeping it mean to you?",
            ]),
            ("When's the last time you felt genuinely jealous of a friend?", .emotions, [
                "What was it about their situation that got to you?",
                "What does that jealousy tell you about what you want?",
            ]),
            ("What's something you've outgrown but haven't let go of yet?", .growth, [
                "What's keeping you attached to it?",
                "What would letting go actually look like?",
            ]),
            ("What's a topic you avoid with certain friends and why?", .communication, [
                "What are you afraid would happen if you brought it up?",
                "Does avoiding it create distance between you?",
            ]),
            ("What's the hardest part about being honest with the people closest to you?", .communication, [
                "What are you usually trying to protect — them or yourself?",
                "When has honesty actually brought you closer?",
            ]),
            ("What do you wish someone would just ask you about?", .emotions, [
                "Why do you think nobody has?",
                "What would it mean to finally talk about it?",
            ]),
            ("What's something you've been overthinking lately?", .emotions, [
                "What's the thought that keeps looping back?",
                "What would it take to finally let it settle?",
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
            ("What's a moment where you felt truly appreciated by a friend?", .appreciation, [
                "What did they do that made it feel real?",
                "How often do you feel that way?",
            ]),
            ("What's something that's been harder than you've let on?", .emotions, [
                "What have you been doing to hold it together?",
                "What would help, even just a little?",
            ]),
            ("What do you think makes you a good friend, and where do you fall short?", .growth, [
                "Do the people in your life see those strengths and weaknesses the same way?",
                "What's one thing you'd like to get better at?",
            ]),
            ("What's a conversation you had recently that left you thinking for days?", .communication, [
                "What was it about that conversation that stuck?",
                "Did it change your mind about anything?",
            ]),
            ("What's something you pretend to be okay with but actually aren't?", .emotions, [
                "How long have you been carrying that pretense?",
                "What would happen if you dropped it?",
            ]),
            ("What's a risk you wish you had the courage to take right now?", .growth, [
                "What's the worst thing that could actually happen?",
                "What would taking it say about who you're becoming?",
            ]),
            ("When was the last time you really showed up for someone in a meaningful way?", .appreciation, [
                "What made you step up in that moment?",
                "How did it feel to be that person for them?",
            ]),
        ], mode: .friends, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Friends · Honest · Real Talk

    static func friends_honest_realTalk() -> [Prompt] {
        make([
            ("When was a time you were meaner than the situation called for?", .conflict, [
                "What was really going on underneath that reaction?",
                "Did you ever make it right?",
            ]),
            ("What version of yourself are you sometimes tempted to present that isn't quite real?", .identity, [
                "What do you get from putting that version forward?",
                "What's the gap between that version and the real one?",
            ]),
            ("What's a mistake you made once that you know you'll never repeat?", .growth, [
                "What did it cost you to learn that lesson?",
                "How did it change the way you make decisions?",
            ]),
            ("Who challenges you the most in your life right now, and how do you deal with it?", .conflict, [
                "What about them pushes your buttons?",
                "Do you think the challenge is making you better or wearing you down?",
            ]),
            ("Who intimidates you, and what do you think that says about you?", .identity, [
                "What quality of theirs triggers that feeling?",
                "Is it something you want for yourself?",
            ]),
            ("What's a risk you took that ended up completely changing things?", .growth, [
                "What gave you the push to take it?",
                "Would you take it again knowing how it turned out?",
            ]),
            ("What's something only your closest friends know about you?", .intimacy, [
                "Why do you keep that one in a smaller circle?",
                "How would things feel different if more people knew?",
            ]),
            ("What's a message you sent that you immediately wished you could take back?", .communication, [
                "What were you feeling when you hit send?",
                "How did it land on the other end?",
            ]),
            ("What's a challenge you've faced that you're proud of getting through?", .appreciation, [
                "What did you discover about yourself in the process?",
                "Did anyone help you through it, or was it all you?",
            ]),
            ("What's something you took credit for that you probably shouldn't have?", .conflict, [
                "Does it still sit with you?",
                "Would you own up to it now if given the chance?",
            ]),
            ("When was the last time you played a version of yourself that wasn't really you?", .identity, [
                "What did that situation require you to be?",
                "How did it feel to come back to yourself after?",
            ]),
            ("When do you tell yourself it's not really lying?", .communication, [
                "What makes that line feel blurry for you?",
                "How do you decide when the truth is worth the discomfort?",
            ]),
            ("What's a moment from your past you wish everyone would just forget?", .past, [
                "What about it still makes you cringe?",
                "Do you think other people remember it as much as you do? Why?",
            ]),
            ("What's a story you tell about yourself that's not totally accurate?", .communication, [
                "What did you change and why?",
                "What would the honest version reveal about you?",
            ]),
            ("What's a way someone has shown up for you that you'll never forget?", .appreciation, [
                "What made that moment different from other times people tried to help?",
                "Did it change what you expect from the people around you?",
            ]),
            ("What's a lesson you had to learn the hard way more than once?", .growth, [
                "What kept pulling you back into the same mistake?",
                "What finally made it stick?",
            ]),
        ], mode: .friends, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Friends · Honest · Deep Dive

    static func friends_honest_deepDive() -> [Prompt] {
        make([
            ("What's a dream you've kept entirely to yourself?", .intimacy, [
                "What makes it feel too private or fragile to share?",
                "What would it take for you to start chasing it?",
            ]),
            ("Who do you owe an apology that you haven't given yet?", .conflict, [
                "What's been stopping you from offering it?",
                "What do you think it would change — for them and for you?",
            ]),
            ("Who's a friend you haven't shown up for the way you should have?", .conflict, [
                "What got in the way?",
                "If you could go back to that moment, what would you do differently?",
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
                "Do you think you deserve that forgiveness?",
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
                "What do you think that thought says about you?",
                "Does having it scare you or do you accept it as part of being human?",
            ]),
            ("What's the most honest thing you've ever said to someone's face?", .communication, [
                "How did they take it?",
                "Would you say it again?",
            ]),
            ("What's an experience that hardened you in a way others don't see?", .past, [
                "What part of you did it close off?",
                "Do you see the hardening as protection or damage?",
            ]),
            ("When did you last feel truly ashamed of yourself?", .emotions, [
                "What triggered the shame?",
                "Have you been able to work through it?",
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
        ], mode: .friends, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Friends · Unfiltered · Real Talk

    static func friends_unfiltered_realTalk() -> [Prompt] {
        make([
            ("When's a time you should have admitted you were wrong but couldn't bring yourself to?", .conflict, [
                "What was at stake that made the admission feel impossible?",
                "Do you think the other person knew you were wrong?",
            ]),
            ("What's something you've never told anyone how you really feel about?", .emotions, [
                "What has keeping it inside done to you?",
                "What would finally saying it change?",
            ]),
            ("What's something you really hope certain people never find out about?", .intimacy, [
                "What are you most afraid they'd think?",
                "Would the truth actually be as bad as you imagine?",
            ]),
            ("Who was the last person who really pushed you past your breaking point?", .conflict, [
                "What did your breaking point look like?",
                "How did you come back from it?",
            ]),
            ("What's a grudge you've been carrying longer than you probably should?", .conflict, [
                "What would it take to finally set it down?",
                "What is holding onto it giving you?",
            ]),
            ("What's a relationship you damaged that you sometimes still think about?", .conflict, [
                "What do you think you would have done differently?",
                "Do you think repair is still possible?",
            ]),
            ("What does loyalty actually mean to you when it gets tested?", .values, [
                "When has your loyalty been tested the hardest?",
                "Where do you draw the line between loyalty and self-respect?",
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
                "What would the full version reveal about you?",
            ]),
            ("When did someone break your trust in a way that changed how you operate?", .conflict, [
                "What defense did you build because of it?",
                "Has anyone since earned back the kind of trust you lost?",
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
                "Would you be proud or horrified if your kids did the same?",
                "Who else knows about it?",
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
                "Do you still have it?",
            ]),
            ("What makes you the proudest about your family?", .appreciation, [
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
            ("What's something a family member taught you that you still use today?", .appreciation, [
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
            ("What's the best piece of advice a family member ever gave you?", .values, [
                "When did you first realize they were right?",
                "Has it held up over time?",
            ]),
            ("What holiday tradition means the most to you and why?", .values, [
                "What would it feel like if that tradition stopped?",
                "What does it represent to you beyond the tradition itself?",
            ]),
            ("Who in your family always knows how to make you feel better?", .appreciation, [
                "What do they do that works so well?",
                "Do they know they have that power?",
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
                "Have you told them you appreciate it now?",
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
                "What pressure does it put on you?",
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
            ("What's a family memory that still makes you emotional?", .emotions, [
                "What about it still gets to you?",
                "Who else in your family shares that memory?",
            ]),
            ("What do you wish your parents had done differently?", .past, [
                "How do you think it would have changed you?",
                "Have you been able to talk to them about it?",
            ]),
            ("What's a sacrifice a family member made for you that you think about often?", .appreciation, [
                "Do they know how much it meant to you?",
                "How did it shape the way you show up for others?",
            ]),
            ("What's something about your upbringing you didn't question until you were older?", .growth, [
                "What made you start questioning it?",
                "How did the new perspective change you?",
            ]),
            ("How has your relationship with a family member changed over the years?", .growth, [
                "What caused the biggest shift?",
                "Is the current version better or just different?",
            ]),
            ("What's the most important thing your family taught you about trust?", .values, [
                "Was it taught through example or through a lesson learned the hard way?",
                "How does that understanding show up in your relationships now?",
            ]),
            ("What's a misunderstanding in your family that was never properly cleared up?", .conflict, [
                "Does it still affect how you relate to each other?",
                "What would it take to finally clear the air?",
            ]),
            ("What do you think your family worries about most when it comes to you?", .emotions, [
                "Is their worry justified?",
                "How do you feel knowing they carry that concern?",
            ]),
            ("What's a moment where your family really came together?", .appreciation, [
                "What brought everyone together?",
                "What did you learn about your family in that moment?",
            ]),
            ("What's something about your family dynamic that outsiders wouldn't understand?", .communication, [
                "Does it work for you, or do you wish it were different?",
                "What would you want someone outside to know?",
            ]),
            ("When did you feel the most supported by your family?", .appreciation, [
                "What did that support look like?",
                "Did it change what you expect from them going forward?",
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
            ("What's something you've forgiven a family member for that was really hard?", .conflict, [
                "What did forgiving them cost you?",
                "Did the forgiveness change the relationship?",
            ]),
            ("What do you think your family's greatest strength is?", .appreciation, [
                "When does that strength show up the most?",
                "How do you contribute to it?",
            ]),
            ("What's a story about your parents' early life that changed how you see them?", .past, [
                "What did it help you understand about who they are?",
                "Did it make you feel closer to them or more complicated about them?",
            ]),
            ("What's something your family doesn't talk about but probably should?", .communication, [
                "What keeps the silence going?",
                "Who do you think would need to go first?",
            ]),
            ("When have you felt the proudest to be part of your family?", .appreciation, [
                "What sparked that pride?",
                "Do you think your family knows you feel that way?",
            ]),
        ], mode: .family, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Family · Honest · Real Talk

    static func family_honest_realTalk() -> [Prompt] {
        make([
            ("What's a conversation you know you need to have with your parents?", .communication, [
                "What's been holding it back?",
                "How do you imagine it going?",
            ]),
            ("What's a decision someone else made that ended up changing the course of your life?", .past, [
                "Did you have any say in it at the time?",
                "How do you feel about it now — grateful, resentful, or somewhere in between?",
            ]),
            ("Who really holds the power in your family, and how does that affect everyone?", .communication, [
                "Is that power dynamic acknowledged or unspoken?",
                "How has it shaped your own relationship with authority?",
            ]),
            ("What about being a parent — or the idea of it — genuinely worries you?", .emotions, [
                "Where do you think that worry comes from?",
                "What pattern are you most afraid of repeating?",
            ]),
            ("What's something from your childhood that you later realized wasn't everyone's normal?", .past, [
                "How did that realization land?",
                "Has it changed the way you see your upbringing?",
            ]),
            ("What's something about your background you wish more people took the time to understand?", .values, [
                "How would your experience change if they really got it?",
                "What's the most common misunderstanding?",
            ]),
            ("What comes up for you when you see a photo of yourself as a kid?", .past, [
                "What do you feel looking at that version of yourself?",
                "What would you want that kid to know?",
            ]),
            ("What's something you did that you refuse to apologize for?", .values, [
                "What principle are you standing on?",
                "Does anyone in your life still hold it against you?",
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
            ("What's an experience that shaped who you are that almost nobody knows about?", .past, [
                "Why have you kept it so private?",
                "What would sharing it mean for you?",
            ]),
            ("What did your parents teach you about love — whether they meant to or not?", .intimacy, [
                "Was it a lesson you had to unlearn or one you're grateful for?",
                "How does it show up in your relationships now?",
            ]),
            ("Who taught you the most about what love actually looks like?", .intimacy, [
                "What did they do that made the lesson stick?",
                "Did they know they were teaching you?",
            ]),
            ("If you could change one thing about the way you were raised, what would it be?", .past, [
                "How do you think that one change would have rippled through your life?",
                "Have you been able to talk to your parents about it?",
            ]),
            ("What would you go back and whisper to your younger self?", .past, [
                "What's the one thing that kid needed to hear most?",
                "Do you think they would have listened?",
            ]),
        ], mode: .family, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Family · Unfiltered · Warm Up

    static func family_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What role do you play in your family, and how did that happen?", .identity, [
                "Is it a role you want, or one that was assigned to you?",
                "What would that free you to be?",
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
                "What would the truth demand from everyone?",
            ]),
            ("What's something about your childhood you've never fully processed?", .emotions, [
                "What happens when it surfaces?",
                "What do you think processing it would require?",
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
            ("What's something a family member did that you've never been able to fully forgive?", .conflict, [
                "What would forgiveness require from you?",
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
            ("What's a toxic pattern in your family that you're trying not to repeat?", .growth, [
                "When do you catch yourself falling into it?",
                "What's your alternative look like?",
            ]),
            ("What's the hardest thing about loving someone in your family?", .emotions, [
                "What makes the love complicated?",
                "Is the difficulty worth it?",
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
            ("What's something you've never confronted a family member about but probably should?", .communication, [
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
        ], mode: .family, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Family · Unfiltered · Real Talk

    static func family_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What subjects are the hardest to bring up in your family?", .communication, [
                "What makes those topics feel off-limits?",
                "What do you think would happen if you went there anyway?",
            ]),
            ("What's a topic that's completely off-limits in your family?", .communication, [
                "Who enforces that boundary?",
                "What do you think the silence is protecting?",
            ]),
            ("What's something you hope your kids — or future kids — never learn about you?", .past, [
                "What are you afraid it would change about how they see you?",
                "Is it something you've made peace with yourself?",
            ]),
            ("What's a question you've always wanted to ask your parents but never have?", .communication, [
                "What are you afraid the answer might be?",
                "What would it change if you finally asked?",
            ]),
        ], mode: .family, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Family · Unfiltered · Deep Dive

    static func family_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something that was taken from you — not necessarily a physical thing?", .past, [
                "How did losing that shape who you became?",
                "Do you think you'll ever get it back in some form?",
            ]),
            ("Whose loss are you the most afraid of?", .emotions, [
                "What would that loss take from your world?",
                "Does the fear of it change how you love them now?",
            ]),
            ("Who are you most afraid of losing in your life?", .emotions, [
                "What makes that person irreplaceable to you?",
                "How does that fear affect the way you hold onto them?",
            ]),
            ("What trait of your parents are you most afraid of seeing in yourself?", .past, [
                "When do you catch glimpses of it?",
                "What do you do when you see it surface?",
            ]),
            ("How has your experience with loss or death shaped the way you live?", .past, [
                "What did loss teach you that nothing else could?",
                "Has it made you hold tighter or let go more?",
            ]),
            ("What's something you've never told your parents?", .communication, [
                "What would it mean for them to finally know?",
                "What's kept you from saying it all this time?",
            ]),
            ("What's a conversation from your past you wish you could have one more time?", .communication, [
                "What would you say differently?",
                "What do you wish you had heard?",
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
            ("What's something you used to know how to do but have completely lost?", .past, [
                "Do you miss it?",
                "What would it take to get it back?",
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
            ("When you look in the mirror, what's the first thing that comes to mind?", .emotions, [
                "Is that thought kind or critical?",
                "Has the voice in your head always said that?",
            ]),
            ("What's a bad habit you've tried to break but keep coming back to?", .growth, [
                "What does the habit give you that makes it so sticky?",
                "What would breaking it actually require from you?",
            ]),
            ("What do you waste the most mental energy worrying about?", .emotions, [
                "How much of that worry has ever come true?",
                "What would you think about if you could stop?",
            ]),
            ("What do you find surprisingly hard to say yes to?", .communication, [
                "What's underneath that hesitation?",
                "What are you protecting by holding back?",
            ]),
            ("What's a part of your life that doesn't match who you thought you'd be by now?", .identity, [
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
            ("What's a relationship in your life that needs more attention?", .intimacy, [
                "What's been getting in the way?",
                "What would showing up more look like?",
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
            ("What's something you need to hear right now but nobody's saying?", .emotions, [
                "Why do you think no one has said it?",
                "Can you say it to yourself and have it count?",
            ]),
            ("What's an area of your life where you've been coasting?", .growth, [
                "What would it look like if you started trying again?",
                "What let you start coasting in the first place?",
            ]),
            ("What's a fear that's been quietly influencing your choices?", .emotions, [
                "How many decisions has it shaped without you realizing?",
                "What would you choose if that fear weren't there?",
            ]),
            ("What would change in your life if you stopped people-pleasing?", .growth, [
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
            ("What's something about your current life that your younger self would find confusing?", .past, [
                "What would you explain to them about how you got here?",
                "Would they be proud or concerned?",
            ]),
            ("What's a way you've grown in the last year that you haven't acknowledged?", .growth, [
                "Why is it so hard to give yourself credit?",
                "What does that growth mean for who you're becoming?",
            ]),
            ("What's something you keep avoiding because it would mean real change?", .growth, [
                "What's the change you're most afraid of?",
                "What would life look like on the other side of it?",
            ]),
            ("What would you change about yourself if you had a magic wand to make it happen?", .values, [
                "Name three reasons why you would make that change?",
                "How would your life change if you made the change?",
            ]),
        ], mode: .soloReflection, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Honest · Real Talk

    static func solo_honest_realTalk() -> [Prompt] {
        make([
            ("What's a blind spot you're slowly starting to see in yourself?", .growth, [
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
            ("What's one thing about yourself you know you need to change?", .growth, [
                "What has that thing cost you already?",
                "What would be different once you made the change?",
            ]),
            ("What's something in your life that nobody truly understands your relationship with?", .identity, [
                "What would someone need to know to get it?",
                "Does the misunderstanding bother you or have you accepted it?",
            ]),
            ("When are you most proud of having stood up for yourself?", .growth, [
                "What gave you the courage to do it?",
                "How did it change what you expect from yourself?",
            ]),
            ("What's something you've been holding onto way longer than you need to?", .past, [
                "What would happen if you finally let it go?",
                "What does holding on give you?",
            ]),
            ("When was the last time you bent the rules in a way that still sits with you?", .conflict, [
                "Do you feel guilty about it or justified?",
                "Would you do it again?",
            ]),
            ("What kind of people make you feel the most envious, and why?", .emotions, [
                "What does the envy reveal about what you want?",
                "Is it something you could actually pursue?",
            ]),
            ("What's something you finally feel clear about after a long stretch of confusion?", .growth, [
                "What brought the clarity?",
                "How does it feel to be on the other side of it?",
            ]),
            ("What's a boundary you've set recently that felt like real progress?", .growth, [
                "What made you finally draw the line?",
                "How has life been different since?",
            ]),
            ("When did you start to feel that perfect justice might not exist?", .growth, [
                "What experience made that idea feel less real?",
                "How has that changed the way you see fairness or people?",
            ]),
            ("What's something you once believed would always work out, but now aren't so sure about?", .emotions, [
                "What caused that belief to shift?",
                "How do you feel holding that uncertainty now?",
            ]),
        ], mode: .soloReflection, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Honest · Deep Dive

    static func solo_honest_deepDive() -> [Prompt] {
        make([
            ("What would you give anything to have a second chance at?", .past, [
                "What would you do differently this time?",
                "What has not getting that chance taught you about your choices in life?",
            ]),
            ("What do you know you need to let go of but can't seem to release?", .growth, [
                "What would your life look like without it?",
                "What keeps your grip so tight?",
            ]),
            ("What's the gap between who you are and who you want to be — and what lives in that gap?", .growth, [
                "What fills that space right now — fear, habit, or something else?",
                "What's the first step changing this and and moving a step towards who you want to be?",
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
            ("What's the ugliest thought you've had about yourself recently?", .emotions, [
                "Where do you think that thought came from?",
                "Do you believe it, or can you see it as just a thought that passed through?",
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
                "What is a healthier replacement and what would it do for you?",
            ]),
            ("What would people think if they could see your internal monologue?", .emotions, [
                "Would they be surprised, concerned, or relieved?",
                "Is there a gap between what you think and what you show?",
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
            ("What's the hardest thing about being you that nobody sees?", .emotions, [
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
                "Does it really matter if others know?",
                "What's the worst thing that could happen and how would you prepare for it?",
            ]),
            ("What's something you've numbed yourself to that you know you need to eventually face?", .emotions, [
                "How are you avoiding it?",
                "What do you think would happen if you addressed it?",
            ]),
            ("What's a part of your story you've rewritten to make it easier to tell?", .past, [
                "What did you leave out and why?",
                "What would the unedited version reveal about you or expect others to accept?",
            ]),
            ("When was the last time you felt completely happy with yourself?", .emotions, [
                "Why did it make you feel that way?",
                "What would you need to do to feel it more often?",
            ]),
            ("What's a sacrifice you made that nobody ever thanked you for?", .appreciation, [
                "Did it help the relationship or damage it?",
                "Would you do it again knowing no one would noticed?",
            ]),
            ("Do you think that confession of wrongs is necessary for you to move forward?", .values, [
                "Who does the confession actually help and why?",
                "Is there a social prupose to the confession of worngs."
            ]),
            ("Do you have a wound in your heart that never fully heals?", .emotions, [
                "Is this something you can change or do you need help from others? Who?",
                "What would healing actually require and what would be the benefits?",
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
            ("When was the last time you felt like a total fraud?", .identity, [
                "What situation brought that feeling on?",
                "Do you think others see through it, or is it all internal?",
            ]),
            ("How would you honestly describe your relationship with your body?", .identity, [
                "When is that relationship at its hardest?",
                "What would a healthier version of it look like?",
            ]),
            ("When did you last seriously doubt yourself, and what triggered it?", .growth, [
                "How did you move through the doubt?",
                "Did it reveal something real or was it just noise?",
            ]),
            ("What have you been faking lately that you wish you could just stop?", .growth, [
                "Who are you performing for?",
                "What would dropping the act actually cost you?",
            ]),
            ("What's a lie you told once that you still think about?", .conflict, [
                "Why does it still have a hold on you?",
                "What would making it right look like now?",
            ]),
            ("When did you first realize that you will one day die?", .emotions, [
                "How old were you, and what made that realization land?",
                "Does that awareness change how you think about your life now?",
            ]),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Unfiltered · Deep Dive

    static func solo_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something you've been putting off being honest with yourself about?", .identity, [
                "What would the honest version sound like if you said it out loud?",
                "What are you afraid will shift once you admit it?",
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
                "Do you think you've earned forgiveness, even if you haven't given it to yourself?",
            ]),
            ("What's a belief you hold deeply but have never actually said out loud?", .values, [
                "What makes it feel too risky to share?",
                "What would it mean to own it publicly?",
            ]),
            ("What's something that hurt you that you never talked to anyone about?", .emotions, [
                "What kept you silent?",
                "What would you need from someone to feel safe opening up about it?",
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
            ("What's something you wish you could finally get closure on?", .emotions, [
                "What would closure actually look like for you?",
                "Is it something someone else needs to give you, or something you give yourself?",
            ]),
            ("What principle would you never compromise on, no matter what?", .values, [
                "When has that principle been tested the hardest?",
                "What does it protect in you that nothing else can?",
            ]),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .deepDive)
    }
}
