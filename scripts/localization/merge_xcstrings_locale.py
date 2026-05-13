#!/usr/bin/env python3
"""
merge_xcstrings_locale.py

Merge a JSON translation map into a Localizable.xcstrings catalog.
For each key in the translations file, inserts a <locale> stringUnit entry
under `localizations` in the catalog.

Safety rules (all enforced):
  - Unknown keys (not in the catalog) → rejected, exit 1.
  - Keys with shouldTranslate: false → skipped with a warning.
  - Empty or whitespace-only values → rejected, exit 1.
  - Format placeholder parity: every specifier found in the English value
    (%@, %1$@, %lld, %1$lld, %d, etc.) must appear the same number of times
    in the translated value. Mismatch → rejected, exit 1.
  - extractionState is never modified.
  - Existing localizations for other locales (en, es, …) are never touched.
  - A run that would write zero keys is rejected.
  - --dry-run validates everything without writing.

Translations file format:
  A JSON object mapping xcstrings key → translated string value.
  {
    "common.button.back":        "Wstecz",
    "lifeStoryChapter.progress": "Rozdział %1$lld z %2$lld · %3$@"
  }

  Keys whose values should stay in English (brand terms, etc.) must still
  appear in the file with their English text — the script does not skip them
  for being identical to English. Omit them from the file to leave them
  untranslated.

Usage:
  python3 scripts/localization/merge_xcstrings_locale.py \\
      --locale pl \\
      --translations /tmp/polish_ui_translations.json

  python3 scripts/localization/merge_xcstrings_locale.py \\
      --catalog Connections/Localizable.xcstrings \\
      --locale es \\
      --translations /tmp/es_ui_corrections.json \\
      --dry-run
"""

import argparse
import json
import os
import re
import sys

DEFAULT_CATALOG = "Connections/Localizable.xcstrings"

# Regex for printf-style format specifiers (iOS / NSString style).
# Captures positional (%1$@) and non-positional (%@, %d, %lld, %f, %ld, %lu).
_SPECIFIER_RE = re.compile(
    r"%(?:\d+\$)?(?:[-+ #0]*\d*(?:\.\d+)?)?(?:hh|h|ll|l|q|z|t|j)?[diouxXeEfFgGcCsSpaAn@]"
)


def extract_specifiers(text: str) -> list[str]:
    """Return all format specifiers found in text (including duplicates)."""
    return _SPECIFIER_RE.findall(text)


def normalize_specifier(spec: str) -> str:
    """Strip positional index from a specifier so %1$@ and %@ compare as the same type."""
    return re.sub(r"^\%\d+\$", "%", spec)


def specifier_multiset(text: str) -> dict[str, int]:
    """Return a count-by-type map of format specifiers in text (position-agnostic)."""
    counts: dict[str, int] = {}
    for s in extract_specifiers(text):
        key = normalize_specifier(s)
        counts[key] = counts.get(key, 0) + 1
    return counts


def load_json(path: str) -> dict:
    if not os.path.exists(path):
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_xcstrings(path: str, data: dict) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


def validate_and_merge(
    catalog: dict,
    translations: dict[str, str],
    locale: str,
    dry_run: bool,
) -> tuple[int, int, int]:
    """
    Validate translations against the catalog and merge them in-place.

    Returns (added_count, updated_count, skipped_count).
    Exits with code 1 on any error.
    """
    strings = catalog.get("strings", {})
    errors: list[str] = []
    warnings: list[str] = []
    added = 0
    updated = 0
    skipped = 0

    for key, value in translations.items():
        # --- Unknown key ---
        if key not in strings:
            errors.append(f"UNKNOWN key: {key!r} — not found in catalog")
            continue

        entry = strings[key]

        # --- shouldTranslate: false ---
        if entry.get("shouldTranslate") is False:
            warnings.append(f"SKIP {key!r} — shouldTranslate is false")
            skipped += 1
            continue

        # --- Empty value ---
        if not isinstance(value, str) or not value.strip():
            errors.append(f"EMPTY value for key: {key!r}")
            continue

        # --- Placeholder parity ---
        en_value = (
            entry.get("localizations", {})
            .get("en", {})
            .get("stringUnit", {})
            .get("value", "")
        )
        en_specs = specifier_multiset(en_value)
        tr_specs = specifier_multiset(value)

        if en_specs != tr_specs:
            errors.append(
                f"PLACEHOLDER MISMATCH for {key!r}:\n"
                f"  English:  {en_value!r}  →  specifiers: {en_specs}\n"
                f"  {locale}:  {value!r}  →  specifiers: {tr_specs}"
            )
            continue

        # --- Merge (track add vs. update) ---
        already_has_locale = locale in entry.get("localizations", {})
        if not dry_run:
            if "localizations" not in entry:
                entry["localizations"] = {}
            entry["localizations"][locale] = {
                "stringUnit": {
                    "state": "translated",
                    "value": value,
                }
            }
        if already_has_locale:
            updated += 1
        else:
            added += 1

    for w in warnings:
        print(f"WARNING: {w}")
    sys.stdout.flush()  # ensure warnings appear before any subsequent stderr output

    if errors:
        print(f"\n{len(errors)} error(s) — no changes written:", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)
        sys.exit(1)

    return added, updated, skipped


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Merge a JSON translation map into a Localizable.xcstrings catalog."
    )
    parser.add_argument(
        "--catalog",
        default=DEFAULT_CATALOG,
        help=f"Path to Localizable.xcstrings (default: {DEFAULT_CATALOG})",
    )
    parser.add_argument(
        "--locale",
        required=True,
        help='Locale code to add, e.g. "pl" or "es"',
    )
    parser.add_argument(
        "--translations",
        required=True,
        help="Path to JSON file mapping xcstrings key → translated string",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate and report without writing the catalog",
    )
    args = parser.parse_args()

    catalog = load_json(args.catalog)
    translations_raw = load_json(args.translations)

    if not isinstance(translations_raw, dict):
        print("ERROR: translations file must be a JSON object (key → string)", file=sys.stderr)
        return 1

    if not translations_raw:
        print("ERROR: translations file is empty — nothing to apply", file=sys.stderr)
        return 1

    # Enforce string values only
    non_string = [k for k, v in translations_raw.items() if not isinstance(v, str)]
    if non_string:
        print(
            f"ERROR: {len(non_string)} translation value(s) are not strings: "
            f"{non_string[:5]}{'…' if len(non_string) > 5 else ''}",
            file=sys.stderr,
        )
        return 1

    translations: dict[str, str] = translations_raw

    print(f"Catalog:      {args.catalog}")
    print(f"Locale:       {args.locale}")
    print(f"Translations: {args.translations} ({len(translations)} keys)")
    if args.dry_run:
        print("Mode:         dry-run (no file will be written)")
    sys.stdout.flush()  # ensure header appears before any error output

    added, updated, skipped = validate_and_merge(catalog, translations, args.locale, args.dry_run)

    if added + updated == 0:
        if skipped:
            print(
                f"ERROR: all {skipped} key(s) skipped (shouldTranslate=false) — nothing to write.",
                file=sys.stderr,
            )
        else:
            print("ERROR: 0 keys would be written — nothing to do.", file=sys.stderr)
        return 1

    if args.dry_run:
        parts = []
        if added:
            parts.append(f"{added} new")
        if updated:
            parts.append(f"{updated} updated")
        if skipped:
            parts.append(f"{skipped} skipped (shouldTranslate=false)")
        print(f"\nDry run complete — {', '.join(parts)}. No file written.")
        return 0

    save_xcstrings(args.catalog, catalog)
    parts = []
    if added:
        parts.append(f"{added} added")
    if updated:
        parts.append(f"{updated} updated")
    if skipped:
        parts.append(f"{skipped} skipped (shouldTranslate=false)")
    print(f"\nDone — {', '.join(parts)}. Wrote: {args.catalog}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
