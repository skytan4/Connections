#!/usr/bin/env python3
"""Generate English-vs-localized audit packets for review agents."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[2]


SENSITIVE_PROMPT_TOPICS = {"sex", "past", "parenting", "intimacy", "conflict"}
SENSITIVE_LIFE_STORY_CHAPTERS = {
    "loveAndPartnership",
    "parentingAndFamilyLife",
    "hardshipAndResilience",
    "legacy",
}


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def esc(value: Any) -> str:
    text = "" if value is None else str(value)
    return text.replace("\n", "<br>").replace("|", "\\|")


def should_include_prompt(item: dict[str, Any], scope: str) -> bool:
    if scope in {"all", "prompts"}:
        return True
    if scope == "sensitive":
        return (
            item.get("topic") in SENSITIVE_PROMPT_TOPICS
            or item.get("intensity") == "unfiltered"
            or item.get("mode") == "family"
        )
    if scope == "ui":
        return False
    if scope == "guided":
        return False
    return True


def should_include_life_story(item: dict[str, Any], scope: str) -> bool:
    if scope in {"all", "guided"}:
        return True
    if scope == "sensitive":
        return item.get("chapter") in SENSITIVE_LIFE_STORY_CHAPTERS
    return False


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def prompts_packet(locale: str, output: Path, scope: str) -> int:
    en = load_json(ROOT / "Connections" / "Data" / "prompts_en.json")["prompts"]
    loc_path = ROOT / "Connections" / "Data" / f"prompts_{locale}.json"
    if not loc_path.exists():
        return 0
    loc = {p["id"]: p for p in load_json(loc_path)["prompts"]}

    rows = [
        "# Prompt Bank Audit Packet",
        "",
        f"Locale: `{locale}`",
        f"Scope: `{scope}`",
        "",
        "| id | mode | intensity | depth | topic | field | English | Translation | status | notes |",
        "|---|---|---|---|---|---|---|---|---|---|",
    ]
    count = 0
    for item in en:
        if not should_include_prompt(item, scope):
            continue
        translated = loc.get(item["id"], {})
        rows.append(
            "| {id} | {mode} | {intensity} | {depth} | {topic} | text | {en_text} | {loc_text} |  |  |".format(
                id=esc(item["id"]),
                mode=esc(item.get("mode")),
                intensity=esc(item.get("intensity")),
                depth=esc(item.get("depth")),
                topic=esc(item.get("topic")),
                en_text=esc(item.get("text")),
                loc_text=esc(translated.get("text")),
            )
        )
        loc_fus = {fu.get("id"): fu for fu in translated.get("followUps", [])}
        for fu in item.get("followUps", []):
            loc_fu = loc_fus.get(fu.get("id"), {})
            rows.append(
                "| {id} | {mode} | {intensity} | {depth} | {topic} | followUp | {en_text} | {loc_text} |  |  |".format(
                    id=esc(fu.get("id")),
                    mode=esc(item.get("mode")),
                    intensity=esc(item.get("intensity")),
                    depth=esc(item.get("depth")),
                    topic=esc(item.get("topic")),
                    en_text=esc(fu.get("text")),
                    loc_text=esc(loc_fu.get("text")),
                )
            )
        count += 1

    write(output / f"{locale}_prompts_{scope}.md", "\n".join(rows) + "\n")
    return count


def fall_in_love_packet(locale: str, output: Path, scope: str) -> int:
    if scope not in {"all", "guided", "sensitive"}:
        return 0
    en = load_json(ROOT / "Connections" / "Data" / "fall_in_love_en.json")["prompts"]
    loc_path = ROOT / "Connections" / "Data" / f"fall_in_love_{locale}.json"
    if not loc_path.exists():
        return 0
    loc = {p["id"]: p for p in load_json(loc_path)["prompts"]}
    rows = [
        "# Fall in Love Audit Packet",
        "",
        f"Locale: `{locale}`",
        "",
        "| id | order | depth | English | Translation | status | notes |",
        "|---|---|---|---|---|---|---|",
    ]
    for item in en:
        translated = loc.get(item["id"], {})
        rows.append(f"| {esc(item['id'])} | {esc(item.get('order'))} | {esc(item.get('depth'))} | {esc(item.get('text'))} | {esc(translated.get('text'))} |  |  |")
    write(output / f"{locale}_fall_in_love.md", "\n".join(rows) + "\n")
    return len(en)


def share_experience_packet(locale: str, output: Path, scope: str) -> int:
    if scope not in {"all", "guided"}:
        return 0
    en = load_json(ROOT / "Connections" / "Data" / "share_experience_en.json")["experiences"]
    loc_path = ROOT / "Connections" / "Data" / f"share_experience_{locale}.json"
    if not loc_path.exists():
        return 0
    loc = {p["id"]: p for p in load_json(loc_path)["experiences"]}
    rows = [
        "# Share an Experience Audit Packet",
        "",
        f"Locale: `{locale}`",
        "",
        "| id | intensity | topic | English | Translation | status | notes |",
        "|---|---|---|---|---|---|---|",
    ]
    for item in en:
        translated = loc.get(item["id"], {})
        rows.append(f"| {esc(item['id'])} | {esc(item.get('intensity'))} | {esc(item.get('topic'))} | {esc(item.get('fullText'))} | {esc(translated.get('fullText'))} |  |  |")
    write(output / f"{locale}_share_experience.md", "\n".join(rows) + "\n")
    return len(en)


def life_story_packet(locale: str, output: Path, scope: str) -> int:
    en = load_json(ROOT / "Connections" / "Data" / "life_story_en.json")["prompts"]
    loc_path = ROOT / "Connections" / "Data" / f"life_story_{locale}.json"
    if not loc_path.exists():
        return 0
    loc = {p["id"]: p for p in load_json(loc_path)["prompts"]}
    rows = [
        "# Life Story Audit Packet",
        "",
        f"Locale: `{locale}`",
        f"Scope: `{scope}`",
        "",
        "| id | chapter | field | English | Translation | status | notes |",
        "|---|---|---|---|---|---|---|",
    ]
    count = 0
    for item in en:
        if not should_include_life_story(item, scope):
            continue
        translated = loc.get(item["id"], {})
        for field in ("text", "followUp1", "followUp2"):
            rows.append(f"| {esc(item['id'])} | {esc(item.get('chapter'))} | {field} | {esc(item.get(field))} | {esc(translated.get(field))} |  |  |")
        count += 1
    if count:
        write(output / f"{locale}_life_story_{scope}.md", "\n".join(rows) + "\n")
    return count


def localization_values(node: Any) -> list[str]:
    values: list[str] = []
    if isinstance(node, dict):
        unit = node.get("stringUnit")
        if isinstance(unit, dict) and isinstance(unit.get("value"), str):
            values.append(unit["value"])
        for child in node.get("variations", {}).values():
            values.extend(localization_values(child))
        for child in node.values():
            if isinstance(child, dict) and ("stringUnit" in child or "variations" in child):
                values.extend(localization_values(child))
    return values


def ui_packet(locale: str, output: Path, scope: str) -> int:
    if scope not in {"all", "ui"}:
        return 0
    catalog = load_json(ROOT / "Connections" / "Localizable.xcstrings")
    rows = [
        "# UI Strings Audit Packet",
        "",
        f"Locale: `{locale}`",
        "",
        "| key | English | Translation | status | notes |",
        "|---|---|---|---|---|",
    ]
    count = 0
    for key, entry in sorted(catalog.get("strings", {}).items()):
        if entry.get("shouldTranslate") is False:
            continue
        en_values = localization_values(entry.get("localizations", {}).get("en", {}))
        loc_values = localization_values(entry.get("localizations", {}).get(locale, {}))
        if not en_values and not loc_values:
            continue
        rows.append(f"| {esc(key)} | {esc(' / '.join(en_values))} | {esc(' / '.join(loc_values))} |  |  |")
        count += 1
    write(output / f"{locale}_ui.md", "\n".join(rows) + "\n")
    return count


def privacy_packet(locale: str, output: Path, scope: str) -> int:
    if scope not in {"all", "ui"}:
        return 0
    en_path = ROOT / "docs" / "privacy.md"
    loc_path = ROOT / "docs" / f"privacy-{locale}.md"
    if not loc_path.exists():
        return 0
    rows = [
        "# Privacy Policy Audit Packet",
        "",
        f"Locale: `{locale}`",
        "",
        "## English",
        "",
        en_path.read_text(encoding="utf-8"),
        "",
        "## Translation",
        "",
        loc_path.read_text(encoding="utf-8"),
        "",
        "## Findings",
        "",
        "| status | section | issue | proposed action |",
        "|---|---|---|---|",
    ]
    write(output / f"{locale}_privacy.md", "\n".join(rows) + "\n")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--locale", required=True, help="Locale to export, e.g. it, nl, zh-Hans")
    parser.add_argument("--scope", choices=["all", "prompts", "guided", "sensitive", "ui"], default="sensitive")
    parser.add_argument("--output", type=Path, default=None, help="Output directory")
    args = parser.parse_args()

    output = args.output or Path("/tmp") / f"localization_audit_{args.locale}_{args.scope}"
    output.mkdir(parents=True, exist_ok=True)

    counts = {
        "prompts": prompts_packet(args.locale, output, args.scope),
        "fall_in_love": fall_in_love_packet(args.locale, output, args.scope),
        "share_experience": share_experience_packet(args.locale, output, args.scope),
        "life_story": life_story_packet(args.locale, output, args.scope),
        "ui": ui_packet(args.locale, output, args.scope),
        "privacy": privacy_packet(args.locale, output, args.scope),
    }
    print(f"Wrote audit packet(s) to {output}")
    for name, count in counts.items():
        if count:
            print(f"- {name}: {count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
