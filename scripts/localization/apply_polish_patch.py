#!/usr/bin/env python3
"""
apply_polish_patch.py

Apply an explicit patch JSON to prompts_pl.json. If the target Polish file
does not exist, it is created by copying the English structure with language
set to "pl" (text fields are preserved as-is from English until translated).

Patch format:
  {
    "p_couples_light_warmUp_dailyLife_001": {
      "text": "Poprawiony tekst promptu…",
      "followUps": [
        { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Poprawiony follow-up" }
      ]
    }
  }

Rules:
  - Prompt id must exist in the target file.
  - Follow-up corrections are applied by id, not by array position.
  - Follow-up id must exist in the target prompt.
  - Empty or whitespace-only text is rejected.
  - Metadata fields (mode, intensity, depth, topic, style, order) are never accepted.
  - A patch entry must contain "text", "followUps", or both — empty objects are rejected.
  - A patch file must apply at least one correction — zero-correction runs are rejected.

Usage:
  python3 scripts/localization/apply_polish_patch.py \\
      --patch /tmp/my_batch_corrections.json

  python3 scripts/localization/apply_polish_patch.py \\
      --source Connections/Data/prompts_en.json \\
      --target Connections/Data/prompts_pl.json \\
      --patch /tmp/my_batch_corrections.json \\
      --dry-run
"""

import argparse
import copy
import json
import os
import sys

METADATA_FIELDS = {"mode", "intensity", "depth", "topic", "style", "order",
                   "id", "schemaVersion", "language"}


def load_json(path: str) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_json(path: str, data: dict) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def create_polish_from_english(en_data: dict) -> dict:
    """Copy English structure and set language to pl."""
    pl = copy.deepcopy(en_data)
    pl["language"] = "pl"
    return pl


def apply_patch(target: dict, patch: dict, dry_run: bool = False) -> tuple[int, list[str]]:
    """
    Apply patch entries to target in-place.

    Returns (applied_count, warnings_list). Raises SystemExit on fatal errors.
    """
    # Build prompt index by id
    prompt_index: dict[str, dict] = {}
    for p in target.get("prompts", []):
        prompt_index[p["id"]] = p

    errors: list[str] = []
    warnings: list[str] = []
    applied = 0

    for prompt_id, corrections in patch.items():
        # --- Validate prompt id ---
        if prompt_id not in prompt_index:
            errors.append(f"UNKNOWN prompt id: {prompt_id}")
            continue

        # --- Reject metadata fields in patch ---
        bad_fields = METADATA_FIELDS & set(corrections.keys())
        if bad_fields:
            errors.append(
                f"{prompt_id}: patch must not include metadata fields: {sorted(bad_fields)}"
            )
            continue

        # --- Reject no-op entries ---
        if "text" not in corrections and "followUps" not in corrections:
            errors.append(
                f"{prompt_id}: patch entry contains neither 'text' nor 'followUps' — no-op entries are not allowed"
            )
            continue

        prompt = prompt_index[prompt_id]

        # --- Apply prompt text ---
        if "text" in corrections:
            new_text = corrections["text"]
            if not isinstance(new_text, str) or not new_text.strip():
                errors.append(f"{prompt_id}: 'text' is empty or whitespace")
                continue
            if not dry_run:
                prompt["text"] = new_text
            applied += 1

        # --- Apply follow-up corrections ---
        if "followUps" in corrections:
            fu_index: dict[str, dict] = {fu["id"]: fu for fu in prompt.get("followUps", [])}
            fu_corrections = corrections["followUps"]

            if not isinstance(fu_corrections, list):
                errors.append(f"{prompt_id}: 'followUps' must be a list")
                continue

            for fu_patch in fu_corrections:
                if not isinstance(fu_patch, dict):
                    errors.append(f"{prompt_id}: follow-up entry must be an object")
                    continue

                fu_id = fu_patch.get("id")
                if not fu_id:
                    errors.append(f"{prompt_id}: follow-up patch is missing 'id'")
                    continue

                if fu_id not in fu_index:
                    errors.append(f"{prompt_id}: UNKNOWN follow-up id: {fu_id}")
                    continue

                fu_text = fu_patch.get("text")
                if fu_text is None:
                    warnings.append(f"{prompt_id} / {fu_id}: no 'text' in follow-up patch — skipped")
                    continue

                if not isinstance(fu_text, str) or not fu_text.strip():
                    errors.append(f"{prompt_id} / {fu_id}: follow-up 'text' is empty or whitespace")
                    continue

                # Reject metadata in follow-up patch
                bad_fu_fields = METADATA_FIELDS & set(fu_patch.keys()) - {"id"}
                if bad_fu_fields:
                    errors.append(
                        f"{prompt_id} / {fu_id}: follow-up patch must not include "
                        f"metadata fields: {sorted(bad_fu_fields)}"
                    )
                    continue

                if not dry_run:
                    fu_index[fu_id]["text"] = fu_text
                applied += 1

    if errors:
        print("\nERRORS (patch not fully applied):", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)
        sys.exit(1)

    return applied, warnings


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Apply explicit patch JSON corrections to prompts_pl.json."
    )
    parser.add_argument(
        "--source",
        default="Connections/Data/prompts_en.json",
        help="English source file (used to create target if it does not exist)",
    )
    parser.add_argument(
        "--target",
        default="Connections/Data/prompts_pl.json",
        help="Polish target file to patch (created from source if absent)",
    )
    parser.add_argument(
        "--patch",
        required=True,
        help="Path to patch JSON file",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate and report without writing the target file",
    )
    args = parser.parse_args()

    # Load patch
    if not os.path.exists(args.patch):
        print(f"ERROR: patch file not found: {args.patch}", file=sys.stderr)
        return 1

    with open(args.patch, encoding="utf-8") as f:
        patch = json.load(f)

    if not isinstance(patch, dict):
        print("ERROR: patch file must be a JSON object keyed by prompt id", file=sys.stderr)
        return 1

    if not patch:
        print("ERROR: patch file is empty — nothing to apply", file=sys.stderr)
        return 1

    # Load or create target
    if os.path.exists(args.target):
        target = load_json(args.target)
        print(f"Loaded target: {args.target}")
    else:
        if not os.path.exists(args.source):
            print(f"ERROR: source file not found: {args.source}", file=sys.stderr)
            return 1
        source = load_json(args.source)
        target = create_polish_from_english(source)
        print(f"Target {args.target} does not exist — created from English source.")

    # Apply
    applied, warnings = apply_patch(target, patch, dry_run=args.dry_run)

    for w in warnings:
        print(f"WARNING: {w}")

    if applied == 0:
        print(
            "ERROR: patch applied 0 corrections — ensure entries contain valid 'text' or 'followUps'.",
            file=sys.stderr,
        )
        return 1

    if args.dry_run:
        print(f"\nDry run — {applied} correction(s) validated. No file written.")
        return 0

    save_json(args.target, target)
    print(f"\nApplied {applied} correction(s). Saved: {args.target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
