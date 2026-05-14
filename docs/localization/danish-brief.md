# Danish Localization Brief

**Locale code:** `da`  
**Status:** In progress — Big Five batch  
**Last updated:** 2026-05-14

---

## Register

- **Warm, natural, emotionally intelligent Danish.** Write as a thoughtful friend would speak.
- **Informal `du` throughout.** Never use `De` (formal capital-D) as a formal second-person address. Modern Danish always uses `du`.
- **Danish directness.** Danish is direct, warm, and understated — similar to Swedish. Avoid theatrical or melodramatic phrasing.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Danish must too, and must remain an unfinished fragment.

---

## Gender Policy — Neutral-First (Hard Rule)

Danish has grammatical gender (common/neuter) but good neutral options.

**Hard rule:** Do not assume the user's or partner's gender.

| Banned form | Why | Use instead |
|---|---|---|
| `han` / `hun` | Gendered third-person pronouns | `de` (singular neutral), `personen`, omit |
| `ham` / `hende` | Gendered object pronouns | `dem`, `personen`, restructure |
| `hans` / `hendes` | Gendered possessives | `deres`, `personens`, restructure |
| `De` (formal capital) | Formal address | `du` |

**Note on `de`:** In modern Danish, `de`/`dem`/`deres` is increasingly used as a singular gender-neutral pronoun, similar to English "they/them." This is acceptable in this context.

**Preferred gender-neutral constructions:**

| Context | Preferred Danish |
|---|---|
| Referring to the partner | `din partner`, `den anden person`, `den anden` |
| Referring to both people | `I`, `jer to`, `jeres forhold`, `sammen` |
| Unknown-gender third person | `de` (singular neutral), `personen`, omit |
| Possessive for partner | `din partners`, `den andens` |

---

## Tone by Content Type

### Light
- Accessible, warm, easy-going. Everyday Danish register.

### Honest
- Sincere, clear, direct. Danish directness — not over-hedged, not blunt.

### Unfiltered
- Direct emotional truth. Danish understatement is an asset. Plain, direct questions carry weight without theatrics.

### Warm Up / Real Talk / Deep Dive
- Natural escalation in seriousness and depth.

### Sex / Intimacy
- Direct and adult. Not clinical, not crude. Danish has a comfortable adult register — use it.
- Completion prompts ending in `…` must remain fragments.

### Hardship / Grief / Regret
- Gentle, respectful, spacious. Danish emotional restraint — no added sentimentality.

### Family / Friends / Life Story
- Warm and natural. Life Story = dignified, unhurried.

---

## Sentence-Completion Prompts

**Hard rule:** Preserve the fragment shape. English `…` → Danish `…`, remain a fragment.

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

- Danish strings are typically similar length to English.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, etc.
- All labels use `du`/`dig`/`dit`, never formal `De`/`Dem`.

---

## Danish-Specific Risks

### `De` Formal Register
Capital-D `De`/`Dem`/`Deres` is the very formal pronoun. It looks like the plural `de`/`dem`/`deres` but is capitalized. Flag any capital-D `De` used as formal address.

### `Han`/`Hun` Defaults
Most common agent error: defaulting to `han`/`hun` for partners. Check all partner references.

### Compound Words
Danish forms compound nouns written as one word: `kærlighedsforhold`, `hverdagsliv`.

### Softening
Danish emotional directness should be preserved. Watch for over-hedged translations of unfiltered prompts.

---

## Glossary

| English term | Danish | Notes |
|---|---|---|
| partner | din partner | Gender-neutral |
| the other person | den anden | Or `den anden person` |
| between you (two) | jer imellem / jeres forhold | Natural for couples |
| connection / bond | forbindelse / bånd | Context-dependent |
| closeness | nærhed | Direct equivalent |
| intimacy | intimitet | For emotional/relational intimacy |
| to feel seen | føle sig set | Natural and direct |
| vulnerability | sårbarhed | Direct equivalent |
| letting go | at slippe | Or `give slip` |
| grief | sorg | Direct equivalent |
| desire | længsel / begær | Context-dependent |
| Light | Let | Clean and natural |
| Honest | Ærligt | Or `Oprigtigt` |
| Unfiltered | Ufiltreret | Clean, modern |
| Warm Up | Opvarmning | Or `Kom i gang` |
| Real Talk | Ærlig snak | Natural |
| Deep Dive | Dybt dyk | Or `Dybdegående` |
| Couples | Par | Direct |
| Friends | Venner | Direct |
| Family | Familie | Direct |
| Solo Reflection | Selvrefleksion | Natural |
| Life Story | Life Story | **English only** |
| Fall in Love | Fall in Love | **English only** |
| Share an Experience | Share an Experience | **English only** |

---

## Coordinator Checklist

1. **`De`/`Dem`/`Deres` (formal)** — flag capital-D formal pronoun; replace with `du`/`dig`/`dit`
2. **`han`/`hun` partner scan** — replace with `din partner`/`den anden`
3. **`hans`/`hendes` scan** — replace with `deres`/`din partners`
4. **Compound words** — verify written as one word
5. **Ellipsis scan** — English `…` → Danish `…`, remain fragment
6. **Understatement check** — translations don't amplify beyond source
7. **English leftovers** — no translated text reads as English except brand terms
8. **Follow-up fidelity** — exact match to English follow-up
9. **ID fidelity** — every key matches a real prompt ID

---

## Decisions on Record

| Decision | Choice | Rationale |
|---|---|---|
| Register | Informal `du` throughout | Modern Danish always uses `du` in conversation |
| Gender policy | Neutral-first; `de` (singular) + restructuring | Follows modern Danish usage |
| Partner term | `din partner` (primary), `den anden` | Gender-neutral, natural |
| Formal `De` | Never | Archaic in this context |
| Brand terms | All English | Feature names |
| Emotional register | Understated, direct | Matches Danish natural register |
