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

### After a locale is complete

**Step 6 — Scan for known bad patterns**

```bash
python3 scripts/localization/scan_localization_patterns.py --locale nl
python3 scripts/localization/scan_localization_patterns.py --locale zh-Hans --fail-on-findings
```

Scans localized JSON banks, `Localizable.xcstrings`, and the locale privacy page
for language-specific red flags such as formal address, gendered pronoun pairs,
Traditional Chinese leakage, slash-gender forms, and Russian masculine fallback
candidates. Findings are audit leads, not automatic proof of an error.

**Step 7 — Choose the lightest safe QA path**

Do not automatically launch a full audit. First decide which path fits:

| Situation | Recommended path |
|---|---|
| Scanner findings are already classified and fixes are known | Direct coordinator patching |
| Scanner findings are narrow but unclassified | One focused patching agent |
| One category has systemic risk | One targeted rewrite/cleanup agent |
| Broad semantic/tone/fidelity quality is unknown | Full 5-job audit |

For direct patching or focused patching agents, use scanner output plus English
source text and keep the task limited to the affected fields. Batch edits instead
of applying repeated one-line writes to large JSON or xcstrings files.

Avoid permission-stalling ad-hoc commands during long runs:

- Do not use `python3 -c "..."`
- Do not use Python heredocs such as `python3 - <<'PY'`
- Prefer existing scripts under `scripts/localization/`
- If a special edit is needed, write one named helper script under `/tmp` and run it

**Step 8 — Generate post-translation audit packets when a full audit is warranted**

```bash
python3 scripts/localization/generate_audit_packet.py \
    --locale it \
    --scope high_risk \
    --output /tmp/it_high_risk_audit
```

Writes Markdown packets that align English source text with the localized target
text and include blank `status` / `notes` columns for review agents. Supported
scopes include `all`, `prompts`, `guided`, `sensitive`, `high_risk`, and `ui`.

**Step 9 — Inspect a locale without ad-hoc inline Python**

```bash
python3 scripts/localization/inspect_locale.py --locale ru --include-scanner
python3 scripts/localization/inspect_locale.py --locale zh-Hans --json
```

Summarizes all localized JSON banks, English-identical text counts, follow-up
parity, `Localizable.xcstrings` coverage, placeholder parity, privacy-page
presence, and optional scanner findings. This is read-only and exists to avoid
permission-stalling `python3 -c` snippets during long autonomous runs.

---

## Script Reference

| Script | Purpose | Key flags |
|---|---|---|
| `extract_polish_batches.py` | Split English prompts into agent batches | `--source`, `--output`, `--dry-run` |
| `apply_polish_patch.py` | Apply patch JSON to a translated prompt bank | `--source`, `--target`, `--patch`, `--dry-run` |
| `merge_xcstrings_locale.py` | Merge UI translations into Localizable.xcstrings | `--catalog`, `--locale`, `--translations`, `--dry-run` |
| `validate_polish_candidate.py` | Validate a translated prompt bank against English | `--source`, `--candidate`, `--locale`, `--verbose` |
| `generate_polish_review_packets.py` | Generate Markdown review tables | `--source-en`, `--source-pl`, `--output` |
| `scan_localization_patterns.py` | Scan complete locales for language-specific red-flag patterns | `--locale`, `--path`, `--json`, `--fail-on-findings` |
| `generate_audit_packet.py` | Generate English-vs-localized Markdown audit packets for review agents | `--locale`, `--scope`, `--output` |
| `inspect_locale.py` | Read-only locale summary across JSON banks, xcstrings, privacy, and optional scanner | `--locale`, `--json`, `--include-scanner`, `--fail-on-issues` |

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
