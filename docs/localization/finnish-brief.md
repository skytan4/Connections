# Finnish Localization Brief

**Locale code:** `fi`  
**Status:** Complete  
**Last updated:** 2026-05-14

---

## Register

- **Warm, natural, emotionally intelligent Finnish.** Write as a thoughtful friend would speak.
- **Pro-drop language.** Finnish naturally omits subject pronouns (`minä`, `sinä`). Use verb conjugations to carry person — do not force explicit pronouns unless emphasis requires them.
- **Informal second person.** Use second-person singular verb forms throughout. Never use formal `Te` (capital T) as a formal address form.
- **Finnish directness.** Plain, warm, and understated. Avoid theatrical or melodramatic phrasing.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Finnish must too, and must remain an unfinished fragment.

---

## Gender Policy — Naturally Neutral

Finnish has no grammatical gender. The third-person pronoun `hän` is gender-neutral. Use naturally — no workarounds needed.

| Context | Preferred Finnish |
|---|---|
| Referring to the partner | `kumppanisi`, `toinen osapuoli` |
| Referring to both people | `te`, `te kaksi`, `teillä` |
| Unknown-gender third person | `hän` (naturally gender-neutral) |

---

## Tone by Content Type

### Light / Honest / Unfiltered
- Same escalation pattern. Finnish understatement: plain and direct.

### Sex / Intimacy
- Direct and adult. Not clinical, not crude.
- Completion prompts ending in `…` must remain fragments.

### Hardship / Grief / Regret
- Gentle, respectful, spacious. Finnish restraint.

### Family / Friends / Life Story
- Warm and natural. Life Story = dignified, unhurried.

---

## Sentence-Completion Prompts

**Hard rule:** English `…` → Finnish `…`, remain a fragment.

---

## Brand Terms — Keep in English

| Term | Policy |
|---|---|
| Deeper Conversations | English only |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

---

## UI Label Guidance

- Finnish strings tend to be longer than English due to agglutinative suffixes — leave room for text expansion.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, etc.

---

## Glossary

| English term | Finnish | Notes |
|---|---|---|
| partner | kumppanisi | Possessive form |
| the other person | toinen osapuoli | Or `toinen` |
| between you (two) | teidän välillä | Natural for couples |
| connection / bond | yhteys / side | Context-dependent |
| closeness | läheisyys | Direct equivalent |
| intimacy | läheisyys / intiimiys | For emotional/relational |
| to feel seen | tuntea itsensä nähdyksi | Natural |
| vulnerability | haavoittuvuus | Direct equivalent |
| letting go | päästäminen irti | Or `irrottautuminen` |
| grief | suru | Direct equivalent |
| desire | halu / kaipaus | Context-dependent |
| Light | Kevyt | Clean and natural |
| Honest | Rehellinen | Direct |
| Unfiltered | Suodattamaton | Modern, clean |
| Warm Up | Lämmittely | Natural |
| Real Talk | Oikea puhe | Natural |
| Deep Dive | Syväsukellus | Natural compound |
| Couples | Parit | Direct |
| Friends | Ystävät | Direct |
| Family | Perhe | Direct |
| Solo Reflection | Itsereflektio | Natural |
| Life Story | Life Story | **English only** |
| Fall in Love | Fall in Love | **English only** |
| Share an Experience | Share an Experience | **English only** |

---

## Finnish-Specific Risks

### Pro-Drop Pitfalls
Not all verb forms make person clear without pronouns. Add `sinä` when the verb form is ambiguous (e.g., past tense conditional).

### Agglutinative Length
Finnish adds suffixes for case, possession, and aspect. Translations will often be 20-40% longer than English. UI labels need room.

### Compound Words
Finnish forms compound nouns as single words: `itsereflektio`, `elämäntarina`, `parisuhde`.

---

## Decisions on Record

| Decision | Choice | Rationale |
|---|---|---|
| Locale code | `fi` | Standard Finnish locale |
| Register | Informal verb conjugation throughout | Modern Finnish always uses implicit `sinä` |
| Gender policy | Naturally neutral via `hän` | Finnish has no grammatical gender |
| Partner term | `kumppanisi` | Possessive, gender-neutral, natural |
| Formal `Te` | Never | Archaic in this context |
| Brand terms | All English | Feature names |
