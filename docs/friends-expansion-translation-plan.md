# Friends Prompt Expansion Translation Plan

## Current Artifacts

- Draft source: `docs/friends-new-prompts.md`
- Production staging preview: `docs/friends-new-prompts-staged.md`
- Machine-readable staged records: `docs/friends-new-prompts-staged.json`

The staged file contains 182 new Friends prompts with:

- stable proposed IDs
- `mode = friends`
- `intensity = light | honest | unfiltered`
- inferred `depth = warmUp | realTalk | deepDive`
- topic
- two follow-ups
- follow-up IDs and `origin` / `impact` styles

## Why Not Insert English First

The localization tests compare each `prompts_XX.json` file against `prompts_en.json` by:

- count
- ID order
- metadata parity
- follow-up ID/style parity
- translated text differing from English

Adding these prompts to English only would intentionally break every localized prompt bank until translations are added. For this expansion, English and localized prompt banks should move together.

## Recommended Workflow

1. Review `docs/friends-new-prompts-staged.md`.
   - Confirm the depth assignments feel right.
   - Adjust any follow-ups that feel too generic.
   - Remove or rewrite any prompts that feel weaker on a second read.

2. Use `docs/friends-new-prompts-staged.json` as the translation source.
   - Translate only these 182 new records.
   - Preserve IDs exactly.
   - Preserve metadata exactly.
   - Translate main `text` and each follow-up `text`.
   - Preserve follow-up `style`.

3. Produce one staged translation file per locale.
   - Suggested temporary location: `/tmp/friends_expansion_<locale>.json`
   - Each file should contain the same 182 prompt IDs in the same order.

4. Validate each staged translation before merging.
   - No missing IDs.
   - No extra IDs.
   - No English placeholder text.
   - Follow-up count is exactly 2 for every prompt.
   - Follow-up IDs and styles match English.
   - Locale-specific scan passes.

5. Merge all locales in one coordinated pass.
   - Append staged English prompts to `Connections/Data/prompts_en.json`.
   - Append each translated staged file to its matching `Connections/Data/prompts_<locale>.json`.
   - Preserve the same prompt order across every locale.

6. Run validation.
   - Run JSON/localization tests.
   - Run language-specific scanners.
   - Spot-check the Friends expansion in the app.

## Locale Targets

Current prompt locales:

- `da`
- `de`
- `es`
- `fi`
- `fr`
- `it`
- `ja`
- `nb`
- `nl`
- `pl`
- `pt-BR`
- `ru`
- `sv`
- `zh-Hans`

## Agent Prompt Requirements

Each translation agent should receive:

- the language brief for its locale
- the language brief's Agent Non-Negotiables
- the staged English JSON records
- the output format below

Agents must output raw JSON only:

```json
{
  "language": "es",
  "prompts": [
    {
      "id": "p_friends_light_warmUp_appreciation_005",
      "text": "Translated prompt text",
      "mode": "friends",
      "intensity": "light",
      "depth": "warmUp",
      "topic": "appreciation",
      "followUps": [
        {
          "id": "p_friends_light_warmUp_appreciation_005_fu_1",
          "text": "Translated follow-up 1",
          "style": "origin"
        },
        {
          "id": "p_friends_light_warmUp_appreciation_005_fu_2",
          "text": "Translated follow-up 2",
          "style": "impact"
        }
      ]
    }
  ]
}
```

## Merge Gate

Do not merge staged prompts into `Connections/Data/prompts_en.json` until every active prompt locale has a matching staged translation file, unless the release plan explicitly accepts temporarily disabling prompt localization parity tests.
