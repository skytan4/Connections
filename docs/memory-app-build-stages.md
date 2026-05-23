# Memory App Build Stages

Updated: 2026-04-27

## Purpose

This document defines the order the app should be built in to minimize recoding.

The guiding idea is simple:

Build the bones first, then the first complete path, then the repeated variants, then polish.

For this app, the biggest recoding risks are:

- Building exercise flows as one-offs
- Hard-coding copy, colors, or layouts into screens
- Treating onboarding, progress, and practice as separate systems
- Adding persistence after the UI already assumes transient state
- Building iPhone-only layouts that break when expanded later

## Core Build Principle

We should not build four exercise apps.

We should build:

1. One app shell
2. One shared exercise framework
3. One shared persistence/history layer
4. One shared progress pipeline
5. One shared design/localization/accessibility system

Then we plug individual practice areas into that system.

## Architecture Rules To Prevent Rework

- No hard-coded user-facing strings in screens
- No hard-coded colors or tint logic in screens
- No exercise-specific persistence model unless the shared model truly cannot support it
- No charts that depend on area-specific custom state shape
- No onboarding logic that bypasses the same adaptation engine used in practice
- No "temporary" UI components for MVP if they will obviously need to be reused

## Recommended Build Order

## Stage 0: Product Freeze For Foundation

Before coding, lock these decisions:

- The four MVP practice areas
- The five MVP skills
- Local-only data
- No required accounts
- Accessibility-first
- Localization-ready
- iPhone-first, iPad-expandable

This prevents foundational architecture from shifting mid-build.

## Stage 1: App Spine

Build the non-negotiable foundation first.

Includes:

- Root app state
- Navigation shell
- Theme tokens
- Typography and spacing tokens
- Localization scaffolding
- Accessibility helpers and conventions
- Core enums and shared models

Goal:

- The app can launch into a stable shell with placeholder screens
- Every future screen already uses theme and localization correctly

Why first:

- This avoids rewriting every screen later for color, copy, and layout rules

## Stage 2: Persistence And Shared State

Build the local data layer before real feature screens.

Includes:

- `UserProfile`
- `AreaState`
- `PracticeSession`
- `PracticeAttempt`
- `SkillProgress`
- Reset/delete path
- Repository or store interfaces

Goal:

- The app can load/save profile state and session history locally

Why now:

- If practice and onboarding are built before persistence, they often need to be rewritten around real data later

## Stage 3: Shared Exercise Framework

Build the reusable exercise engine before implementing any single practice area fully.

Includes:

- Exercise definition model
- Round state model
- Session state model
- Shared intro / play / result flow
- Shared feedback presentation
- Shared help affordance
- Shared result-writing hooks into persistence

Goal:

- One generic exercise path works with stubbed content

Why now:

- This is the biggest rework saver in the whole app
- Without this, each practice area tends to become its own custom mini-app

## Stage 4: Adaptive Difficulty Engine

Build the adaptation logic as a service before scaling content.

Includes:

- Warm-up calibration logic
- Starting difficulty recommendation
- In-session up / hold / down decisions
- Per-area state updates
- Booster recommendation flags

Goal:

- The same engine powers onboarding calibration and normal practice

Why now:

- If onboarding and practice each invent their own difficulty logic, they diverge fast and create recoding later

## Stage 5: First Complete Vertical Slice

Pick one practice area and build it end to end.

Best candidate:

- `Lists and Errands` or `Names and Faces`

Includes:

- Onboarding handoff into first practice
- Real exercise content
- Shared help panel
- Real scoring/history writes
- Real progress updates
- End-of-session summary

Goal:

- One truly complete user journey exists in production shape

Why before all areas:

- It exposes architecture weaknesses early
- It is cheaper to fix the framework with one area than after four

## Stage 6: Onboarding Completion

Once the first vertical slice works, finish the full onboarding flow around the shared systems.

Includes:

- Welcome
- Reassurance
- Goal selection
- Support preferences
- Warm-up calibration
- Meaningful first win
- Suggested next step

Goal:

- A new user can go from install to successful first session without confusion

Why after first vertical slice:

- The best onboarding is shaped around a real first-use outcome, not a hypothetical one

## Stage 7: Expand To Remaining MVP Practice Areas

Now add the other three MVP areas using the shared engine.

Includes:

- `Names and Faces`
- `Dates and Appointments`
- `Remember Later`

Goal:

- New areas require content/configuration work and light UI specialization only

This stage is the test of whether the architecture is working.

If each new area requires major new state or navigation rewrites, stop and fix the framework before proceeding.

## Stage 8: Skills System

Build the skills area after practice is real enough to connect it meaningfully.

Includes:

- Skills overview
- Individual lesson screens
- Skill progress persistence
- Link from skill lesson to recommended practice
- Booster logic

Goal:

- Skills feel integrated with practice, not like a detached content tab

Why now:

- Skills are more valuable when they can point into actual working exercises

## Stage 9: Progress Pipeline And Charts

Build the full progress experience after enough real data shape exists.

Includes:

- Progress home
- Area detail charts
- Skills progress
- Weekly reflection summaries
- Next recommended action from progress

Goal:

- Progress is computed from the same shared history model used by practice

Why now:

- Building charts before the history model stabilizes often causes rework

## Stage 10: Settings, Privacy, Data Management

Build the trust and control surfaces once the underlying systems exist.

Includes:

- Settings
- Privacy view
- Accessibility preferences
- Data reset/delete controls
- Optional language override if supported

Goal:

- The product promise is visible and controllable

## Stage 11: iPad Expansion And Responsive Refinement

Do not wait until the end of the entire product to think about iPad, but do the dedicated layout expansion pass here.

Includes:

- Wider layout behavior
- Side-by-side cards where appropriate
- Chart/detail split opportunities
- Navigation adaptability checks
- Large-window testing

Goal:

- The app expands cleanly without changing its mental model

Why not earlier:

- The architecture should be ready from day one
- The dedicated layout tuning pass is more efficient after core screens exist

## Stage 12: Accessibility And Localization Hardening

Accessibility and localization start at Stage 1, but they still need a focused hardening pass.

Includes:

- Dynamic Type testing
- VoiceOver pass
- Contrast review
- Large tap target audit
- Long-string localization test
- Right-to-left readiness audit if desired

Goal:

- No core flow breaks under real accessibility or translation pressure

## Stage 13: Content Scaling

Only after the engine, persistence, progress, and onboarding are stable should the app scale content meaningfully.

Includes:

- More exercise variants
- More area content
- More skill examples
- Better weekly summaries

Goal:

- Content expansion does not require new architecture

## Stage 14: Optional Features

Only consider these after MVP is stable:

- Reminder customization
- Optional notes
- Care partner mode
- External support/donation link
- Additional practice areas

These should plug into the existing system, not reshape it.

## Dependency Logic

The safest dependency order is:

1. Theme + localization + models
2. Persistence
3. Shared exercise engine
4. Adaptation
5. First real practice slice
6. Onboarding around real practice
7. Remaining practice areas
8. Skills
9. Progress
10. Settings/privacy
11. iPad refinement
12. Hardening
13. Content scale
14. Optional extras

## What Not To Do

Avoid this order:

- Build all onboarding screens first
- Then build one-off exercises
- Then add persistence
- Then add progress

That order almost guarantees recoding because:

- Onboarding won’t match real practice
- Exercises won’t share structure
- Stored history won’t match UI assumptions
- Progress logic will be retrofitted

## Stage Exit Criteria

Do not move to the next stage until the current stage is truly stable enough.

Examples:

### Exit Stage 3 only when:

- A generic exercise flow can run from definition data
- Help can open in place
- Results can be captured through shared models

### Exit Stage 5 only when:

- One practice area works end to end
- History is saved
- Difficulty adapts
- Session summary renders

### Exit Stage 9 only when:

- Progress views are driven from stored history, not mock data
- Every progress screen points to a next action

## Best Immediate Next Step

Before coding full UI breadth, define:

1. The exact first practice area
2. Its round mechanics
3. Its scoring inputs
4. Its adaptive thresholds
5. Its result summary pattern

Then build that vertical slice on top of the shared framework.

## Bottom Line

To avoid recoding:

- Build systems before variations
- Build one complete path before scaling breadth
- Make onboarding, practice, history, and progress share the same core models
- Keep theming, localization, privacy, and accessibility in the foundation from day one

That is the shortest path to an app that can grow without constant structural rewrites.
