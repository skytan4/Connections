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
        FollowUp(text: "Why that?"),
        FollowUp(text: "Has that always been true?"),
        FollowUp(text: "What changed?")
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
    static func make(_ entries: [(String, Topic, [String])], mode: Mode, intensity: Intensity, depth: DepthLevel) -> [Prompt] {
        entries.map { Prompt(text: $0.0, mode: mode, intensity: intensity, depthLevel: depth, topic: $0.1, followUps: $0.2.map { FollowUp(text: $0) }) }
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
            ("What's the most unexpected compliment you've ever received?", .appreciation),
            ("When was the last time you got completely lost in a great experience?", .dailyLife),
            ("What's the funniest thing that's happened to us that we never get tired of retelling?", .dailyLife),
            ("Something I do that turns me off is…", .sex),
            ("Something that tends to turn me on is…", .sex),
            ("One of the most sensual experiences I've had that didn't involve sex was…", .sex),
            ("I still remember a time I felt deeply desired when…", .sex),
            ("An intimate memory that still makes me cringe a little is…", .sex),
            ("One of the most memorable intimate moments I've had was…", .sex),
            ("Something I do that helps make intimacy more engaging is…", .sex),
            ("An embarrassing intimate moment I've experienced was…", .sex),
            ("What makes me feel most desired by you is…", .sex),
            ("A moment I felt truly connected to you physically was…", .sex),
        ], mode: .couples, intensity: .light, depth: .realTalk)
    }

    // MARK: - Couples · Light · Deep Dive

    static func couples_light_deepDive() -> [Prompt] {
        make([
            ("What moment made you think — okay, this person really gets me?", .intimacy),
            ("What's something about us you'd never want to change?", .appreciation),
            ("How do you think we've changed each other for the better?", .growth),
            ("What's your favorite chapter of our story so far?", .past),
        ], mode: .couples, intensity: .light, depth: .deepDive)
    }

    // MARK: - Couples · Honest · Warm Up

    static func couples_honest_warmUp() -> [Prompt] {
        make([
            ("What's been on your mind late at night recently?", .emotions),
            ("What's weighing on you the most right now?", .emotions),
            ("When was the last time you got way more upset than the situation deserved?", .conflict),
            ("I feel most sensual when…", .sex),
            ("I feel most attractive when…", .sex),
            ("What's something you wish I understood better about you?", .communication),
            ("What's a fear you haven't told me about?", .emotions),
            ("When do you feel most disconnected from me?", .intimacy),
            ("What's something I do that makes you feel truly seen?", .appreciation),
            ("What's a part of your day you wish we could share more?", .dailyLife),
            ("What's a habit of mine that quietly frustrates you?", .conflict),
            ("What's something you've been meaning to apologize for?", .conflict),
            ("When do you feel the safest with me?", .intimacy),
            ("What's something about our relationship that surprised you?", .growth),
            ("What's something you admire about the way I love you?", .appreciation),
            ("What's a conversation we had that stuck with you?", .communication),
            ("What do you think we're both avoiding right now?", .communication),
            ("When was the last time I really made you laugh?", .appreciation),
            ("What's a way I've helped you grow that you haven't mentioned?", .growth),
            ("What do you wish we did more of together?", .dailyLife),
            ("What's something about our early days that you miss?", .past),
            ("How do you feel about how we handle money together?", .values),
            ("What's a boundary you need me to respect more?", .communication),
            ("What's something you're proud of us for getting through?", .growth),
            ("When do you feel most like yourself around me?", .identity),
            ("What's an insecurity that still shows up in our relationship?", .emotions),
            ("What's something I said recently that meant more than I probably realized?", .appreciation),
            ("What do you need from me that you find hard to ask for?", .communication),
            ("What's a small moment between us that you keep replaying?", .intimacy),
            ("What's something you've learned about love from being with me?", .growth),
        ], mode: .couples, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Couples · Honest · Real Talk

    static func couples_honest_realTalk() -> [Prompt] {
        make([
            ("What does money actually mean to you — beyond the obvious?", .values),
            ("What's something in your life that's worth fighting harder for?", .values),
            ("When was the last time you really cried, and what brought it on?", .emotions),
            ("What's the last promise you broke, and does it still bother you?", .conflict),
            ("When was the last time you held back tears and pretended you were fine?", .emotions),
            ("Who would you most want to show the person you've become?", .appreciation),
            ("What's a conversation you know you need to have but keep putting off?", .communication),
            ("How do you feel when you notice yourself getting older?", .emotions),
            ("What's something you really want from me but haven't been able to ask for?", .communication),
            ("Where do you feel the most friction between us right now?", .conflict),
            ("What would you change about how you handle conflict with the people you love?", .conflict),
            ("When do you wish you had spoken up instead of staying quiet?", .communication),
            ("When was the last time jealousy really got under your skin?", .emotions),
            ("What do you admire most about the way your partner handles hard things?", .appreciation),
            ("I wish someone had prepared me better for sex by telling me…", .sex),
            ("I tend to lose interest during intimacy when…", .sex),
            ("A message I sometimes imagine sending you is…", .sex),
            ("A message I secretly wish I'd receive from you is…", .sex),
            ("In terms of energy or dynamic, I tend to lean more toward…", .sex),
            ("When it comes to initiating intimacy, I usually…", .sex),
            ("Most of what I've learned about sex has come from…", .sex),
            ("One thing I wish we talked about more openly is…", .sex),
            ("Something I'd like us to explore together is…", .sex),
        ], mode: .couples, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Couples · Honest · Deep Dive

    static func couples_honest_deepDive() -> [Prompt] {
        make([
            ("What does your heart need to hear from me right now?", .emotions),
            ("What moment completely changed how you think about love?", .intimacy),
            ("What about our future excites you and scares you at the same time?", .emotions),
            ("I think the idea of marriage, when it comes to intimacy, is…", .sex),
            ("During intimacy, everything else fades away when…", .sex),
            ("A sexual question or uncertainty I still think about is…", .sex),
            ("A belief about sex I've had to rethink over time is…", .sex),
            ("Something I don't fully understand about desire is…", .sex),
            ("My sex life changed in a meaningful way after…", .sex),
            ("An early experience that shaped how I think about sex was…", .sex),
            ("The difference between emotional intimacy and physical intimacy feels like…", .sex),
            ("Sex feels most meaningful to me when…", .sex),
            ("Growing up, the message I got about sex was…", .sex),
            ("What makes me feel most safe during intimacy is…", .sex),
            ("What helps me fully relax and be present with you is…", .sex),
        ], mode: .couples, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Couples · Unfiltered · Warm Up

    static func couples_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What part of yourself have you been hiding from the people closest to you?", .emotions),
            ("What's something about us that you've never quite figured out?", .communication),
            ("How honest do you think we really are with each other?", .communication),
            ("I feel most sensual when…", .sex),
            ("I feel most attractive when…", .sex),
            ("What's a thought about us you've never said out loud?", .intimacy),
            ("What's something you need from this relationship that you're not getting?", .communication),
            ("When have you felt the most misunderstood by me?", .conflict),
            ("What's something about me that you've had to learn to accept?", .growth),
            ("What's a version of yourself you only show to me?", .identity),
            ("What scares you most about our future together?", .emotions),
            ("What's a pattern in our relationship you think we should break?", .conflict),
            ("What do you wish you could be more honest about with me?", .communication),
            ("What's something I do that triggers something deeper in you?", .emotions),
            ("When did you last question whether we were on the same page?", .communication),
            ("What's something about love that nobody warned you about?", .growth),
            ("What's a resentment you've been carrying that you haven't voiced?", .conflict),
            ("What's the most vulnerable you've ever felt with me?", .intimacy),
            ("What do you think our biggest blind spot as a couple is?", .growth),
            ("What's a truth about yourself that you're afraid would change how I see you?", .emotions),
            ("When have you sacrificed too much of yourself for this relationship?", .values),
            ("What's a fight we had that actually changed something for the better?", .conflict),
            ("What's something about my past that still sits with you?", .past),
            ("What would you change about how we communicate when things get hard?", .communication),
            ("What's an expectation you've placed on me that might not be fair?", .conflict),
            ("When was the last time you felt completely alone even though we were together?", .emotions),
            ("What's something you've forgiven me for that I don't know about?", .conflict),
            ("What do you think we each avoid feeling the most?", .emotions),
            ("What's a way you've changed since being with me that worries you?", .identity),
            ("What's something about us that you'd be embarrassed for others to know?", .intimacy),
        ], mode: .couples, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Couples · Unfiltered · Real Talk

    static func couples_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What's something you've been pretending is fine when it really isn't?", .emotions),
            ("When did you hurt someone without meaning to, and what happened after?", .conflict),
            ("What makes you the hardest to live with — if you're being honest?", .conflict),
            ("When did you last feel genuinely lost, and what was happening?", .emotions),
            ("In what situations are you your own worst enemy?", .growth),
            ("How do you tend to withdraw your love or attention when you're upset?", .conflict),
            ("When was a time you admitted you were wrong — and how did that feel?", .conflict),
            ("Something I've always been curious to explore sexually is…", .sex),
            ("The word \u{201C}forbidden\u{201D} makes me think of…", .sex),
        ], mode: .couples, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Couples · Unfiltered · Deep Dive

    static func couples_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something you used to dream about but have quietly given up on?", .emotions),
            ("What would you give up everything for if you had to choose?", .values),
            ("Is there someone you think of as the one who got away?", .intimacy),
            ("What's the hardest lesson love has ever taught you?", .intimacy),
            ("What's the heartbreak that hit you the hardest?", .emotions),
            ("When was the last time you felt truly lonely, even if you weren't alone?", .emotions),
            ("What would be something you could never forgive in a relationship?", .conflict),
            ("If my partner had an affair, I think I would…", .sex),
            ("One of the most awkward or uncomfortable moments I've had after intimacy was…", .sex),
            ("A fantasy I have mixed feelings about is…", .sex),
            ("Something I haven't been fully honest about in my sexual past is…", .sex),
            ("A recurring fantasy I've had is…", .sex),
        ], mode: .couples, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Friends · Light · Warm Up

    static func friends_light_warmUp() -> [Prompt] {
        make([
            ("How do you wish people would describe you when they introduce you?", .identity),
            ("What's a book you find yourself recommending to everyone?", .dailyLife),
            ("Is there a contact in your phone you know you should probably delete?", .conflict),
            ("If your life was a movie, who would you cast to play you?", .dailyLife),
            ("What's the last time you got caught doing something you shouldn't have been doing?", .dailyLife),
            ("What's the most embarrassing moment you can actually laugh about now?", .dailyLife),
            ("What's the last truly generous thing you did for someone without being asked?", .appreciation),
            ("What's a rule you secretly enjoy breaking?", .identity),
            ("If you got fired tomorrow, what would it probably be for?", .dailyLife),
            ("If you could be known for one thing, what would it be?", .values),
            ("What's something you've always wondered if everyone secretly does too?", .identity),
            ("What could you talk about for hours that most people wouldn't expect?", .values),
            ("What would you happily do for a living if money didn't matter at all?", .dailyLife),
            ("If you could start a completely different career tomorrow, what would you pick?", .dailyLife),
            ("If you wrote a book about your life so far, what would you call it?", .values),
            ("What brings out your competitive side more than anything else?", .identity),
            ("At a party, where would someone most likely find you?", .dailyLife),
            ("What do people consistently get wrong about you?", .communication),
            ("What's something you pretend to know way more about than you actually do?", .identity),
            ("What's the weirdest dream you've ever had?", .dailyLife),
            ("What's a quality in your closest friend that you genuinely admire?", .appreciation),
            ("When was the last time someone made your day without even trying?", .appreciation),
            ("What's the most random thing on your bucket list?", .dailyLife),
            ("What's a hill you will die on that nobody else seems to care about?", .values),
            ("What's the best meal you've ever had and where was it?", .dailyLife),
            ("What's something you're weirdly good at that has no practical use?", .identity),
            ("What's the last thing you stayed up way too late doing?", .dailyLife),
            ("What's a trend you absolutely refuse to get on board with?", .values),
            ("What's the most thoughtful thing a friend has ever done for you?", .appreciation),
            ("What's something you only do when nobody's watching?", .identity),
        ], mode: .friends, intensity: .light, depth: .warmUp)
    }

    // MARK: - Friends · Light · Real Talk

    static func friends_light_realTalk() -> [Prompt] {
        make([
            ("Who's someone who had a huge impact on your life without ever realizing it?", .appreciation),
            ("When did you completely flip your perspective on something you used to believe?", .growth),
            ("Who do you owe a long-overdue thank you?", .appreciation),
        ], mode: .friends, intensity: .light, depth: .realTalk)
    }

    // MARK: - Friends · Light · Deep Dive

    static func friends_light_deepDive() -> [Prompt] {
        make([
            ("How do you think we've rubbed off on each other over time?", .growth),
            ("What do you think keeps our friendship going through everything?", .appreciation),
            ("What's a value you think we share that really matters to you?", .values),
            ("What's a moment where you felt like I really got you?", .intimacy),
        ], mode: .friends, intensity: .light, depth: .deepDive)
    }

    // MARK: - Friends · Honest · Warm Up

    static func friends_honest_warmUp() -> [Prompt] {
        make([
            ("What's a story people tell about you that isn't quite right — but you never bother to correct?", .communication),
            ("How do you honestly feel when a friend is always running late?", .conflict),
            ("Who gets under your skin more than anyone, and why do you think that is?", .conflict),
            ("What was the last lie you told, and why did you tell it?", .communication),
            ("What are you the most judgmental about, even if you'd never admit it?", .values),
            ("What's something you've always been a little bit embarrassed about?", .emotions),
            ("What's a friendship you let fade that you sometimes regret?", .past),
            ("What do you wish your friends understood about your life right now?", .communication),
            ("When was the last time you felt left out by people you care about?", .emotions),
            ("What's something you've noticed about yourself that you don't love?", .growth),
            ("What's a compliment you received that caught you off guard?", .appreciation),
            ("What's something you keep doing even though you know it's not great for you?", .growth),
            ("What do you find hardest about maintaining friendships as you get older?", .communication),
            ("What's a promise you made to yourself that you've actually kept?", .values),
            ("When's the last time you felt genuinely jealous of a friend?", .emotions),
            ("What's something you've outgrown but haven't let go of yet?", .growth),
            ("What's a topic you avoid with certain friends and why?", .communication),
            ("What's the hardest part about being honest with the people closest to you?", .communication),
            ("What do you wish someone would just ask you about?", .emotions),
            ("What's something you've been overthinking lately?", .emotions),
            ("What's an opinion you hold that you know your friends would push back on?", .values),
            ("When did a friend disappoint you in a way they probably don't know about?", .conflict),
            ("What's a part of your personality that only comes out around certain people?", .identity),
            ("What's a moment where you felt truly appreciated by a friend?", .appreciation),
            ("What's something that's been harder than you've let on?", .emotions),
            ("What do you think makes you a good friend, and where do you fall short?", .growth),
            ("What's a conversation you had recently that left you thinking for days?", .communication),
            ("What's something you pretend to be okay with but actually aren't?", .emotions),
            ("What's a risk you wish you had the courage to take right now?", .growth),
            ("When was the last time you really showed up for someone in a meaningful way?", .appreciation),
        ], mode: .friends, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Friends · Honest · Real Talk

    static func friends_honest_realTalk() -> [Prompt] {
        make([
            ("When was a time you were meaner than the situation called for?", .conflict),
            ("What version of yourself are you sometimes tempted to present that isn't quite real?", .identity),
            ("What's a mistake you made once that you know you'll never repeat?", .growth),
            ("Who challenges you the most in your life right now, and how do you deal with it?", .conflict),
            ("Who intimidates you, and what do you think that says about you?", .identity),
            ("What's a risk you took that ended up completely changing things?", .growth),
            ("What's something only your closest friends know about you?", .intimacy),
            ("What's a message you sent that you immediately wished you could take back?", .communication),
            ("What's a challenge you've faced that you're proud of getting through?", .appreciation),
            ("What's something you took credit for that you probably shouldn't have?", .conflict),
            ("When was the last time you played a version of yourself that wasn't really you?", .identity),
            ("When do you tell yourself it's not really lying?", .communication),
            ("What's a moment from your past you wish everyone would just forget?", .past),
            ("What's a story you tell about yourself that's not totally accurate?", .communication),
            ("What's a way someone has shown up for you that you'll never forget?", .appreciation),
            ("What's a lesson you had to learn the hard way more than once?", .growth),
        ], mode: .friends, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Friends · Honest · Deep Dive

    static func friends_honest_deepDive() -> [Prompt] {
        make([
            ("What's a dream you've kept entirely to yourself?", .intimacy),
            ("Who do you owe an apology that you haven't given yet?", .conflict),
            ("Who's a friend you haven't shown up for the way you should have?", .conflict),
        ], mode: .friends, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Friends · Unfiltered · Warm Up

    static func friends_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What's something you pretend doesn't bother you but absolutely does?", .emotions),
            ("What do people get wrong about you the most?", .communication),
            ("What opinion do you hold that most of your friends would disagree with?", .values),
            ("What's the worst advice you've ever followed?", .growth),
            ("What's a part of yourself you've had to fight to accept?", .identity),
            ("What's something you've done that you'll never fully explain to anyone?", .past),
            ("When have you been the villain in someone else's story?", .conflict),
            ("What's a belief you held strongly that completely fell apart?", .values),
            ("What's something about the way you were raised that you've had to unlearn?", .growth),
            ("What's the loneliest you've ever felt in a room full of people?", .emotions),
            ("What's a side of yourself that only comes out when you're angry?", .identity),
            ("What's something you've said that you can never take back?", .conflict),
            ("What's a truth about yourself that most people couldn't handle?", .identity),
            ("When was the last time you seriously considered cutting someone off?", .conflict),
            ("What's something you judge other people for that you're also guilty of?", .values),
            ("What's the most selfish thing you've done that you don't regret?", .values),
            ("What's a feeling you've been suppressing for way too long?", .emotions),
            ("What's something you've never been able to forgive yourself for?", .emotions),
            ("What do you wish people would stop pretending to care about?", .values),
            ("What's a moment where you realized a friendship was one-sided?", .conflict),
            ("What's something dark you've thought about that you'd never say out loud?", .emotions),
            ("What's the most honest thing you've ever said to someone's face?", .communication),
            ("What's an experience that hardened you in a way others don't see?", .past),
            ("When did you last feel truly ashamed of yourself?", .emotions),
            ("What's a secret you've kept from your closest friends?", .intimacy),
            ("What's a way you've manipulated a situation that you're not proud of?", .conflict),
            ("What's a double standard you hold that you know isn't fair?", .values),
            ("What's something you lost respect for someone over?", .conflict),
            ("When's the last time you cried and what set it off?", .emotions),
            ("What's a question you're afraid someone might ask you?", .emotions),
        ], mode: .friends, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Friends · Unfiltered · Real Talk

    static func friends_unfiltered_realTalk() -> [Prompt] {
        make([
            ("When's a time you should have admitted you were wrong but couldn't bring yourself to?", .conflict),
            ("What's something you've never told anyone how you really feel about?", .emotions),
            ("What's something you really hope certain people never find out about?", .intimacy),
            ("Who was the last person who really pushed you past your breaking point?", .conflict),
            ("What's a grudge you've been carrying longer than you probably should?", .conflict),
            ("What's a relationship you damaged that you sometimes still think about?", .conflict),
            ("What does loyalty actually mean to you when it gets tested?", .values),
        ], mode: .friends, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Friends · Unfiltered · Deep Dive

    static func friends_unfiltered_deepDive() -> [Prompt] {
        make([
            ("Is there a friendship you've outgrown but haven't walked away from yet?", .conflict),
            ("What's a story you've told before but never the complete, honest version?", .intimacy),
            ("When did someone break your trust in a way that changed how you operate?", .conflict),
        ], mode: .friends, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Family · Light · Warm Up

    static func family_light_warmUp() -> [Prompt] {
        make([
            ("What's a value from your culture or background that really matters to you?", .values),
            ("What's a moment from your younger years you can't believe you walked away from?", .past),
            ("What's a story you know you've told way too many times?", .dailyLife),
            ("What's a smell that instantly takes you back to a specific moment?", .past),
            ("What's something you genuinely can't believe you got away with growing up?", .past),
            ("What completely breaks your willpower every single time?", .dailyLife),
            ("What's something you miss being able to do that you used to take for granted?", .past),
            ("What do you wish you could still get away with?", .past),
            ("What's your most irrational fear — the one that makes no logical sense?", .emotions),
            ("What's the best prank you've ever managed to pull off?", .dailyLife),
            ("What's a totally normal thing that makes you weirdly self-conscious?", .dailyLife),
            ("What's the most uncomfortable gathering you've ever had to sit through?", .dailyLife),
            ("What did you used to daydream about for hours as a kid?", .past),
            ("What's the last thing you saw or read that you definitely weren't supposed to?", .dailyLife),
            ("What's the most meaningful gift anyone has ever given you?", .appreciation),
            ("What makes you the proudest about your family?", .appreciation),
            ("What's a guilty pleasure you will always defend?", .dailyLife),
            ("What's a family recipe or tradition you never want to lose?", .values),
            ("What's the funniest thing that ever happened at a family gathering?", .dailyLife),
            ("What's something a family member taught you that you still use today?", .appreciation),
            ("What's a nickname from your childhood and how did you get it?", .past),
            ("What's a family trip or vacation you'll never forget?", .past),
            ("What did you get in trouble for the most as a kid?", .past),
            ("What's a song or movie that always reminds you of your family?", .appreciation),
            ("What's something your family is surprisingly competitive about?", .dailyLife),
            ("What's a family joke that an outsider would never understand?", .dailyLife),
            ("What's a skill you picked up from watching a family member?", .growth),
            ("What's the best piece of advice a family member ever gave you?", .values),
            ("What holiday tradition means the most to you and why?", .values),
            ("Who in your family always knows how to make you feel better?", .appreciation),
        ], mode: .family, intensity: .light, depth: .warmUp)
    }

    // MARK: - Family · Light · Real Talk

    static func family_light_realTalk() -> [Prompt] {
        make([
            ("What's a story about you that you'd love to see passed down in your family?", .values),
            ("What's one day in your life you know you'll never forget?", .past),
            ("How did you see the world when you were young, and when did that change?", .past),
            ("What's the kindest thing anyone has ever done for you?", .appreciation),
            ("What's something your family does that you didn't appreciate until you were older?", .appreciation),
        ], mode: .family, intensity: .light, depth: .realTalk)
    }

    // MARK: - Family · Light · Deep Dive

    static func family_light_deepDive() -> [Prompt] {
        make([
            ("How has your idea of what family means changed over the years?", .values),
            ("What do you hope the next generation picks up from how we are?", .values),
            ("What moment brought us closer than anything else?", .intimacy),
            ("What's your favorite thing about being part of this family?", .appreciation),
        ], mode: .family, intensity: .light, depth: .deepDive)
    }

    // MARK: - Family · Honest · Warm Up

    static func family_honest_warmUp() -> [Prompt] {
        make([
            ("What feelings come up for you around family gatherings?", .emotions),
            ("What's something you think this family avoids talking about?", .communication),
            ("What's something that's changed in this family that you're still adjusting to?", .emotions),
            ("What's a family expectation you've struggled to live up to?", .values),
            ("What's something you wish you had said to a family member sooner?", .communication),
            ("When did you first realize your family wasn't like everyone else's?", .past),
            ("What's a way your family shows love that took you a while to recognize?", .appreciation),
            ("What role do you play in your family and how do you feel about it?", .identity),
            ("What's something you've inherited from your parents — a habit or trait — that surprises you?", .identity),
            ("What's a family memory that still makes you emotional?", .emotions),
            ("What do you wish your parents had done differently?", .past),
            ("What's a sacrifice a family member made for you that you think about often?", .appreciation),
            ("What's something about your upbringing you didn't question until you were older?", .growth),
            ("How has your relationship with a family member changed over the years?", .growth),
            ("What's the most important thing your family taught you about trust?", .values),
            ("What's a misunderstanding in your family that was never properly cleared up?", .conflict),
            ("What do you think your family worries about most when it comes to you?", .emotions),
            ("What's a moment where your family really came together?", .appreciation),
            ("What's something about your family dynamic that outsiders wouldn't understand?", .communication),
            ("When did you feel the most supported by your family?", .appreciation),
            ("What's a conversation you keep having with family that never goes anywhere?", .conflict),
            ("What's something you appreciate about your family that you rarely say?", .appreciation),
            ("What's a lesson your family taught you through their mistakes?", .growth),
            ("What's a way you've tried to break a family pattern?", .growth),
            ("What emotion do you associate most with your childhood home?", .emotions),
            ("What's something you've forgiven a family member for that was really hard?", .conflict),
            ("What do you think your family's greatest strength is?", .appreciation),
            ("What's a story about your parents' early life that changed how you see them?", .past),
            ("What's something your family doesn't talk about but probably should?", .communication),
            ("When have you felt the proudest to be part of your family?", .appreciation),
        ], mode: .family, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Family · Honest · Real Talk

    static func family_honest_realTalk() -> [Prompt] {
        make([
            ("What's a conversation you know you need to have with your parents?", .communication),
            ("What's a decision someone else made that ended up changing the course of your life?", .past),
            ("Who really holds the power in your family, and how does that affect everyone?", .communication),
            ("What about being a parent — or the idea of it — genuinely worries you?", .emotions),
            ("What's something from your childhood that you later realized wasn't everyone's normal?", .past),
            ("What's something about your background you wish more people took the time to understand?", .values),
            ("What comes up for you when you see a photo of yourself as a kid?", .past),
            ("What's something you did that you refuse to apologize for?", .values),
        ], mode: .family, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Family · Honest · Deep Dive

    static func family_honest_deepDive() -> [Prompt] {
        make([
            ("What do you wish someone had told you when you were growing up?", .past),
            ("What's an experience that shaped who you are that almost nobody knows about?", .past),
            ("What did your parents teach you about love — whether they meant to or not?", .intimacy),
            ("Who taught you the most about what love actually looks like?", .intimacy),
            ("If you could change one thing about the way you were raised, what would it be?", .past),
            ("What would you go back and whisper to your younger self?", .past),
        ], mode: .family, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Family · Unfiltered · Warm Up

    static func family_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What role do you play in your family, and how did that happen?", .identity),
            ("What conversation are you dreading that you know needs to happen?", .conflict),
            ("What would change if everyone in this family said what they actually meant?", .communication),
            ("What's a family secret that shaped you more than anyone realizes?", .past),
            ("What's the biggest lie your family tells itself?", .communication),
            ("What's something about your childhood you've never fully processed?", .emotions),
            ("What's a wound from your family that still hasn't healed?", .emotions),
            ("When did you stop trying to earn a family member's approval?", .growth),
            ("What's something you resent about how responsibilities are divided in your family?", .conflict),
            ("What's a part of your family history that feels heavy to carry?", .past),
            ("What's something a family member did that you've never been able to fully forgive?", .conflict),
            ("What do you wish your parents really knew about your life right now?", .communication),
            ("What's a way your family made you feel small without realizing it?", .emotions),
            ("What's a toxic pattern in your family that you're trying not to repeat?", .growth),
            ("What's the hardest thing about loving someone in your family?", .emotions),
            ("What's a part of your identity that your family still doesn't fully accept?", .identity),
            ("What would your younger self think about your relationship with your family now?", .past),
            ("What's a boundary with family that you had to fight to set?", .conflict),
            ("What's something you've never confronted a family member about but probably should?", .communication),
            ("What's a way your family dealt with conflict that you've had to unlearn?", .conflict),
            ("What's the most painful thing a family member has ever said to you?", .emotions),
            ("When have you felt like the black sheep of your family?", .identity),
            ("What's something about your parents' relationship that affected how you see love?", .intimacy),
            ("What's an unfair expectation that was placed on you growing up?", .values),
            ("What's a truth about your family that nobody outside would believe?", .communication),
            ("What do you carry from your family that you wish you could put down?", .emotions),
            ("What's a sacrifice you made for your family that went unnoticed?", .appreciation),
            ("What's something you swore you'd never do as a parent that you catch yourself doing?", .growth),
            ("When did you first realize you were repeating a family pattern?", .growth),
            ("What's the thing your family is most in denial about?", .communication),
        ], mode: .family, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Family · Unfiltered · Real Talk

    static func family_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What subjects are the hardest to bring up in your family?", .communication),
            ("What's a topic that's completely off-limits in your family?", .communication),
            ("What's something you hope your kids — or future kids — never learn about you?", .past),
            ("What's a question you've always wanted to ask your parents but never have?", .communication),
        ], mode: .family, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Family · Unfiltered · Deep Dive

    static func family_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something that was taken from you — not necessarily a physical thing?", .past),
            ("Whose loss are you the most afraid of?", .emotions),
            ("Who are you most afraid of losing in your life?", .emotions),
            ("What trait of your parents are you most afraid of seeing in yourself?", .past),
            ("How has your experience with loss or death shaped the way you live?", .past),
            ("What's something you've never told your parents?", .communication),
            ("What's a conversation from your past you wish you could have one more time?", .communication),
        ], mode: .family, intensity: .unfiltered, depth: .deepDive)
    }

    // MARK: - Solo Reflection · Light · Warm Up

    static func solo_light_warmUp() -> [Prompt] {
        make([
            ("What do you spend too much time doing that you probably shouldn't?", .dailyLife),
            ("What are you feeling genuinely proud of right now?", .appreciation),
            ("What keeps showing up in your dreams lately?", .emotions),
            ("What have you been quietly getting better at without anyone noticing?", .appreciation),
            ("What do you do when you're completely alone and nobody can see?", .dailyLife),
            ("What do you catch yourself complaining about the most?", .dailyLife),
            ("What's something you used to know how to do but have completely lost?", .past),
            ("What's a small win you had recently that you didn't celebrate enough?", .appreciation),
            ("What's the last thing that genuinely surprised you about yourself?", .identity),
            ("What's a comfort food that always makes everything a little better?", .dailyLife),
            ("What's a place that always makes you feel calm?", .emotions),
            ("What's something you're looking forward to right now?", .dailyLife),
            ("What would you do with an entire day with zero obligations?", .dailyLife),
            ("What's something you've been meaning to get back into?", .growth),
            ("What's the best compliment you've ever received?", .appreciation),
            ("What's a simple pleasure that never gets old for you?", .dailyLife),
            ("What's something you're grateful for that you rarely think about?", .appreciation),
            ("What's a skill you picked up that changed your daily life?", .growth),
            ("What's your go-to way to recharge when you're running on empty?", .dailyLife),
            ("What's the last thing you learned that genuinely excited you?", .growth),
            ("What's a childhood memory that always makes you smile?", .past),
            ("What's something about your morning routine that sets the tone for your day?", .dailyLife),
            ("What's a personal rule you live by that most people don't know about?", .values),
            ("What's something you've gotten more patient about as you've gotten older?", .growth),
            ("What's a song that always puts you in a good mood?", .emotions),
            ("What's the last thing you did that felt truly spontaneous?", .dailyLife),
            ("What's a quality about yourself that you've come to appreciate?", .appreciation),
            ("What's something you collect — physically or mentally?", .identity),
            ("What's a place you've been that left a lasting impression on you?", .past),
            ("What's something you do purely for the joy of it, with no goal attached?", .dailyLife),
        ], mode: .soloReflection, intensity: .light, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Light · Real Talk

    static func solo_light_realTalk() -> [Prompt] {
        make([
            ("What do you hope people remember about you?", .values),
            ("When was the last time you felt completely and totally free?", .emotions),
            ("What's something you lost that you still think about?", .past),
            ("When was the last time you felt like everything was going your way?", .emotions),
            ("What's something you used to care deeply about that barely matters to you now?", .growth),
        ], mode: .soloReflection, intensity: .light, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Light · Deep Dive

    static func solo_light_deepDive() -> [Prompt] {
        make([
            ("What does a good life actually look like to you — not what anyone told you it should be?", .values),
            ("What's a belief that's shaped who you are more than anything?", .values),
            ("What's something you've built — a habit, a relationship, a mindset — that you're really proud of?", .growth),
            ("What's a part of your life that feels exactly right?", .appreciation),
        ], mode: .soloReflection, intensity: .light, depth: .deepDive)
    }

    // MARK: - Solo Reflection · Honest · Warm Up

    static func solo_honest_warmUp() -> [Prompt] {
        make([
            ("When you look in the mirror, what's the first thing that comes to mind?", .emotions),
            ("What's a bad habit you've tried to break but keep coming back to?", .growth),
            ("What do you waste the most mental energy worrying about?", .emotions),
            ("What do you find surprisingly hard to say yes to?", .communication),
            ("What's a part of your life that doesn't match who you thought you'd be by now?", .identity),
            ("What's something you keep putting off that's actually important to you?", .growth),
            ("What emotion do you have the hardest time sitting with?", .emotions),
            ("What's a standard you hold yourself to that might be too high?", .values),
            ("What's something you've been telling yourself that might not be true?", .growth),
            ("What's a relationship in your life that needs more attention?", .intimacy),
            ("What's something you're carrying that you haven't shared with anyone?", .emotions),
            ("What do you think people assume about you that's wrong?", .identity),
            ("What's a decision you made recently that you're still second-guessing?", .emotions),
            ("What's something you need to hear right now but nobody's saying?", .emotions),
            ("What's an area of your life where you've been coasting?", .growth),
            ("What's a fear that's been quietly influencing your choices?", .emotions),
            ("What would change in your life if you stopped people-pleasing?", .growth),
            ("What's something you used to be sure about that you're not sure about anymore?", .values),
            ("What do you think your biggest distraction in life is right now?", .dailyLife),
            ("What's a part of your personality you've been hiding lately?", .identity),
            ("What's a compliment you struggle to accept about yourself?", .identity),
            ("What's something you need to forgive yourself for?", .emotions),
            ("When was the last time you were truly honest with yourself about something uncomfortable?", .growth),
            ("What's a boundary you need to set but haven't?", .communication),
            ("What's the gap between how you present yourself and how you actually feel?", .identity),
            ("What motivates you more — fear of failure or desire for something better?", .values),
            ("What's something about your current life that your younger self would find confusing?", .past),
            ("What's a way you've grown in the last year that you haven't acknowledged?", .growth),
            ("What's something you keep avoiding because it would mean real change?", .growth),
            ("What would you do differently if you truly believed you deserved it?", .values),
        ], mode: .soloReflection, intensity: .honest, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Honest · Real Talk

    static func solo_honest_realTalk() -> [Prompt] {
        make([
            ("What's a blind spot you're slowly starting to see in yourself?", .growth),
            ("What's a decision you keep avoiding even though you know it matters?", .growth),
            ("How does it feel when you're the one holding the power in a situation?", .values),
            ("What's one thing about yourself you know you need to change?", .growth),
            ("What's something in your life that nobody truly understands your relationship with?", .identity),
            ("When are you most proud of having stood up for yourself?", .growth),
            ("What's something you've been holding onto way longer than you need to?", .past),
            ("When was the last time you bent the rules in a way that still sits with you?", .conflict),
            ("What kind of people make you feel the most envious, and why?", .emotions),
            ("What's something you finally feel clear about after a long stretch of confusion?", .growth),
            ("What's a boundary you've set recently that felt like real progress?", .growth),
        ], mode: .soloReflection, intensity: .honest, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Honest · Deep Dive

    static func solo_honest_deepDive() -> [Prompt] {
        make([
            ("What would you give anything to have a second chance at?", .past),
            ("What do you know you need to let go of but can't seem to release?", .growth),
            ("What's the gap between who you are and who you want to be — and what lives in that gap?", .growth),
        ], mode: .soloReflection, intensity: .honest, depth: .deepDive)
    }

    // MARK: - Solo Reflection · Unfiltered · Warm Up

    static func solo_unfiltered_warmUp() -> [Prompt] {
        make([
            ("What do you have a complicated relationship with that's hard to explain?", .emotions),
            ("When are you most tempted to break your own rules?", .values),
            ("What's a feeling you've been swallowing instead of expressing?", .emotions),
            ("What's the ugliest thought you've had about yourself recently?", .emotions),
            ("What's a part of your past you'd erase if you could?", .past),
            ("What's a way you self-sabotage that you're fully aware of?", .growth),
            ("What's a truth about your life that you dress up when you talk about it?", .identity),
            ("What's something you pretend to have figured out but really haven't?", .identity),
            ("What's a coping mechanism you rely on that isn't actually healthy?", .growth),
            ("What would people think if they could see your internal monologue?", .emotions),
            ("What's the most painful thing you've realized about yourself?", .growth),
            ("What's a desire you have that you feel ashamed of?", .emotions),
            ("What's a version of yourself you've buried that sometimes still surfaces?", .identity),
            ("What's the hardest thing about being you that nobody sees?", .emotions),
            ("What's a promise you've broken to yourself more than once?", .values),
            ("What's a relationship you stayed in too long and why?", .past),
            ("What's something you're afraid to want because you might not get it?", .emotions),
            ("What do you think your life would look like if you stopped performing for others?", .identity),
            ("What's a memory that still makes you feel shame when it surfaces?", .past),
            ("What's the most honest thing you could say about where you are in life right now?", .growth),
            ("What's something you need that you've convinced yourself you don't?", .emotions),
            ("What keeps you up at night that you've never told anyone?", .emotions),
            ("What's a pattern in your relationships that you can't seem to break?", .growth),
            ("What's the thing you're most afraid of other people finding out about you?", .identity),
            ("What's a feeling you've numbed yourself to that you know you need to face?", .emotions),
            ("What's a part of your story you've rewritten to make it easier to tell?", .past),
            ("When was the last time you felt completely disgusted with yourself?", .emotions),
            ("What's a sacrifice you made that nobody ever thanked you for?", .appreciation),
            ("What would you confess if there were truly no consequences?", .values),
            ("What's a wound you keep reopening because you haven't fully dealt with it?", .emotions),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .warmUp)
    }

    // MARK: - Solo Reflection · Unfiltered · Real Talk

    static func solo_unfiltered_realTalk() -> [Prompt] {
        make([
            ("What's something you wish you'd never had to see?", .past),
            ("When was the last time you felt like a total fraud?", .identity),
            ("How would you honestly describe your relationship with your body?", .identity),
            ("When did you last seriously doubt yourself, and what triggered it?", .growth),
            ("What have you been faking lately that you wish you could just stop?", .growth),
            ("What's a lie you told once that you still think about?", .conflict),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .realTalk)
    }

    // MARK: - Solo Reflection · Unfiltered · Deep Dive

    static func solo_unfiltered_deepDive() -> [Prompt] {
        make([
            ("What's something you've been putting off being honest with yourself about?", .identity),
            ("Is there a relationship in your life that you know has run its course?", .conflict),
            ("What's a part of yourself that you know you need to outgrow?", .growth),
            ("What's something you still carry guilt about?", .emotions),
            ("What's a belief you hold deeply but have never actually said out loud?", .values),
            ("What's something that hurt you that you never talked to anyone about?", .emotions),
            ("If you could erase one memory completely, which would you choose?", .past),
            ("What's the worst thing you've done to someone that still weighs on you?", .conflict),
            ("When have you felt the most humiliated in your life?", .emotions),
            ("If you got to choose how your life story ends, what would it look like?", .values),
            ("How did being treated badly by someone shape the way you see yourself?", .past),
            ("What's something that happened that permanently changed who you are?", .past),
            ("When was a time you felt rejected that really stung?", .emotions),
            ("What's something you wish you could finally get closure on?", .emotions),
            ("What principle would you never compromise on, no matter what?", .values),
        ], mode: .soloReflection, intensity: .unfiltered, depth: .deepDive)
    }
}
