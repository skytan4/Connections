# Dutch Localization Brief

**Locale code:** `nl`  
**Status:** All banks complete (prompts 598/598, fall_in_love 36/36, share_experience 21/21, life_story 50/50). xcstrings UI strings pending.  
**Last updated:** 2026-05-14

---

## Agent Non-Negotiables

Copy these into every Dutch translation or audit-agent prompt:

- Use informal **je/jij** throughout; never use formal `u` or `uw`.
- Do not use gendered unknown-person pronouns: avoid `hij/zij`, `hem/haar`, `hem of haar`, `zijn of haar`; prefer `ze`, `diegene`, `de persoon`, or restructure.
- Use `je partner`, `de ander`, `diegene`, or omission for partner/person references.
- Check compounds carefully; plausible compounds may be unnatural or wrong.
- Watch `er...aan` forms such as `ertoe`, `ervan`, `ermee`; particle splitting errors are common.
- Watch neuter nouns: `het/dat/dit gevoel`, `gemis`, `verlies`, `moment`.
- Preserve involuntary meaning with `hoeven` where English says “had to / never had to,” not `willen`.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- **Warm, natural, emotionally intelligent Dutch.** Write as a thoughtful friend would speak, not as a form or instruction manual.
- **Informal `je`/`jij` throughout.** Never use `u`/`uw` in any prompt, follow-up, or UI string.
- **Avoid bureaucratic or overly literal phrasing.** Dutch has its own idioms for emotional and relational concepts — use them.
- **Direct but not harsh.** Honest questions should feel inviting, not interrogative.
- **Tender but not sentimental.** Emotional warmth is appropriate; flowery language is not.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Dutch must too, and must remain an unfinished fragment — not a full question.

---

## Gender Policy — Neutral-First (Hard Rule)

Dutch prompts must address the user and their partner without assuming any gender. This is enforced throughout all prompt, follow-up, and UI text.

**Hard rule:** Do not use any gendered pronouns when referring to the user or the user's partner.

| Banned form | Why | Use instead |
|---|---|---|
| `hij` / `zij` | Gendered third-person pronouns | `ze` (plural neutral), `diegene`, `de persoon`, omit |
| `hem` / `haar` | Gendered object pronouns | `ze`, `hen`, restructure to avoid |
| `hem of haar` | Explicit binary | `ze`, `diegene` |
| `zijn of haar` | Explicit binary possessive | `hun`, `diens`, restructure |
| `u` / `uw` | Formal register | `je` / `jouw` |

**Preferred gender-neutral constructions:**

| Context | Preferred Dutch |
|---|---|
| Referring to the partner | `je partner`, `de ander`, `diegene`, `de persoon naast je` |
| Referring to both people | `jullie`, `jullie samen`, `jullie relatie` |
| Unknown-gender third person | `ze` (plural used as singular neutral), `diegene`, drop the pronoun |
| Possessive for partner | `van je partner`, `van diegene`, `hun` |

---

## Tone by Content Type

### Light
- Accessible, warm, easy-going.
- Not childish or trivial.
- Conversational Dutch, everyday register.
- Avoid making light prompts sound like a quiz or interview.

### Honest
- Emotionally sincere and clear.
- Gentle directness — not blunt, not over-hedged.
- Do not soften honest prompts to the point that they lose their genuine question.

### Unfiltered
- Direct emotional truth.
- Not crude, not accusatory, not aggressive.
- Do not make unfiltered prompts shocking; but do not soften away their edge either.

### Warm Up
- A real on-ramp — easy to answer, still meaningful.
- Should feel like the start of something, not like filler.

### Real Talk
- A genuine step up from Warm Up — requires some reflection.
- Should feel worth showing up for, not just a slightly harder version of Light.

### Deep Dive
- Serious, searching, spacious questions.
- Leave room for silence or difficulty.
- Do not over-explain or frame the question with a preamble.

### Sex / Intimacy
- Direct and adult. Not clinical, not crude, not coy.
- Dutch has a comfortable adult register for intimacy — stay in it.
- Avoid clinical medical terms for sexual topics.
- Avoid vulgar or coarse phrasing.
- Completion prompts (ending in `…`) must remain fragments.

### Hardship / Grief / Regret
- Gentle, respectful, and spacious.
- Leave room for the user to sit with difficulty without feeling pressed.
- Avoid minimizing language (`het overkomt iedereen`, `dat is normaal`).

### Family / Intergenerational
- Warm and grounded.
- Dutch family language is direct and familiar — use it naturally.
- Do not flatten family relationships into generic "family."

### Friends
- Warm and casual, not romance-coded unless the prompt explicitly addresses that.
- Playful where the English is playful; earnest where the English is earnest.

### Life Story
- Intergenerational tone — addressing older adults reflecting on a full life.
- Dignified, unhurried, respectful.
- Follow-ups should invite depth, not push for answers.
- Hardship and legacy chapters deserve particular care — spacious, not sentimental.

---

## Sentence-Completion Prompts

Many prompts are intentionally fragments, such as "I feel most loved when…"

**Hard rule:** Preserve the fragment shape. Do not turn a fragment into a full question.

| English | Good Dutch shape | Avoid |
|---|---|---|
| I feel most sensual when… | `Ik voel me het meest sensueel als…` | `Wanneer voel je je het meest sensueel?` |
| Sex feels most meaningful to me when… | `Seks voelt voor mij het meest betekenisvol als…` | Converting to a direct question |
| A fantasy I have mixed feelings about is… | `Een fantasie waar ik gemengde gevoelens over heb is…` | Adding explanation or judgment |

---

## Brand Terms — Keep in English

The following product feature names must remain in English in all Dutch strings:

| Term | Policy |
|---|---|
| Deeper Conversations | English only (`shouldTranslate: false` in xcstrings) |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

---

## UI Label Guidance

- Dutch compound words can be long. Monitor button labels, tab titles, and segment controls for truncation after translation.
- Common Dutch UI labels run 15–30% longer than their English equivalents.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, etc.
- Reorder placeholder positions only if Dutch grammar requires it — do not drop or duplicate them.
- All labels use `je`/`jij`, never `u`/`uw`.
- Keep UI labels clear and direct; avoid conversational filler words that inflate label length.

---

## Dutch-Specific Risks

### Compound Word Accuracy
Dutch creates compound nouns by joining words. Agents sometimes produce malformed or non-standard compounds.
- Confirmed correction example: `familieopkomsten` → `familiebijeenkomsten` (family gatherings)
- When in doubt, split the compound or check a standard dictionary. A believable-sounding compound is not always a real one.

### Formal Register Creep
`u`/`uw` violations are the most common agent error. Coordinator must grep for `\bu\b` and `\buw\b` in every batch before applying.

### `er...aan`/`er...van`/`er...bij` Particle Splitting
Dutch verbs with pronominal adverbs (`ertoe`, `ervan`, `ermee`, `erbij`) must be written as one word when the pronoun is stranded.
- Confirmed correction: `er toe deed` → `ertoe deed`

### Wrong Article with Neuter Nouns
Dutch neuter nouns take `het`/`dat`/`dit`, not `de`/`die`/`deze`.
- Confirmed correction: `die gemis` → `dat gemis` (`het gemis`)
- Common neuter nouns in prompt context: `het verlies`, `het gemis`, `het gevoel`, `het leven`, `het moment`

### Involuntary vs Voluntary Aspect
Dutch `hoeven` + te-infinitive expresses "did not need to / should not have had to" (involuntary). `Willen` expresses willingness.
- Confirmed correction: `Wat had je nooit willen zien?` (voluntary) → `Wat had je nooit hoeven zien?` (involuntary — captures "things you were forced to witness")

### Semantic Inversion in Negatives
Agents sometimes invert the meaning of a prompt when restructuring a negative.
- Confirmed correction: `"Waar ben je al een tijdje mee bezig om eerlijk naar jezelf te zijn?"` (actively working on honesty) → `"Wat stel je al een tijdje uit om eerlijk over te zijn naar jezelf?"` (putting off being honest) — these are opposite meanings.

---

## Glossary

Preferred Dutch translations for recurring terms. All agents must use these consistently.

| English term | Dutch | Notes |
|---|---|---|
| prompt / question | vraag | Natural for a conversation prompt. Avoid `aanwijzing` (hint/cue). |
| session | sessie | Direct equivalent. |
| Go Deeper | Ga dieper | Button/CTA. |
| Unfiltered | Ongefilterd | Clean, modern. |
| Honest | Eerlijk | Adjective. In flowing text: `eerlijk` or `oprecht`. |
| Light | Licht | Clean and natural. |
| Warm Up | Warming-up | Borrowed English term, widely understood in Dutch. |
| Real Talk | Echt gesprek | Or `Eerlijk gesprek`. Avoid literal "Real Talk." |
| Deep Dive | Diepteduik | Natural compound. |
| partner | je partner | Gender-neutral in context. Always informal. |
| the other person | de ander | Preferred over `de andere persoon`. |
| that person / they | diegene | Gender-neutral singular. |
| between you (two) | tussen jullie | Natural for couples context. |
| connection / bond | verbinding / band | `band` is warmer; `verbinding` is more neutral. Context-dependent. |
| closeness | nabijheid | Direct equivalent. |
| intimacy | intimiteit | For emotional/relational intimacy. |
| to feel seen | je gezien voelen | Natural and direct. |
| to feel appreciated | je gewaardeerd voelen | Or `je erkend voelen` depending on context. |
| vulnerability | kwetsbaarheid | Direct equivalent. |
| appreciation | waardering | For valuing someone/something. Use `dankbaarheid` only when English specifically means gratitude. |
| values | waarden | Direct equivalent. |
| growth | groei | Personal development. |
| conflict | conflict | Direct equivalent. |
| communication | communicatie | Direct equivalent. |
| letting go | loslaten | Natural Dutch phrase for releasing. |
| grief | verdriet / rouw | `verdriet` = sadness/grief; `rouw` = mourning/bereavement. Context-dependent. |
| regret | spijt | Direct and natural. |
| hardship | tegenspoed / moeilijke periode | Context-dependent. |
| to feel safe | je veilig voelen | Natural and direct. |
| desire | verlangen / begeerte | `verlangen` = longing; `begeerte` = desire/craving. Context-dependent. |
| Life Story | Life Story | **English only — brand term.** |
| Fall in Love | Fall in Love | **English only — brand term.** |
| Share an Experience | Share an Experience | **English only — brand term.** |

---

## Coordinator Checklist

Before applying any Dutch translation batch, run these checks:

1. **`u`/`uw` scan** — grep for `\bu\b` and `\buw\b`; flag any formal register violations
2. **`hij`/`zij` scan** — flag gendered third-person pronouns referring to the user or partner
3. **`hem`/`haar` scan** — flag gendered object pronouns; replace with `ze`/`hen` or restructure
4. **`zijn of haar`/`hem of haar` scan** — flag explicit binary constructions
5. **Compound word check** — verify Dutch compound nouns are real words, not agent inventions
6. **Particle joining check** — verify `er...toe`, `er...van`, `er...mee`, etc. are written as single words when stranded (`ertoe`, `ervan`, `ermee`)
7. **Article/gender check** — verify neuter nouns use `het`/`dat`/`dit`, not `de`/`die`/`deze`
8. **Ellipsis scan** — every English prompt ending in `…` must still end in `…` in Dutch and remain a fragment
9. **Semantic scan** — spot-check negatives and restructured prompts; involuntary/voluntary aspect must be preserved
10. **English leftovers** — no translated text still reads as English except approved brand terms
11. **Brand term scan** — Deeper Conversations, Life Story, Fall in Love, Share an Experience remain in English
12. **Follow-up fidelity** — each follow-up translates the exact matching English follow-up attached to the same ID; no invented or swapped follow-ups
13. **ID fidelity** — every patch key matches a real prompt ID in the source bank

---

## Decisions on Record

| Decision | Choice | Rationale |
|---|---|---|
| Register | Informal `je`/`jij` throughout | Dutch informal register is natural for conversation prompts |
| Gender policy | Neutral-first; no fallback to gendered pronouns | No masculine fallback needed — Dutch has viable neutral constructions |
| Partner term | `je partner` (primary), `de ander`, `diegene` | Common, gender-neutral, naturally informal |
| Formal `u` | Never | Hard rule; `u` sounds distant and formal in this context |
| Brand terms | All English | Feature names; translating adds scope without user benefit |
| Compound words | Standard Dutch dictionary forms | Agents produce plausible-sounding non-words; verify before applying |
