# Norwegian Bokmål Localization Brief

**Locale code:** `nb` (NOT `no`)  
**Status:** In progress — Big Five batch  
**Last updated:** 2026-05-14

---

## Register

- **Warm, natural, emotionally intelligent Norwegian Bokmål.** Write as a thoughtful friend would speak.
- **Informal `du` throughout.** Never use `De` (formal capital-D) as a formal second-person address. Modern Norwegian always uses `du` in conversation.
- **Norwegian directness.** Norwegian Bokmål is direct, warm, and understated. Avoid theatrical or melodramatic phrasing.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Norwegian must too, and must remain an unfinished fragment.

---

## Gender Policy — Neutral-First (Hard Rule)

Norwegian Bokmål has good neutral options. `hen` is accepted in modern Norwegian as a gender-neutral singular pronoun. `de`/`dem`/`deres` can be used as a gender-neutral singular.

**Hard rule:** Do not assume the user's or partner's gender.

| Banned form | Why | Use instead |
|---|---|---|
| `han` / `hun` | Gendered third-person pronouns | `hen`, `personen`, omit |
| `ham` / `henne` | Gendered object pronouns | `hen` (obj), `personen`, restructure |
| `hans` / `hennes` | Gendered possessives | `hens`, `personens`, restructure |
| `De` (formal capital) | Formal address | `du` |

**Preferred gender-neutral constructions:**

| Context | Preferred Norwegian |
|---|---|
| Referring to the partner | `partneren din`, `den andre personen`, `den andre` |
| Referring to both people | `dere`, `dere to`, `forholdet deres`, `sammen` |
| Unknown-gender third person | `hen`, `de` (singular neutral), `personen`, omit |
| Possessive for partner | `partnerens`, `den andres` |

---

## Tone by Content Type

### Light / Honest / Unfiltered
- Same escalation pattern as Swedish/Danish.
- Norwegian understatement: plain and direct. Not theatrical.

### Sex / Intimacy
- Direct and adult. Not clinical, not crude.
- Completion prompts ending in `…` must remain fragments.

### Hardship / Grief / Regret
- Gentle, respectful, spacious. Norwegian restraint — no added sentimentality.

### Family / Friends / Life Story
- Warm and natural. Life Story = dignified, unhurried.

---

## Sentence-Completion Prompts

**Hard rule:** English `…` → Norwegian `…`, remain a fragment.

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

- Norwegian strings are similar length to English or slightly shorter.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, etc.
- All labels use `du`/`deg`/`ditt`, never formal `De`/`Dem`.

---

## Norwegian-Specific Risks

### `De` Formal Register
Capital-D `De` is the formal address pronoun. Flag any formal `De` used as singular address.

### `Han`/`Hun` Defaults
Common agent error. Check all partner references.

### Compound Words
Norwegian forms compound nouns as single words: `kjærlighetsforhold`, `hverdagsliv`, `selvrefleksjon`.

### Bokmål vs. Nynorsk
Write in Bokmål, not Nynorsk. Watch for Nynorsk-specific forms (e.g., `eg` instead of `jeg`, `ikkje` instead of `ikke`).

---

## Glossary

| English term | Norwegian Bokmål | Notes |
|---|---|---|
| partner | partneren din | Gender-neutral |
| the other person | den andre | Or `den andre personen` |
| between you (two) | mellom dere / forholdet deres | Natural for couples |
| connection / bond | tilknytning / bånd | Context-dependent |
| closeness | nærhet | Direct equivalent |
| intimacy | intimitet | For emotional/relational |
| to feel seen | å føle seg sett | Natural |
| vulnerability | sårbarhet | Direct equivalent |
| letting go | å slippe | Or `gi slipp` |
| grief | sorg | Direct equivalent |
| desire | lengsel / begjær | Context-dependent |
| Light | Lett | Clean and natural |
| Honest | Ærlig | Or `Oppriktig` |
| Unfiltered | Ufiltrert | Clean, modern |
| Warm Up | Oppvarming | Natural |
| Real Talk | Ærlig samtale | Natural |
| Deep Dive | Dypdykk | Natural compound |
| Couples | Par | Direct |
| Friends | Venner | Direct |
| Family | Familie | Direct |
| Solo Reflection | Selvrefleksjon | Natural |
| Life Story | Life Story | **English only** |
| Fall in Love | Fall in Love | **English only** |
| Share an Experience | Share an Experience | **English only** |

---

## Coordinator Checklist

1. **`De`/`Dem`/`Deres` (formal)** — flag capital-D formal; replace with `du`/`deg`/`ditt`
2. **`han`/`hun` partner scan** — replace with `partneren din`/`den andre`/`hen`
3. **`hans`/`hennes` scan** — replace with `hens`/`partnerens`
4. **Nynorsk form check** — flag `eg`, `ikkje`, `me`, `oss` as wrong dialect
5. **Compound words** — verify written as one word
6. **Ellipsis scan** — English `…` → Norwegian `…`, remain fragment
7. **English leftovers** — no text reads as English except brand terms
8. **Follow-up fidelity** — exact match to English follow-up
9. **ID fidelity** — every key matches a real prompt ID

---

## Decisions on Record

| Decision | Choice | Rationale |
|---|---|---|
| Locale code | `nb` | Bokmål is the standard written form; `no` is ambiguous |
| Register | Informal `du` throughout | Modern Norwegian always uses `du` in conversation |
| Gender policy | Neutral-first; `hen` + restructuring | Accepted in modern Norwegian |
| Partner term | `partneren din` (primary), `den andre` | Gender-neutral, natural |
| Dialect | Bokmål only | Most widely used written standard |
| Formal `De` | Never | Archaic in this context |
| Brand terms | All English | Feature names |
