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

    /// Returns topics that have at least one prompt for the given mode and intensity.
    func availableTopics(for mode: Mode, intensity: Intensity) -> [Topic] {
        let present = Set(prompts.filter { $0.mode == mode && $0.intensity == intensity }.map(\.topic))
        return Topic.allCases.filter { present.contains($0) }
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

    // MARK: - Couples · Light · Warm Up

    static func couples_light_warmUp() -> [Prompt] {
        make([
            ("If you could know one thing about your future, what would you want to find out?", .dailyLife),
            ("What's something you're unreasonably stubborn about?", .identity),
            ("What's something you know you're completely irrational about?", .identity),
            ("What's a tiny personal preference you feel surprisingly passionate about?", .dailyLife),
            ("What do you spend way too much money on without any regret?", .dailyLife),
            ("What do you know you make a bigger deal about than you should?", .communication),
            ("What would you love to be able to spend more freely on?", .dailyLife),
            ("Are you more of a host or a guest — and what does that say about you?", .dailyLife),
            ("If you were stuck at home for months, what three things would you absolutely need?", .dailyLife),
            ("What's your go-to midnight snack raid?", .dailyLife),
            ("Who or what have you been quietly fascinated by lately?", .intimacy),
            ("What's the most disastrous date you've ever been on?", .dailyLife),
            ("What's your favorite real love story — yours or someone else's?", .intimacy),
            ("What do you need most from me when you're not feeling well?", .communication),
            ("What are you surprisingly high-maintenance about?", .dailyLife),
            ("What are you a complete control freak about?", .identity),
            ("What's the one thing you absolutely cannot be teased about?", .communication),
            ("What's basically impossible for you to say no to?", .communication),
            ("What's something about your partner that you fell in love with all over again recently?", .appreciation),
            ("I feel most sensual when…", .sex),
            ("I feel most attractive when…", .sex),
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
