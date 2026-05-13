# scripts/localization — Polish Localization Tooling

Scripts to support the Polish (`pl`) localization of Deeper Conversations.
These scripts do **not** perform translation. They prepare batches for
translation agents, apply human corrections, validate candidates, and
generate reviewer packets.

---

## Intended Order

### Before translation agents run

**Step 1 — Extract batch files for translation agents**

```bash
python3 scripts/localization/extract_polish_batches.py
```

Reads `Connections/Data/prompts_en.json` and writes one JSON batch file per
tone/context group to `/tmp/polish_batches/`. No Polish file is created.

Each batch file contains:
- `group` — group name
- `tone_note` — guidance for the translation agent
- `brief_ref` — path to the Polish localization brief
- `count` — number of prompts in this batch
- `prompts` — array of prompts with id, mode, intensity, depth, topic, text, followUps

### After translation agents produce corrections

**Step 2 — Apply patch corrections**

```bash
python3 scripts/localization/apply_polish_patch.py \
    --patch /tmp/my_agent_output.json
```

Applies explicit patch JSON to `Connections/Data/prompts_pl.json`.
If the Polish file does not exist, it is **created** from the English
structure (language set to `pl`) before the patch is applied.

The patch file format is:
```json
{
  "p_couples_light_warmUp_dailyLife_001": {
    "text": "Polish prompt text here…",
    "followUps": [
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Follow-up text" }
    ]
  }
}
```

Corrections are applied by id, not by array position. Metadata fields
(mode, intensity, depth, topic, style, order) are rejected.

### After all patches are applied

**Step 3 — Validate the candidate file**

```bash
python3 scripts/localization/validate_polish_candidate.py
```

Checks `Connections/Data/prompts_pl.json` against the English source.
Exits non-zero if any check fails. Run this before committing.

### For human review

**Step 4 — Generate Markdown review packets**

```bash
python3 scripts/localization/generate_polish_review_packets.py \
    --output /tmp/polish_review_packets
```

Generates Markdown files with English/Polish comparison tables,
organized by sensitive group. Reviewers return corrections as patch JSON
(see `docs/localization/polish-review-workflow.md`).

---

## Script Reference

| Script | Purpose |
|---|---|
| `extract_polish_batches.py` | Split English prompts into agent batches |
| `apply_polish_patch.py` | Apply patch JSON to prompts_pl.json |
| `validate_polish_candidate.py` | Validate prompts_pl.json against English |
| `generate_polish_review_packets.py` | Generate Markdown review tables |

All scripts accept `--help` for full usage.

---

## Where files go

| Artifact | Location |
|---|---|
| Agent batch files | `/tmp/polish_batches/` (not committed) |
| Review packets | `/tmp/polish_review_packets/` (not committed) |
| Polish prompts file | `Connections/Data/prompts_pl.json` (committed when ready) |

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

- These scripts do not alter Spanish translation files.
- `apply_polish_patch.py` is the only script that creates `prompts_pl.json`.
- All other Polish JSON banks (`fall_in_love_pl.json`, etc.) are handled
  separately and are not covered by these scripts.
- The Xcode build does not depend on these scripts.
