# Italian Localization Brief

**Locale code:** `it`  
**Status:** In progress — Big Five batch (Italian, Swedish, Danish, Norwegian Bokmål, Finnish)  
**Last updated:** 2026-05-14

---

## Register

- **Warm, natural, emotionally intelligent Italian.** Write as a thoughtful friend would speak, not as a therapist or a form.
- **Informal `tu` throughout.** Never use `Lei`/`Suo`/`Sua` (formal) in any prompt, follow-up, or UI string.
- **Avoid melodrama.** Italian can easily tip into over-expressiveness. Keep emotional prompts warm but grounded — not theatrical.
- **Direct but not harsh.** Honest and unfiltered prompts should feel inviting and courageous, not aggressive or confrontational.
- **Tender but not sentimental.** Warmth is welcome; purple prose is not.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Italian must too, and must remain an unfinished fragment — not a full question.

---

## Gender Policy — Neutral-First (Hard Rule)

Italian has grammatical gender, which creates a real challenge for user-addressed prompts. The goal is to avoid assuming the user's gender while keeping prose natural.

**Priority order for gender-neutral constructions:**

1. **Infinitive constructions** — `Cosa significa per te fare bene le cose?` instead of a gendered participle
2. **Question forms without agreement** — `Come ti sei sentito/a?` is acceptable but clunky; prefer restructuring to avoid it entirely
3. **Noun-based constructions** — `Che tipo di persona sei?` rather than `Sei una persona che...`
4. **When agreement is unavoidable** — use `lui/lei` or restructure; do not default to masculine

**Hard rule for partner references:** Never use `lui` or `lei` as a default pronoun for the partner. Use:

| Banned form | Why | Use instead |
|---|---|---|
| `lui` / `lei` | Gendered third-person pronouns | `il tuo partner`, `l'altra persona`, `l'altro/l'altra`, omit |
| `il tuo ragazzo` / `la tua ragazza` | Assumes gender and relationship type | `il tuo partner` |
| `suo` / `sua` (formal) | Formal register | `tuo` / `tua` |
| `Lei` / `Suo` | Formal address | `tu` / `tuo` |

**Preferred gender-neutral constructions:**

| Context | Preferred Italian |
|---|---|
| Referring to the partner | `il tuo partner`, `l'altra persona`, `l'altro/l'altra` |
| Referring to both people | `voi`, `voi due`, `tra di voi`, `la vostra relazione` |
| User-addressed participle | Restructure to infinitive or noun form |
| Past participle in context | `ti sei sentito/a` is a last resort; prefer restructuring |

---

## Tone by Content Type

### Light
- Accessible, easy, inviting.
- Everyday Italian register — the kind you'd use chatting with a close friend.
- Avoid making light prompts feel like a quiz or interview.

### Honest
- Emotionally sincere and clear.
- Gentle directness — not blunt, not over-hedged.
- Do not soften honest prompts to the point that they lose their genuine question.

### Unfiltered
- Direct emotional truth.
- Not cruel, not aggressive, but unsparing.
- Do not make unfiltered prompts feel shocking; but do not soften their edge either.

### Warm Up
- A real on-ramp — easy to answer, genuinely meaningful.
- Should feel like the start of something.

### Real Talk
- A genuine step up from Warm Up.
- Should feel worth showing up for.

### Deep Dive
- Serious, searching, spacious.
- Leave room for difficulty or silence.
- Do not over-explain or frame the question with a preamble.

### Sex / Intimacy
- Direct and adult. Not clinical, not crude, not coy.
- Italian has a natural adult register for intimacy — stay in it.
- Avoid clinical medical terms for sexual topics.
- Avoid vulgar (`volgare`) or coarse phrasing.
- Completion prompts (ending in `…`) must remain fragments.

### Hardship / Grief / Regret
- Gentle, respectful, and spacious.
- Leave room for the user to sit with difficulty without feeling pressed.
- Avoid minimizing language (`capita a tutti`, `è normale`).

### Family / Intergenerational
- Warm and grounded.
- Italian family language is direct and familiar — use it naturally.
- Do not flatten family relationships into generic "famiglia."

### Friends
- Warm and casual, not romance-coded unless the prompt explicitly addresses that.
- Playful where the English is playful; earnest where the English is earnest.

### Life Story
- Addressing older adults reflecting on a full life.
- Dignified, unhurried, respectful.
- Follow-ups should invite depth, not push for answers.
- Hardship and legacy chapters deserve particular care — spacious, not sentimental.

---

## Sentence-Completion Prompts

Many prompts are intentionally fragments.

**Hard rule:** Preserve the fragment shape. Do not turn a fragment into a full question.

| English | Good Italian shape | Avoid |
|---|---|---|
| I feel most loved when… | `Mi sento più amato/a quando…` (or: `La cosa che mi fa sentire più amato/a è…`) | `Quando ti senti più amato?` |
| A fantasy I have mixed feelings about is… | `Una fantasia riguardo cui ho sentimenti contrastanti è…` | Converting to a direct question |
| Something I've never told you is… | `Una cosa che non ti ho mai detto è…` | Adding a question mark |

Note: for first-person sentence completions with past participles, `/a` suffix notation is acceptable when restructuring would be awkward. Prefer restructuring when natural.

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

- Italian strings can run 10–25% longer than English.
- Monitor button labels, tab titles, and segment controls for truncation.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, etc.
- Reorder placeholder positions only if Italian grammar requires it — do not drop or duplicate them.
- All labels use `tu`/`tuo`, never `Lei`/`Suo`.
- Keep UI labels clear and direct; avoid filler words that inflate label length.

---

## Italian-Specific Risks

### Gendered Participle Defaults
The most common agent error: defaulting to masculine past participles (`sentito`, `pronto`, `aperto`) when addressing the user generically.
- Coordinator must scan for context where these appear and verify they are restructured or use infinitive form.

### Formal Register Creep
`Lei`/`Suo`/`Sua` violations are a known agent risk in Italian. Coordinator must grep for `\bLei\b` and `\bSuo\b` / `\bSua\b` before applying.

### False Friends and Calques
Italian agents sometimes produce literal English calques that sound unnatural.
- Watch for: `fare senso` (should be `avere senso`), `supportare` (should be `sostenere` for emotional support), `muovere avanti` (should be `andare avanti`).

### Melodrama
Italian prompts should be warm, not theatrical. Watch for over-dramatic phrasing like `il profondo abisso di...` or excessive use of superlatives.

### Ellipsis Preservation
Italian completion fragments must retain `…` and not become full questions. This is a hard rule.

---

## Glossary

| English term | Italian | Notes |
|---|---|---|
| prompt / question | domanda | Natural for a conversation prompt. |
| session | sessione | Direct equivalent. |
| Go Deeper | Vai più in profondità | Or `Approfondisci`. |
| Unfiltered | Senza filtri | Clean, modern. |
| Honest | Sincero/a | Or `Onesto/a`. In UI: `Sincero`. |
| Light | Leggero | Clean and natural. |
| Warm Up | Riscaldamento | Or keep `Warm Up` if it feels too technical. |
| Real Talk | Conversazione vera | Or `Parliamo sul serio`. |
| Deep Dive | Approfondimento | Natural. |
| partner | il tuo partner | Gender-neutral. Always informal. |
| the other person | l'altra persona | Or `l'altro/l'altra` depending on context. |
| between you (two) | tra di voi | Natural for couples context. |
| connection / bond | connessione / legame | `legame` is warmer; `connessione` more neutral. |
| closeness | vicinanza | Direct equivalent. |
| intimacy | intimità | For emotional/relational intimacy. |
| to feel seen | sentirsi visti | Natural and direct. |
| to feel appreciated | sentirsi apprezzati | Or `sentirsi valorizzati`. |
| vulnerability | vulnerabilità | Direct equivalent. |
| appreciation | apprezzamento | Use `gratitudine` only when English specifically means gratitude. |
| values | valori | Direct equivalent. |
| growth | crescita | Personal development. |
| conflict | conflitto | Direct equivalent. |
| communication | comunicazione | Direct equivalent. |
| letting go | lasciar andare | Natural Italian phrase. |
| grief | dolore / lutto | `dolore` = pain/grief; `lutto` = mourning/bereavement. Context-dependent. |
| regret | rimpianto | Direct and natural. |
| hardship | difficoltà / momento difficile | Context-dependent. |
| to feel safe | sentirsi al sicuro | Natural and direct. |
| desire | desiderio | Direct and appropriate for all registers. |
| Life Story | Life Story | **English only — brand term.** |
| Fall in Love | Fall in Love | **English only — brand term.** |
| Share an Experience | Share an Experience | **English only — brand term.** |

---

## Coordinator Checklist

Before applying any Italian translation batch:

1. **`Lei`/`Suo`/`Sua` scan** — grep for formal register; flag any violations
2. **`lui`/`lei` partner scan** — flag gendered third-person pronouns referring to the user's partner; replace with `il tuo partner` or restructure
3. **Masculine default scan** — flag past participles addressing the user generically (e.g., `sei pronto`, `ti sei sentito`); prefer infinitive or restructured forms
4. **Calque check** — flag `fare senso`, `supportare` (emotional), `muovere avanti` and similar false friends
5. **Ellipsis scan** — every English prompt ending in `…` must still end in `…` in Italian and remain a fragment
6. **Melodrama scan** — spot-check unfiltered and deep-dive batches; flag over-theatrical phrasing
7. **Semantic scan** — spot-check negatives and restructured prompts; meaning must not be inverted or softened
8. **English leftovers** — no translated text still reads as English except approved brand terms
9. **Brand term scan** — Deeper Conversations, Life Story, Fall in Love, Share an Experience remain in English
10. **Follow-up fidelity** — each follow-up translates the exact matching English follow-up at the same position/ID
11. **ID fidelity** — every patch key matches a real prompt ID in the source bank

---

## Decisions on Record

| Decision | Choice | Rationale |
|---|---|---|
| Register | Informal `tu` throughout | Italian informal register is natural for conversation prompts |
| Gender policy | Neutral-first; restructure to infinitive/noun when possible | Avoids masculine default while keeping prose natural |
| Partner term | `il tuo partner` (primary), `l'altra persona`, `l'altro/l'altra` | Common, gender-neutral, naturally informal |
| Formal `Lei` | Never | Hard rule; `Lei` sounds distant and cold in this context |
| Gendered participles | Restructure when possible; `/a` suffix as last resort | Respects user's gender without cluttering text |
| Brand terms | All English | Feature names; translating adds scope without user benefit |
| Melodrama | Actively suppressed | Italian can over-dramatize; warm but grounded is the target register |
