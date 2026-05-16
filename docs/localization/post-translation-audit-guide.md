# Post-Translation Audit Guide

## Purpose

This guide defines the review pass to run after a locale has already been translated, validated, and built. It is for **auditing**, not re-translating.

Use this when a language has no native-speaker review available, or when a completed localization needs one more quality-hardening pass before visual QA, TestFlight, or public release.

The audit should catch issues that structural tests cannot catch:

- Fluent but semantically wrong translations
- Follow-ups that drift from the exact English source
- Tone/register mismatches
- Gender, pronoun, or formality violations
- Sensitive-content vocabulary problems
- UI/paywall copy that is correct but awkward or too long

---

## Choose the Lightest Safe QA Path First

Do not default to a full multi-agent audit. Pick the smallest review workflow that matches the actual uncertainty.

| Situation | Use this path | Why |
|---|---|---|
| Scanner findings are already classified and fixes are known | **Direct coordinator patching** | Re-running agents only re-litigates settled decisions |
| Scanner findings are narrow but not classified | **One focused patching agent** | One reviewer can classify, patch, and validate faster than an audit swarm |
| One known category has systemic risk | **One targeted rewrite/cleanup agent** | Keeps voice consistent and avoids conflicting patch styles |
| Broad quality is unknown across prompts/guided/UI | **5-job audit structure** | Use only when semantic/tone/fidelity risk is still unknown |
| Findings exceed the escalation threshold | **Stop and redesign the cleanup pass** | Many individual patches signal a policy or first-pass failure |

### Direct Coordinator Patching

Use direct patching when the work is already bounded, for example:

- A scanner found 30 pronoun findings and a prior review has already decided which to drop, keep, or restructure.
- A copy-paste error has an exact documented fix.
- A grep target such as `相手` or `vous` needs a small perspective/formality check.
- A locale has a short list of known UI label fixes.

Direct patching rules:

1. Read the English source for every changed field.
2. Preserve the same question, relationship context, emotional intensity, and follow-up purpose.
3. Patch only the fields with a concrete issue.
4. Do not polish acceptable text just because it could be prettier.
5. Batch edits where possible.
6. Validate, run affected localization tests, and build if resources/UI changed.
7. Report before/after for every changed field.

### One Focused Patching Agent

Use one agent when findings are narrow but still need classification. Give the agent:

1. The exact scanner output or grep output.
2. The relevant language brief and `Agent Non-Negotiables`.
3. The affected localized fields plus English source text.
4. A strict output table: `false_positive`, `acceptable`, `requires_patch`, or `ambiguous`.
5. Permission to patch only `requires_patch` items with high confidence.

The agent must not perform a broad audit, rewrite unrelated strings, or review the whole locale.

### Full Multi-Agent Audit

Use the 5-job audit only when broad quality is genuinely unknown, such as:

- A new non-native-reviewed locale has not had adversarial review.
- A language has high silent-failure risk and no classified scanner decisions.
- Prior findings show repeated semantic drift, follow-up drift, or systemic grammar-policy failure.
- John explicitly asks for a full post-translation audit.

The Russian post-translation QA showed why this matters: a full audit plus separate patching pass is expensive and should be reserved for unresolved systemic risk. The Japanese cleanup showed the preferred path for bounded work: classified scanner findings plus known fixes can be patched directly in minutes.

---

## Source of Truth

Every audit agent must read:

1. `docs/localization/agent-translation-workflow.md`
2. The language-specific brief for the assigned locale
3. This audit guide
4. The English source content and translated target content for the assigned scope

The English source remains the source of record. Never judge a translation only against another translated locale.

---

## Auditor Role

Audit agents are reviewers, not rewrite agents.

**Hard rule:** Do not rewrite speculatively.

An auditor may propose a correction only when it identifies a concrete issue:

- Wrong meaning
- Missing source detail
- Added detail not in source
- Follow-up mismatch
- Register/formality violation
- Language-specific policy violation
- Sensitive-content tone problem
- Placeholder or formatting problem
- Clear grammar/naturalness problem that affects user experience

If a translation is acceptable but another wording might be prettier, approve it. Do not churn working translations.

---

## Audit Output Format

Each audited item must receive one of three statuses:

| Status | Meaning |
|---|---|
| `approve` | No action needed |
| `approve_with_notes` | Acceptable, but note a nuance, visual QA risk, or non-blocking concern |
| `requires_patch` | Concrete issue found; provide a correction |

For every `requires_patch`, include:

| Field | Required |
|---|---|
| `id` or key | Prompt ID, follow-up ID, guided-bank ID, or xcstrings key |
| `field` | `text`, `followUps[0].text`, `followUp1`, `fullText`, `localizations.<locale>`, etc. |
| `english_source` | Exact English source text |
| `current_translation` | Exact current translation |
| `issue` | Specific reason this is wrong or risky |
| `proposed_correction` | Replacement text only for the affected field |
| `confidence` | `high`, `medium`, or `low` |

Patch output should follow the same patch format used by translation agents. Notes can be Markdown; patches must be machine-readable JSON.

### Confidence Tiers

| Tier | Meaning | Coordinator action |
|---|---|---|
| `high` | Concrete, verifiable issue; no ambiguity about English meaning | Apply patch; no further review needed |
| `medium` | Likely issue but involves stylistic judgment or cultural nuance | Coordinator reviews before applying |
| `low` | Possible issue; uncertain without a fluent native speaker | Flag for native review; do not auto-apply |

### approve_with_notes Handling

`approve_with_notes` items are not patches. Append them to `<locale>_notes.md` in the audit output directory. They are context for visual QA or a future native-speaker review — not action items for the current pass.

### 25% Escalation Threshold

If `requires_patch` findings exceed **25% of total reviewed items** in any single job, stop and escalate to John before applying anything. This indicates a systematic quality problem requiring a full rewrite pass, not an audit patch cycle.

---

## Universal Audit Checklist

Run these checks for every language and every scope:

1. **Source fidelity** — the translated text asks the same question or communicates the same UI meaning.
2. **Follow-up fidelity** — each follow-up translates the exact English follow-up attached to the same ID.
3. **No semantic inversion** — watch for "avoid" becoming "try," "involuntary" becoming "wanted," "miss" becoming "remember," etc.
4. **No softening into vagueness** — emotional prompts must not become generic mood prompts.
5. **No over-intensifying** — light prompts must not become dramatic; honest prompts must not become harsh.
6. **Sentence-completion preservation** — English prompts ending in `…` must remain open-ended fragments ending in `…`.
7. **Brand terms** — Deeper Conversations, Fall in Love, Life Story, Share an Experience stay in English.
8. **English leftovers** — no untranslated English except approved brand terms.
9. **Metadata unchanged** — no IDs, modes, topics, depths, chapters, styles, counts, or order changes.
10. **UI placeholders** — all `%1$@`, `%2$@`, `%1$lld`, etc. are preserved; any reordering is intentional and reported.
11. **UI length and clarity** — flag long button/nav labels, paywall bullets, onboarding titles, and settings rows.
12. **Privacy/legal copy** — do not embellish claims; preserve meaning exactly.

---

## Risk Categories and Tone Rules

Use these category rules in addition to the language brief.

| Scope | Audit focus |
|---|---|
| Light prompts | Warm, easy, conversational. No therapy-speak or over-seriousness. |
| Honest prompts | Direct and emotionally sincere. Do not soften discomfort away. |
| Unfiltered prompts | Clear and direct, not cruel, shocking, vulgar, or accusatory. |
| Sex prompts | Adult and natural. Not clinical unless source is clinical; not crude; not coy or censored. |
| Intimacy prompts | Tender, emotionally safe, not generic romance copy. |
| Grief/loss/hardship | Quiet, respectful, spacious. No melodrama, no minimizing, no moralizing. |
| Family/intergenerational | Grounded and respectful. Do not add duty, tradition, or family-role assumptions not in source. |
| Friends | Warm and casual. Do not romance-code friendship prompts. |
| Solo reflection | Introspective but not self-help slogan language. |
| Life Story | Dignified, intergenerational, reflective. Legacy and hardship lines need extra care. |
| Paywall | Clear, accurate, low-pressure. No exaggerated claims. |
| Onboarding | Inviting and concise. Preserve app voice and avoid sounding instructional-heavy. |
| Settings/privacy | Clear and literal enough for user trust. Avoid marketing language. |

---

## 5-Job Audit Structure

Use this structure only when the triage section above says a full audit is warranted. Run five jobs per language. Generate packets with `generate_audit_packet.py`. All output lands in `/tmp/localization_audit_<locale>_<scope>/`.

| Job | Generator command | Agent reads | Focus |
|---|---|---|---|
| 1 | `--scope high_risk` | `<locale>_prompts_high_risk.md` | Sex prompts + unfiltered/deepDive prompts only |
| 2 | `--scope guided` | `<locale>_life_story_guided.md` | Full Life Story (50 items × 3 fields each) |
| 3 | `--scope guided` | `<locale>_fall_in_love.md` + `<locale>_share_experience.md` | Fall in Love (36) + Share an Experience (21) |
| 4 | `--scope ui` | `<locale>_ui.md` + `<locale>_privacy.md` | UI strings (325) + privacy policy |
| 5 | scanner + sample | Scanner output + 30-prompt random sample | Pattern violations + general fluency spot check |

Jobs 2 and 3 draw from the same `--scope guided` run — generate it once, hand different files to different agents.

### Job 5: Scanner + Sample

Run the scanner first:

```
python3 scripts/localization/scan_localization_patterns.py --locale <locale>
```

Select 30 prompts at random from `prompts_<locale>.json`, excluding sex/unfiltered (already covered by Job 1) and any items already flagged by the scanner. Give the agent: scanner findings + the 30 selected prompts with their English sources.

### Patching Efficiency Rules

Do not apply many tiny file writes through Xcode or an editor integration. Large JSON and xcstrings files can trigger expensive indexing, diff refreshes, or permission prompts on every write.

Use this order of preference:

1. One patch JSON applied through `scripts/localization/apply_polish_patch.py`.
2. Existing locale scripts such as `merge_xcstrings_locale.py` or `inspect_locale.py`.
3. One named helper script under `/tmp` for a special batch edit.
4. Manual `apply_patch` only for small documentation or code edits.

Avoid:

- `python3 -c "..."`
- Python heredocs such as `python3 - <<'PY'`
- Repeated single-field Xcode writes
- Repeated one-line rewrites of the same large JSON file

If a task has more than a handful of field edits, collect them first and apply them as one batch. Then validate once.

### Wave Scheduling for Big Five

Three waves of parallel agents:

| Wave | Languages | Jobs per language | Total agents |
|---|---|---|---|
| A | Italian, Swedish | 1–5 | 10 |
| B | Danish, Norwegian Bokmål | 1–5 | 10 |
| C | Finnish | 1–5 | 5 |

Run Japanese, Simplified Chinese, and Russian with the same 5-job structure but treat each as a solo wave — higher silent-failure risk warrants individual attention.

---

## Back-Translation Sampling

Back-translation is optional for low-risk languages and recommended for high-risk or non-native-reviewed languages.

Use it for:

- Simplified Chinese
- Japanese
- Russian
- Any language with suspiciously elegant but possibly softened translations
- Sensitive categories in any language when no fluent reviewer is available

Sample size:

- 30-50 prompts per language for broad audit
- Include sex, grief/loss, unfiltered, family, Life Story legacy, paywall, and onboarding
- For a pilot in a high-risk language, use 10 prompts and require back-translation or a source-fidelity summary before scaling

Back-translation rule:

The goal is not word-for-word matching. The goal is to verify the same emotional question, relationship context, and intensity survive.

---

## Language Checklist Matrix

Use this matrix to give audit agents a quick view of the language-specific traps. The full brief remains authoritative.

| Locale | Brief | Formality scan | Gender/person scan | Biggest risk | Sensitive review |
|---|---|---|---|---|---|
| `es` | `docs/localization/spanish-brief.md` | Informal Latin American `tú`; no formal `usted` | Neutral restructure preferred for gendered adjectives; no gendered partner assumptions | Gendered adjectives, emotional register, slash-form overuse | Recommended |
| `de` | `docs/localization/german-brief.md` | Informal `du`; no formal `Sie/Ihnen/Ihr` | Watch gendered partner/person pronouns; no colon/slash gender forms | Long compounds, stiff literal phrasing, gendered pronouns | Recommended |
| `fr` | `docs/localization/french-brief.md` | Informal `tu`; no `vous` except lexical items like `rendez-vous` | No midpoint/slash forms; avoid gendered predicates on user | Gendered predicates, softened directness, formal phrasing | Recommended |
| `pt-BR` | `docs/localization/brazilian-portuguese-brief.md` | Brazilian `você`; no EU-PT `tu` conjugations | Active/noun restructures for gendered adjectives; no gendered partner assumptions | Follow-up drift, EU-PT leakage, gendered predicates | Recommended |
| `it` | `docs/localization/italian-brief.md` | No formal `Lei/Suo/Sua` | Avoid masculine-default participles/adjectives; no gendered partner assumptions | Melodrama, gender agreement, literal calques | Recommended |
| `sv` | `docs/localization/swedish-brief.md` | Informal `du` | Watch neutral person references | Stiff literal phrasing, awkward compounds | Recommended |
| `da` | `docs/localization/danish-brief.md` | Informal `du` | Watch neutral person references | Clunky literal English structures, compounds/idioms | Recommended |
| `nb` | `docs/localization/norwegian-brief.md` | Informal `du`; no formal `De` | Neutral-first; avoid Swedish/Danish leakage | Wrong Norwegian variety, unnatural compounds | Recommended |
| `fi` | `docs/localization/finnish-brief.md` | Informal/pro-drop; avoid forced `sinä` | Naturally gender-neutral, but watch case/possessive structure | Case errors, long UI strings, over-explicit pronouns | Recommended |
| `nl` | `docs/localization/dutch-brief.md` | No `u/uw` | No `hij/zij`, `hem/haar`; use neutral `ze`, `diegene`, `je partner` | Compound errors, semantic inversion, wrong articles | Recommended |
| `pl` | `docs/localization/polish-brief.md` | Informal `ty`; no `Pan/Pani` | Neutral restructure first; no slash forms | Gendered verbs/adjectives, verb aspect | Native review available; still audit sensitive content |
| `ja` | `docs/localization/japanese-brief.md` | Avoid business/customer-service Japanese | Omit pronouns naturally; avoid overusing `あなた`, `私`, `パートナー` | Fluent but softened meaning, pronoun overload, fragment loss | Required for sensitive batches |
| `zh-Hans` | `docs/localization/simplified-chinese-brief.md` | No `您` | No `TA`, `他/她`; omit/restructure when natural | Fluent but generic/slogan-like, Traditional leakage, mode contamination | Required for sensitive batches |
| `ru` | `docs/localization/russian-brief.md` | Informal `ты`; no formal `вы/Вас/Вам/Ваш` | Neutral restructure first; report any masculine fallback; no slash forms | Gendered past tense/adjectives, aspect, literary over-elevation | Required for sensitive batches |

---

## Big Five Language Checklists

These checklists supplement the Universal Audit Checklist and the Language Checklist Matrix for the Big Five pending locales (IT/SV/DA/NB/FI). Run them on top of the matrix, not instead of it.

### Italian (`it`)

- No formal `Lei/Suo/Sua` anywhere — app uses informal `tu`
- Masculine-default agreement: flag `stressato`, `pronto`, `aperto`, `perso`, `connesso` without feminine counterpart or neutral restructure
- Melodrama check: sincere and grounded in sensitive prompts; not theatrical or operatic
- Calque check: English idiom structure carried into Italian word order is a red flag (e.g., "tenere il tempo" for "keep track")
- No gender-coded partner-role assumptions added beyond the English source

### Swedish (`sv`)

- `du` throughout; no `ni` or archaic formal address
- Compound word naturalness: read each compound aloud — if it sounds like a translation, flag it
- Word order: Swedish has strict V2 order; English SVO structures imported directly sound stiff
- Fragments ending in `…` must remain open-ended fragments, not completed sentences

### Danish (`da`)

- `du` throughout
- Compound words and hyphenation: Danish often splits where Swedish compounds
- English-literal constructions: Danish has stricter word order than English; calqued structure reads immediately wrong to a native speaker
- Fragments: Danish allows looser fragments than Swedish, but `…` endings must be preserved

### Norwegian Bokmål (`nb`)

- Text must be Bokmål, not Nynorsk: `ikke` (not `ikkje`), `jeg` (not `eg`), `ikke` (not `ikkje`), `er` (not `er`/`vert`), `å` infinitive (not `å`/`vera`)
- Swedish leakage: `ska` → `skal`; `är` → `er`; `och` → `og`; `med` is shared but check context
- Danish leakage: `kan` is shared; watch `har`/`hadde`, `vil`/`ville`, spelling differences
- `du` throughout; no formal `De`

### Finnish (`fi`)

- Case endings: Finnish encodes relationships through suffixes; check possessive constructions and postpositional phrases
- Pronoun avoidance: `sinä` should appear only for emphasis — Finnish is naturally pro-drop
- UI string length: Finnish words are long; flag any translated label that is 50%+ longer than the English source — it will likely overflow
- Verb agreement: conjugation should consistently address `sinä` (2nd person singular) throughout

---

## Known Failure Modes From This Project

These are real failure patterns observed during prior localization work. Audit agents should actively look for them.

| Failure mode | What happened | Audit response |
|---|---|---|
| Follow-up drift | Portuguese agents translated main prompts but replaced follow-ups with adjacent/invented questions | Compare every follow-up against English source |
| Semantic inversion | Dutch had "putting off being honest" translated as actively working on honesty | Check verbs like avoid, resist, miss, let go, carry, want, need |
| Gendered fallback | Polish/French/Portuguese/Russian-style languages default to gendered adjectives or past tense | Apply language-specific neutral restructure policy |
| Formality drift | Agents may use formal address in intimate app copy | Scan language-specific formal pronouns |
| Pronoun overload | Japanese/Chinese can sound translated when every English pronoun is preserved | Omit/restructure where natural while preserving meaning |
| Slogan/idiom drift | Chinese/Japanese can become polished but vague | Prioritize source fidelity over elegance |
| Melodrama | Italian/Russian can become over-literary or dramatic | Keep tone grounded and conversational |
| Compound invention | Dutch/Scandinavian/Germanic languages can produce plausible non-words | Verify compounds are standard/natural |
| Placeholder damage | UI strings can drop or duplicate `%@`/`%lld` placeholders | Run placeholder parity test and manual review |
| Brand leakage | Feature names can get translated inconsistently | Keep approved brand terms in English |

---

## Patch and Report Format

Auditors should submit:

1. A Markdown findings table
2. Optional patch JSON containing only concrete corrections
3. A short summary by risk category

Findings table:

```markdown
| status | id/key | field | issue | confidence | proposed action |
|---|---|---|---|---|---|
| requires_patch | p_example_001 | followUps[0].text | Follow-up answers adjacent source, not this ID | high | Apply patch |
| approve_with_notes | settings.paywall.footer | localizations.it | Long label, visual QA recommended | medium | No patch |
```

Patch JSON for `prompts_<locale>.json`:

```json
{
  "p_couples_light_warmUp_dailyLife_001": {
    "text": "Corrected prompt text",
    "followUps": [
      { "id": "p_couples_light_warmUp_dailyLife_001_fu_1", "text": "Corrected follow-up" }
    ]
  }
}
```

For `Localizable.xcstrings`, use the locale merge workflow or a key-value correction JSON:

```json
{
  "settings.language.appLanguage.subtitle": "Corrected UI string"
}
```

---

## Coordinator Responsibilities After Audit Agents Return

The coordinator must:

1. Deduplicate findings.
2. Reject speculative rewrites.
3. Apply only concrete, source-backed corrections.
4. Run validators for changed JSON banks.
5. Run affected localization tests.
6. Run build if app code, xcstrings, project, or bundled resources changed.
7. Report every applied correction with before/after.
8. Commit only if John has approved or the current session explicitly authorizes autonomous commits.

Default policy: no commit until John reviews.

Exception: if John explicitly authorizes autonomous end-to-end execution for the current session, commit according to that session's instructions. This exception does not carry over automatically.
