# Polish Localization Review Workflow

## Purpose

This document defines the review process for Polish (`pl`) translations produced by automated agents. It is intended for human reviewers checking translation quality before translations are merged into the app.

---

## Reviewer Rules

1. **Do not edit JSON files directly.** The source translation files (`prompts_pl.json`, `fall_in_love_pl.json`, etc.) are generated and applied programmatically. Manual edits to those files will be overwritten or cause merge conflicts.

2. **Return all corrections as patch JSON.** See the Patch Format section below.

3. **Do not change metadata fields.** `id`, `mode`, `intensity`, `depth`, `topic`, `order`, `chapter`, `style`, `schemaVersion`, `language` — these are structural and must never be altered by a reviewer.

4. **Do not leave empty `text` fields.** An empty or whitespace-only string is invalid and will fail automated tests.

5. **Consult the brief first.** All decisions about register, gender, glossary terms, and sensitive content are settled in `docs/localization/polish-brief.md`. Do not introduce new approaches that contradict the brief.

---

## Patch Format

Submit corrections as a JSON object keyed by prompt ID. Only include prompts that need changes — do not include unchanged entries.

```json
{
  "p_couples_light_warmUp_dailyLife_001": {
    "text": "Corrected Polish prompt text here…",
    "followUps": [
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Corrected follow-up 1 text" },
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_2", "text": "Corrected follow-up 2 text" }
    ]
  },
  "p_friends_honest_realTalk_values_042": {
    "text": "Corrected Polish prompt text here"
  }
}
```

### Patch Rules

| Rule | Detail |
|---|---|
| Prompt ID must exist | The key must match an `id` field in the source JSON. Unknown IDs are rejected. |
| Follow-up IDs must match | Each `id` inside `followUps` must match the original follow-up `id`. Do not add, remove, or renumber follow-ups. |
| `followUps` is optional | If only the prompt text needs fixing, omit `followUps`. If one or more follow-up texts need fixing, include only those follow-up corrections, each with its original follow-up `id`. The patcher applies follow-up corrections by `id`, not by array position. |
| Metadata is never edited | Do not include `mode`, `intensity`, `depth`, `topic`, `order`, `style`, or any non-text field. |
| Empty text is invalid | A `text` value of `""` or whitespace will be rejected by automated tests. |

---

## Review Table Format

When reviewing a batch, copy this Markdown table structure and fill it in. Submit the completed table alongside your patch JSON.

```markdown
| id | mode | intensity | depth | topic | English | Polish (generated) | Reviewer notes |
|---|---|---|---|---|---|---|---|
| p_couples_light_warmUp_dailyLife_001 | couples | light | warmUp | dailyLife | What's one small thing I did today that you noticed? | Jaką jedną małą rzecz, którą dziś zrobiłem(-am), zauważyłeś(-aś)? | Slash notation — use gender-neutral rewrite |
```

Leave the **Reviewer notes** column blank for entries that need no change. For entries needing correction, note the specific issue (e.g., "wrong verb aspect", "too formal", "brand term should be English", "gender awkwardness").

---

## Sensitive Packet Routing

The full prompt set is divided into thematic review packets. Sensitive packets are reviewed separately and may go to a different reviewer than the general-tone packets.

| Packet name | Contents | Notes |
|---|---|---|
| `general` | All non-sensitive prompts | Default reviewer |
| `couples_intimacy` | Couples mode, intimacy topic | Tender, adult, emotionally safe — see brief |
| `sex_unfiltered` | Unfiltered intensity, sex topic | Direct but not vulgar — see brief |
| `hardship_grief_regret` | Hardship, grief, or regret topics across all modes | Gentle, spacious — avoid minimizing language |
| `family_intergenerational` | Family mode and Life Story prompts | Respectful, culturally grounded Polish family language |

Each packet will be distributed as a standalone Markdown file containing the review table for that group, plus a corresponding patch JSON template. Reviewers should return:

1. The completed review table (notes column filled in)
2. A patch JSON containing only the entries that need correction

---

## Common Issues to Watch For

- **Slash notation** (`gotowy/a`, `zmęczony/a`) — not allowed per brief; flag and suggest a neutral rewrite
- **Wrong verb aspect** — imperfective for ongoing states and reflection prompts; perfective only for specific completed events
- **Formal register** (`Pan/Pani`) — all prompts use informal `ty`; flag any formal forms
- **Brand terms translated** — `Life Story`, `Fall in Love`, `Share an Experience`, `Deeper Conversations` must remain in English
- **Glossary deviations** — check against the glossary in `polish-brief.md`; e.g., `więź` not `połączenie`, `wrażliwość` not `podatność na zranienie`
- **Missing or altered ellipsis** — if English prompt ends with `…`, Polish must too
- **Truncation risk** — Polish runs 20–40% longer than English; flag phrases that may overflow buttons or labels in the UI

---

## Review Completion Checklist

Before submitting your review packet, confirm:

- [ ] Patch JSON keys match real prompt IDs
- [ ] No metadata fields included in patch
- [ ] No empty `text` values in patch
- [ ] Follow-up IDs match originals (not renumbered)
- [ ] Slash notation eliminated or flagged
- [ ] Sensitive prompts reviewed against the brief's guidance for that category
- [ ] Brand terms left in English
- [ ] Glossary terms consistent with `polish-brief.md`
