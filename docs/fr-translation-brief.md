# French Translation Brief — Connections App

**Locale code:** `fr`  
**Status:** Pilot validated (94/598 prompts). Ready to scale.  
**Last updated:** 2026-05-13

---

## Translation style

- Use natural contemporary French.
- Use informal **`tu`**, never **`vous`**.
- Tone: warm, clear, emotionally sincere, conversational.
- Avoid stiff therapy-French, corporate phrasing, academic wording, or overly literary/poetic phrasing.
- Do not make prompts more intense than the English.
- Do not soften honest/unfiltered prompts so much that they lose directness.
- Preserve sentence-completion shape and ellipses where present.
- Preserve emotional intensity: light stays light, honest stays honest, unfiltered stays direct.

---

## Gender/person rules

### Hard rule: no midpoint, slash, or parenthetical inclusive forms in app copy

Do **not** use:
- `passionné·e`, `fier·e`, `seul·e`, `prêt·e`
- `fatigué/e`, `heureux/se`
- `prêt(e)`, `seul(e)`
- any similar construction

Prefer natural neutral restructures instead:

| Avoid | Prefer |
|---|---|
| `passionné·e` | `qui te tient à cœur` |
| `fier·e` | `que tu assumes` — or restructure if user gender unknown |
| `coincé·e` | `dans une situation où tu ne peux pas sortir` / restructure |
| `seul·e` | `en solitude`, `sans personne autour`, `par toi-même`, or restructure |
| `heureux·se` | `ça te fait du bien`, `ça t'apporte de la joie`, or restructure |
| `affecté·e` | `Quel effet ça a eu sur toi ?` |
| `choyé·e` | `être aux petits soins` |
| `sorti·e` | `sorti` (masculine used as gender-neutral generic) |
| `fait·e` (pronominal + inf) | `fait` — `se faire + infinitive` is invariable in modern French |
| `resté·e debout` | `veiller` (`tu as veillé`) |
| `invité·e` | `Tu préfères inviter ou être invité ?` |

### Gendered user-addressed past participles/adjectives

Avoid applying gendered past participles or adjectives directly to the user as a predicate. These require gender agreement in French and assume the user's gender.

Bad examples:
- `pour que tu te sentes apprécié` (masculine)
- `tu te sens valorisé` (masculine)
- `tu es retombé amoureux` (masculine)

Preferred fixes:
- `apprécié` / `valorisé` → `reconnu` (neutral in this context)
- `retombé amoureux` → restructure using infinitive: `qui te fait encore tomber amoureux` avoids agreement on `tu`

### Partner/person references

- Avoid defaulting to a male or female partner.
- Prefer: `la personne que tu aimes`, `la personne en face de toi`, `l'autre personne`, `entre vous`, `dans votre relation`
- Use `ton partenaire` only when natural; it is grammatically masculine but commonly used as gender-neutral in French. Avoid `partenaire/partenaire` constructions.
- When referring to a friend of unknown gender, avoid `chez lui` / `chez elle`. Drop the pronoun or use `cette personne`.

---

## JSON integrity

- Translate only user-facing `text` fields (prompt and follow-up).
- Keep every prompt ID and follow-up ID **exactly unchanged**.
- Do not translate metadata: `mode`, `intensity`, `depth`, `topic`, `style`, `order`.
- Do not add or remove prompts or follow-ups.

---

## Brand terms — keep in English, unchanged

- Deeper Conversations
- Life Story
- Fall in Love
- Share an Experience

---

## Glossary

| English | French (preferred) | Notes |
|---|---|---|
| prompt / question | question | |
| session | session | |
| connection / bond | lien | |
| closeness | proximité | |
| appreciation | reconnaissance / ce que tu apprécies | context-dependent |
| communication | communication | |
| conflict | conflit | |
| growth | évolution / croissance | context-dependent |
| values | valeurs | |
| identity | identité | |
| vulnerability | vulnérabilité | |
| intimacy | intimité / proximité | context-dependent |
| to feel seen | se sentir compris | prefer over `se sentir vu/vue` |
| to feel appreciated / valued | se sentir reconnu | use consistently |
| safety | sécurité / se sentir en sécurité | |
| depth | profondeur | |
| letting go | lâcher prise / laisser partir | context-dependent |
| other person | l'autre personne / la personne en face de toi | |
| sense of belonging | sentiment d'appartenance | consider warmer alternatives: `se sentir à sa place`, `se sentir chez soi` |
| to recharge | se ressourcer | |
| to show up for someone | être là pour quelqu'un | |
| daily life / everyday | vie quotidienne / du quotidien | |
| late-night snack | snack du soir | |
| guilty pleasure | plaisir coupable | |

---

## Coordinator checklist (apply before every patch)

1. **Midpoint/slash/parenthetical scan** — grep for `·`, `/`, `(e)` in translated text; resolve every hit with a neutral restructure before applying
2. **`vous` scan** — flag any `\bvous\b` matches, **excluding** `rendez-vous` (it is a normal French noun, not formal address)
3. **Gendered user-addressed predicates** — check for `apprécié`, `valorisé`, `aimé`, `retombé`, `seul`, `prêt`, `fatigué`, and similar forms used as predicates directly on `tu`; replace with neutral equivalents
4. **Partner/person gender** — flag `chez lui`, `chez elle`, `son mari`, `sa femme`, `son petit ami`, `sa petite amie` used for unknown-gender partner; replace with neutral
5. **English leftovers** — check that no translated prompt still contains the English source text
6. **Glossary normalization** — verify preferred terms are used consistently
7. **Report every correction** before applying; note the original and the fixed version

---

## Agent output format

Each agent outputs a JSON patch file. Format:

```json
{
  "prompt_id_here": {
    "text": "French translation of main prompt",
    "followUps": {
      "followup_id_fu_1": "French translation of follow-up 1",
      "followup_id_fu_2": "French translation of follow-up 2"
    }
  }
}
```

Agents must **not** edit project files directly, must **not** create `prompts_fr.json`, and must **not** translate outside their assigned batch.

---

## Pilot notes (2026-05-13)

- Both pilot agents (connection_appreciation / light_warmup_everyday) maintained consistent tone.
- Agent A used colloquial `C'est quoi...` openings — natural and appropriate.
- Agent B used more formal question inversion (`Quelle est...`) — also appropriate for variety.
- Main issue: Agent B produced 11 midpoint forms. All fixed by coordinator. Brief has been updated with explicit rule and examples.
- `rendez-vous` triggered a false `vous` positive. Coordinator scan now excludes it.
- `se sentir reconnu` established as the standard neutral replacement for `se sentir apprécié/valorisé`.
