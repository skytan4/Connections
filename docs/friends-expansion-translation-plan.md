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

2. Generate translation packets.
   - Run `ruby scripts/generate_friends_expansion_translation_packets.rb`.
   - This writes two batches per locale to `/tmp/friends_expansion_translation_packets/<locale>/batch_01` and `batch_02`.
   - Batch sizes are 100 and 82 prompts, which keeps each translation assignment below the ~120 prompt guidance in `docs/localization/agent-translation-workflow.md`.

3. Translate each locale batch.
   - Translate only the records in that batch's `source.json`.
   - Preserve IDs exactly.
   - Preserve metadata exactly.
   - Translate main `text` and each follow-up `text`.
   - Preserve follow-up `style`.

4. Assemble each locale after both batches are translated.
   - Save each batch result as `/tmp/friends_expansion_translation_packets/<locale>/batch_01/translated.json` and `batch_02/translated.json`.
   - Run `ruby scripts/assemble_friends_expansion_translation.rb --locale <locale>`.
   - This writes `/tmp/friends_expansion_translation_packets/<locale>/translated.json`.
   - The assembled file must contain the same 182 prompt IDs in the same order.

5. Validate each staged translation before merging.
   - No missing IDs.
   - No extra IDs.
   - No English placeholder text.
   - Follow-up count is exactly 2 for every prompt.
   - Follow-up IDs and styles match English.
   - Locale-specific scan passes.

6. Merge all locales in one coordinated pass.
   - Append staged English prompts to `Connections/Data/prompts_en.json`.
   - Append each translated staged file to its matching `Connections/Data/prompts_<locale>.json`.
   - Preserve the same prompt order across every locale.

7. Run validation.
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

Each batch agent must output raw JSON only:

```json
{
  "language": "es",
  "batch": 1,
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
