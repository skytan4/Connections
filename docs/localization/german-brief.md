# German Localization Brief

**Locale code:** `de`  
**Status:** Translation complete; brief added retroactively for future audit and maintenance  
**Last updated:** 2026-05-15

---

## Agent Non-Negotiables

Copy these into every German translation or audit-agent prompt:

- Use informal **du** throughout; never use formal `Sie`, `Ihnen`, `Ihr`, or `Ihre` as user address.
- Do not assume gender for partner/person references; avoid default `er`, `ihn`, `ihm`, `sein` for unknown people.
- Prefer `die andere Person`, `dein Gegenüber`, `die Person an deiner Seite`, `ihr beide`, `zwischen euch`.
- Reject colon/slash gender forms such as `Partner:in`, `Partner/in`, `Partner(in)`; restructure naturally.
- Use `Sex` when English explicitly says sex; do not euphemize everything as `Nähe`.
- Keep German clear and grounded; avoid overlong compounds and stiff literal English structures.
- Preserve strict source fidelity for follow-ups; translate the exact attached follow-up.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- Use warm, natural contemporary German.
- Use informal **`du`** throughout. Do not use formal `Sie`, `Ihnen`, `Ihr`, or `Ihre` as address to the user.
- Tone should feel intimate and thoughtful, not therapy-formal, bureaucratic, corporate, or overly literary.
- German can become long and abstract. Prefer clear, grounded phrasing.
- Preserve ellipses (`…`) in sentence-completion prompts. If English ends in `…`, German must too, and must remain an unfinished fragment.

---

## Gender and Person Policy

German has gendered nouns and pronouns. Avoid assuming user, partner, friend, or family-member gender.

**Hard rules:**

| Avoid | Prefer |
|---|---|
| `er`, `ihn`, `ihm`, `sein` for unknown-gender partner/person | `die andere Person`, `dein Gegenüber`, `dieser Mensch`, omit |
| `Partner:in`, `Partner/in`, `Partner(in)` | Natural restructure |
| `dein Mann`, `deine Frau`, `Freund/Freundin` | Only if English specifies |
| Formal `Sie` | Informal `du` |

`dein Partner` is acceptable as a common generic couples term, but avoid overusing it when a warmer neutral phrase works better.

Preferred alternatives:

- `die Person an deiner Seite`
- `dein Gegenüber`
- `die andere Person`
- `ihr beide`
- `zwischen euch`
- `in eurer Beziehung`

---

## Sensitive Content

- Sex/intimacy: direct adult German. Use `Sex` when English says sex; do not euphemize everything as `Nähe`.
- Intimacy/closeness: `Nähe`, `Intimität`, `Verbindung`, depending on context.
- Grief/hardship/regret: restrained and grounded; avoid melodrama.
- Family: natural and respectful; do not add moral duty or traditional role framing.
- Unfiltered: direct and emotionally honest, not aggressive.

---

## German-Specific Risks

### Overlong Compounds

German compounds can become technically correct but visually heavy. For UI labels and prompts, split or simplify when a compound feels unnatural.

### Gendered Pronoun Drift

Audit `ihn`, `ihm`, `sein`, `er` carefully. Many hits are grammatical references to masculine nouns, but any unknown-gender person reference needs review.

### Stiff Question Inversion

German questions can become formal if translated too literally. Prefer conversational order when natural.

### English Calques

Watch for literal imports of English idioms. German should sound like German, not English with German words.

---

## Brand Terms

Keep these in English:

| Term | Policy |
|---|---|
| Deeper Conversations | English only |
| Life Story | English only |
| Fall in Love | English only |
| Share an Experience | English only |

---

## UI Guidance

- German strings can run 20–40% longer than English. Keep buttons and nav labels concise.
- Preserve placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, `%2$lld`, `%3$@`.
- Avoid bureaucratic UI words where warmer options exist.
- Watch compact screens for wrapping in settings, paywall, onboarding, and session setup.

---

## Glossary

| English | German | Notes |
|---|---|---|
| prompt / question | Frage | Natural. |
| session | Sitzung / Session | `Session` may fit app UI; `Sitzung` can feel therapy-like. |
| Go Deeper | Tiefer gehen | CTA/button. |
| Light | Leicht | Intensity label. |
| Honest | Ehrlich | Natural. |
| Unfiltered | Ungefiltert | Natural. |
| Warm Up | Aufwärmen | Natural. |
| Real Talk | Ehrliches Gespräch | Avoid stiff literal English. |
| Deep Dive | Tiefgang / Tiefer eintauchen | Context-dependent. |
| partner | Partner / die Person an deiner Seite | Avoid gendered pronouns. |
| other person | dein Gegenüber / die andere Person | Natural. |
| connection / bond | Verbindung | |
| closeness | Nähe | Warm. |
| intimacy | Intimität / Nähe | Context-dependent. |
| vulnerability | Verletzlichkeit / Offenheit | `Offenheit` is softer. |
| appreciation | Wertschätzung | |
| grief / loss | Trauer / Verlust | Context-dependent. |
| desire | Verlangen / Lust | `Lust` more sexual. |

---

## Coordinator Checklist

1. Scan for formal address: `Sie`, `Ihnen`, `Ihr`, `Ihre`.
2. Scan `er/ihn/ihm/sein` and verify no unknown-gender person or partner assumption.
3. Reject colon/slash/parenthetical gender forms like `Partner:in`.
4. Check German compounds for naturalness and UI length.
5. Verify sentence completions preserve `…`.
6. Check sex prompts use direct adult register and do not over-euphemize.
7. Check sensitive prompts for over-literary or tragic tone.
8. Verify no English leftovers except approved brand terms.
9. Preserve placeholders exactly.
