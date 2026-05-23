# Memory App Technical Specification

Updated: 2026-04-27

## Purpose

This document translates the product brief and MVP spec into an implementation-oriented plan for a SwiftUI app.

It is written to reduce ambiguity before coding begins.

## Build Goal

Build a local-only, accessibility-first, localization-ready, iPhone-first memory practice app with an architecture that can grow into iPad cleanly.

## Platform And Architectural Assumptions

- SwiftUI app
- Modern Apple platform patterns
- Local-only persistence
- No required network layer for MVP
- iPhone-first layouts that expand to iPad
- Semantic theme system
- Localization resources for all user-facing copy

## Proposed App Modules

Recommended top-level folders or modules:

- `Models`
- `Services`
- `Views`
- `Components`
- `Theme`
- `Localization`
- `Data`

Suggested responsibilities:

- `Models`: domain types and persisted entities
- `Services`: persistence, adaptation, progress summaries, scheduling logic
- `Views`: screen composition
- `Components`: reusable UI parts
- `Theme`: semantic colors, typography, spacing, chart styles
- `Localization`: string catalogs and translator context
- `Data`: exercise definitions, skill lesson content, seeded copy

## Reuse From Existing Connections App

There is useful foundation in the existing `Connections` app that can accelerate this build.

Best candidates to reuse conceptually or adapt directly:

- Root environment wiring pattern from `ContentView`
- Local settings persistence pattern from `SettingsStore`
- Semantic theme/token structure from `Theme.swift`
- Background treatment patterns from `AtmosphericBackground` and `NeutralBackground`
- Reusable card/button composition patterns from `SelectionCard`
- Enum-driven navigation patterns from `SessionSetupView` and `SessionBuilderView`

Recommended stance:

- Reuse architectural patterns and components where they fit
- Do not copy domain-specific session logic directly
- Do not carry over hard-coded wording, colors, or conversation-specific assumptions

## iOS 18 Navigation Constraint

The existing app already documents an important SwiftUI behavior on iOS 18.

Rule:

- Do not mutate shared session state into an active session and trigger navigation in the same synchronous source-view button handler

Safer pattern:

1. Source/setup view writes the chosen configuration only
2. Navigation is triggered through a route value
3. Destination/play view starts the session in `onAppear`, guarded so it only runs once

This pattern is already used in the existing app and should be preserved in the Memory app.

Additional recommendation:

- Prefer enum-based routing over multiple scattered boolean navigation flags for multi-destination setup flows

This reduces ambiguity and makes iOS 18 navigation behavior easier to manage.

## Core Domain Model

### Enumerations

Recommended core enums:

- `PracticeArea`
- `SkillType`
- `SessionLength`
- `DifficultyBand`
- `ExerciseKind`
- `HelpTopic`
- `GoalType`
- `SupportPreference`

### Example Domain Concepts

- `PracticeArea.namesAndFaces`
- `PracticeArea.datesAndAppointments`
- `PracticeArea.listsAndErrands`
- `PracticeArea.rememberLater`

- `SkillType.chunking`
- `SkillType.association`
- `SkillType.visualization`
- `SkillType.spacedRetrieval`
- `SkillType.ifThenPlanning`

## Persistent Data Model

All persistence should support local-only storage.

### Minimum Persistent Entities

#### `UserProfile`

Stores:

- App versioned profile ID
- Selected goals
- Accessibility preferences
- Practice duration preference
- Reminder preference
- Readability mode preference
- Onboarding completion state
- Selected app language override if supported

#### `AreaState`

Stores one record per practice area:

- Current difficulty band
- Rolling accuracy
- Rolling confidence
- Last practiced date
- Current suggested next challenge
- Current booster due state

#### `PracticeSession`

Stores one record per completed session:

- Session ID
- Date
- Area
- Exercise kind
- Duration
- Difficulty at session start
- Difficulty at session end
- Overall result summary
- Help usage count
- Strategy prompt used

#### `PracticeAttempt`

Stores round-level detail:

- Attempt ID
- Session ID
- Round index
- Challenge parameters
- Accuracy result
- Delay used
- Recognition or free recall mode
- Confidence if collected
- Adaptation decision

#### `SkillProgress`

Stores one record per skill:

- Skill type
- Introduced state
- Completed lesson state
- Reinforcement count
- Last reviewed date
- Needs booster flag

#### `WeeklyReflection`

Stores generated weekly summaries:

- Week start date
- Sessions completed
- Areas practiced
- Summary highlights
- Recommendation text key

#### `UserNote`

Optional for MVP:

- Note ID
- Date
- Area or skill association
- Text

## Persistence Strategy

Recommended persistence qualities:

- Local-only
- Versionable
- Easy to migrate
- Good for querying recent history and area trends

The exact implementation can be finalized later, but the storage layer should support:

- Loading profile and area state at app launch
- Appending session history after each session
- Computing weekly and per-area summaries
- Resetting all data safely if requested

## Service Layer

Recommended services:

### `ProfileStore`

Responsibilities:

- Load and save `UserProfile`
- Manage onboarding completion
- Manage preferences

### `PracticeHistoryStore`

Responsibilities:

- Save sessions and attempts
- Query recent sessions
- Query per-area history
- Provide inputs to progress charts

### `AdaptiveDifficultyEngine`

Responsibilities:

- Use warm-up calibration and recent history
- Recommend starting difficulty
- Adjust difficulty during and after sessions
- Maintain per-area challenge state

Suggested inputs:

- Accuracy
- Time or pacing when relevant
- Confidence
- Recent success or struggle pattern
- Delay tolerance

Suggested outputs:

- Next challenge parameters
- Up / hold / down decision
- Suggested review or booster

### `ProgressSummaryEngine`

Responsibilities:

- Build progress cards
- Build per-area chart series
- Build weekly reflection summaries
- Translate internal metrics into supportive user-facing labels
- Recommend the next best practice or booster action from progress state

### `SkillRecommendationEngine`

Responsibilities:

- Recommend skill lessons based on area performance
- Flag boosters
- Suggest linked practice after a lesson

### `PrivacyInfoProvider`

Responsibilities:

- Provide local-only privacy copy keys for settings and onboarding
- Keep privacy explanation consistent across the app

## Exercise Framework

The app should not implement each exercise as a totally unique flow.

It should define a shared exercise framework.

### Shared Exercise Parts

- Intro content
- Round presentation
- User response capture
- Result feedback
- Difficulty adjustment
- History write
- Session summary

### Exercise Definition Model

Each exercise should be definable through data and configuration where possible.

Suggested fields:

- Exercise ID
- Practice area
- Exercise kind
- Localized title key
- Localized instructions key
- Localized help key
- Challenge generator configuration
- Supported skills linkage

## Screen Architecture

## Root Navigation

Recommended root sections:

- Home
- Practice
- Skills
- Progress
- Settings

## Screen List

### Onboarding

- `WelcomeView`
- `ReassuranceView`
- `GoalSelectionView`
- `SupportPreferencesView`
- `WarmupCalibrationView`
- `OnboardingCompleteView`

Onboarding requirement:

- The first-run flow must create a meaningful first win, not just gather baseline data.

### Home And Practice

- `HomeView`
- `PracticeAreaListView`
- `PracticeAreaDetailView`
- `ExerciseIntroView`
- `ExercisePlayView`
- `ExerciseResultView`

Home requirement:

- `HomeView` should surface one recommended next action as the primary CTA.

### Skills

- `SkillsOverviewView`
- `SkillLessonView`
- `SkillPracticeLinkView`

### Progress

- `ProgressHomeView`
- `AreaProgressDetailView`
- `SkillsProgressView`
- `WeeklyReflectionView`

### Settings

- `SettingsView`
- `PrivacyView`
- `AccessibilityOptionsView`
- `DataManagementView`

## Reusable Components

Recommended reusable components:

- `PrimaryActionButton`
- `SecondaryActionButton`
- `SupportCard`
- `MetricCard`
- `ProgressChartCard`
- `SectionHeader`
- `ExerciseHelpButton`
- `ExerciseHelpSheet`
- `AreaTile`
- `SkillTile`

## Theming System

No hard-coded colors or tinting in feature screens.

Recommended semantic tokens:

- `backgroundPrimary`
- `backgroundSecondary`
- `surfacePrimary`
- `surfaceElevated`
- `textPrimary`
- `textSecondary`
- `accentPrimary`
- `accentMuted`
- `successSupport`
- `warningSupport`
- `chartAreaNames`
- `chartAreaDates`
- `chartAreaLists`
- `chartAreaRememberLater`

Typography should also be tokenized:

- screen title
- section title
- body
- supportive caption
- metric label
- chart label

## Localization Strategy

All user-facing strings must be localizable.

Recommended approach:

- String catalogs
- Context comments for translators
- No string concatenation for user-visible sentences
- Localization keys for exercise titles, instructions, and help text

Must localize:

- Screen titles
- Buttons
- Exercise content
- Help panels
- Progress labels
- Accessibility labels and hints
- Privacy copy

## Accessibility Requirements

Every important screen should support:

- Dynamic Type
- VoiceOver
- High contrast readability
- Large touch targets
- Recoverable navigation
- No essential hidden gestures

Special requirements:

- Help must be available without losing context
- Progress charts need text alternatives or summaries
- Exercise instructions must be replayable or reopenable

## iPad Expansion Rules

The first implementation should be phone-first but structurally ready for iPad.

That means:

- Components should expand horizontally
- Cards should support stacking and side-by-side placement
- Progress layouts should allow wider chart/detail combinations
- Navigation architecture should be able to evolve into sidebar-adaptable patterns

## Privacy And Data Rules

The product promise is local-only data.

Implementation must support:

- No required remote database
- No upload of score or history data
- No account dependency
- Clear delete/reset path

If future features change this, privacy copy and architecture assumptions must be revisited explicitly.

## Monetization Caution

If monetization is added later, avoid ads and aggressive paywall behavior in the core practice loop.

For this category and audience, trust erosion from monetization pressure is a product risk, not just a pricing issue.

## Build Phases

### Phase 1: Foundation

- Theme tokens
- Localization scaffolding
- Core models
- Persistence layer
- Root navigation shell

### Phase 2: First-Run And Practice Engine

- Onboarding flow
- Warm-up calibration
- Shared exercise framework
- One practice area end to end

### Phase 3: MVP Practice Coverage

- Remaining three MVP practice areas
- Skills area
- Contextual help

### Phase 4: Progress And Polish

- Progress charts
- Weekly reflections
- Settings and privacy
- Accessibility refinements

## Pre-Coding Decisions Still Needed

These should be decided before implementing final content-heavy logic:

- Exact challenge parameter model for each practice area
- Exact confidence collection pattern
- Exact difficulty thresholds for up/hold/down
- Whether notes ship in MVP
- Whether reminders ship in MVP

## Suggested Repo Outcome

If we proceed from this spec, the next implementation doc could define:

- concrete Swift types
- folder/file map
- persistence technology choice
- exact screen order
- seed content format

## Current Readiness Assessment

After this technical spec:

- Product vision readiness: 8.5/10
- MVP definition readiness: 9/10
- Build-ready readiness: 8.5/10

That is enough to begin implementation of the app foundation with much lower rework risk.
