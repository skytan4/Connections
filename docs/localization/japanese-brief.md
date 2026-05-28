# Japanese Localization Brief

## Purpose

This document defines the translation standards, policies, and glossary for a future Japanese (`ja`) localization of Deeper Conversations. All translators, translation agents, and coordinator reviewers must read this brief before producing Japanese content.

Japanese requires a more opinionated brief than many European languages because natural Japanese often omits subjects, pronouns, and relationship labels that English repeats. The goal is not a literal English-to-Japanese mapping. The goal is emotionally faithful, culturally natural Japanese that preserves the exact intent of each prompt.

---

## Agent Non-Negotiables

Copy these into every Japanese translation or audit-agent prompt:

- Natural omission first: do not force English pronouns into Japanese. Avoid unnecessary `あなた`, `私`, `私たち`, `彼`, `彼女`, `パートナー`.
- Use warm conversational Japanese; avoid customer-service, corporate, school-worksheet, or stiff `です/ます` overuse.
- Preserve directness and emotional intensity; do not soften sex, grief, unfiltered, or deep prompts into vague mood questions.
- Keep mode context clear despite omission: couples must not become generic/family/friend prompts, and family/friend prompts must not become romantic.
- Use contextual relationship words sparingly: `ふたり`, `相手`, `大切な人`, `この関係`, or omission.
- Sensitive batches require second independent review when no fluent human reviewer is available.
- Preserve `…` sentence completions as Japanese fragments, not full questions.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.
- Agent must self-scan for pronoun overload before returning output.

---

## Register

- **Warm, natural, emotionally intelligent Japanese.** Write like a thoughtful person inviting a real conversation, not like a form, therapy worksheet, or corporate survey.
- **Use a soft conversational register.** Avoid stiff business Japanese and avoid overly casual slang.
- **Default to gentle plain/polite balance.** Prompts may use natural plain forms where they feel intimate and direct. Use `です/ます` sparingly when it softens the line, but do not make the voice formal or distant.
- **Avoid `あなた` unless absolutely necessary.** Japanese usually does not need a direct "you." Repeated `あなた` will sound translated and emotionally awkward.
- **Avoid over-explaining.** Japanese can carry emotional nuance through phrasing and omission. Do not add extra commentary or moral framing.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Japanese must also remain an unfinished completion-style fragment.

---

## Core Japanese Policy: Natural Omission First

English prompts frequently name the subject: "you," "I," "we," "your partner," "someone." Japanese often sounds better when these are omitted or implied.

**Policy:**

1. **Do not force English pronouns into Japanese.**
   - Avoid repetitive `あなた`, `私`, `私たち`, `僕`, `俺`, `彼`, `彼女`.
   - Use them only when the contrast is essential to the meaning.

2. **Prefer context-based phrasing.**
   - "What do you need from me?" can often become `今、どんな支えがあると安心できる？`
   - If "from me" is essential, include it naturally: `今、私からどんな支えがあると安心できる？`

3. **Keep relationship context without over-labeling.**
   - Couples prompts can often use `ふたり`, `この関係`, `相手`, `大切な人`, or omit the noun.
   - Friends and family prompts should not be accidentally romance-coded.

4. **When in doubt, preserve meaning over word count.**
   - Short Japanese is good only if it keeps the same emotional question.

---

## Politeness and Distance

Japanese politeness changes emotional distance. This app should not sound like customer support or a school worksheet.

| Avoid | Why | Prefer |
|---|---|---|
| Overuse of `あなたは...ですか？` | Stiff and translated | Drop `あなた`; use natural question shape |
| Heavy `です/ます` in every line | Too formal for intimate prompts | Mix natural plain forms and soft endings |
| Slangy casual speech | Can feel careless in sensitive prompts | Warm, simple, adult Japanese |
| Command-like phrasing | Too abrupt | Invite reflection with `どんな`, `いつ`, `何が`, `どう感じる` |

Do not use honorific customer-service language such as `ご利用`, `いただく`, `お願いいたします` in prompt content. UI strings may use standard app Japanese, but still should feel simple and human.

---

## Partner and Person References

There is no single perfect Japanese equivalent for every English use of "partner." Choose based on context.

| English context | Preferred Japanese | Notes |
|---|---|---|
| Romantic partner, natural direct reference | `パートナー` | Acceptable, but do not overuse if the noun can be omitted. |
| The person across from you | `相手` | Natural, neutral, useful in prompts. |
| Emotionally close person | `大切な人` | Warmer than `パートナー`; use when appropriate. |
| The two of you | `ふたり` | Very useful for couples prompts. |
| Relationship | `この関係`, `ふたりの関係` | Good for avoiding repeated partner nouns. |
| Someone unspecified | `誰か`, `ある人`, `その人` | Choose based on emotional tone. |

Avoid defaulting to gendered terms like `彼`, `彼女`, `夫`, `妻`, `彼氏`, `彼女` unless the English source explicitly specifies that role.

---

## Sentence-Completion Prompts

Many prompts are intentionally fragments, such as "I feel most loved when…" or "Sex feels most meaningful to me when…"

**Hard rule:** Preserve the fragment shape. Do not turn every fragment into a full question.

Examples:

| English | Preferred Japanese shape | Avoid |
|---|---|---|
| I feel most loved when… | `いちばん愛されていると感じるのは…` | `いつ一番愛されていると感じますか？` |
| I feel most sensual when… | `いちばん官能的な気持ちになるのは…` | A full explanatory sentence |
| A fantasy I have mixed feelings about is… | `複雑な気持ちになる空想は…` | Adding judgment or explanation |

Coordinator must verify that every English prompt ending in `…` also ends in `…` in Japanese and still reads as a natural completion.

---

## Directness and Emotional Intensity

Japanese often expresses direct emotional questions more indirectly than English. That is fine, but the meaning must not be softened away.

### Light
- Friendly, easy, not childish.
- Natural everyday Japanese.
- Avoid making light prompts sound like interview questions.

### Honest
- Clear and emotionally sincere.
- Use gentle directness; avoid over-hedging.
- Do not turn uncomfortable prompts into vague mood questions.

### Unfiltered
- Direct emotional truth, not rudeness.
- Do not make unfiltered prompts aggressive, accusatory, or shocking.
- Do not soften so much that the question loses its edge.

Bad pattern:
- English: "What are you pretending not to know?"
- Too soft: `最近、少し気になっていることはありますか？`
- Better: `本当は気づいているのに、気づかないふりをしていることは何？`

---

## Sensitive Content Guidance

### Sex / Intimacy

Japanese sexuality vocabulary can become clinical, euphemistic, childish, or crude very quickly. Stay in a natural adult register.

- Use `セックス` for sex when the topic is explicit and adult.
- Use `性的`, `欲望`, `触れる`, `体`, `親密さ`, `官能的` carefully and only when they fit the source.
- Avoid medical terms unless the English is clinical.
- Avoid vulgar slang.
- Avoid making sex prompts cute or coy.

### Couples / Intimacy

- Tender, adult, emotionally safe.
- Prefer `親密さ`, `近さ`, `ふたり`, `相手`, `大切な人`, depending on context.
- Avoid overusing `愛` if the English does not explicitly mean love.

### Hardship / Grief / Regret

- Gentle, spacious, and respectful.
- Avoid melodrama.
- Avoid minimizing phrases.
- Death, loss, and family pain should feel grounded and quiet.

### Family / Intergenerational

- Respectful without becoming formal.
- Japanese family terms carry cultural weight; choose carefully.
- Avoid assuming traditional family roles unless the source does.

### Friends

- Warm and conversational.
- Do not romance-code friend prompts.
- Playful prompts can be lighter, but not slangy or flippant.

---

## Brand Terms — Keep in English

The following are product feature names and must remain in English in all Japanese strings:

| Term | Policy |
|---|---|
| Deeper Conversations | English only (`shouldTranslate: false` in xcstrings) |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

If a brand term appears in a Japanese sentence, keep the English term unchanged and make the surrounding Japanese natural.

---

## UI Translation Guidance

Japanese UI often needs shorter, clearer labels than literal English.

- Prefer compact app-native labels.
- Do not overuse honorific or customer-service phrasing.
- Preserve placeholders exactly (`%1$@`, `%2$@`, `%1$lld`, etc.).
- Reorder placeholders if Japanese grammar requires it, but do not drop or duplicate them.
- Avoid translating brand terms.
- Check layout carefully: Japanese may be shorter in characters but can wrap differently due to line-breaking behavior.

Examples:

| English UI concept | Possible Japanese |
|---|---|
| Back | `戻る` |
| Done | `完了` |
| Settings | `設定` |
| Go Deeper | `もっと深く` |
| Start Session | `セッションを始める` |
| All Topics | `すべてのトピック` |

These are starting points, not mandatory translations for every context.

---

## Glossary

Preferred Japanese translations for recurring concepts. Agents should use these consistently while still respecting context.

| English term | Japanese | Notes |
|---|---|---|
| prompt / question | `質問` | Natural for conversation prompts. |
| session | `セッション` | Standard app term. |
| Go Deeper | `もっと深く` | Button/CTA. Avoid literal movement phrasing. |
| Unfiltered | `フィルターなし` / `飾らずに` | Label vs prose may differ. |
| Honest | `正直に` / `正直な` | Use adverb/adjective as context requires. |
| Light | `軽め` | Natural tone label. |
| Warm Up | `ウォームアップ` | App/category label. |
| Real Talk | `本音の話` | Natural emotional equivalent. |
| Deep Dive | `深掘り` | Common and natural. |
| partner | `パートナー` / `相手` | Use sparingly; omit when natural. |
| the two of you / us | `ふたり` | Very useful in couples prompts. |
| relationship | `関係`, `ふたりの関係` | Context-dependent. |
| intimacy | `親密さ` | Emotional closeness. |
| closeness | `近さ`, `親しさ` | Choose by tone. |
| connection / bond | `つながり`, `絆` | `絆` can feel weighty; use carefully. |
| vulnerability | `弱さを見せること`, `無防備さ` | Avoid overly technical terms. |
| appreciation | `ありがたさ`, `感謝`, `大切に思うこと` | Context-dependent; do not overuse `感謝` if English means being valued. |
| to feel seen | `ちゃんと見てもらえていると感じる`, `理解されていると感じる` | Choose based on context. |
| to feel safe | `安心できる` | Often better than literal "safe." |
| desire | `欲望`, `望み`, `求めているもの` | `欲望` is stronger/sexual; use carefully. |
| fantasy | `空想`, `ファンタジー` | Sex context may use `ファンタジー`; reflective context may use `空想`. |
| grief | `悲しみ`, `喪失感` | Context-dependent. |
| regret | `後悔` | Direct equivalent. |
| letting go | `手放すこと` | Natural in emotional contexts. |
| closure | `区切り`, `けじめ`, `終わりの感覚` | Choose carefully; no single perfect equivalent. |

---

## Japanese-Specific Risks

### Pronoun Overload

The most likely agent failure is overusing `あなた`, `私`, and `パートナー`. Coordinator must scan for repeated pronouns and remove them where natural.

### Meaning Loss Through Softening

Japanese translations may become beautiful but too vague. Coordinator must compare against the English and ask: "Does this still ask the same specific thing?"

### Politeness Drift

Agents may drift into stiff `です/ます` or customer-service Japanese. Coordinator should normalize toward warm conversational phrasing.

### Sex Vocabulary Drift

Agents may become too clinical or too euphemistic. Sex prompts need special review by a Japanese speaker if possible.

### Sentence Fragment Loss

Agents may convert sentence-completion prompts into full questions. This must be corrected.

### Cultural Over-Adaptation

Do not localize away the app's emotional honesty. Cultural naturalness is good; avoiding the core question is not.

---

## JSON Integrity

- Translate only user-facing text fields.
- Preserve every prompt ID and follow-up ID exactly.
- Do not translate metadata: `mode`, `intensity`, `depth`, `topic`, `style`, `order`, `chapter`.
- Do not add, remove, reorder, summarize, or replace prompts or follow-ups.
- Every follow-up must translate the exact English follow-up attached to the same ID.
- Preserve `schemaVersion`.
- Set `language` to `ja` for Japanese JSON banks.

---

## Coordinator Checklist

Before applying any Japanese patch, coordinator must check:

1. **ID fidelity** — every key exists and matches the assigned English source.
2. **Follow-up fidelity** — each follow-up translates the exact matching English follow-up, not a nearby or invented one.
3. **Pronoun scan** — check for overuse of `あなた`, `私`, `私たち`, `彼`, `彼女`, `パートナー`.
4. **Politeness scan** — remove stiff business/customer-service Japanese where it appears.
5. **Sentence-completion scan** — every source line ending in `…` still ends in `…` and remains a fragment.
6. **Sensitive content scan** — sex, grief, family, and unfiltered prompts preserve tone without becoming crude, vague, or clinical.
7. **Brand scan** — Deeper Conversations, Life Story, Fall in Love, Share an Experience remain English.
8. **Placeholder scan** — UI placeholders are preserved exactly.
9. **English leftovers** — no translated text is still English except approved brand terms.
10. **Specificity check** — no prompt has been softened into a more generic question.
11. **Independent review agent (required for sensitive batches)** — for sex, grief/loss/hardship, unfiltered, Life Story legacy, and emotionally delicate family batches, run a second independent review agent after the coordinator pass. The review agent should assess Japanese quality and source fidelity only; it should not rewrite unless it identifies a concrete, specific issue. This pass is required — it does not replace native-speaker review, but it is the minimum standard when no Japanese-speaking human reviewer is available.

---

## Agent Output Format

Each agent outputs a JSON patch file. Format:

```json
{
  "prompt_id_here": {
    "text": "Japanese translation of main prompt",
    "followUps": [
      { "id": "prompt_id_here_fu_1", "text": "Japanese translation of follow-up 1" },
      { "id": "prompt_id_here_fu_2", "text": "Japanese translation of follow-up 2" }
    ]
  }
}
```

Agents must not edit project files directly, must not create final `*_ja.json` files, and must not translate outside their assigned batch.

---

## Confirmed Japanese Policy Decisions

These decisions are confirmed and in effect for all Japanese translation work.

| Decision | Confirmed policy |
|---|---|
| Overall register | Warm conversational Japanese with a light plain/polite balance. Avoid both slang and business formality. |
| Direct address | Omit pronouns by default. Do not force `あなた`, `私`, `私たち`, or `パートナー` unless required for meaning or contrast. |
| Partner / person terms | Context-dependent. Use `相手`, `ふたり`, `大切な人`, `パートナー`, `この関係`, or omission depending on context. Do not default to `パートナー` everywhere. |
| Sex vocabulary | Natural adult register. Not crude, not clinical, not coy. Preserve emotional honesty without making the language shocking or euphemistic. |
| Human review | Not available during development. No fluent Japanese reviewer is assumed to be available before translation starts. Required compensation: agent translation + coordinator review + independent review-agent pass for all sensitive batches. Sensitive batches are marked "native-speaker review recommended before public release" but development is not blocked on that review. |

---

## No Human Review Available During Development

John cannot perform Japanese-language human review, and no fluent Japanese reviewer is assumed to be available before translation work begins. This section defines the required compensation and its limits.

### Required process for sensitive batches

The following batches require a second independent review-agent pass after the coordinator review:

- Sex prompts
- Grief / loss / hardship prompts
- Unfiltered prompts
- Life Story legacy prompts
- Emotionally delicate family prompts

**How the second review agent works:**
- It receives the translated Japanese output alongside the English source.
- It reviews for: Japanese naturalness, register consistency, source fidelity, pronoun overuse, meaning loss through softening, tone drift in sensitive content, and sentence-completion fragment preservation.
- It does **not** rewrite speculatively. It flags concrete issues with before/after corrections only.
- Its output is reviewed by the coordinator before anything is applied.

### What this does not cover

An independent review agent can catch structural errors, pronoun overload, politeness drift, obvious meaning loss, and incomplete fragments. It cannot fully substitute for a native speaker's intuition on subtle emotional register, cultural connotation, or natural flow in intimate and delicate contexts.

All sensitive batches translated without native-speaker review must be marked in the commit message and session report as **"native-speaker review recommended before public release."** This is a known limitation, not a blocker.
