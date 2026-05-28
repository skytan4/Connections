#!/usr/bin/env python3
"""Scan localized files for known language-specific red-flag patterns.

This is an audit helper, not a translation validator. Findings are leads for a
coordinator or review agent to inspect; some may be false positives.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: str
    note: str
    regex: bool = False
    flags: int = 0


RULES: dict[str, list[Rule]] = {
    "it": [
        Rule("formal-address", r"\b(Lei|Suo|Sua|Vostro|Vostra)\b", "Formal Italian address in intimate app copy", True),
        Rule("slash-gender", r"\b\w+/\w+\b|\([a-z]\)", "Slash or parenthetical gender form; prefer restructure", True, re.IGNORECASE),
    ],
    "fr": [
        Rule("midpoint-inclusive", "·", "Midpoint inclusive form; prefer natural neutral restructure"),
        Rule("slash-or-parenthetical", r"\b\w+/\w+\b|\([eE]\)", "Slash or parenthetical inclusive form", True),
        Rule("formal-vous", r"(?<!rendez-)\b[vV]ous\b", "Possible formal vous; rendez-vous is ignored", True),
    ],
    "pt-BR": [
        Rule("portugal-tu-es", r"\b(tu|teu|tua|és|estás|foste|fizeste)\b", "Possible EU-PT or tu-register leakage", True, re.IGNORECASE),
        Rule("slash-gender", r"\b\w+/\w+\b|\([ao]\)", "Slash or parenthetical gender form", True, re.IGNORECASE),
    ],
    "nl": [
        Rule("formal-u", r"\b[uU]\b|\buw\b", "Formal Dutch address; use je/jij/jou", True, re.IGNORECASE),
        Rule("binary-pronoun-pair", r"hij/zij|zij/hij|hem/haar|haar/hem|zijn/haar|haar/zijn|hem of haar|hij of zij", "Binary gender construction", True, re.IGNORECASE),
    ],
    "pl": [
        Rule("formal-address", r"\b(Pan|Pani|Państwo)\b", "Formal Polish address; use ty register", True),
        Rule("slash-gender", r"\b\w+/\w+\b|\([a-ząćęłńóśźż]\)", "Slash or parenthetical gender form", True, re.IGNORECASE),
    ],
    "de": [
        Rule("formal-sie", r"\b(Sie|Ihnen|Ihr|Ihre|Ihrem|Ihren)\b", "Possible formal German address; use du register", True),
    ],
    "ja": [
        Rule("pronoun-anata", "あなた", "Check for unnecessary direct pronoun"),
        Rule("pronoun-watashi", "私", "Check for unnecessary first-person pronoun"),
        Rule("partner-overuse", "パートナー", "Check for overuse of partner label"),
        Rule("business-register", r"ご利用|いただく|お願いいたします", "Customer-service register in app copy", True),
    ],
    "zh-Hans": [
        Rule("formal-nin", "您", "Formal address; use 你"),
        Rule("gendered-written-pronoun", r"他/她|她/他|他或她|她或他|TA", "Gendered/mixed written pronoun; restructure", True),
        Rule("traditional-character", r"說|個|時|發|來|國|學|開|問", "Common Traditional Chinese character leakage", True),
        Rule("filial-duty", r"孝顺|孝道|报答父母|尽孝", "Family-duty framing should only appear if source warrants it", True),
    ],
    "ru": [
        Rule("formal-vy", r"\b(вы|Вы|Вас|вам|Вам|Ваш|Ваша|Ваше|Ваши)\b", "Formal Russian address; use ты register", True),
        Rule("slash-gender", r"\b[\wёЁ]+/[\wёЁ]+\b|[\wёЁ]+\(-?[а-яё]+\)", "Slash or parenthetical gender form (incl. hyphen-dash variant); restructure", True, re.IGNORECASE),
        Rule("gendered-pair", r"он/она|она/он|его/её|его/ее|он или она|она или он", "Gendered pronoun pair for unknown person", True, re.IGNORECASE),
        Rule("masculine-fallback-candidate", r"\b(был|готов|устал|счастлив|влюблён|почувствовал)\b", "Possible masculine fallback; must be justified if user-addressed", True, re.IGNORECASE),
    ],
    "es": [
        Rule("formal-usted", r"\b(usted|ustedes|Usted|Ustedes)\b", "Formal Spanish address; use tú register", True),
        Rule("slash-gender", r"\b\w+/\w+\b|\([ao]s?\)", "Slash or parenthetical gender form; prefer neutral restructure", True, re.IGNORECASE),
    ],
    "sv": [
        Rule("formal-ni", r"\b(Ni|Er|Ert|Era)\b", "Possible formal Swedish address; use du", True),
    ],
    "da": [
        Rule("formal-de", r"\b(De|Dem|Deres)\b", "Possible formal Danish address; use du", True),
    ],
    "nb": [
        Rule("formal-de", r"\b(De|Dem|Deres)\b", "Possible formal Norwegian address; use du", True),
    ],
    "fi": [
        Rule("forced-sina", "sinä", "Check for unnecessary explicit sinä in Finnish pro-drop contexts", False, re.IGNORECASE),
    ],
}


BANKS = ("prompts", "fall_in_love", "life_story", "share_experience", "mortality_conversations")


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def iter_json_texts(path: Path) -> list[tuple[str, str]]:
    data = load_json(path)
    rows: list[tuple[str, str]] = []

    def add(label: str, value: Any) -> None:
        if isinstance(value, str) and value:
            rows.append((label, value))

    if "prompts" in data:
        for item in data["prompts"]:
            item_id = item.get("id", "?")
            add(f"{item_id}.text", item.get("text"))
            add(f"{item_id}.followUp1", item.get("followUp1"))
            add(f"{item_id}.followUp2", item.get("followUp2"))
            for fu in item.get("followUps", []):
                add(f"{fu.get('id', item_id + '.fu')}.text", fu.get("text"))
    if "experiences" in data:
        for item in data["experiences"]:
            add(f"{item.get('id', '?')}.fullText", item.get("fullText"))
    return rows


def iter_xcstrings_texts(path: Path, locale: str) -> list[tuple[str, str]]:
    data = load_json(path)
    rows: list[tuple[str, str]] = []
    for key, entry in data.get("strings", {}).items():
        loc = entry.get("localizations", {}).get(locale)
        if not loc:
            continue
        for value in localization_values(loc):
            rows.append((f"{key}.localizations.{locale}", value))
    return rows


def localization_values(node: Any) -> list[str]:
    values: list[str] = []
    if isinstance(node, dict):
        unit = node.get("stringUnit")
        if isinstance(unit, dict) and isinstance(unit.get("value"), str):
            values.append(unit["value"])
        for child in node.get("variations", {}).values():
            values.extend(localization_values(child))
        for child in node.values():
            if isinstance(child, dict) and child is not unit:
                # Variations can nest dictionaries in different shapes.
                if "stringUnit" in child or "variations" in child:
                    values.extend(localization_values(child))
    return values


def default_paths(locale: str) -> list[Path]:
    paths: list[Path] = []
    for bank in BANKS:
        candidate = ROOT / "Connections" / "Data" / f"{bank}_{locale}.json"
        if candidate.exists():
            paths.append(candidate)
    privacy = ROOT / "docs" / f"privacy-{locale}.md"
    if privacy.exists():
        paths.append(privacy)
    for catalog_name in ("Localizable.xcstrings", "Paywall.xcstrings"):
        catalog = ROOT / "Connections" / catalog_name
        if catalog.exists():
            paths.append(catalog)
    return paths


def scan_text(rule: Rule, text: str) -> list[str]:
    if rule.regex:
        return [m.group(0) for m in re.finditer(rule.pattern, text, rule.flags)]
    flags = re.IGNORECASE if rule.flags & re.IGNORECASE else 0
    if flags:
        return [m.group(0) for m in re.finditer(re.escape(rule.pattern), text, flags)]
    return [rule.pattern] if rule.pattern in text else []


def iter_path_texts(path: Path, locale: str) -> list[tuple[str, str]]:
    if path.suffix == ".xcstrings":
        return iter_xcstrings_texts(path, locale)
    if path.suffix == ".json":
        return iter_json_texts(path)
    return [(f"{path.name}:body", path.read_text(encoding="utf-8"))]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--locale", required=True, help="Locale to scan, e.g. it, nl, zh-Hans, ru")
    parser.add_argument("--path", action="append", type=Path, help="Specific file path to scan; may be repeated")
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of text")
    parser.add_argument("--fail-on-findings", action="store_true", help="Exit non-zero if findings are present")
    args = parser.parse_args()

    rules = RULES.get(args.locale, [])
    if not rules:
        raise SystemExit(f"No scan rules configured for locale '{args.locale}'")

    paths = args.path or default_paths(args.locale)
    findings: list[dict[str, str]] = []
    for path in paths:
        if not path.exists():
            continue
        for label, text in iter_path_texts(path, args.locale):
            for rule in rules:
                matches = scan_text(rule, text)
                if matches:
                    snippet = text.replace("\n", " ")
                    if len(snippet) > 180:
                        snippet = snippet[:177] + "..."
                    findings.append(
                        {
                            "path": str(path.relative_to(ROOT) if path.is_relative_to(ROOT) else path),
                            "label": label,
                            "rule": rule.name,
                            "matches": ", ".join(sorted(set(matches))),
                            "note": rule.note,
                            "snippet": snippet,
                        }
                    )

    if args.json:
        print(json.dumps({"locale": args.locale, "findings": findings}, ensure_ascii=False, indent=2))
    else:
        if not findings:
            print(f"No pattern findings for {args.locale}.")
        else:
            print(f"{len(findings)} pattern finding(s) for {args.locale}:")
            for item in findings:
                print(f"- {item['path']} :: {item['label']} :: {item['rule']} :: {item['matches']}")
                print(f"  {item['note']}")
                print(f"  {item['snippet']}")

    return 1 if findings and args.fail_on_findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
