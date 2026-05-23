#!/usr/bin/env python3
"""
generate_polish_review_packets.py

Generate Markdown review packets for Polish-speaking reviewers after
prompts_pl.json has been produced by translation agents.

Each packet contains a table:
  id | mode | intensity | depth | topic | English | Polish | Reviewer notes

Packets generated:
  - general.md           (all prompts not in other packets)
  - couples_intimacy.md  (mode=couples, topic=intimacy)
  - sex_unfiltered.md    (topic=sex)
  - hardship_grief_regret.md
  - family_intergenerational.md (mode=family)

Usage:
  python3 scripts/localization/generate_polish_review_packets.py \\
      --output /tmp/polish_review_packets

  python3 scripts/localization/generate_polish_review_packets.py \\
      --source-en Connections/Data/prompts_en.json \\
      --source-pl Connections/Data/prompts_pl.json \\
      --output /tmp/polish_review_packets
"""

import argparse
import json
import os
import sys

BRIEF_PATH = "docs/localization/polish-brief.md"

PACKET_DEFS = [
    {
        "name":     "sex_unfiltered",
        "heading":  "Sex / Unfiltered",
        "guidance": (
            "These prompts address sexual topics directly. "
            "Use the emotionally honest adult register — not clinical, not vulgar. "
            "See polish-brief.md section 'Sex / Unfiltered'."
        ),
        "filter":   lambda p: p["topic"] == "sex",
    },
    {
        "name":     "couples_intimacy",
        "heading":  "Couples / Intimacy",
        "guidance": (
            "Tender, adult, emotionally safe. "
            "Use warm relational language: bliskość, czułość, intymność. "
            "See polish-brief.md section 'Couples / Intimacy'."
        ),
        "filter":   lambda p: p["mode"] == "couples" and p["topic"] == "intimacy",
    },
    {
        "name":     "hardship_grief_regret",
        "heading":  "Hardship / Grief / Regret",
        "guidance": (
            "Gentle, respectful, and spacious. Leave room for difficulty. "
            "Avoid minimizing language (to nic wielkiego, każdemu się zdarza). "
            "See polish-brief.md section 'Hardship / Grief / Regret'."
        ),
        "filter":   lambda p: (
            p["mode"] == "couples"
            and p["topic"] == "dailyLife"
            and not (p["intensity"] == "light" and p["depth"] == "warmUp")
        ),
    },
    {
        "name":     "family_intergenerational",
        "heading":  "Family / Intergenerational",
        "guidance": (
            "Respectful and grounded. Polish family language carries strong cultural weight. "
            "Appropriate warmth for parents, grandparents, siblings. "
            "See polish-brief.md section 'Family / Intergenerational'."
        ),
        "filter":   lambda p: p["mode"] == "family",
    },
]

# 'general' catches everything not matched by the named packets above
def is_named_packet(p: dict) -> bool:
    return any(pkt["filter"](p) for pkt in PACKET_DEFS)


def escape_cell(text: str) -> str:
    """Escape pipe characters so they don't break Markdown table cells."""
    return text.replace("|", "\\|")


def build_table(pairs: list[tuple[dict, dict]]) -> str:
    lines = [
        "| id | mode | intensity | depth | topic | English | Polish | Reviewer notes |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for en_p, pl_p in pairs:
        row = "| {} | {} | {} | {} | {} | {} | {} | |".format(
            escape_cell(en_p.get("id", "")),
            escape_cell(en_p.get("mode", "")),
            escape_cell(en_p.get("intensity", "")),
            escape_cell(en_p.get("depth", "")),
            escape_cell(en_p.get("topic", "")),
            escape_cell(en_p.get("text", "")),
            escape_cell(pl_p.get("text", "")),
        )
        lines.append(row)
        # Follow-up rows (indented id to distinguish)
        en_fus = en_p.get("followUps", [])
        pl_fus = pl_p.get("followUps", [])
        for en_fu, pl_fu in zip(en_fus, pl_fus):
            fu_row = "| ↳ {} | | | | | {} | {} | |".format(
                escape_cell(en_fu.get("id", "")),
                escape_cell(en_fu.get("text", "")),
                escape_cell(pl_fu.get("text", "")),
            )
            lines.append(fu_row)
    return "\n".join(lines)


def write_packet(
    path: str,
    heading: str,
    guidance: str,
    pairs: list[tuple[dict, dict]],
) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(f"# Polish Review Packet: {heading}\n\n")
        f.write("## Instructions for Reviewers\n\n")
        f.write(f"- **Always read** `{BRIEF_PATH}` before reviewing.\n")
        f.write("- **Do not edit JSON files directly** — they are applied programmatically.\n")
        f.write(
            "- **Return corrections** as explicit patch JSON "
            "(see `polish-review-workflow.md` for format).\n\n"
        )
        f.write(f"## Tone Guidance\n\n{guidance}\n\n")
        f.write(f"## Prompts ({len(pairs)})\n\n")
        if pairs:
            f.write(build_table(pairs))
        else:
            f.write("_No prompts in this packet._")
        f.write("\n")


def load_json(path: str) -> dict:
    if not os.path.exists(path):
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate Markdown review packets from prompts_en.json + prompts_pl.json."
    )
    parser.add_argument(
        "--source-en",
        default="Connections/Data/prompts_en.json",
        help="English source file",
    )
    parser.add_argument(
        "--source-pl",
        default="Connections/Data/prompts_pl.json",
        help="Polish candidate file (must exist before running this script)",
    )
    parser.add_argument(
        "--output",
        default="/tmp/polish_review_packets",
        help="Output directory for Markdown packets (default: /tmp/polish_review_packets)",
    )
    args = parser.parse_args()

    en_data = load_json(args.source_en)
    pl_data = load_json(args.source_pl)

    en_prompts = en_data.get("prompts", [])
    pl_prompts = pl_data.get("prompts", [])

    if len(en_prompts) != len(pl_prompts):
        print(
            f"ERROR: prompt count mismatch — en={len(en_prompts)}, pl={len(pl_prompts)}. "
            "Run validate_polish_candidate.py first.",
            file=sys.stderr,
        )
        return 1

    # Build id → pl lookup
    pl_by_id = {p["id"]: p for p in pl_prompts}

    os.makedirs(args.output, exist_ok=True)

    written_ids: set[str] = set()

    # Named packets
    for pkt in PACKET_DEFS:
        pairs = [
            (en_p, pl_by_id[en_p["id"]])
            for en_p in en_prompts
            if pkt["filter"](en_p) and en_p["id"] in pl_by_id
        ]
        out_path = os.path.join(args.output, f"{pkt['name']}.md")
        write_packet(out_path, pkt["heading"], pkt["guidance"], pairs)
        for en_p, _ in pairs:
            written_ids.add(en_p["id"])
        print(f"  {pkt['name']}.md — {len(pairs)} prompts")

    # General packet: everything not in a named packet
    general_pairs = [
        (en_p, pl_by_id[en_p["id"]])
        for en_p in en_prompts
        if en_p["id"] not in written_ids and en_p["id"] in pl_by_id
    ]
    out_path = os.path.join(args.output, "general.md")
    write_packet(
        out_path,
        "General",
        (
            "These prompts cover the full range of non-sensitive topics and modes. "
            "Follow the register guidance in polish-brief.md: warm, natural, informal ty, "
            "no bureaucratic or literal English phrasing."
        ),
        general_pairs,
    )
    print(f"  general.md — {len(general_pairs)} prompts")

    total = sum(
        len([
            en_p for en_p in en_prompts if pkt["filter"](en_p)
        ])
        for pkt in PACKET_DEFS
    ) + len(general_pairs)

    print(f"\nTotal prompts across all packets: {total} / {len(en_prompts)}")
    print(f"Review packets written to: {args.output}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
