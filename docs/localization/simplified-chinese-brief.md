# Simplified Chinese Localization Brief

## Purpose

This document defines the translation standards, policies, and glossary for a future Simplified Chinese (`zh-Hans`) localization of Deeper Conversations. All translators, translation agents, and coordinator reviewers must read this brief before producing Simplified Chinese content.

Simplified Chinese is not just "English with shorter strings." Natural Chinese often omits subjects, uses relationship context rather than repeated labels, and can become either too stiff or too slogan-like if translated literally. The goal is warm, emotionally faithful, culturally natural Simplified Chinese that preserves the exact intent of each prompt.

---

## Pilot Requirement Before Full Translation

Simplified Chinese translation must begin with a small pilot batch before full prompt translation proceeds.

**Pilot size:** ~10 prompts, selected to cover at least two modes and two intensity levels.

**Required for pilot review:**
- Back-translation of each prompt (translate the Chinese back to English in plain prose) OR a source-fidelity summary that describes, for each prompt, whether the Chinese preserves the exact question and intent of the English
- Coordinator review of both the Chinese and the back-translation against the English source

**Why:** Chinese can read fluent, natural, and grammatically correct while drifting semantically — softened into a mood prompt, altered in specificity, or shifted in emotional register — in ways that a non-fluent reviewer cannot catch without back-translation. The pilot exists to surface agent behavior before it is applied across 598 prompts.

The pilot report must be reviewed and approved before Wave 1 translation begins.

---

## Register

- **Use Simplified Chinese characters only.** Do not use Traditional Chinese characters or Taiwan/Hong Kong-specific terms.
- **Warm, natural, emotionally intelligent Mandarin.** Write like a thoughtful person inviting a real conversation, not like a questionnaire, self-help slogan, or corporate notice.
- **Use informal `你`, not formal `您`.** The app is intimate and conversational. `您` creates unwanted distance.
- **Do not overuse pronouns.** Chinese can often omit `你`, `我`, `我们`, and `对方` when context is clear.
- **Direct but not blunt.** Honest prompts should be clear and emotionally specific, not harsh or accusatory.
- **Tender but not sentimental.** Avoid melodrama, inspirational-poster phrasing, or ornate idioms.
- **Preserve ellipses (`…`) in sentence-completion prompts.** If the English prompt ends with `…`, the Chinese must also remain an unfinished completion-style fragment.

---

## Core Chinese Policy: Context First, Pronouns Second

English repeats "you," "I," "we," "your partner," and "someone" more often than natural Chinese does.

**Policy:**

1. **Omit pronouns when the meaning remains clear.**
   - Avoid mechanically translating every "you" as `你`.
   - Avoid repeated `我`, `我们`, `你们`, or `对方` if the context already carries the relationship.

2. **Use `你` when direct address is emotionally important.**
   - `你` is appropriate in reflective questions.
   - Do not replace clear directness with vague abstraction.

3. **Avoid formal address.**
   - `您`, `您的`, `请您` are not allowed in prompts or app copy unless quoting a source that explicitly requires formality.

4. **Preserve the speaker relationship.**
   - Couples prompts should still feel like they happen between two people in a relationship.
   - Family prompts should not become romantic.
   - Friend prompts should not become couple-coded.

---

## Gender and Person Reference Policy

Spoken Mandarin is gender-neutral in third person, but written Chinese distinguishes `他`, `她`, and `它`. Avoid introducing gender where the English source does not specify it.

**Hard rules:**

- Do not use `他/她`, `他或她`, `她或他`, `他(她)`, `TA`, or any mixed or stylized form for unknown-gender people. `TA` is banned — see above.
- Do not default to `他` for a partner, friend, parent, or unspecified person.
- Do not assume spouse terms such as `丈夫`, `妻子`, `男朋友`, `女朋友` unless the English source specifies them.

Preferred neutral options:

| English context | Preferred Chinese | Notes |
|---|---|---|
| your partner | `伴侣`, `对方`, `另一半` | `伴侣` is neutral but slightly formal; `另一半` is warmer/romantic; choose by context. |
| the person across from you | `对方` | Useful and neutral. |
| someone important | `重要的人`, `在乎的人` | Warm and broad. |
| the two of you | `你们`, `彼此`, `两个人`, `这段关系` | Choose based on sentence shape. |
| that person | `那个人`, `这个人`, `对方` | Avoid gendered pronouns. |
| family member | `家人`, `某个家人`, `家里的某个人` | Context-dependent. |

`TA` is banned. Do not use it in prompts or UI copy. Agents must restructure, omit the pronoun, or use a neutral noun: `对方`, `那个人`, `这个人`, `重要的人`, `在乎的人`. In Mandarin there is almost always a natural neutral alternative; `TA` is never necessary.

---

## Sentence-Completion Prompts

Many prompts are intentionally fragments, such as "I feel most loved when…" or "Sex feels most meaningful to me when…"

**Hard rule:** Preserve the fragment shape. Do not turn every fragment into a full question.

Examples:

| English | Preferred Chinese shape | Avoid |
|---|---|---|
| I feel most loved when… | `我最能感受到被爱的时候是…` | `你什么时候最能感受到被爱？` |
| I feel most sensual when… | `我最有感官上的亲密感时，是…` | A full explanatory question |
| A fantasy I have mixed feelings about is… | `一个让我心情复杂的幻想是…` | Adding judgment or moral framing |

Coordinator must verify that every English prompt ending in `…` also ends in `…` in Chinese and still reads as a natural completion.

---

## Directness and Emotional Intensity

Chinese can make emotional questions sound softer through omission and indirectness. That is useful, but the core question must not be diluted.

### Light

- Friendly, simple, easy to answer.
- Natural everyday Mandarin.
- Avoid making light prompts sound like survey items.

### Honest

- Clear and emotionally sincere.
- Use gentle directness.
- Avoid therapy jargon and abstract self-help language.

### Unfiltered

- Honest and direct, not rude.
- Do not make unfiltered prompts aggressive, accusatory, or sensational.
- Do not soften them into vague mood prompts.

Bad pattern:

- English: "What are you pretending not to know?"
- Too soft: `最近有什么让你有点在意的事吗？`
- Better: `有什么事，其实你已经知道，却一直假装不知道？`

---

## Sensitive Content Guidance

### Sex / Intimacy

Chinese sex vocabulary can become clinical, crude, censored, or euphemistic very quickly. Stay in a natural adult register.

**Register hierarchy for sex vocabulary:**

| Word | Register | Use when |
|---|---|---|
| `性` | Neutral, modern | English explicitly says "sex"; default primary word |
| `性爱` | Warmer, relational | Couples intimacy contexts; sex as connection |
| `做爱` | Colloquial-romantic | Use sparingly; only when tone is clearly intimate and informal |
| `性关系` | Slightly clinical | Avoid unless English is explicitly clinical |
| `性交` | Clinical/medical | Avoid unless English is clinical |

- Use `亲密`, `身体`, `欲望`, `幻想`, `触碰`, `吸引` carefully and contextually.
- Avoid crude slang.
- Do not censor or obscure words with symbols.
- Do not make sex prompts coy or childish.
- Do not soften explicit prompts into `亲密感` or `靠近` when the English says "sex" directly.

### Couples / Intimacy

- Tender, adult, emotionally safe.
- Prefer `亲密`, `靠近`, `彼此`, `这段关系`, `对方`, depending on context.
- Avoid overusing `爱` if the English does not explicitly mean love.

### Hardship / Grief / Regret

- Gentle, spacious, and respectful.
- Avoid melodrama.
- Avoid minimizing or moralizing.
- Loss, death, and family pain should feel grounded and quiet.

### Family / Intergenerational

- Respectful and grounded.
- Chinese family terms carry cultural expectations; do not assume traditional family roles beyond the source.
- Avoid turning family prompts into duty/filial-piety statements unless the English source clearly points there.
- Do not introduce duty/filial-piety framing or vocabulary unless the English source explicitly does so. Specifically avoid adding terms like `孝顺`, `孝道`, `报答父母`, `尽孝` unless directly warranted by the source text. Life Story legacy prompts are especially at risk of this drift.

### Friends

- Warm and conversational.
- Do not romance-code friendship prompts.
- Playful prompts can be light, but avoid internet slang that will age quickly.

---

## Brand Terms — Keep in English

The following are product feature names and must remain in English in all Simplified Chinese strings:

| Term | Policy |
|---|---|
| Deeper Conversations | English only (`shouldTranslate: false` in xcstrings) |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

If a brand term appears inside a Chinese sentence, keep the English term unchanged and make the surrounding Chinese natural.

---

## UI Translation Guidance

Chinese UI can be compact, but each character carries weight. Short does not always mean clear.

- Prefer concise, app-native labels.
- Use Simplified Chinese punctuation where natural: `，` `。` `？` `：`.
- Preserve placeholders exactly (`%1$@`, `%2$@`, `%1$lld`, etc.).
- Reorder placeholders only if Chinese grammar requires it, and do not drop or duplicate them. Any placeholder reordering must be explicitly flagged in the coordinator report so the coordinator can manually verify the semantic meaning is preserved.
- Do not translate brand terms.
- Avoid overly formal UI language such as `请您`, `设置项`, `功能模块` unless context requires it.
- Watch for visual density: a short Chinese label can still feel heavy in a button if too abstract.

Examples:

| English UI concept | Possible Chinese |
|---|---|
| Back | `返回` |
| Done | `完成` |
| Settings | `设置` |
| Go Deeper | `深入一点` |
| Start Session | `开始会话` |
| All Topics | `所有话题` |
| Favorites | `收藏` |

These are starting points, not mandatory translations for every context.

---

## Glossary

Preferred Simplified Chinese translations for recurring concepts. Agents should use these consistently while still respecting context.

| English term | Simplified Chinese | Notes |
|---|---|---|
| Couples (mode) | `伴侣` | Mode label. |
| Friends (mode) | `朋友` | Mode label. |
| Family (mode) | `家庭` | Mode label. |
| Solo Reflection (mode) | `自我反思` | Canonical UI label. `独自反思` is understandable but not preferred. |
| prompt / question | `问题` | Natural for conversation prompts. |
| session | `会话` / `一次对话` | `会话` for UI; `一次对话` in prose when warmer. |
| Go Deeper | `深入一点` | Button/CTA. Warmer than literal movement phrasing. |
| Unfiltered | `不加过滤` / `坦率一点` | Label vs prose may differ. |
| Honest | `坦诚` / `诚实` | `坦诚` often warmer for emotional conversations. |
| Light | `轻松` | Tone label. |
| Warm Up | `热身` | Natural category label. |
| Real Talk | `真心话` / `认真聊聊` | Choose by tone and UI length. |
| Deep Dive | `深度探索` / `深入聊聊` | UI vs prose may differ. |
| partner | `伴侣`, `对方`, `另一半` | Context-dependent; avoid overusing one term. |
| the two of you / us | `你们`, `彼此`, `两个人` | Choose by sentence shape. |
| relationship | `关系`, `这段关系` | Context-dependent. |
| intimacy | `亲密`, `亲密感` | Emotional/physical closeness. |
| closeness | `靠近`, `亲近`, `更近一点` | Choose by tone. |
| connection / bond | `连接`, `联结`, `关系里的连结` | `联结` is warmer; `连接` can sound technical. |
| vulnerability | `脆弱`, `袒露脆弱`, `敞开自己` | Avoid jargon; choose natural phrasing. |
| appreciation | `欣赏`, `看见`, `珍惜`, `感谢` | Context-dependent; do not overuse `感谢` if English means being valued. |
| to feel seen | `被真正看见`, `被理解` | `被看见` is common but can feel therapy-coded; use carefully. |
| to feel safe | `感到安心`, `觉得安全` | `安心` is often warmer. |
| desire | `欲望`, `想要的东西`, `渴望` | `欲望` is stronger/sexual; use carefully. |
| fantasy | `幻想` | Sex context and general imagination both possible; context matters. |
| grief | `悲伤`, `失去后的痛` | Context-dependent. |
| regret | `后悔`, `遗憾` | `遗憾` can be softer; preserve source intensity. |
| letting go | `放下`, `放手` | Context-dependent. |
| closure | `一个了结`, `结束感`, `放下的感觉` | No single perfect equivalent. |
| boundaries | `界限` | More natural than literal boundary words in emotional context. |

---

## Simplified Chinese-Specific Risks

### Traditional Character Leakage

Agents may produce Traditional Chinese characters. Coordinator must scan for obvious Traditional forms and ensure the final text is Simplified Chinese.

### Pronoun and Relationship Label Overload

Repeated `你`, `我`, `我们`, `伴侣`, or `对方` can make Chinese sound translated. Coordinator should remove or restructure where context is clear.

### Written Gender Pronouns

Avoid `他/她`, `他或她`, `TA`, and gendered spouse/romantic terms unless the English source specifies them.

### Meaning Loss Through Softening

Chinese translations may become polite but vague. Coordinator must ask: "Does this still ask the same specific thing?"

### Idiom and Slogan Drift

Agents may use four-character idioms, inspirational slogans, or polished phrases that sound nice but change the emotional register. Prefer plain, intimate language.

### Sex Vocabulary Drift

Agents may become too clinical, too euphemistic, or too censored. Sex prompts require special review.

### Punctuation and Fragment Loss

English sentence-completion prompts ending in `…` must remain fragments. Agents may convert them into full questions.

### Regional Vocabulary

Use broadly understandable Simplified Chinese. Avoid Taiwan/Hong Kong-specific vocabulary and overly region-specific Mainland slang.

---

## JSON Integrity

- Translate only user-facing text fields.
- Preserve every prompt ID and follow-up ID exactly.
- Do not translate metadata: `mode`, `intensity`, `depth`, `topic`, `style`, `order`, `chapter`.
- Do not add, remove, reorder, summarize, or replace prompts or follow-ups.
- Every follow-up must translate the exact English follow-up attached to the same ID.
- Preserve `schemaVersion`.
- Set `language` to `zh-Hans` for Simplified Chinese JSON banks.

---

## Coordinator Checklist

Before applying any Simplified Chinese patch, coordinator must check:

1. **ID fidelity** — every key exists and matches the assigned English source.
2. **Follow-up fidelity** — each follow-up translates the exact matching English follow-up, not a nearby or invented one.
3. **Simplified character scan** — no Traditional Chinese leakage.
4. **Formality scan** — no `您`, `您的`, `请您` in app/prompt copy.
5. **Pronoun scan** — check for overuse of `你`, `我`, `我们`, `伴侣`, `对方`; remove where natural.
6. **Gendered written pronoun scan** — no `他/她`, `他或她`, `她或他`, `TA` for unknown-gender people.
7. **Sentence-completion scan** — every source line ending in `…` still ends in `…` and remains a fragment.
8. **Sensitive content scan** — sex, grief, family, and unfiltered prompts preserve tone without becoming crude, vague, clinical, or censored.
9. **Brand scan** — Deeper Conversations, Life Story, Fall in Love, Share an Experience remain English.
10. **Placeholder scan** — UI placeholders are preserved exactly.
11. **English leftovers** — no translated text is still English except approved brand terms.
12. **Specificity check** — no prompt has been softened into a more generic question.
13. **Idiom/slogan scan** — remove ornamental idioms or inspirational phrasing that changes the app voice.
14. **Mode-relationship check** — verify that couples, family, friends, and solo prompts have not been contaminated across modes by pronoun/label omission. Dropped pronouns must not make family prompts romantic, friend prompts couple-coded, or couples prompts so generic they lose relational specificity.

---

## Sensitive Batch Review

If no fluent Simplified Chinese reviewer is available, sensitive batches **must** receive a second independent review-agent pass before apply. This is required, not optional — the second agent pass is the only quality gate between translation and commit when no fluent reviewer is present.

Sensitive batches:

- Sex prompts
- Grief/loss/hardship prompts
- Unfiltered prompts
- Life Story legacy prompts
- Emotionally delicate family prompts

The review agent should assess source fidelity, Chinese naturalness, register consistency, pronoun/gender issues, and sensitive vocabulary. It should not rewrite speculatively; it should only propose concrete corrections tied to specific IDs and fields.

Native-speaker review is required before public release for sensitive Chinese content.

---

## Agent Output Format

Each agent outputs a JSON patch file. Format:

```json
{
  "prompt_id_here": {
    "text": "Simplified Chinese translation of main prompt",
    "followUps": [
      { "id": "prompt_id_here_fu_1", "text": "Simplified Chinese translation of follow-up 1" },
      { "id": "prompt_id_here_fu_2", "text": "Simplified Chinese translation of follow-up 2" }
    ]
  }
}
```

Agents must not edit project files directly, must not create final `*_zh-Hans.json` files, and must not translate outside their assigned batch.

---

## Confirmed Simplified Chinese Policy Decisions

These decisions are confirmed for Simplified Chinese translation work unless John explicitly changes them.

| Decision | Choice |
|---|---|
| Locale code | `zh-Hans` |
| Script | Simplified Chinese only |
| Register | Warm conversational Mandarin; informal `你`; no formal `您` |
| Pronoun policy | Context-first; omit pronouns where natural, but preserve directness when needed |
| Gender policy | Avoid written gendered pronouns for unknown people; use neutral nouns or restructure |
| Partner/person terms | Context-dependent: `伴侣`, `对方`, `另一半`, `彼此`, `这段关系`, or omission |
| Sex vocabulary | Natural adult register; not crude, not clinical, not coy, not censored |
| Brand terms | Deeper Conversations, Life Story, Fall in Love, Share an Experience remain English |
| Sensitive review | Second independent review-agent pass **required** if no fluent reviewer is available |
