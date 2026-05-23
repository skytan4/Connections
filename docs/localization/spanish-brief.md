# Spanish Localization Brief

**Locale code:** `es`  
**Variant:** Latin American Spanish  
**Status:** Translation complete; brief added retroactively for future audit and maintenance  
**Last updated:** 2026-05-15

---

## Agent Non-Negotiables

Copy these into every Spanish translation or audit-agent prompt:

- Use Latin American Spanish and informal **tú** throughout; no formal `usted`, `su`, `le` as user address.
- Avoid gendered user predicates where practical: `cansado`, `listo`, `orgulloso`, `visto`, `valorado`, `solo`.
- Prefer verbs/nouns/restructures: `sientes orgullo`, `sentiste que te veía`, `en soledad`, `por tu cuenta`.
- Use `tu pareja`, `la otra persona`, `esa persona`, or omission for unknown-gender partner/person references.
- Avoid `él/ella`, `novio/novia`, `esposo/esposa` unless source specifies.
- Keep emotional tone warm and grounded, not clinical, corporate, or melodramatic.
- Keep sex/intimacy adult and natural, not crude, clinical, or coy.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- Use warm, natural Latin American Spanish.
- Use informal **`tú`** throughout. Do not use formal `usted`, `su`, `le`, or `lo/la` as formal address to the user.
- Tone should feel emotionally intelligent, inviting, and conversational — not clinical, corporate, academic, or overly poetic.
- Preserve emotional intensity: light stays accessible, honest stays sincere, unfiltered stays direct.
- Preserve ellipses (`…`) in sentence-completion prompts. If English ends in `…`, Spanish must also end in `…` and remain an unfinished fragment.

---

## Gender Policy

Spanish has gendered adjectives and participles. Avoid assuming the user's gender when possible.

**Preferred strategies:**

| Risk | Prefer |
|---|---|
| `cansado/a`, `listo/a`, `orgulloso/a` | Restructure with nouns or verbs: `con cansancio`, `con preparación`, `sientes orgullo` |
| `te sentiste visto/a` | `sentiste que te veía`, `sentiste que alguien te entendía` |
| `solo/a` | `en soledad`, `sin compañía`, `por tu cuenta` |
| Gendered partner pronouns | `tu pareja`, `la otra persona`, omit pronoun |

Slash forms like `/a` are acceptable only when a natural restructure would be significantly worse. Prefer restructuring for app copy, especially prompts and UI labels.

---

## Partner and Person References

- `tu pareja` is the preferred neutral couples term.
- Avoid assuming gender with `él`, `ella`, `novio`, `novia`, `esposo`, or `esposa` unless the English source specifies.
- For friends/family unknown-gender people, prefer `esa persona`, `alguien`, `quien`, or restructure.

---

## Sensitive Content

- Sex/intimacy: natural adult register; not crude, not clinical, not coy.
- Grief/hardship/regret: grounded and spacious; avoid minimizing language like `a todos les pasa`.
- Family: warm and culturally natural, but do not add duty, religion, or moral framing not present in English.
- Unfiltered: direct but not harsh.

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

- Spanish strings can be longer than English; keep buttons and headings concise.
- Preserve placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, `%2$lld`, `%3$@`.
- Avoid formal or bureaucratic UI language.
- Use clear, friendly labels rather than literal English calques.

---

## Glossary

| English | Spanish | Notes |
|---|---|---|
| prompt / question | pregunta | Natural. |
| session | sesión | Standard. |
| Go Deeper | Profundizar / Ir más profundo | Context-dependent. |
| Light | Ligero | UI/intensity label. |
| Honest | Honesto / Sincero | `Sincero` often warmer. |
| Unfiltered | Sin filtro | Natural. |
| Warm Up | Calentamiento | Or warmer per UI context. |
| Real Talk | Conversación honesta | Avoid untranslated English unless branded. |
| Deep Dive | Profundizar / Inmersión profunda | Context-dependent. |
| partner | pareja | Neutral. |
| connection / bond | conexión / vínculo | `vínculo` is warmer. |
| closeness | cercanía | Natural. |
| intimacy | intimidad | Emotional/physical context. |
| vulnerability | vulnerabilidad | Direct. |
| appreciation | aprecio / reconocimiento | Use `gratitud` only when English means gratitude. |
| grief / loss | duelo / pérdida | Context-dependent. |
| desire | deseo | Natural adult register. |

---

## Coordinator Checklist

1. Scan for formal address: `usted`, `ustedes`, `su`, `le` where it addresses the user formally.
2. Scan for gendered user predicates: `cansado`, `listo`, `orgulloso`, `visto`, `valorado`, `solo`.
3. Prefer neutral restructures over `/a` notation in final app copy.
4. Check partner references for `él/ella`, `novio/novia`, `esposo/esposa`.
5. Verify sentence completions preserve `…` and remain fragments.
6. Check sensitive prompts for softening or added moral/religious framing.
7. Verify no English leftovers except approved brand terms.
8. Preserve placeholders exactly.
