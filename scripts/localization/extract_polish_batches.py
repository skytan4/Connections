#!/usr/bin/env python3
"""
extract_polish_batches.py

Read prompts_en.json and split all prompts into tone/context batch files
for Polish translation agents. Each batch file contains the prompts a single
agent should translate, plus a tone note for that agent.

Output: /tmp/polish_batches/<group_name>.json  (one file per group)

Usage:
  python3 scripts/localization/extract_polish_batches.py
  python3 scripts/localization/extract_polish_batches.py --source Connections/Data/prompts_en.json
  python3 scripts/localization/extract_polish_batches.py --output /tmp/polish_batches
  python3 scripts/localization/extract_polish_batches.py --dry-run
"""

import argparse
import json
import os
import sys

# ---------------------------------------------------------------------------
# Group definitions — must be mutually exclusive and exhaustive.
# Assignment rules are evaluated in order; the first match wins.
# ---------------------------------------------------------------------------

GROUP_META = {
    "light_warmup_everyday": {
        "tone_note": (
            "Warm, playful, low-pressure. These are light-intensity warm-up prompts about "
            "everyday shared life. Use informal ty. Keep the energy easy and conversational. "
            "Avoid heavy vocabulary. Imperfective verbs throughout."
        ),
    },
    "connection_appreciation": {
        "tone_note": (
            "Warm and emotionally affirming. Topics cover appreciation, gratitude, and emotional "
            "connection. Use tender language: więź, bliskość, docenienie. Imperfective verbs. "
            "Register is sincere but not sentimental."
        ),
    },
    "communication_conflict": {
        "tone_note": (
            "Direct but not harsh. Topics cover how partners communicate and navigate conflict. "
            "Honest register. Avoid confrontational framing — prompts are invitations, not accusations. "
            "Imperfective verbs for ongoing patterns; perfective only for specific completed events."
        ),
    },
    "identity_values_growth": {
        "tone_note": (
            "Reflective and grounded. Topics cover personal identity, core values, and growth. "
            "Thoughtful register. Use natural Polish for introspective questions. "
            "Imperfective verbs for ongoing states and reflection."
        ),
    },
    "past_family_memory": {
        "tone_note": (
            "Gentle and spacious. Topics include the past, memory, parenting, and family history. "
            "Leave room for the respondent to sit with difficulty. Avoid minimizing language. "
            "Polish family language carries cultural weight — use it with care."
        ),
    },
    "couples_intimacy": {
        "tone_note": (
            "Tender, adult, and emotionally safe. Couples mode, intimacy topic. "
            "Use warm relational language: bliskość, czułość, intymność. "
            "Not clinical and not crude. See polish-brief.md section 'Couples / Intimacy'."
        ),
    },
    "sex_unfiltered": {
        "tone_note": (
            "Direct but not vulgar. All sex-topic prompts, all modes. "
            "Polish has a range of registers — stay in the emotionally honest adult register. "
            "Avoid clinical terms (stosunek płciowy) and slang. "
            "See polish-brief.md section 'Sex / Unfiltered'."
        ),
    },
    "hardship_grief_regret": {
        "tone_note": (
            "Emotionally honest and spacious. These prompts address daily tension, invisible "
            "expectations, and emotional strain at deeper intensity levels. "
            "Gentle and non-minimizing. Imperfective verbs. "
            "See polish-brief.md section 'Hardship / Grief / Regret'."
        ),
    },
    "solo_reflection": {
        "tone_note": (
            "Introspective and self-directed. Solo Reflection mode — the respondent reflects "
            "on themselves, not a partner. Use informal ty. Warm but not effusive. "
            "Imperfective verbs for ongoing states and habits."
        ),
    },
    "friends_playful_closeness": {
        "tone_note": (
            "Warm and casual, not romance-coded. Friends mode — playful where the English is "
            "playful, earnest where earnest. Use informal ty. Avoid overly formal or stiff phrasing. "
            "See polish-brief.md section 'Friends'."
        ),
    },
    "family_intergenerational": {
        "tone_note": (
            "Respectful and grounded. Family mode — prompts may address parents, grandparents, "
            "or siblings. Polish family language carries strong cultural weight — use it with care. "
            "See polish-brief.md section 'Family / Intergenerational'."
        ),
    },
}

# Evaluation order matters — first matching rule wins.
_ORDERED_GROUP_NAMES = [
    "sex_unfiltered",
    "couples_intimacy",
    "family_intergenerational",
    "friends_playful_closeness",
    "solo_reflection",
    "communication_conflict",
    "connection_appreciation",
    "identity_values_growth",
    "past_family_memory",
    "light_warmup_everyday",
    "hardship_grief_regret",   # catch-all — must be last
]


def assign_group(prompt: dict) -> str:
    """Return the group name for a single prompt. Never returns None."""
    mode      = prompt["mode"]
    intensity = prompt["intensity"]
    depth     = prompt["depth"]
    topic     = prompt["topic"]

    # 1. Sex prompts — sensitive, isolated regardless of mode
    if topic == "sex":
        return "sex_unfiltered"

    # 2. Couples-specific intimacy — tender adult content, smaller packet
    if mode == "couples" and topic == "intimacy":
        return "couples_intimacy"

    # 3-5. Mode-based groups — all remaining prompts for that mode
    if mode == "family":
        return "family_intergenerational"
    if mode == "friends":
        return "friends_playful_closeness"
    if mode == "soloReflection":
        return "solo_reflection"

    # 6-11. Remaining prompts are all couples mode at this point.
    if topic in ("communication", "conflict"):
        return "communication_conflict"
    if topic in ("appreciation", "emotions"):
        return "connection_appreciation"
    if topic in ("identity", "values", "growth"):
        return "identity_values_growth"
    if topic in ("past", "parenting"):
        return "past_family_memory"
    if intensity == "light" and depth == "warmUp":
        return "light_warmup_everyday"

    # Catch-all: couples/dailyLife at honest or unfiltered depths
    return "hardship_grief_regret"


def build_prompt_entry(p: dict) -> dict:
    """Return only the fields a translation agent needs."""
    return {
        "id":        p["id"],
        "mode":      p["mode"],
        "intensity": p["intensity"],
        "depth":     p["depth"],
        "topic":     p["topic"],
        "text":      p["text"],
        "followUps": [
            {"id": fu["id"], "style": fu["style"], "text": fu["text"]}
            for fu in p.get("followUps", [])
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Split prompts_en.json into tone/context batches for Polish translation agents."
    )
    parser.add_argument(
        "--source",
        default="Connections/Data/prompts_en.json",
        help="Path to prompts_en.json (default: Connections/Data/prompts_en.json)",
    )
    parser.add_argument(
        "--output",
        default="/tmp/polish_batches",
        help="Output directory for batch files (default: /tmp/polish_batches)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print group counts without writing files",
    )
    args = parser.parse_args()

    # Load source
    if not os.path.exists(args.source):
        print(f"ERROR: source file not found: {args.source}", file=sys.stderr)
        return 1

    with open(args.source, encoding="utf-8") as f:
        source = json.load(f)

    prompts = source.get("prompts", [])
    total_en = len(prompts)

    # Assign groups
    groups: dict[str, list] = {name: [] for name in _ORDERED_GROUP_NAMES}
    review_required: list = []

    for p in prompts:
        group = assign_group(p)
        if group in groups:
            groups[group].append(build_prompt_entry(p))
        else:
            review_required.append(p)

    # Verify coverage
    total_assigned = sum(len(v) for v in groups.values())
    unmatched = total_assigned + len(review_required)

    print(f"\nPrompt counts by group:")
    print(f"  {'Group':<32} {'Count':>5}")
    print(f"  {'-'*32} {'-'*5}")
    for name in _ORDERED_GROUP_NAMES:
        print(f"  {name:<32} {len(groups[name]):>5}")
    print(f"  {'-'*32} {'-'*5}")
    print(f"  {'TOTAL ASSIGNED':<32} {total_assigned:>5}")
    print(f"  {'English source total':<32} {total_en:>5}")

    if review_required:
        print(f"\nWARNING: {len(review_required)} prompt(s) placed in review_required:")
        for p in review_required:
            print(f"  {p['id']}")

    if total_assigned != total_en:
        print(
            f"\nFAIL: assigned {total_assigned} but English has {total_en} — mismatch!",
            file=sys.stderr,
        )
        return 1

    print(f"\nAll {total_en} prompts assigned. Coverage verified.")

    if args.dry_run:
        print("\nDry run — no files written.")
        return 0

    # Write output
    os.makedirs(args.output, exist_ok=True)

    for name in _ORDERED_GROUP_NAMES:
        batch = {
            "group":      name,
            "tone_note":  GROUP_META[name]["tone_note"],
            "brief_ref":  "docs/localization/polish-brief.md",
            "count":      len(groups[name]),
            "prompts":    groups[name],
        }
        out_path = os.path.join(args.output, f"{name}.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(batch, f, ensure_ascii=False, indent=2)

    if review_required:
        out_path = os.path.join(args.output, "review_required.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump({"group": "review_required", "prompts": review_required}, f,
                      ensure_ascii=False, indent=2)

    print(f"\nBatch files written to: {args.output}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
