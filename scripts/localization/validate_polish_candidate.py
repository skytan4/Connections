#!/usr/bin/env python3
"""
validate_polish_candidate.py

Validate a translated prompt bank (e.g. prompts_pl.json, prompts_es.json)
against the English source. Exits non-zero if any check fails.

Checks:
  - schemaVersion == 1
  - language field matches --locale (default: "pl")
  - prompt count matches English
  - prompt IDs match English in order
  - metadata fields match exactly: mode, intensity, depth, topic
  - follow-up count matches per prompt
  - follow-up IDs and styles match per prompt
  - no empty prompt text
  - no empty follow-up text
  - no translated prompt/follow-up text is identical to English
    (allowlist: brand terms that must stay in English)

Usage:
  python3 scripts/localization/validate_polish_candidate.py \\
      --candidate Connections/Data/prompts_pl.json

  python3 scripts/localization/validate_polish_candidate.py \\
      --source    Connections/Data/prompts_en.json \\
      --candidate Connections/Data/prompts_es.json \\
      --locale    es \\
      --verbose
"""

import argparse
import json
import os
import sys

# Strings that are legitimately identical between English and any locale
# (brand terms kept in English per localization briefs).
# Only exact matches are allowed. A sentence that merely *contains* a brand
# term is NOT allowlisted — it must still be translated.
ENGLISH_ALLOWLIST = {
    "Life Story",
    "Fall in Love",
    "Share an Experience",
    "Deeper Conversations",
}

METADATA_FIELDS = ("mode", "intensity", "depth", "topic")


def load_json(path: str) -> dict:
    if not os.path.exists(path):
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def is_allowlisted(text: str) -> bool:
    """Return True only if text is exactly a protected brand term (after stripping whitespace)."""
    return text.strip() in ENGLISH_ALLOWLIST


def validate(en_data: dict, loc_data: dict, locale: str, verbose: bool) -> list[str]:
    errors: list[str] = []

    def err(msg: str) -> None:
        errors.append(msg)
        if verbose:
            print(f"  FAIL  {msg}")

    def ok(msg: str) -> None:
        if verbose:
            print(f"  pass  {msg}")

    # --- Top-level metadata ---
    if loc_data.get("schemaVersion") != 1:
        err(f"schemaVersion is {loc_data.get('schemaVersion')!r}, expected 1")
    else:
        ok("schemaVersion == 1")

    if loc_data.get("language") != locale:
        err(f"language is {loc_data.get('language')!r}, expected {locale!r}")
    else:
        ok(f"language == {locale!r}")

    en_prompts = en_data.get("prompts", [])
    loc_prompts = loc_data.get("prompts", [])

    # --- Count ---
    if len(loc_prompts) != len(en_prompts):
        err(f"prompt count: expected {len(en_prompts)}, got {len(loc_prompts)}")
        # Can't do per-prompt checks reliably if counts differ
        return errors
    else:
        ok(f"prompt count == {len(en_prompts)}")

    # --- Per-prompt checks ---
    for i, (en_p, loc_p) in enumerate(zip(en_prompts, loc_prompts)):
        pid = en_p.get("id", f"index_{i}")

        # ID order
        if loc_p.get("id") != pid:
            err(f"[{i}] id mismatch: expected '{pid}', got '{loc_p.get('id')}'")
            continue   # skip deeper checks for mismatched entry

        # Metadata parity
        for field in METADATA_FIELDS:
            if loc_p.get(field) != en_p.get(field):
                err(f"{pid}: {field} mismatch: en={en_p.get(field)!r} {locale}={loc_p.get(field)!r}")

        # Non-empty text
        loc_text = loc_p.get("text", "")
        if not loc_text or not loc_text.strip():
            err(f"{pid}: prompt text is empty")
        else:
            en_text = en_p.get("text", "")
            if loc_text == en_text and not is_allowlisted(loc_text):
                err(f"{pid}: prompt text is still English (not translated)")

        # Follow-ups
        en_fus = en_p.get("followUps", [])
        loc_fus = loc_p.get("followUps", [])

        if len(loc_fus) != len(en_fus):
            err(f"{pid}: follow-up count: expected {len(en_fus)}, got {len(loc_fus)}")
            continue

        for j, (en_fu, loc_fu) in enumerate(zip(en_fus, loc_fus)):
            fu_id = en_fu.get("id", f"{pid}_fu_{j}")

            if loc_fu.get("id") != fu_id:
                err(f"{pid}: follow-up[{j}] id mismatch: expected '{fu_id}', got '{loc_fu.get('id')}'")
                continue

            if loc_fu.get("style") != en_fu.get("style"):
                err(
                    f"{pid} / {fu_id}: style mismatch: "
                    f"en={en_fu.get('style')!r} {locale}={loc_fu.get('style')!r}"
                )

            loc_fu_text = loc_fu.get("text", "")
            if not loc_fu_text or not loc_fu_text.strip():
                err(f"{pid} / {fu_id}: follow-up text is empty")
            else:
                en_fu_text = en_fu.get("text", "")
                if loc_fu_text == en_fu_text and not is_allowlisted(loc_fu_text):
                    err(f"{pid} / {fu_id}: follow-up text is still English (not translated)")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate a translated prompt bank against the English source."
    )
    parser.add_argument(
        "--source",
        default="Connections/Data/prompts_en.json",
        help="English source file (default: Connections/Data/prompts_en.json)",
    )
    parser.add_argument(
        "--candidate",
        default="Connections/Data/prompts_pl.json",
        help="Translated candidate file to validate (default: Connections/Data/prompts_pl.json)",
    )
    parser.add_argument(
        "--locale",
        default="pl",
        help='Expected value of the "language" field in the candidate file (default: pl)',
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print each check result (pass/fail) as it runs",
    )
    args = parser.parse_args()

    en_data = load_json(args.source)
    loc_data = load_json(args.candidate)

    if args.verbose:
        print(f"\nValidating: {args.candidate}")
        print(f"Against:    {args.source}")
        print(f"Locale:     {args.locale}\n")

    errors = validate(en_data, loc_data, locale=args.locale, verbose=args.verbose)

    if errors:
        print(f"\n{len(errors)} error(s) found:")
        for e in errors:
            print(f"  {e}")
        print("\nValidation FAILED.")
        return 1

    count = len(en_data.get("prompts", []))
    print(f"\nValidation passed — {count} prompts OK.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
