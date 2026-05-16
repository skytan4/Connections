# Swedish Localization Brief

**Locale code:** `sv`  
**Status:** In progress — Big Five batch  
**Last updated:** 2026-05-14

---

## Agent Non-Negotiables

Copy these into every Swedish translation or audit-agent prompt:

- Use informal **du** throughout; do not use `ni` as formal singular.
- Use Swedish restraint: warm and direct, but not theatrical, over-emotional, or therapy-like.
- Do not assume gender: avoid `han/hon`, `honom/henne`, `hans/hennes` for unknown people; use `hen`, `personen`, or restructure.
- Use `din partner`, `den andra personen`, `ni två`, `er relation`, or omission for partner/person references.
- Check word order and compounds; avoid English calques and stiff literal structures.
- Keep sex/intimacy adult and natural, not clinical or vulgar.
- Preserve strict source fidelity for follow-ups; translate the exact attached follow-up.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- **Warm, natural, emotionally intelligent Swedish.** Write as a thoughtful friend would speak.
- **Informal `du` throughout.** Never use `ni` as a formal second-person singular. `ni` is used only as a genuine second-person plural (addressing multiple people).
- **Swedish directness.** Swedish tends to be understated, clear, and direct — not theatrical, not over-warm. The tone should feel natural to a Swedish speaker, not translated from English.
- **Avoid English calques.** Swedish has its own idioms for emotional and relational concepts — use them.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Swedish must too, and must remain an unfinished fragment — not a full question.

---

## Gender Policy — Neutral-First (Hard Rule)

Swedish has excellent neutral options. Modern Swedish has accepted `hen` as a gender-neutral singular pronoun, alongside restructuring with `du`, `man`, and noun-based constructions.

**Hard rule:** Do not assume the user's or partner's gender.

| Banned form | Why | Use instead |
|---|---|---|
| `han` / `hon` | Gendered third-person pronouns | `hen`, `personen`, omit |
| `honom` / `henne` | Gendered object pronouns | `hen` (obj), `personen`, restructure |
| `hans` / `hennes` | Gendered possessives | `hens`, `personens`, restructure |
| `ni` (formal singular) | Formal address | `du` |

**Preferred gender-neutral constructions:**

| Context | Preferred Swedish |
|---|---|
| Referring to the partner | `din partner`, `den andra personen`, `den andre` |
| Referring to both people | `ni`, `ni två`, `er relation`, `tillsammans` |
| Unknown-gender third person | `hen`, `den personen`, omit pronoun |
| Possessive for partner | `din partners`, `den andres` |

---

## Tone by Content Type

### Light
- Accessible, warm, easy-going.
- Everyday Swedish register — the kind you'd use talking with a close friend.
- Avoid making light prompts feel like an interview or quiz.

### Honest
- Emotionally sincere and clear.
- Swedish directness — not blunt, not over-hedged.
- Do not soften honest prompts until they lose their genuine question.

### Unfiltered
- Direct emotional truth.
- Swedish understatement is an asset here: a plain, direct question can be more powerful than a dramatic one.
- Do not soften the edge, but do not amplify it theatrically either.

### Warm Up
- A real on-ramp — easy to answer, genuinely meaningful.
- Should feel like the start of something.

### Real Talk
- A genuine step up from Warm Up.
- Should feel worth engaging with.

### Deep Dive
- Serious, searching, spacious.
- Leave room for difficulty or silence.
- Do not over-explain or add a preamble.

### Sex / Intimacy
- Direct and adult. Not clinical, not crude.
- Swedish has a comfortable adult register for intimacy — stay in it.
- Avoid clinical medical terms for sexual topics.
- Avoid vulgar (obscene) phrasing.
- Completion prompts (ending in `…`) must remain fragments.

### Hardship / Grief / Regret
- Gentle, respectful, and spacious.
- Swedish emotional register tends toward restraint — do not add sentimentality that isn't in the original.
- Leave room to sit with difficulty.

### Family / Intergenerational
- Warm and grounded.
- Swedish family language is direct and familiar — use it naturally.

### Friends
- Warm and casual. Playful where the English is playful; earnest where earnest.

### Life Story
- Addressing older adults reflecting on a full life.
- Dignified, unhurried, respectful.
- Hardship and legacy chapters deserve particular care.

---

## Sentence-Completion Prompts

**Hard rule:** Preserve the fragment shape. Do not turn a fragment into a full question.

| English | Good Swedish shape | Avoid |
|---|---|---|
| I feel most loved when… | `Jag känner mig mest älskad när…` | `När känner du dig mest älskad?` |
| A fantasy I have mixed feelings about is… | `En fantasi jag har blandade känslor för är…` | Converting to a direct question |

---

## Brand Terms — Keep in English

| Term | Policy |
|---|---|
| Deeper Conversations | English only (`shouldTranslate: false` in xcstrings) |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

---

## UI Label Guidance

- Swedish strings are typically similar in length to English or slightly shorter.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, etc.
- Reorder placeholder positions only if Swedish grammar requires it.
- All labels use `du`/`dig`/`ditt`, never formal `ni`/`er`.

---

## Swedish-Specific Risks

### `Ni` Formal Register
Using `ni` as a polite singular is old-fashioned and sounds stiff. Modern Swedish always uses `du`. Coordinator must grep for `\bNi\b` and `\bEr\b` used as formal singular.

### `Han`/`Hon` Defaults
Agents sometimes default to `han`/`hon` when referring to the partner. Check all partner references.

### English Loanwords
Swedish has absorbed many English words, but agents sometimes over-use them where natural Swedish exists.
- Watch for: `supporta` (should be `stödja`), `connecta` (should be `koppla`/`knyta an`).

### Compound Words
Swedish forms compound nouns. Agents sometimes write them as separate words.
- Example: `kärleksrelation` not `kärleks relation`; `vardagsliv` not `vardags liv`

### Understatement Register
Swedish emotional register is understated. Watch for translations that amplify or dramatize beyond the English source. "Difficult" should not become "oerhört svårt" unless the English says "incredibly hard."

---

## Glossary

| English term | Swedish | Notes |
|---|---|---|
| prompt / question | fråga | Natural for a conversation prompt. |
| session | session | Direct equivalent. |
| Go Deeper | Gå djupare | Button/CTA. |
| Unfiltered | Ofiltrerat | Clean, modern. |
| Honest | Ärligt | Or `Uppriktigt`. In UI: `Ärligt`. |
| Light | Lätt | Clean and natural. |
| Warm Up | Uppvärmning | Or `Kom igång`. |
| Real Talk | Ärligt samtal | Or `På riktigt`. |
| Deep Dive | Djupdykning | Natural compound. |
| partner | din partner | Gender-neutral in context. |
| the other person | den andre / den andra personen | Context-dependent. |
| between you (two) | er emellan / er relation | Natural for couples context. |
| connection / bond | kontakt / band | `band` is warmer; `kontakt` more neutral. |
| closeness | närhet | Direct equivalent. |
| intimacy | intimitet | For emotional/relational intimacy. |
| to feel seen | känna sig sedd | Natural and direct. |
| to feel appreciated | känna sig uppskattad | Or `känna sig värdesatt`. |
| vulnerability | sårbarhet | Direct equivalent. |
| appreciation | uppskattning | Use `tacksamhet` only when English means gratitude. |
| values | värderingar | Direct equivalent. |
| growth | utveckling / tillväxt | `utveckling` = personal development. |
| conflict | konflikt | Direct equivalent. |
| letting go | att släppa taget | Natural Swedish phrase. |
| grief | sorg | Direct equivalent. |
| regret | ånger / bitterhet | `ånger` = remorse; context-dependent. |
| to feel safe | känna sig trygg | Natural and direct. |
| desire | längtan / begär | `längtan` = longing; `begär` = desire. |
| Life Story | Life Story | **English only — brand term.** |
| Fall in Love | Fall in Love | **English only — brand term.** |
| Share an Experience | Share an Experience | **English only — brand term.** |

---

## Coordinator Checklist

1. **`ni`/`er` scan (formal singular)** — flag formal second-person singular; replace with `du`/`dig`
2. **`han`/`hon` partner scan** — flag gendered pronouns for the partner; replace with `hen`/`den andre`/`din partner`
3. **`hans`/`hennes` scan** — flag gendered possessives; replace with `hens`/`din partners`
4. **Compound word check** — verify Swedish compounds are written as single words
5. **Ellipsis scan** — every English prompt ending in `…` must still end in `…` in Swedish and remain a fragment
6. **Understatement check** — spot-check that translations don't amplify or dramatize beyond the source
7. **English leftovers** — no translated text still reads as English except brand terms
8. **Brand term scan** — Deeper Conversations, Life Story, Fall in Love, Share an Experience remain in English
9. **Follow-up fidelity** — each follow-up translates the exact matching English follow-up
10. **ID fidelity** — every patch key matches a real prompt ID

---

## Decisions on Record

| Decision | Choice | Rationale |
|---|---|---|
| Register | Informal `du` throughout | Modern Swedish always uses `du` in conversation |
| Gender policy | Neutral-first; `hen` + restructuring | Swedish has excellent neutral options |
| Partner term | `din partner` (primary), `den andre`, `den andra personen` | Common, gender-neutral, informal |
| Formal `ni` | Never (as singular) | Archaic; sounds stiff and distant |
| Brand terms | All English | Feature names; translating adds scope without user benefit |
| Emotional register | Understated, restrained | Matches Swedish natural register; avoid amplification |
