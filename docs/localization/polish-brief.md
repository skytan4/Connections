# Polish Localization Brief

## Purpose

This document defines the translation standards, policies, and glossary for the Polish (`pl`) localization of Deeper Conversations. All translators and translation agents must read this brief before producing any Polish content.

---

## Agent Non-Negotiables

Copy these into every Polish translation or audit-agent prompt:

- Use warm informal **ty** throughout; never use `Pan`, `Pani`, or formal address.
- Gender policy is Option B: neutral constructions preferred, masculine fallback only where truly unavoidable.
- No slash notation or awkward gender-pair notation. Restructure instead.
- Prefer `chcesz`, `możesz`, `masz`, infinitives, noun phrases, and impersonal frames like `gdyby dało się...`.
- Use `partner/partnerka` only when context requires; otherwise prefer neutral/restructured phrasing.
- Watch Polish verb aspect: imperfective for ongoing reflection/habits, perfective for completed events.
- Keep sex/intimacy adult and natural, not clinical or crude.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- **Warm, natural, emotionally intelligent Polish.** Write as a thoughtful friend would speak, not as a form or instruction manual.
- **Informal singular `ty` throughout.** Never use `Pan/Pani` or any formal register.
- **Avoid bureaucratic or literal English phrasing.** Polish has its own idioms for emotional and relational concepts — use them.
- **Direct but not harsh.** Honest questions should feel inviting, not interrogative.
- **Tender but not sentimental.** Emotional warmth is appropriate; overwrought or flowery language is not.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Polish must too.

---

## Gender Policy — Option B

Polish verb and adjective forms change by grammatical gender. This is a real challenge for prompts that address the user directly.

**Policy:**

1. **Prefer gender-neutral constructions first.** Infinitives, noun phrases, and second-person present-tense verb forms are often naturally gender-neutral in Polish and should be used wherever they sound natural.
   - Example: `"Czy zdarzyło ci się…"` (Has it happened to you…) is gender-neutral.
   - Example: `"Co czujesz, gdy…"` (What do you feel when…) is gender-neutral.

2. **Avoid slash notation** (`zmęczony/a`, `gotowy/a`). It is grammatically awkward and visually cluttered in running text.

3. **Use masculine fallback only where a neutral construction is not practical.** This applies primarily to past-tense verb phrases and certain adjective predicates where gender is grammatically required and no natural workaround exists.
   - Example: `"Byłeś kiedyś…"` (Have you ever been… [masc.]) is acceptable as fallback.

4. **Flag for human review** any prompt where gender awkwardness remains after best effort. Add a comment in the review Markdown noting the specific gender issue.

> **Important note on scope:** Gender policy applies almost entirely to `prompts_pl.json`, where verbs directly address the user. UI strings in `Localizable.xcstrings` (button labels, section headers, titles) are almost always noun phrases or infinitives and are naturally gender-neutral — no special handling needed there.

---

## Sensitive Content Guidance

### Couples / Intimacy
- Tender, adult, and emotionally safe.
- Not clinical (avoid medical vocabulary for emotional closeness).
- Not crude (avoid vulgar expressions).
- Use warm relational language: *bliskość*, *czułość*, *intymność*.

### Sex / Unfiltered
- Direct but not vulgar.
- Polish has a range of registers for sexuality — stay in the emotionally honest, adult register.
- Avoid clinical terms (*stosunek płciowy*) and slang. Prefer natural adult language.

### Hardship / Grief / Regret
- Gentle, respectful, and spacious.
- Leave room for the user to sit with difficulty without feeling pressed.
- Avoid minimizing language (*to nic wielkiego*, *każdemu się zdarza*).

### Family / Intergenerational
- Respectful and grounded.
- Polish family language carries strong cultural weight — use it with care.
- Appropriate warmth for parents, grandparents, siblings; avoid flattening into generic "family."

### Friends
- Warm and casual, not romance-coded unless the prompt intentionally addresses romantic friendship.
- Playful where the English is playful. Earnest where the English is earnest.

---

## Brand Terms — Keep in English

The following are product feature names and must remain in English in all Polish strings:

| Term | Policy |
|---|---|
| Deeper Conversations | English only (`shouldTranslate: false` in xcstrings) |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

---

## Polish-Specific Risks

### Plural Forms
Polish has four plural forms (1 / 2–4 / 5+ / genitive plural). Any UI string that includes a count (e.g., `%lld sessions`) requires plural rules. Before finalizing `Localizable.xcstrings` translations, verify no keys use `%lld` or `%d` format specifiers with count semantics. If found, they require `.stringsdict`-style plural handling.

### Verb Aspect
Polish verbs carry perfective/imperfective aspect.
- Use **imperfective** for ongoing states, habits, and reflection prompts (`mówisz`, `czujesz`, `myślisz`).
- Use **perfective** only when describing a specific completed event (`powiedziałeś`, `zdecydowałeś`).
- When in doubt, imperfective is safer and more open-ended, which suits conversational prompts.

### Word Length
Polish words and phrases run approximately 20–40% longer than their English equivalents. After the first build with Polish active, do a visual pass on all fixed-width UI components (buttons, tab labels, segment controls) for truncation.

---

## Glossary

Preferred Polish translations for recurring terms. All agents must use these consistently.

| English term | Polish | Notes |
|---|---|---|
| prompt | pytanie | "Question" — most natural for a conversation prompt. Avoid *monit* (technical). |
| session | sesja | Direct equivalent. Widely understood in app contexts. |
| Go Deeper | Zagłęb się | Idiomatic. Prefer over literal *Idź głębiej*. |
| Unfiltered | Bez filtrów | "Without filters" — modern, clean. |
| Honest | Szczery | Adjective. In prose: *szczerze* (adverb). |
| Light | Lekki / Lekko | Adjective (*lekki*) for labels, adverb (*lekko*) in flowing text. |
| Warm Up | Rozgrzewka | Standard Polish term for warm-up. Natural in this context. |
| Real Talk | Szczera rozmowa | "Honest conversation." More natural than a literal translation. |
| Deep Dive | W głąb | "Into the depths." Evocative and natural. |
| partner | partner / partnerka | Modern and neutral. Use *partner* when gender is unknown; *partnerka* when referring to a female partner. Do not use *ukochany/a* (too romantic) or *chłopak/dziewczyna* (too casual). |
| intimacy | intymność | Direct equivalent. |
| values | wartości | Direct equivalent. |
| growth | rozwój | Personal development/growth. |
| conflict | konflikt | Direct equivalent. |
| appreciation | docenienie | Valuing / appreciating someone or something. Use *wdzięczność* (gratitude) only when the English specifically means gratitude rather than appreciation. |
| communication | komunikacja | Direct equivalent. |
| vulnerability | wrażliwość | Emotional openness/sensitivity. More natural in Polish emotional contexts than *podatność na zranienie* (literal). |
| connection | więź | Relational bond. More emotionally resonant than *połączenie* (link/connection in a technical sense). |
| closeness | bliskość | Direct equivalent. |
| Life Story | Life Story | **English only — brand term.** |
| Fall in Love | Fall in Love | **English only — brand term.** |
| Share an Experience | Share an Experience | **English only — brand term.** |

---

## Decisions Still Open

None — all policy decisions above are settled. The table below documents the key choices and their rationale for the record.

| Decision | Choice | Rationale |
|---|---|---|
| Gender policy | Option B (neutral-first, masculine fallback) | Slash notation is unnatural in Polish running text |
| `partner` term | partner / partnerka | Modern, neutral, appropriate for couples app |
| Brand terms | All English | Feature names; translating adds scope without user benefit |
| Verb aspect default | Imperfective | More open-ended; suits reflective prompts |
