# Gentle Recall UI Guidance

Updated: 2026-04-28

## Purpose

This document is the working UI standard for Gentle Recall.

Use it to:

- keep current screens visually and structurally consistent
- reduce one-off design decisions as new practice areas are added
- give Claude a stable target for implementation work
- avoid future rework when iPad layouts and more exercises are added

## Screens Reviewed

- `A calm place to practice memory.`
- `Lists and Errands`
- `Names and Faces`
- `Progress`
- `Today's practice`
- `Settings`

## Product Direction To Preserve

- Calm, premium, and warm
- Encouraging rather than evaluative
- One clear primary action per screen
- Large-text friendly without looking clinical
- Local-first and trust-building
- Easy to extend to iPad without redesigning the product model

## Screen Review

### `A calm place to practice memory.`

Keep:

- Clean, chrome-light onboarding stages
- Strong single-column reading flow
- Primary action fixed near the bottom
- Privacy reassurance early in the flow

Adjust:

- Treat each stage as one main message, not a stack of many equally loud blocks
- Use one primary card per stage when possible
- Keep goals and preferences as selection surfaces, but avoid making them feel like forms
- Add a subtle sense of progress later if needed, but do not turn onboarding into a wizard UI

Standard:

- Each onboarding stage should contain:
  - one headline
  - one short explanation
  - one main interaction area
  - one primary action
- Selection surfaces in onboarding should be self-labeling and directly tappable; avoid form-style label-above-field layouts unless the control is truly a settings control.

### `Lists and Errands`

Keep:

- Three-phase flow: study, bridge, recall
- Strong practice context label
- One large clear instruction at a time
- Optional strategy card in a secondary visual role

Adjust:

- Treat the study card as the visual anchor of the screen
- Keep item rows visually light and highly scannable
- Avoid adding extra instructional copy under the main title unless it truly reduces confusion

Standard:

- Practice screens should follow this order:
  - context label
  - main instruction
  - primary content card
  - optional strategy support
  - one primary button

### `Names and Faces`

Keep:

- Same phase structure as `Lists and Errands`
- Distinct study presentation with name prominence and softer detail text
- Structured content model rather than reparsed display strings

Adjust:

- Names should remain the dominant line
- Details should stay quieter and slightly more spacious than list items
- Avoid adding decorative avatar imagery unless it materially helps recall

Standard:

- The visual hierarchy for each person should be:
  - name first
  - detail second
  - enough spacing to prevent adjacent people from visually blending together

### `Progress`

Keep:

- Area-by-area cards
- Warm language instead of score-heavy language
- Attempt-level feedback and recent-round trend

Adjust:

- Keep metric density low
- Use one consistent card order across all areas
- Prefer trend interpretation over raw numbers wherever possible
- Add next-step guidance later before adding more charts

Standard card order:

- area title and icon
- difficulty badge
- primary stats
- confidence signal
- recent rounds
- last practiced

### `Today's practice`

Keep:

- Simple introduction and one obvious next action
- Best-next-step framing
- Privacy reassurance present in the app home, not just onboarding

Adjust:

- The best-next-step card should remain the visual focal point
- Support cards below it should stay lighter in emphasis
- Avoid adding multiple competing calls to action on the home screen

Standard:

- `Today's practice` should always answer:
  - what should I do next
  - why this is the right next step
  - what reassurance do I need right now

### `Settings`

Keep:

- Familiar native form structure
- Reading, practice length, privacy, and data grouped logically

Adjust:

- Keep Settings plainly functional rather than overly styled
- Use native controls where possible
- Reserve custom visual treatment for high-emotion and practice-flow screens, not utility screens

Standard:

- `Settings` should feel stable and familiar, not decorative

## Shared Layout Rules

- Prefer one primary column on iPhone
- Use a small number of strong cards instead of many weak containers
- Keep section stacking consistent: title block, content block, action block
- Avoid dense horizontal layouts on phone unless the content is trivially short
- Keep the most important action within natural thumb reach near the lower portion of the screen
- Do not let secondary actions visually compete with the primary action

## Typography And Readability Rules

- `hero` is for the main screen headline only
- `screenTitle` is for the main instruction in a practice phase
- `sectionTitle` is for card titles and secondary headings
- `body` is for all explanatory copy
- `label` is for prominent row content, short value phrases, and button text
- `caption` is for quiet support text, context tags, and timestamps
- Avoid mixing too many font roles in the same card
- Readability mode must work through shared typography behavior, not screen-local hacks

## Spacing And Card Rules

- Preserve generous outer padding on reading-heavy screens
- Use one spacing rhythm per screen section instead of many slightly different gaps
- Keep support cards visually soft and breathable
- Use rounded cards as calm containers, not as decoration for every small element
- If a card contains the main task, it should be visually stronger than informational cards around it

## Color And Emphasis Rules

- Warm neutral surfaces remain the default
- Accent color is for:
  - primary buttons
  - icons with meaning
  - lightweight progress emphasis
- Do not use accent color as a substitute for hierarchy everywhere
- Color must not carry meaning alone

## Copy And Tone Rules

- Say `practice` more often than `test`
- Normalize challenge without dramatizing failure
- Prefer short, supportive sentences
- Avoid sounding clinical, juvenile, or gamey
- Do not stack reassurance messages unnecessarily; one clear reassurance is stronger than three diluted ones
- Empty states should be quiet and forward-looking, not apologetic or overly explanatory

## Motion Rules

- Keep transitions calm, readable, and unhurried
- Default to simple fades and gentle `easeInOut` timing in the roughly `0.25s` to `0.35s` range
- Avoid bouncy, spring-heavy, or attention-seeking motion in practice flows

## Accessibility Rules

- Every meaningful interaction must remain understandable without relying on color alone
- Accessibility labels, hints, and summaries must follow the same localization rules as visible text
- Toggle-driven accessibility settings must have a real visible effect
- Large text must remain usable without clipping, cramped cards, or hidden actions
- Practice content should remain finishable in VoiceOver-friendly reading order

## iPad And Adaptive Layout Rules

- Do not redesign the app for iPad as a different product
- Keep the same mental model as iPhone
- On iPad, prefer widening content before multiplying panels
- Natural iPad adaptations:
  - two cards side by side when they are peers
  - wider study cards
  - roomier progress grids
  - more horizontal breathing room around the primary column
- Avoid hard-coded widths that assume phone-only layouts
- Build adaptive layout decisions at the container level, not into the domain logic

## Implementation Rules For Claude

- Refer to screens by the visible title at the top of the screen
- Before changing a screen, check whether the change matches the structure in this document
- Reuse existing visual patterns before inventing a new one
- If a new practice area needs a unique treatment, keep the phase structure familiar even if the content card changes
- Keep primary-action placement and visual hierarchy consistent across practice screens
- Do not add visual complexity unless it clearly improves comprehension or confidence

## Do Not Drift From This

- One clear primary action per screen
- One primary content card per practice phase
- Calm premium tone over “brain game” energy
- Structured, localization-safe content models
- Accessibility-first behavior that is real, not symbolic
- iPad-friendly layout choices at build time, not as a later rescue project

## Next Review Trigger

Review this document again when one of these happens:

- the third practice area lands
- the first iPad-specific layout adjustments are introduced
- the first non-English localization pass begins
- the home or progress screen gains significantly more complexity
