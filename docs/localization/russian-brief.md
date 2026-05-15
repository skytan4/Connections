# Russian Localization Brief

**Locale code:** `ru`  
**Status:** Pre-translation prep — brief complete, translation not yet started  
**Last updated:** 2026-05-14

This brief must be read before any Russian translation begins. Russian has more grammar-level risks than any other language in this project to date, primarily because of grammatical gender agreement in past tense and adjectives. Read the Gendered Grammar Policy section carefully before producing a single prompt.

---

## Register

- **Warm, conversational, thoughtful Russian.** Write as a thoughtful friend would speak.
- **Informal `ты` throughout.** All prompts and UI copy use informal second-person singular. Never use formal `вы`, `Вас`, `Вам`, `Ваш` in prompts or UI copy unless the source explicitly quotes speech that is formal in context.
- **Not literary, not ornate, not bureaucratic.** Russian has a strong literary tradition that pulls toward elevated diction. Resist it. The target is plain, warm, direct — what a thoughtful friend says in a real conversation, not what a novelist writes.
- **Not therapy-formal.** Avoid `самораскрытие`, `осознанность`, and similar therapy-imported terms when simpler natural Russian works.
- **Avoid melodrama.** Russian can make emotional content sound tragic-grand. The app tone is quiet, warm, and grounded.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Russian must too, and must remain an unfinished fragment.

---

## Gendered Grammar Policy — The Critical Section

Russian past-tense verbs and short-form adjectives agree with the grammatical gender of their subject. This creates a direct problem when addressing an unknown-gender user in second person.

| Form | Masculine | Feminine |
|---|---|---|
| Past tense | `ты был`, `ты чувствовал` | `ты была`, `ты чувствовала` |
| Short adjective | `ты готов`, `ты счастлив` | `ты готова`, `ты счастлива` |
| Reflexive past | `ты почувствовал себя` | `ты почувствовала себя` |

**Hard policy: neutral restructure first.**

Prefer present tense, infinitives, impersonal constructions, or noun-based phrasing that does not require gender agreement. Do not assume the user's gender.

| Problematic form | Neutral restructure |
|---|---|
| `Когда ты почувствовал(а) себя...` | `Когда ты чувствуешь себя...` (present tense) |
| `Ты был(а) счастлив(а), когда...` | `Что приносило тебе радость, когда...` |
| `Ты готов(а) к этому?` | `Как ты к этому относишься?` |
| `Ты когда-нибудь чувствовал(а) себя одиноким?` | `Бывало ли тебе одиноко?` (impersonal) |
| `Ты стал(а) другим человеком?` | `Изменился ли ты как человек?` → avoid; use `Как ты изменился за это время?` + flag for review |

**Masculine fallback:** Use only as an absolute last resort — when a neutral restructure genuinely cannot produce natural Russian for the specific prompt and every restructure option has been exhausted. Masculine fallback is not permitted simply because it is easier or faster than restructuring.

Every masculine fallback must be reported in the coordinator report with all of the following:

| Field | What to include |
|---|---|
| Prompt ID / key | Exact ID (e.g., `p_soloReflection_honest_deepDive_identity_003`) |
| Field | `text`, `followUp1`, `fu_1`, etc. |
| Exact Russian phrase | The masculine-gendered phrase used |
| Why restructure was not practical | Specific reason a neutral form was not achievable for this prompt |
| Needs later review? | Yes / No — flag if a fluent reviewer should check this item |

Masculine fallbacks that are not reported in this format will be treated as errors by the coordinator and must be corrected before apply.

**SoloReflection prompts** are the highest-risk category because they address "you" in first-person reflection contexts, often in past tense. These should be prioritized for neutral restructure and flagged for second-agent review.

---

## No Slash or Parenthetical Notation — Hard Ban

**Banned forms:**

- `готов/а`
- `счастлив(а)`
- `устал(а)`
- `влюблён/влюблена`
- Any `X/Y` or `X(Y)` gender annotation

These look translated and break app voice. Agents must restructure to avoid gendered forms, not annotate them. If an agent produces slash or parenthetical notation, the coordinator must reject and require a restructure before applying.

---

## Partner and Person References

Do not assume the user's or partner's gender.

**Preferred neutral options:**

| English context | Preferred Russian | Notes |
|---|---|---|
| your partner | `партнёр`, `близкий человек`, `любимый человек` | `партнёр` is grammatically masculine but used as contemporary gender-neutral default; use across contexts but don't over-repeat |
| the other person | `тот, кто рядом`, `человек рядом`, `другой человек` | More neutral options |
| the two of you | `вы двое`, `вы оба` | Prefer `вы двое`; `оба` is masculine-inclusive, `обе` is feminine — `вы двое` avoids the issue |
| between you | `между вами`, `в ваших отношениях` | Natural |
| someone important | `близкий человек`, `важный для тебя человек` | Warm and broad |
| your relationship | `ваши отношения`, `ваша пара` | Context-dependent |

**Banned partner terms (unless source specifies):**

| Term | Why |
|---|---|
| `партнёрша` | Explicitly feminine; ban unless source specifies female partner |
| `он/она`, `его/её`, `он или она` | Gendered pronoun pairs for unknown-gender people |
| `муж`, `жена` | Assumes marital status and gender; ban unless source specifies |
| `парень`, `девушка` | Gendered romantic terms; ban unless source specifies |

---

## Sex and Intimacy Vocabulary

Russian sex vocabulary has a wide register spread. Stay in a natural adult register — direct without being crude or clinical.

**Register hierarchy:**

| Word/phrase | Register | Use when |
|---|---|---|
| `секс` | Neutral, modern | English explicitly says "sex"; primary default word |
| `сексуальная жизнь`, `интимная жизнь` | Neutral, relational | "Sex life" or intimacy-as-ongoing-context |
| `близость`, `интимность` | Warm, emotional/physical closeness | Intimacy, emotional connection; do not default to these when English says "sex" directly |
| `влечение`, `желание` | Desire | Sexual or general desire; context-dependent |
| `чувственность` | Sensuality | Physical-sensory contexts |
| `половой акт`, `совокупление` | Clinical/medical | Avoid unless English is explicitly clinical |

- Do not censor or euphemize sex into only `близость` when English says "sex" directly.
- Do not use crude slang.
- Sentence-completion prompts ending in `…` must remain open fragments.

---

## Verb Aspect

Russian verbs come in perfective/imperfective pairs. Getting this wrong produces prompts that feel grammatically off.

| Context | Use | Example |
|---|---|---|
| Habits, ongoing feelings, recurring patterns | **Imperfective** | `Что ты чувствуешь, когда...` |
| Reflection on patterns and states | **Imperfective** | `Что тебя обычно беспокоит?` |
| Specific completed past events | **Perfective** | `Что изменило твой взгляд на это?` |
| Prompts about what usually happens | **Imperfective** | `Как ты обычно справляешься с...` |

Agents often default to perfective. Coordinator should spot-check aspect in reflective prompts — these are the most common failure case.

---

## Sensitive Content

### Grief / Hardship / Regret

- Quiet, grounded, and respectful.
- Russian literary tradition leans toward tragic grandeur; the app tone is restrained and warm.
- Loss and family pain should feel grounded, not operatic.
- Avoid moralizing or adding resolution not in the source.

### Family / Intergenerational

- Respectful and grounded.
- Do not introduce duty framing unless the English source explicitly does.
- Avoid added moral or prescriptive weight.

### Unfiltered Intensity

- Direct, not cruel.
- Do not soften unfiltered prompts into vague mood questions.
- Do not make them aggressive or sensational.

### Sex / Intimacy

- Adult register; see vocabulary hierarchy above.
- Not coy, not clinical, not euphemized.

---

## Sentence-Completion Prompts

**Hard rule:** English `…` → Russian `…`, remain a fragment.

Do not turn sentence-completion prompts into full questions. The prompt is meant to be completed out loud by the user.

| English | Good Russian shape | Avoid |
|---|---|---|
| `I feel most loved when…` | `Я больше всего чувствую себя любимым, когда…` → gendered; restructure: `Мне больше всего чувствуется любовь, когда…` | Turning into a question |
| `The thing I'm most afraid to say is…` | `То, что мне труднее всего сказать — это…` | `Чего ты больше всего боишься сказать?` |

---

## Brand Terms — Keep in English

| Term | Policy |
|---|---|
| Deeper Conversations | English only |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

---

## UI Guidance

- Russian strings run **20–40% longer** than English. Button labels, navigation titles, and section headers need special attention — prioritize concise natural Russian over literal completeness.
- Preserve all format placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, `%2$lld`, `%3$@`.
- Any placeholder reordering must be explicitly flagged in the coordinator report; coordinator must verify semantic meaning is preserved.
- Avoid formal UI language: `Настройки` not `Конфигурация параметров`; `Готово` not `Подтвердить выбор`.
- Russian punctuation: use `—` (em dash) naturally for syntactic pauses; don't force English comma patterns.

---

## Glossary

Preferred Russian translations for recurring terms. Agents should use these consistently, respecting context.

| English term | Russian | Notes |
|---|---|---|
| Light (intensity) | `Лёгкий` | Tone label. |
| Honest (intensity) | `Искренний` | Warmer than `Честный`; prefer for emotional contexts. `Честный` is fine in UI labels where `Искренний` is too long. |
| Unfiltered (intensity) | `Без фильтров` | **Canonical UI label.** `Без купюр` carries a stronger "uncensored/nothing cut" connotation that can feel sharper than the app's tone intends; use only in prose contexts if a more emphatic phrasing is needed, not as a UI label. |
| Warm Up (depth) | `Разогрев` | Natural category label. |
| Real Talk (depth) | `Честный разговор` | Natural. |
| Deep Dive (depth) | `Глубокое погружение` | Natural. |
| Couples (mode) | `Пары` | Mode label. |
| Friends (mode) | `Друзья` | Mode label. |
| Family (mode) | `Семья` | Mode label. |
| Solo Reflection (mode) | `Личное размышление` | Or `Наедине с собой` (warmer but longer). Choose by UI space. |
| prompt / question | `вопрос` | Natural for conversation prompts. |
| session | `сессия` | UI label. `встреча` or `разговор` in prose when warmer. |
| Go Deeper | `Глубже` | Button/CTA. Concise. |
| partner | `партнёр`, `близкий человек` | Context-dependent; do not over-repeat one term. |
| the two of you | `вы двое` | Preferred over `вы оба` (avoids gender agreement in `оба/обе`). |
| relationship | `отношения` | Standard. |
| intimacy | `близость`, `интимность` | Emotional/physical closeness; not default for "sex". |
| vulnerability | `уязвимость`, `открытость` | `открытость` is softer and less therapy-coded; prefer in casual prompts. |
| connection / bond | `связь` | Neutral. `близость` also works when warmer tone needed. |
| appreciation | `признательность`, `ценить`, `замечать` | `ценить` is often warmer than `признательность` in conversation prompts. |
| to feel seen | `чувствовать себя замеченным` | Gendered — restructure: `ощущать, что тебя видят` |
| grief / loss | `горе` (grief), `потеря` (loss) | `горе` is heavier; `потеря` is the act of losing something. |
| desire | `желание`, `влечение` | `влечение` is more specifically sexual. |
| letting go | `отпустить`, `отпускать` | Imperfective `отпускать` for ongoing; perfective `отпустить` for a completed release. |
| closure | Context-dependent | No single default. Use `завершённость`, `поставить точку`, `принять и отпустить` as context demands. |
| boundaries | `границы` | Natural in emotional context. |

---

## Coordinator Checklist

Before applying any Russian patch:

1. **ID fidelity** — every key exists and matches the assigned English source. Zero missing, zero extra, zero duplicates.
2. **Follow-up fidelity** — each follow-up translates the exact matching English follow-up at the same array position. Not a nearby one. Not an invented one.
3. **Formality scan** — no `вы`, `Вас`, `Вам`, `Ваш` in prompts or UI copy as a form of address to the user.
4. **Gendered past-tense / adjective scan** — search for `был`, `была`, `готов`, `готова`, `устал`, `устала`, `почувствовал`, `почувствовала`, and similar forms in second-person contexts. Flag any instance where the gender agreement assumes user gender; require neutral restructure. If masculine fallback was used, verify that it was reported with all required fields (prompt ID, field, exact phrase, reason, review flag). Any unreported masculine fallback is an error.
5. **Slash / parenthetical notation scan** — search for `/а`, `(а)`, `/я`, `(я)` and similar annotation patterns. Reject and require restructure.
6. **Partner term scan** — no `партнёрша` unless source specifies female partner; no `муж`/`жена`/`парень`/`девушка` unless source specifies.
7. **Gendered pronoun scan** — no `он/она`, `его/её`, `он или она` for unknown-gender people.
8. **Ellipsis / fragment scan** — every English prompt ending in `…` still ends in `…` in Russian and reads as a natural unfinished completion.
9. **Sex vocabulary register check** — verify `секс` is used where English says "sex" directly; verify `близость` is not substituted for explicit content.
10. **Literary / ornate register check** — flag elevated, formal, or literary diction that doesn't match the conversational app voice.
11. **Aspect consistency** — spot-check imperfective use in reflective, habit, and ongoing-state prompts; flag perfective where imperfective is correct.
12. **Brand terms** — Deeper Conversations, Life Story, Fall in Love, Share an Experience remain in English.
13. **Placeholder check** — all format placeholders preserved exactly; any reordering flagged and semantically verified.
14. **English leftovers** — no translated text is still in English except approved brand terms.
15. **Specificity check** — no prompt has been softened into a more generic question than the English source.

---

## Sensitive Batch Review

If no fluent Russian reviewer is available, sensitive batches **must** receive a second independent review-agent pass before apply. This is required, not optional.

Sensitive batches:

- Sex prompts
- Grief / loss / hardship prompts
- Unfiltered prompts
- Life Story legacy prompts
- Emotionally delicate family prompts

The review agent should assess: source fidelity, Russian naturalness, gendered grammar neutrality, register consistency, sensitive vocabulary, slash/parenthetical notation, and aspect correctness. It should propose only concrete corrections tied to specific IDs and fields — not speculative rewrites.

Native-speaker review is required before public release for Russian sensitive content.

---

## Confirmed Russian Policy Decisions

| Decision | Choice |
|---|---|
| Locale code | `ru` |
| Register | Warm conversational Russian; informal `ты`; no formal `вы` in prompts or UI |
| Gendered grammar | Neutral restructure first; masculine fallback only as absolute last resort — must be reported with prompt ID, field, exact phrase, reason, and review flag |
| Slash/parenthetical notation | Hard ban — restructure required |
| Partner term default | `партнёр` (contemporary neutral); context-dependent alternatives as listed |
| `партнёрша` | Banned unless source specifies female partner |
| Sex vocabulary | `секс` as primary neutral word; see register hierarchy |
| Brand terms | Deeper Conversations, Life Story, Fall in Love, Share an Experience remain English |
| Sensitive review | Second independent review-agent pass **required** if no fluent reviewer is available |
