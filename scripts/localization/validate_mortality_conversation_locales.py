#!/usr/bin/env python3
"""Validate localized Mortality Conversations JSON banks against English."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = ROOT / "Connections" / "Data"
DEFAULT_LOCALES = (
    "da",
    "de",
    "es",
    "fi",
    "fr",
    "it",
    "ja",
    "nb",
    "nl",
    "pl",
    "pt-BR",
    "ru",
    "sv",
    "zh-Hans",
)


def load(locale: str) -> dict[str, Any]:
    path = DATA_DIR / f"mortality_conversations_{locale}.json"
    if not path.exists():
        raise AssertionError(f"{path.relative_to(ROOT)} is missing")
    return json.loads(path.read_text(encoding="utf-8"))


def validate_locale(locale: str, english: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    try:
        localized = load(locale)
    except Exception as exc:
        return [str(exc)]

    if localized.get("schemaVersion") != english.get("schemaVersion"):
        errors.append("schemaVersion does not match English")
    if localized.get("language") != locale:
        errors.append(f"language must be {locale!r}, got {localized.get('language')!r}")

    en_prompts = english.get("prompts") or []
    loc_prompts = localized.get("prompts") or []
    if len(loc_prompts) != len(en_prompts):
        errors.append(f"prompt count mismatch: expected {len(en_prompts)}, got {len(loc_prompts)}")
        return errors

    seen_ids: set[str] = set()
    for index, (en_prompt, loc_prompt) in enumerate(zip(en_prompts, loc_prompts), start=1):
        prompt_id = en_prompt.get("id", f"index {index}")
        if loc_prompt.get("id") != en_prompt.get("id"):
            errors.append(f"{prompt_id}: id mismatch at index {index}")
        if loc_prompt.get("topic") != en_prompt.get("topic"):
            errors.append(f"{prompt_id}: topic mismatch")
        if loc_prompt.get("order") != en_prompt.get("order"):
            errors.append(f"{prompt_id}: order mismatch")
        text = str(loc_prompt.get("text", "")).strip()
        if not text:
            errors.append(f"{prompt_id}: empty translated text")
        if locale != "en" and text == str(en_prompt.get("text", "")).strip():
            errors.append(f"{prompt_id}: text is still English")
        if loc_prompt.get("id") in seen_ids:
            errors.append(f"{prompt_id}: duplicate id")
        seen_ids.add(loc_prompt.get("id", ""))

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--locale", action="append", help="Locale to validate; may be repeated")
    args = parser.parse_args()

    english = load("en")
    locales = tuple(args.locale) if args.locale else DEFAULT_LOCALES
    failures: dict[str, list[str]] = {}
    for locale in locales:
        errors = validate_locale(locale, english)
        if errors:
            failures[locale] = errors
        else:
            print(f"ok {locale}")

    if failures:
        for locale, errors in failures.items():
            print(f"\n{locale}:")
            for error in errors:
                print(f"  - {error}")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
