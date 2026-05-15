# Agent Translation Workflow

## Purpose

This document defines the end-to-end process for translating Connections prompt banks using parallel Claude agents. It applies to every language. Language-specific rules (register, gender policy, glossary) live in the language's own brief document; this document covers the mechanics of batching, prompting, reviewing, applying, validating, and reporting.

For quality-hardening after a language is already translated, use `docs/localization/post-translation-audit-guide.md`. That guide defines the audit-agent role, output format, risk-category checks, language checklist matrix, and back-translation sampling process.

---

## What Gets Translated

Each language has four banks:

| File | Key | Records | Follow-ups? |
|---|---|---|---|
| `prompts_XX.json` | `prompts` | ~598 prompts | Yes — each prompt has 2 follow-ups |
| `fall_in_love_XX.json` | `prompts` | 36 prompts | No |
| `share_experience_XX.json` | `experiences` | 21 experiences | No |
| `life_story_XX.json` | `prompts` | 50 prompts | Yes — each prompt has `followUp1` and `followUp2` |

All files live in `Connections/Connections/Data/`.

The English source files (`prompts_en.json`, `fall_in_love_en.json`, etc.) are the authoritative source of record. Always translate from English. Never translate from another locale.

---

## File Formats

### prompts_XX.json

```json
{
  "schemaVersion": 1,
  "language": "XX",
  "prompts": [
    {
      "id": "p_couples_light_warmUp_dailyLife_001",
      "text": "Translated prompt text",
      "mode": "couples",
      "intensity": "light",
      "depth": "warmUp",
      "topic": "dailyLife",
      "followUps": [
        { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Translated follow-up 1" },
        { "id": "p_couples_light_warmUp_dailyLife_001_fu_2", "text": "Translated follow-up 2" }
      ]
    }
  ]
}
```

### fall_in_love_XX.json

```json
{
  "schemaVersion": 1,
  "language": "XX",
  "prompts": [
    { "id": "fil_01", "text": "Translated text", "intensity": "honest", "depth": "warmUp", "order": 1 }
  ]
}
```

### share_experience_XX.json

```json
{
  "schemaVersion": 1,
  "language": "<locale>",
  "experiences": [
    { "id": "se1", "fullText": "Translated text", "intensity": "light", "topic": "dailyLife" }
  ]
}
```

### life_story_XX.json

```json
{
  "schemaVersion": 1,
  "language": "XX",
  "prompts": [
    {
      "id": "ls_childhood_001",
      "text": "Translated prompt text",
      "chapter": "childhood",
      "order": 1,
      "followUp1": "Translated follow-up 1",
      "followUp2": "Translated follow-up 2"
    }
  ]
}
```

---

## Patch Format (prompts_XX.json)

Corrections to `prompts_XX.json` are delivered as a keyed JSON object. Only include prompts that need changes.

```json
{
  "p_couples_light_warmUp_dailyLife_001": {
    "text": "Corrected translated prompt text",
    "followUps": [
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Corrected follow-up 1" },
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_2", "text": "Corrected follow-up 2" }
    ]
  }
}
```

### Patch rules

| Rule | Detail |
|---|---|
| Key must match a real prompt ID | Unknown keys are rejected by the apply script |
| Follow-up IDs must match exactly | Do not renumber, add, or remove follow-ups |
| `followUps` is optional | Omit if only the main text needs correction; include only the follow-ups that need correction |
| Never include metadata | Do not include `mode`, `intensity`, `depth`, `topic`, `order`, `chapter`, or any non-text field |
| Never include `style` | The `style` field on each follow-up (`"origin"` or `"impact"`) is metadata, not translatable text. Omit it from patches. The apply script preserves the English source `style` values automatically. Reviewers must not include or edit `style`. |
| No empty `text` values | Whitespace-only strings fail automated tests |

---

## Agent Split Strategy

### prompts_XX.json (~598 prompts)

Split by topic, mode, or alphabet as needed to keep each agent's batch under ~120 prompts. Typical split for a 598-prompt bank:

- **5 agents (A–E):** ~120 prompts each, or split at natural topic/mode boundaries
- **10 agents (A–J):** ~60 prompts each — useful for higher quality control or sensitive topic isolation

For a Wave approach (where a pilot batch was already done):
- Wave 1: Translate the remaining untranslated prompts, minus any planned deferred batches
- Wave 2: Translate the deferred batches (e.g., sex topic, past topic)

### Guided banks (fall_in_love, share_experience, life_story)

- **fall_in_love** (36 prompts): 1 agent
- **share_experience** (21 experiences): 1 agent
- **life_story** (50 prompts): 2 agents — split at ~25 each, at a chapter boundary

---

## What to Give Each Agent

Each agent prompt must include:

1. **Language brief** — register, gender policy, key rules from the language brief doc
2. **Assigned batch** — exact IDs or a range, plus the English source text for each item
3. **Output format** — the exact JSON structure to produce (patch format for prompts; full array for guided banks)
4. **Hard constraints:**
   - Translate only the assigned IDs — nothing outside the batch
   - Preserve every ID exactly
   - Translate every follow-up attached to each prompt (use the English follow-up attached to the same ID, not a nearby one)
   - Do not translate metadata fields
   - Do not write to project files directly
   - Do not create the final `_XX.json` file — produce the patch or array only
   - Output raw JSON, no commentary

5. **Sensitive content guidance** if the batch includes sex, hardship, grief, or unfiltered prompts

The agent brief should also embed the EN source text for each item in the batch so the agent does not need to read project files.

---

## Coordinator Review (Before Applying Anything)

After all agents complete, run these checks before writing a single file to disk:

### Always check

1. **ID fidelity** — every key/id in the output matches a real ID in the assigned English source. Zero missing, zero extra, zero duplicates.
2. **Follow-up fidelity** — each follow-up translates the exact English follow-up at the same array position / with the same ID. Not a nearby one. Not an invented one.
3. **Language-specific scan** — run the checks defined in the language brief (e.g., gender pronouns, formal register, slash notation, semantic drift)
4. **English leftovers** — no translated text is still in English, except approved brand terms
5. **Brand terms** — Deeper Conversations, Life Story, Fall in Love, Share an Experience are in English
6. **Ellipsis preservation** — every prompt that ends with `…` in English still ends with `…` in the translation and remains a fragment

### Also check (spot-check at minimum)

7. **Semantic accuracy** — re-read the 5 most emotionally intense prompts per batch against English; check nothing was softened into vagueness or inverted in meaning
8. **Tone consistency** — light prompts stayed accessible; unfiltered prompts kept their directness
9. **Sensitive topics** — sex, hardship, grief, and Life Story legacy prompts reviewed against the language brief's guidance

### Simplified Chinese only

10. **Traditional character leakage scan** — before applying any Simplified Chinese patch, check output for high-frequency Traditional-only characters. Common tells: `說`, `個`, `時`, `發`, `來`, `國`, `學`, `開`, `問`. A basic text search is sufficient; the goal is catching obvious agent-side script confusion before it reaches the file.

---

## Correction Report Format

For every correction applied, record before and after in this format:

```
**Agent X — [short description of issue]:**
- Before: `"[original translated text]"`
- After: `"[corrected text]"`
```

Collect all corrections in the session report, grouped by agent. Report zero corrections explicitly if a batch was clean.

---

## Dry-Run / Apply / Validate Flow

### 1. Dry-run (verify counts)

Before writing anything, run a Python count check:

```python
import json

# Load English source
with open("Connections/Data/prompts_en.json") as f:
    en = json.load(f)
en_ids = {p["id"] for p in en["prompts"]}

# Load patch
with open("/tmp/wave_X_patch.json") as f:
    patch = json.load(f)

missing = [pid for pid in patch if pid not in en_ids]
print(f"Patch size: {len(patch)}")
print(f"Missing IDs: {missing}")
```

### 2. Apply

Use a Python apply script. Template:

```python
import json, sys

BASE_PATH = "Connections/Connections/Data/prompts_XX.json"
PATCH_FILES = ["/tmp/wave_1_patch.json"]  # list all patch files

with open(BASE_PATH, "r", encoding="utf-8") as f:
    base = json.load(f)

patch_map = {}
for path in PATCH_FILES:
    with open(path, "r", encoding="utf-8") as f:
        patch = json.load(f)
    for pid, pdata in patch.items():
        if pid in patch_map:
            print(f"WARNING: duplicate patch ID {pid}", file=sys.stderr)
        patch_map[pid] = pdata

patched_count = 0
for prompt in base["prompts"]:
    pid = prompt["id"]
    if pid not in patch_map:
        continue
    pdata = patch_map[pid]
    prompt["text"] = pdata["text"]
    if "followUps" in pdata:
        patch_fus = {fu["id"]: fu["text"] for fu in pdata["followUps"]}
        for fu in prompt["followUps"]:
            if fu["id"] in patch_fus:
                fu["text"] = patch_fus[fu["id"]]
            else:
                print(f"WARNING: follow-up {fu['id']} not in patch", file=sys.stderr)
    patched_count += 1

print(f"Patched: {patched_count} prompts")
print(f"Total prompts in file: {len(base['prompts'])}")

with open(BASE_PATH, "w", encoding="utf-8") as f:
    json.dump(base, f, ensure_ascii=False, indent=2)
    f.write("\n")

print("Done.")
```

### 3. Validate

```bash
python3 scripts/localization/validate_polish_candidate.py \
  --locale XX \
  --candidate Connections/Connections/Data/prompts_XX.json
```

Expected output when all prompts are translated:
```
Validation passed — 598 prompts OK.
```

Expected output when some prompts are still English (pre-translation or deferred batch):
```
276 prompts still appear to be in English — [IDs listed]
```

This is not a failure during a Wave approach; it means those prompts are deferred and will be handled in a later wave.

---

## Guided Banks: Apply Directly (No Patch Script Needed)

Guided bank files (`fall_in_love_XX.json`, `share_experience_XX.json`, `life_story_XX.json`) are written directly from agent output. There is no incremental patching — the agent produces the full translated array, and the coordinator writes the complete file with corrections applied.

Steps:
1. Receive agent output (translated array)
2. Apply coordinator corrections directly to the in-memory content
3. Write the final `_XX.json` file to `Connections/Connections/Data/`
4. Run localization tests to verify: `DutchLocalizationTests` (or the equivalent for the locale)

---

## Running Localization Tests

After applying all banks for a locale:

```
RunSomeTests: [locale]LocalizationTests
```

Expected result when all banks are complete but xcstrings UI strings are not yet added:
- All JSON bank tests pass
- xcstrings tests skip (not fail) — this is correct behavior

A skipped xcstrings test means the bank files are ready but UI strings haven't been added yet. A failed test means something is wrong with the bank files.

---

## "Do Not Commit Until John Reviews" Policy

**Never commit localization work in the same session it was produced.**

After completing a translation wave:
1. Deliver the coordinator report (counts, corrections, test results, representative examples)
2. Stop
3. Wait for John to review the report and approve before committing

This policy applies to every wave, every language, every guided bank update.

**Exception:** If John has explicitly authorized autonomous end-to-end execution for the current session (including commit and push), proceed without a review gate. Authorization for one session does not carry over to future sessions — the default is always no commit without review.

---

## Session Deliverable Format

At the end of every translation session, deliver a report with:

1. **Files created or modified** — list with path, record count, and what changed
2. **Coordinator corrections** — every before/after correction applied, grouped by agent. "0 corrections" if clean.
3. **Gender/register scan result** — pass or list of issues found
4. **Test results** — passed / failed / skipped counts and which tests skipped (with reason)
5. **Build result** — succeeded or errors
6. **Representative examples** — 6–8 EN → [locale] side-by-side samples, including at least one from each bank and one from a sensitive topic
7. **Unresolved concerns** — any wording that was borderline or worth a second human eye

---

## Localization Test Infrastructure

Each locale has a `[Language]LocalizationTests.swift` test class at `Tests/ConnectionsTests/`. Tests are modeled on `PolishLocalizationTests.swift`.

Key test categories:
- **JSON bank loading** — verifies `JSONBankLoader` resolves the locale file (not English fallback)
- **Count parity** — translated bank has same number of records as English
- **ID parity** — translated bank has exactly the same IDs as English
- **Metadata parity** — `intensity`, `depth`, `order`, `chapter`, `topic` match English
- **Non-empty fields** — no empty `text`, `fullText`, `followUp1`, `followUp2`
- **Follow-up parity** (prompts) — same number of follow-ups per prompt as English
- **Translation regression** — translated text differs from English (catches untranslated entries)
- **Schema version** — `schemaVersion: 1` in all files
- **Language field** — `language: "XX"` in all files
- **xcstrings tests** — skipped until UI strings are added; will activate automatically once Dutch appears in `Localizable.xcstrings`

New locale test class checklist:
1. Copy `PolishLocalizationTests.swift`
2. Replace `pl` with the new locale code throughout
3. Replace `Polish` with the new language name in method names and strings
4. File path: `Tests/ConnectionsTests/[Language]LocalizationTests.swift`
5. The folder reference in the Xcode project picks up new files automatically — no manual project.pbxproj edit needed
6. Run `xcodebuild build-for-testing` after adding the file to register the new tests with the test runner

---

## Language Brief Locations

| Language | Brief |
|---|---|
| Dutch (`nl`) | `docs/localization/dutch-brief.md` |
| Polish (`pl`) | `docs/localization/polish-brief.md` |
| French (`fr`) | `docs/fr-translation-brief.md` |
| Japanese (`ja`) | `docs/localization/japanese-brief.md` |
| Simplified Chinese (`zh-Hans`) | `docs/localization/simplified-chinese-brief.md` |
| Italian (`it`) | `docs/localization/italian-brief.md` |
| Swedish (`sv`) | `docs/localization/swedish-brief.md` |
| Danish (`da`) | `docs/localization/danish-brief.md` |
| Norwegian Bokmål (`nb`) | `docs/localization/norwegian-brief.md` |
| Finnish (`fi`) | `docs/localization/finnish-brief.md` |
| Russian (`ru`) | `docs/localization/russian-brief.md` |
| German (`de`) | *(not yet written)* |
| Spanish (`es`) | *(not yet written)* |
| Portuguese BR (`pt-BR`) | *(not yet written)* |
