# French Localization Brief

**Locale code:** `fr`  
**Status:** Translation complete; standardized brief added for future audit and maintenance  
**Last updated:** 2026-05-15

---

## Agent Non-Negotiables

Copy these into every French translation or audit-agent prompt:

- Use informal **tu** throughout; no formal `vous` except lexical items like `rendez-vous`.
- Hard-ban midpoint/slash/parenthetical forms: no `passionné·e`, `seul/e`, `prêt(e)`, etc.
- Avoid gendered predicates on the user: restructure `apprécié`, `valorisé`, `retombé amoureux`, `humilié`, `seul`, `prêt`, etc.
- Prefer active verbs, nouns, or infinitives: `je te valorise`, `un sentiment de reconnaissance`, `qui te fait tomber amoureux`.
- Avoid gendered partner/person defaults: no `chez lui/elle`, `son mari/sa femme`, `petit ami/petite amie` unless source specifies.
- Preserve directness; do not soften unfiltered or sex prompts into vague reflective language.
- Keep French natural and contemporary, not academic, corporate, or therapy-formal.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- Use natural contemporary French.
- Use informal **`tu`** throughout. Do not use formal `vous` as user address.
- Tone: warm, clear, emotionally sincere, conversational.
- Avoid stiff therapy-French, corporate phrasing, academic wording, or overly literary/poetic phrasing.
- Do not make prompts more intense than the English.
- Do not soften honest/unfiltered prompts so much that they lose directness.
- Preserve sentence-completion shape and ellipses where present.

---

## Gender and Person Rules

### Hard rule: no midpoint, slash, or parenthetical inclusive forms

Do **not** use:

- `passionné·e`, `fier·e`, `seul·e`, `prêt·e`
- `fatigué/e`, `heureux/se`
- `prêt(e)`, `seul(e)`
- any similar construction

Prefer natural neutral restructures instead.

| Avoid | Prefer |
|---|---|
| `passionné·e` | `qui te tient à cœur` |
| `fier·e` | `qui te remplit de fierté`, `que tu assumes` |
| `seul·e` | `par toi-même`, `en solitude`, `sans personne autour` |
| `heureux·se` | `ça te fait du bien`, `ça t'apporte de la joie` |
| `affecté·e` | `Quel effet ça a eu sur toi ?` |
| `choyé·e` | `être aux petits soins` |

### Gendered user predicates

Avoid applying gendered past participles or adjectives directly to the user.

Bad shapes:

- `tu te sens apprécié`
- `tu es retombé amoureux`
- `tu t'es senti humilié`

Preferred:

- Use active verbs: `je te valorise`, `ça te touche`
- Use nouns: `un sentiment de reconnaissance`, `de l'humiliation`
- Use infinitives: `qui te fait tomber amoureux`

### Partner/person references

- Avoid defaulting to a male or female partner.
- Prefer: `la personne que tu aimes`, `la personne en face de toi`, `l'autre personne`, `entre vous`, `dans votre relation`.
- `ton partenaire` is acceptable when natural, but do not overuse it.
- For friends/family unknown-gender people, avoid `chez lui` / `chez elle`; use `cette personne` or restructure.

---

## Sensitive Content

- Sex/intimacy: direct adult French; not clinical, crude, or coy.
- Grief/hardship/regret: grounded and respectful; avoid melodrama.
- Family: do not add traditional-duty or moral framing not present in English.
- Unfiltered: preserve directness; do not soften into vague reflective language.

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

- French often runs longer than English; keep UI labels concise.
- Preserve placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, `%2$lld`, `%3$@`.
- Scan `vous`, but exclude lexical items like `rendez-vous`.
- Avoid formal inverted questions if they feel stiff in app copy.

---

## Glossary

| English | French | Notes |
|---|---|---|
| prompt / question | question | |
| session | session | |
| Go Deeper | Aller plus loin | CTA/button. |
| Light | Léger | |
| Honest | Honnête / sincère | `sincère` often warmer. |
| Unfiltered | Sans filtre | |
| Warm Up | Échauffement / Mise en route | Context-dependent. |
| Real Talk | Vraie conversation | |
| Deep Dive | En profondeur | |
| connection / bond | lien | |
| closeness | proximité | |
| appreciation | reconnaissance / ce que tu apprécies | Context-dependent. |
| to feel appreciated / valued | se sentir reconnu | Established neutral choice. |
| to feel seen | se sentir compris / se sentir reconnu | Avoid literal `vu/vue` if gendered. |
| vulnerability | vulnérabilité | |
| sense of belonging | sentiment d'appartenance | Consider warmer `se sentir à sa place`. |
| to recharge | se ressourcer | |
| to show up for someone | être là pour quelqu'un | |
| daily life | vie quotidienne / quotidien | |
| grief / loss | deuil / perte | |
| desire | désir | |

---

## Coordinator Checklist

1. Scan for midpoint/slash/parenthetical forms: `·`, `/`, `(e)`.
2. Scan for `vous`, excluding `rendez-vous`.
3. Check gendered user predicates: `apprécié`, `valorisé`, `aimé`, `retombé`, `seul`, `prêt`, `fatigué`, `humilié`.
4. Check partner/person gender: `chez lui`, `chez elle`, `son mari`, `sa femme`, `petit ami`, `petite amie`.
5. Verify `se sentir reconnu` / neutral restructures for appreciation/seen/valued contexts.
6. Verify sentence completions preserve `…`.
7. Check sensitive prompts for softening or added intensity.
8. Verify no English leftovers except approved brand terms.
9. Preserve placeholders exactly.
