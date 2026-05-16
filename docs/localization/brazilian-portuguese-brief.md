# Brazilian Portuguese Localization Brief

**Locale code:** `pt-BR`  
**Status:** Translation complete; brief added retroactively for future audit and maintenance  
**Last updated:** 2026-05-15

---

## Agent Non-Negotiables

Copy these into every Brazilian Portuguese translation or audit-agent prompt:

- Use Brazilian **você** throughout; do not use European Portuguese `tu` conjugations such as `és`, `tens`, `fazes`, `queres`, `estás`.
- Preserve natural BR-PT `te` usage where idiomatic; do not over-formalize into European-sounding phrasing.
- Avoid gendered user predicates like `sozinho`, `valorizado`, `cuidado`, `orgulhoso`, `pronto`; prefer active verbs or noun restructures.
- For valued/cherished/appreciated, prefer `reconhecimento`, `valorizar`, or `eu te valorizo` over gendered participles.
- Translate every follow-up against the exact English follow-up for the same ID; do not substitute adjacent or invented follow-ups.
- Avoid gendered partner/person assumptions: no default `ele/ela`, `dele/dela`, `namorado/namorada`, `marido/esposa`.
- Keep sex/intimacy adult and natural, not vulgar, clinical, or coy.
- Preserve `…` sentence completions as fragments.
- Keep brand terms in English: Deeper Conversations, Life Story, Fall in Love, Share an Experience.
- Preserve all JSON IDs, metadata, order, and UI placeholders exactly.

---

## Register

- Use natural Brazilian Portuguese.
- Use **`você`** throughout, with natural Brazilian `te` clitic usage where idiomatic.
- Do not use European Portuguese `tu` conjugations (`és`, `tens`, `fazes`, `queres`) as user address.
- Tone should feel warm, emotionally intelligent, conversational, and grounded.
- Avoid corporate, clinical, academic, or overly poetic phrasing.
- Preserve emotional intensity: light stays easy, honest stays sincere, unfiltered stays direct.
- Preserve ellipses (`…`) in sentence-completion prompts. If English ends in `…`, Portuguese must too, and must remain a fragment.

---

## Gender Policy

Brazilian Portuguese has gendered adjectives and participles. Avoid assuming the user's gender.

**Preferred strategies:**

| Risk | Prefer |
|---|---|
| `sozinho/sozinha` | `sensação de solidão`, `sem companhia`, `por conta própria` |
| `valorizado/valorizada` | Active verb: `eu te valorizo`, `você sente que eu reconheço` |
| `cuidado/cuidada` | Noun/restructure: `por precisar de cuidado`, `sentir cuidado` |
| `orgulhoso/orgulhosa` | `sensação de orgulho`, `ter orgulho de` |
| `pronto/pronta` | `ter maturidade`, `estar em condições`, restructure |

Avoid slash/parenthetical forms in final app copy. Prefer active verbs, nouns, or full sentence restructures.

---

## Partner and Person References

- `parceiro/parceira` is gendered; use only when the context can support it or when source specifies.
- Prefer `a pessoa ao seu lado`, `a outra pessoa`, `essa pessoa`, `vocês dois`, `a relação de vocês`.
- Avoid `ele/ela`, `dele/dela`, `namorado/namorada`, `marido/esposa` unless the English source specifies.

---

## Follow-Up Fidelity

Portuguese had a known project failure mode: agents translated main prompts but replaced follow-ups with adjacent or invented questions.

**Hard rule:** Every follow-up must translate the exact English follow-up attached to that ID. Do not summarize, substitute, reorder, or invent a nearby reflective question.

Coordinator must compare follow-ups against English source, especially in `prompts_pt-BR.json`.

---

## Sensitive Content

- Sex/intimacy: direct adult Brazilian Portuguese; not vulgar, not clinical, not coy.
- Grief/hardship/regret: gentle and grounded; avoid minimizing language.
- Family: natural and warm, but do not add religious, moral-duty, or traditional-role assumptions.
- Unfiltered: preserve the edge without becoming aggressive.

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

- Brazilian Portuguese strings can be longer than English; check onboarding, paywall, settings, and session setup.
- Preserve placeholders exactly: `%1$@`, `%2$@`, `%1$lld`, `%2$lld`, `%3$@`.
- Use clear Brazilian UI language. Avoid European phrasing.
- Keep one-time purchase/paywall wording concrete and trust-preserving.

---

## Glossary

| English | Portuguese BR | Notes |
|---|---|---|
| prompt / question | pergunta | Natural. |
| session | sessão | Standard. |
| Go Deeper | Ir Mais Fundo | Existing UI style. |
| Light | Leve | |
| Honest | Honesto / Sincero | `Sincero` often warmer. |
| Unfiltered | Sem filtro | |
| Warm Up | Aquecimento | |
| Real Talk | Conversa sincera | |
| Deep Dive | Aprofundamento / Mais fundo | Context-dependent. |
| partner | a pessoa ao seu lado / parceiro | Context-dependent; avoid gender assumptions. |
| connection / bond | conexão / vínculo | `vínculo` warmer. |
| closeness | proximidade | |
| intimacy | intimidade | |
| appreciation | reconhecimento / valorização | `reconhecimento` established. |
| valued / cherished | valorizar / reconhecer | Prefer active verbs over gendered participles. |
| loneliness | sensação de solidão | Avoid `sozinho/sozinha` when user-gendered. |
| running on empty | no limite | Natural idiom. |
| bucket list | lista de desejos | |
| catch yourself doing | se pegar + gerúndio | Natural BR-PT. |
| grief / loss | luto / perda | |
| desire | desejo | |

---

## Coordinator Checklist

1. Scan for European Portuguese user address: `és`, `tens`, `fazes`, `queres`, `estás`.
2. Scan for gendered user predicates: `sozinho`, `valorizado`, `cuidado`, `orgulhoso`, `pronto`, `cansado`.
3. Prefer active verb/noun restructures over slash forms.
4. Compare every follow-up against the exact English follow-up for that ID.
5. Check partner/person references for `ele/ela`, `dele/dela`, `namorado/namorada`, `marido/esposa`.
6. Verify sentence completions preserve `…`.
7. Check sensitive prompts for softening or added moral/religious framing.
8. Verify no English leftovers except approved brand terms.
9. Preserve placeholders exactly.
