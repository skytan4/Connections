# scripts/localization — Localization Tooling

Scripts to support locale translations (Polish `pl`, Spanish `es`, and future locales)
of Deeper Conversations. These scripts do **not** perform translation. They prepare
batches for translation agents, apply corrections, validate candidates, generate reviewer
packets, and merge UI strings into `Localizable.xcstrings`.

---

## Intended Order

### Before translation agents run

**Step 1 — Extract batch files for translation agents**

```bash
python3 scripts/localization/extract_polish_batches.py
```

Reads `Connections/Data/prompts_en.json` and writes one JSON batch file per
tone/context group to `/tmp/polish_batches/`. No locale file is created.

Each batch file contains:
- `group` — group name
- `tone_note` — guidance for the translation agent
- `brief_ref` — path to the localization brief
- `count` — number of prompts in this batch
- `prompts` — array of prompts with id, mode, intensity, depth, topic, text, followUps

### After translation agents produce corrections

**Step 2 — Apply patch corrections to a prompt bank**

```bash
python3 scripts/localization/apply_polish_patch.py \
    --patch /tmp/my_agent_output.json
```

Applies explicit patch JSON to `Connections/Data/prompts_pl.json` (or any target
locale file via `--target`). If the target file does not exist, it is **created**
from the English structure before the patch is applied.

The patch file format is:
```json
{
  "p_couples_light_warmUp_dailyLife_001": {
    "text": "Translated prompt text here…",
    "followUps": [
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Follow-up text" }
    ]
  }
}
```

Corrections are applied by id, not by array position. Metadata fields
(mode, intensity, depth, topic, style, order) are rejected.

**Step 3 — Merge UI strings into Localizable.xcstrings**

```bash
python3 scripts/localization/merge_xcstrings_locale.py \
    --locale pl \
    --translations /tmp/polish_ui_translations.json
```

Inserts a locale entry for each key in the translations file into
`Connections/Localizable.xcstrings`. Validates placeholder parity, rejects
unknown keys, rejects empty values, and never touches `shouldTranslate: false`
entries or existing localizations for other locales.

Translations file format (key → value):
```json
{
  "common.button.back": "Wstecz",
  "lifeStoryChapter.progress": "Rozdział %1$lld z %2$lld · %3$@"
}
```

### After all patches are applied

**Step 4 — Validate the candidate prompt bank**

```bash
python3 scripts/localization/validate_polish_candidate.py \
    --candidate Connections/Data/prompts_pl.json
```

Checks a translated prompt bank against the English source.
Exits non-zero if any check fails. Run this before committing.
Accepts `--locale` to validate non-Polish files (default: `pl`).

### For human review

**Step 5 — Generate Markdown review packets**

```bash
python3 scripts/localization/generate_polish_review_packets.py \
    --output /tmp/polish_review_packets
```

Generates Markdown files with English/translated comparison tables,
organized by sensitive group. Reviewers return corrections as patch JSON
(see `docs/localization/polish-review-workflow.md`).

---

## Script Reference

| Script | Purpose | Key flags |
|---|---|---|
| `extract_polish_batches.py` | Split English prompts into agent batches | `--source`, `--output`, `--dry-run` |
| `apply_polish_patch.py` | Apply patch JSON to a translated prompt bank | `--source`, `--target`, `--patch`, `--dry-run` |
| `merge_xcstrings_locale.py` | Merge UI translations into Localizable.xcstrings | `--catalog`, `--locale`, `--translations`, `--dry-run` |
| `validate_polish_candidate.py` | Validate a translated prompt bank against English | `--source`, `--candidate`, `--locale`, `--verbose` |
| `generate_polish_review_packets.py` | Generate Markdown review tables | `--source-en`, `--source-pl`, `--output` |

All scripts accept `--help` for full usage.

---

## Where files go

| Artifact | Location |
|---|---|
| Agent batch files | `/tmp/polish_batches/` (not committed) |
| Review packets | `/tmp/polish_review_packets/` (not committed) |
| Polish prompts | `Connections/Data/prompts_pl.json` (committed when ready) |
| Spanish prompts | `Connections/Data/prompts_es.json` (committed) |
| UI strings | `Connections/Localizable.xcstrings` (committed) |

---

## Tone/Context Groups (extract script)

Prompts are assigned to exactly one group. Rules are checked in order;
first match wins. All 598 English prompts must be assigned.

| Group | Rule | Count |
|---|---|---|
| `sex_unfiltered` | topic = sex | 41 |
| `couples_intimacy` | mode = couples AND topic = intimacy | 13 |
| `family_intergenerational` | mode = family | 132 |
| `friends_playful_closeness` | mode = friends | 122 |
| `solo_reflection` | mode = soloReflection | 145 |
| `communication_conflict` | topic in {communication, conflict} | 38 |
| `connection_appreciation` | topic in {appreciation, emotions} | 42 |
| `identity_values_growth` | topic in {identity, values, growth} | 21 |
| `past_family_memory` | topic in {past, parenting} | 25 |
| `light_warmup_everyday` | intensity = light AND depth = warmUp | 12 |
| `hardship_grief_regret` | catch-all (couples/dailyLife deeper levels) | 7 |
| **Total** | | **598** |

---

## Notes

- `apply_polish_patch.py` is the only script that creates `prompts_pl.json` from scratch.
- `merge_xcstrings_locale.py` never creates new xcstrings keys — it only adds locale entries to existing keys.
- `validate_polish_candidate.py` works for any locale via `--locale`; defaults to `pl`.
- All other locale JSON banks (`fall_in_love_pl.json`, `life_story_pl.json`, etc.) are handled separately and are not covered by `apply_polish_patch.py`.
- The Xcode build does not depend on these scripts.
