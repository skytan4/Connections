#!/usr/bin/env python3
"""Inspect a completed locale without ad-hoc inline Python.

This script is intentionally read-only. It summarizes the localized JSON banks,
xcstrings coverage, privacy file presence, and optional scanner findings for a
locale. Use it during long autonomous translation/audit runs instead of
`python3 -c` snippets.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
BANKS = {
    "prompts": ("prompts", "prompts"),
    "fall_in_love": ("prompts", "prompts"),
    "life_story": ("prompts", "prompts"),
    "share_experience": ("experiences", "experiences"),
}
XCSTRING_CATALOGS = ("Localizable.xcstrings", "Paywall.xcstrings")
PLACEHOLDER_RE = re.compile(r"%\d+\$[@a-zA-Z]+|%[@a-zA-Z]+")


@dataclass
class BankSummary:
    bank: str
    path: str
    exists: bool
    schema_version: int | None = None
    language: str | None = None
    target_count: int | None = None
    english_count: int | None = None
    id_mismatches: int = 0
    empty_text_fields: int = 0
    english_identical_fields: int = 0
    text_fields_checked: int = 0
    followup_mismatches: int = 0


@dataclass
class XcstringsSummary:
    path: str
    exists: bool
    translatable_keys: int = 0
    localized_keys: int = 0
    empty_values: int = 0
    placeholder_mismatches: int = 0
    brand_has_locale: bool = False


@dataclass
class PrivacySummary:
    path: str
    exists: bool
    contains_april_24_2026: bool = False


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def text_fields(bank: str, item: dict[str, Any]) -> list[tuple[str, str]]:
    fields: list[tuple[str, str]] = []
    if isinstance(item.get("text"), str):
        fields.append(("text", item["text"]))
    if isinstance(item.get("fullText"), str):
        fields.append(("fullText", item["fullText"]))
    if isinstance(item.get("followUp1"), str):
        fields.append(("followUp1", item["followUp1"]))
    if isinstance(item.get("followUp2"), str):
        fields.append(("followUp2", item["followUp2"]))
    for index, follow_up in enumerate(item.get("followUps", [])):
        if isinstance(follow_up, dict) and isinstance(follow_up.get("text"), str):
            fu_id = follow_up.get("id", f"followUps[{index}]")
            fields.append((f"followUps.{fu_id}", follow_up["text"]))
    return fields


def prompt_followups(item: dict[str, Any]) -> list[str]:
    return [fu.get("id", "") for fu in item.get("followUps", []) if isinstance(fu, dict)]


def summarize_bank(locale: str, bank: str) -> BankSummary:
    array_key = BANKS[bank][1]
    target_path = ROOT / "Connections" / "Data" / f"{bank}_{locale}.json"
    english_path = ROOT / "Connections" / "Data" / f"{bank}_en.json"
    summary = BankSummary(bank=bank, path=str(target_path.relative_to(ROOT)), exists=target_path.exists())
    if not target_path.exists():
        return summary

    target = load_json(target_path)
    english = load_json(english_path)
    target_items = target.get(array_key, [])
    english_items = english.get(array_key, [])
    summary.schema_version = target.get("schemaVersion")
    summary.language = target.get("language")
    summary.target_count = len(target_items)
    summary.english_count = len(english_items)

    english_by_id = {item.get("id"): item for item in english_items if isinstance(item, dict)}
    for index, target_item in enumerate(target_items):
        if not isinstance(target_item, dict):
            continue
        target_id = target_item.get("id")
        english_item = english_by_id.get(target_id)
        if english_item is None:
            summary.id_mismatches += 1
            english_item = english_items[index] if index < len(english_items) and isinstance(english_items[index], dict) else {}
        elif index >= len(english_items) or english_items[index].get("id") != target_id:
            summary.id_mismatches += 1

        for field, target_text in text_fields(bank, target_item):
            summary.text_fields_checked += 1
            if not target_text.strip():
                summary.empty_text_fields += 1
            english_value = lookup_text_field(english_item, field)
            if english_value is not None and target_text == english_value:
                summary.english_identical_fields += 1

        if bank == "prompts":
            if prompt_followups(target_item) != prompt_followups(english_item):
                summary.followup_mismatches += 1
        elif bank == "life_story":
            for key in ("followUp1", "followUp2"):
                if key in english_item and key not in target_item:
                    summary.followup_mismatches += 1
    return summary


def lookup_text_field(item: dict[str, Any], field: str) -> str | None:
    if field in ("text", "fullText", "followUp1", "followUp2"):
        value = item.get(field)
        return value if isinstance(value, str) else None
    if field.startswith("followUps."):
        fu_id = field.removeprefix("followUps.")
        for follow_up in item.get("followUps", []):
            if isinstance(follow_up, dict) and follow_up.get("id") == fu_id:
                value = follow_up.get("text")
                return value if isinstance(value, str) else None
    return None


def localization_values(node: Any) -> list[str]:
    values: list[str] = []
    if not isinstance(node, dict):
        return values
    unit = node.get("stringUnit")
    if isinstance(unit, dict) and isinstance(unit.get("value"), str):
        values.append(unit["value"])
    variations = node.get("variations", {})
    if isinstance(variations, dict):
        for child in variations.values():
            values.extend(localization_values(child))
    return values


def placeholders(text: str) -> list[str]:
    return sorted(PLACEHOLDER_RE.findall(text))


def summarize_xcstrings(locale: str) -> XcstringsSummary:
    existing_paths = [ROOT / "Connections" / name for name in XCSTRING_CATALOGS if (ROOT / "Connections" / name).exists()]
    summary = XcstringsSummary(
        path=", ".join(str(path.relative_to(ROOT)) for path in existing_paths) or "Connections/*.xcstrings",
        exists=bool(existing_paths),
    )
    for path in existing_paths:
        data = load_json(path)
        for key, entry in data.get("strings", {}).items():
            if entry.get("shouldTranslate") is False:
                if key == "Deeper Conversations" and locale in entry.get("localizations", {}):
                    summary.brand_has_locale = True
                continue
            summary.translatable_keys += 1
            localizations = entry.get("localizations", {})
            loc = localizations.get(locale)
            if not loc:
                continue
            summary.localized_keys += 1
            en_values = localization_values(localizations.get("en", {}))
            loc_values = localization_values(loc)
            if any(not value.strip() for value in loc_values):
                summary.empty_values += 1
            if len(en_values) != len(loc_values):
                summary.placeholder_mismatches += 1
            else:
                for en_value, loc_value in zip(en_values, loc_values):
                    if placeholders(en_value) != placeholders(loc_value):
                        summary.placeholder_mismatches += 1
                        break
    return summary


def summarize_privacy(locale: str) -> PrivacySummary:
    path = ROOT / "docs" / f"privacy-{locale}.md"
    summary = PrivacySummary(path=str(path.relative_to(ROOT)), exists=path.exists())
    if not path.exists():
        return summary
    text = path.read_text(encoding="utf-8")
    date_markers = [
        "April 24, 2026",
        "24 avril 2026",
        "24 aprile 2026",
        "24 april 2026",
        "24. april 2026",
        "24. huhtikuuta 2026",
        "2026年4月24日",
        "24 апреля 2026",
        "24 de abril de 2026",
        "24 kwietnia 2026",
        "24. April 2026",
        "24 april 2026",
    ]
    summary.contains_april_24_2026 = any(marker in text for marker in date_markers)
    return summary


def run_scanner(locale: str) -> dict[str, Any]:
    script = ROOT / "scripts" / "localization" / "scan_localization_patterns.py"
    result = subprocess.run(
        ["python3", str(script), "--locale", locale, "--json"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        return {"error": result.stderr.strip() or result.stdout.strip(), "findings": []}
    return json.loads(result.stdout)


def print_text_report(locale: str, banks: list[BankSummary], xc: XcstringsSummary, privacy: PrivacySummary, scanner: dict[str, Any] | None) -> None:
    print(f"Locale inspection: {locale}")
    print()
    print("JSON banks")
    for bank in banks:
        if not bank.exists:
            print(f"- {bank.bank}: MISSING ({bank.path})")
            continue
        print(
            f"- {bank.bank}: count {bank.target_count}/{bank.english_count}, "
            f"language={bank.language}, schema={bank.schema_version}, "
            f"text fields={bank.text_fields_checked}, english-identical={bank.english_identical_fields}, "
            f"empty={bank.empty_text_fields}, id mismatches={bank.id_mismatches}, "
            f"follow-up mismatches={bank.followup_mismatches}"
        )
    print()
    print("xcstrings")
    if xc.exists:
        print(
            f"- localized keys {xc.localized_keys}/{xc.translatable_keys}, "
            f"empty values={xc.empty_values}, placeholder mismatches={xc.placeholder_mismatches}, "
            f"brand has locale={xc.brand_has_locale}"
        )
    else:
        print(f"- MISSING ({xc.path})")
    print()
    print("privacy")
    if privacy.exists:
        print(f"- {privacy.path}: exists, effective-date marker OK={privacy.contains_april_24_2026}")
    else:
        print(f"- MISSING ({privacy.path})")
    if scanner is not None:
        print()
        print("scanner")
        if "error" in scanner:
            print(f"- ERROR: {scanner['error']}")
        else:
            print(f"- findings={len(scanner.get('findings', []))}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--locale", required=True, help="Locale code, e.g. ru, zh-Hans, pt-BR")
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of text")
    parser.add_argument("--include-scanner", action="store_true", help="Run scan_localization_patterns.py and include finding count")
    parser.add_argument("--fail-on-issues", action="store_true", help="Exit non-zero for missing files, mismatches, empties, or English-identical fields")
    args = parser.parse_args()

    banks = [summarize_bank(args.locale, bank) for bank in BANKS]
    xc = summarize_xcstrings(args.locale)
    privacy = summarize_privacy(args.locale)
    scanner = run_scanner(args.locale) if args.include_scanner else None

    payload = {
        "locale": args.locale,
        "banks": [asdict(bank) for bank in banks],
        "xcstrings": asdict(xc),
        "privacy": asdict(privacy),
        "scanner": scanner,
    }

    if args.json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print_text_report(args.locale, banks, xc, privacy, scanner)

    issue_count = 0
    for bank in banks:
        if not bank.exists:
            issue_count += 1
            continue
        issue_count += bank.id_mismatches + bank.empty_text_fields + bank.english_identical_fields + bank.followup_mismatches
        if bank.target_count != bank.english_count:
            issue_count += 1
        if bank.language != args.locale:
            issue_count += 1
        if bank.schema_version != 1:
            issue_count += 1
    if not xc.exists:
        issue_count += 1
    else:
        issue_count += xc.empty_values + xc.placeholder_mismatches + int(xc.brand_has_locale)
        if xc.localized_keys != xc.translatable_keys:
            issue_count += 1
    if not privacy.exists:
        issue_count += 1
    if scanner and scanner.get("error"):
        issue_count += 1

    return 1 if args.fail_on_issues and issue_count else 0


if __name__ == "__main__":
    raise SystemExit(main())
