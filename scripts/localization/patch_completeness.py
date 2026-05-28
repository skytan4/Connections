#!/usr/bin/env python3
"""Apply localization completeness fixes: translate all English-passthrough strings.

Handles ~80 untranslated strings across ru, zh-Hans, ja, de, nl, pl, it, sv, da, nb, fi, fr.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
XCSTRINGS = ROOT / "Connections" / "Localizable.xcstrings"

# Translations organized as: { key: { locale: translation } }
PATCHES: dict[str, dict[str, str]] = {

    # ─── Life Story topic title (3 display keys) ──────────────────────────────
    "lifeStoryIntro.title": {
        "ru": "История жизни",
        "zh-Hans": "人生故事",
        "ja": "ライフストーリー",
        "de": "Lebensgeschichte",
        "nl": "Levensverhaal",
        "pl": "Historia życia",
        "it": "Storia di vita",
        "sv": "Livsberättelse",
        "da": "Livshistorie",
        "nb": "Livshistorie",
        "fi": "Elämäntarina",
    },
    "lifeStoryPlay.topBar.label": {
        "ru": "История жизни",
        "zh-Hans": "人生故事",
        "ja": "ライフストーリー",
        "de": "Lebensgeschichte",
        "nl": "Levensverhaal",
        "pl": "Historia życia",
        "it": "Storia di vita",
        "sv": "Livsberättelse",
        "da": "Livshistorie",
        "nb": "Livshistorie",
        "fi": "Elämäntarina",
    },
    "sessionBuilder.lifeStory.title": {
        "ru": "История жизни",
        "zh-Hans": "人生故事",
        "ja": "ライフストーリー",
        "de": "Lebensgeschichte",
        "nl": "Levensverhaal",
        "pl": "Historia życia",
        "it": "Storia di vita",
        "sv": "Livsberättelse",
        "da": "Livshistorie",
        "nb": "Livshistorie",
        "fi": "Elämäntarina",
    },

    # ─── Share an Experience top bar ──────────────────────────────────────────
    "shareExperience.topBar.label": {
        "ru": "Поделиться опытом",
        "zh-Hans": "分享故事",
        "ja": "体験をシェア",
        "de": "Erlebnisse teilen",
        "nl": "Ervaring delen",
        "pl": "Podziel się historią",
        "it": "Condividi un'esperienza",
        "sv": "Dela en upplevelse",
        "da": "Del en oplevelse",
        "nb": "Del en opplevelse",
        "fi": "Jaa kokemus",
    },

    # ─── Fall in Love topic name ───────────────────────────────────────────────
    "topic.fallInLove": {
        "ru": "Влюбиться",
        "zh-Hans": "坠入爱河",
        "ja": "恋に落ちる",
        "de": "Verlieben",
        "nl": "Verliefd worden",
        "pl": "Zakochać się",
        "it": "Innamorarsi",
        "sv": "Förälska dig",
        "da": "Bliv forelsket",
        "nb": "Bli forelsket",
        "fi": "Rakastua",
    },

    # ─── Fall in Love play view top bar (couples) ──────────────────────────────
    "fallInLovePlay.topBar.couples": {
        "ru": "Влюбиться",
        "zh-Hans": "坠入爱河",
        "ja": "恋に落ちる",
        "de": "Verlieben",
        "nl": "Verliefd worden",
        "pl": "Zakochać się",
        "it": "Innamorarsi",
        "sv": "Förälska dig",
        "da": "Bliv forelsket",
        "nb": "Bli forelsket",
        "fi": "Rakastua",
    },

    # ─── Fall in Love play view top bar (friends: "Get Closer") ───────────────
    "fallInLovePlay.topBar.friends": {
        "it": "Avvicinarsi",
        "fi": "Lähentyä",
    },

    # ─── Fall in Love intro title (couples: "Fall in love again") ─────────────
    "fallInLoveIntro.title.couples": {
        "sv": "Förälska dig igen",
        "nb": "Bli forelsket igjen",
    },

    # ─── Favorites context labels ─────────────────────────────────────────────
    "favoritesPlay.context.fallInLove": {
        "ja": "36の質問 · %1$@",
        "it": "36 domande · %1$@",
        "sv": "36 frågor · %1$@",
        "fi": "36 kysymystä · %1$@",
        "fr": "36 questions · %1$@",
    },
    "favoritesPlay.context.shareExperience": {
        "ru": "Поделиться опытом · %1$@",
        "zh-Hans": "分享故事 · %1$@",
        "ja": "体験をシェア · %1$@",
        "nl": "Ervaring delen · %1$@",
        "pl": "Podziel się historią · %1$@",
        "it": "Condividi un'esperienza · %1$@",
        "sv": "Dela en upplevelse · %1$@",
        "fi": "Jaa kokemus · %1$@",
    },

    # ─── Danish session length labels ─────────────────────────────────────────
    "sessionLength.five.label": {
        "da": "5 spørgsmål",
    },
    "sessionLength.ten.label": {
        "da": "10 spørgsmål",
    },
    "sessionLength.twenty.label": {
        "da": "20 spørgsmål",
    },
}


def patch(strings: dict, key: str, locale: str, value: str) -> bool:
    entry = strings.get(key)
    if entry is None:
        print(f"  SKIP (key not found): {key}")
        return False
    locs = entry.setdefault("localizations", {})
    if locale not in locs:
        locs[locale] = {"stringUnit": {"state": "translated", "value": value}}
        return True
    su = locs[locale].get("stringUnit", {})
    old = su.get("value", "")
    if old == value:
        return False  # already correct
    su["value"] = value
    su["state"] = "translated"
    locs[locale]["stringUnit"] = su
    return True


def main() -> None:
    data = json.loads(XCSTRINGS.read_text(encoding="utf-8"))
    strings = data["strings"]
    changed = 0

    for key, locale_map in PATCHES.items():
        for locale, value in locale_map.items():
            if patch(strings, key, locale, value):
                changed += 1
                print(f"  patched  {key} [{locale}] → {value!r}")

    XCSTRINGS.write_text(
        json.dumps(data, ensure_ascii=False, indent=2, sort_keys=False) + "\n",
        encoding="utf-8",
    )
    print(f"\nDone. {changed} strings updated in {XCSTRINGS.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
