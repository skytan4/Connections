# Memory App MVP Specification

Updated: 2026-04-27

## Purpose

This document narrows the product brief into a true MVP.

The goal is to define the smallest version of the Memory app that still feels:

- Useful
- Premium
- Encouraging
- Evidence-aligned
- Technically extensible

This MVP should prove the core product thesis:

Older adults will return to a calm, supportive memory practice app when it teaches real strategies, adapts to their pace, and shows meaningful progress without feeling clinical or punishing.

## MVP Product Goal

Ship a local-only iPhone-first app that helps older adults practice everyday memory through a small set of guided exercises, adaptive difficulty, strategy lessons, progress tracking, and supportive onboarding.

## MVP Success Criteria

The MVP is successful if it can do all of the following:

1. Help a new user start without fear or confusion.
2. Deliver a short practice session that feels clear and respectful.
3. Adapt exercise difficulty based on early and ongoing performance.
4. Store scores and history locally.
5. Show progress by memory area.
6. Teach at least a few memory strategies in a reusable way.
7. Support accessibility, localization, and future iPad expansion without redesigning the app.

## Target User For MVP

Primary target:

- Older adults who want to practice memory and feel more confident in daily life.

Secondary target:

- Family-assisted or care-partner-supported users who may occasionally practice with someone else nearby.

The MVP is not primarily designed for:

- Clinical diagnosis
- Dementia screening
- Formal neuropsychological testing
- Children or school-oriented learning

## MVP Positioning

Best positioning:

"A guided memory practice app for older adults that teaches real strategies and adapts to your level."

MVP promise:

- Practice memory calmly
- Learn practical recall strategies
- Track encouraging progress
- Keep your data private on your device

## Core MVP Pillars

The MVP should ship only what is necessary to support these five pillars:

1. Practice
2. Skills
3. Progress
4. Personalization
5. Trust

## In-Scope MVP Features

### 1. Welcoming Onboarding

Include:

- Warm welcome
- Plain-language explanation of the app
- Reassurance that challenge is normal
- Goal selection
- Optional support/accessibility preferences
- Gentle hidden-baseline warm-up

Must achieve:

- Early success
- Low anxiety
- Initial calibration
- A meaningful first win that helps the user feel real value quickly, not just complete setup

### 2. Practice Area Selection

MVP practice areas:

- Names and Faces
- Dates and Appointments
- Lists and Errands
- Remember Later

Why these four:

- They feel practical and understandable
- They map well to daily-life needs
- They create variety without over-expanding V1

### 3. Adaptive Practice Sessions

Each area should support:

- Short sessions
- Multiple rounds per session
- Gradual challenge increase
- Step-back after repeated misses
- Friendly feedback
- In-place help explaining the purpose of the exercise

### 4. Skills Area

MVP strategy lessons:

- Chunking
- Association
- Visualization
- Spaced Retrieval
- If-Then Planning

Each skill should include:

- A short explanation
- Why it matters
- A quick guided example
- A linked practice recommendation

### 5. Progress Experience

The MVP should include:

- Progress home
- Per-area progress detail screens
- Skills progress screen
- Weekly reflection summary

Metrics shown should remain supportive and simple.

### 6. Local-Only Data Storage

The MVP should store locally:

- Session history
- Exercise results
- Per-area difficulty state
- Strategy progress
- Preferences
- Optional notes/reflections if included

### 7. Accessibility-First Foundation

The MVP must support:

- Dynamic Type
- Strong contrast
- Large tap targets
- VoiceOver-ready controls
- Low-vision friendly design decisions
- Simple, shallow navigation

### 8. Localization-Ready Foundation

The MVP must be built so:

- All user-facing strings are localizable
- Strings come from localization resources
- Future languages can be added without recoding screens

### 9. Privacy Clarity

The MVP should clearly state:

- Data stays on device
- No account required
- No score/history upload
- No personal tracking of memory data

## Out-Of-Scope For MVP

These are intentionally excluded from the first release unless priorities change:

- Cloud sync
- User accounts
- Social features
- Clinician dashboards
- Competitive game mechanics
- Large library of dozens of exercise categories
- Research export
- Cross-device sync
- Advanced care team sharing
- Apple Watch companion
- Mac version
- Full custom iPad-only UI
- Voice-led coaching system
- AI-generated exercise content

## Nice-To-Have But Not Required For MVP

- Optional care partner mode
- Optional notes and daily-life wins
- Reminder scheduling customization
- Audio read-aloud support
- Richer chart filtering
- Additional exercise areas

These should not delay the core build.

## MVP Screen Map

### Primary Flow

1. Welcome
2. Reassurance
3. Goals
4. Support preferences
5. Warm-up calibration
6. Home
7. Practice area
8. Exercise session
9. Session result
10. Progress

### Core Navigation Tabs Or Areas

- Home
- Practice
- Skills
- Progress
- Settings

### MVP Home Screen Responsibilities

- Resume today's practice
- Suggest next area
- Show short encouragement
- Provide quick access to skills and progress
- Recommend one best next action clearly

## Exercise Structure Requirements

All MVP exercises should share a common framework:

- Intro state
- Active round
- Result state
- Adaptation update
- History write

This is important because the first version should build one engine that can host multiple exercise types, not four unrelated mini-apps.

## Personalization Rules For MVP

The MVP should personalize using:

- Warm-up calibration
- Recent performance
- Per-area history
- Self-selected goals
- Accessibility/readability preferences

The MVP should not depend on:

- Age bands
- Formal clinical classification
- Manual difficulty setup as the primary model

## MVP Content Rules

The MVP content should be:

- Calm
- Short
- Concrete
- Reassuring
- Free of jargon

Avoid:

- Competitive language
- Diagnostic framing
- Abstract "brain power" claims
- Dense instructions

The MVP should also clearly communicate why it is different from:

- Reminders apps
- Notes apps
- Generic brain-game bundles

Its value is guided practice, adaptive challenge, strategy teaching, and progress insight.

## Data Requirements For MVP

Minimum persistent entities:

- User preferences
- Practice session
- Practice attempt or round
- Area progress summary
- Skill lesson progress
- Weekly reflection summary

## Design Requirements For MVP

- No hard-coded colors or tinting
- Semantic theming tokens only
- No hard-coded user-facing strings
- Flexible layouts only
- Local-only history storage
- iPhone-first but iPad-expandable layout
- Liquid Glass only in functional chrome, not dense reading surfaces

## Launch Quality Bar For MVP

Before MVP is considered ready, it should satisfy:

- Smooth first-run onboarding
- At least four reliable practice areas
- Adaptive difficulty working end to end
- Progress history visible and understandable
- Accessibility basics verified
- Privacy language implemented
- Localization architecture in place
- Small-screen layout verified
- Large Dynamic Type usable

## Key Open Decisions Before Coding Content At Scale

These do not block app scaffolding, but should be answered before large content production:

- Exact exercise mechanics for each of the four MVP areas
- Exact scoring formula and difficulty adjustment thresholds
- Whether notes/daily-life wins are in MVP or post-MVP
- Whether care partner mode is MVP or post-MVP
- Whether reminders ship in MVP

## Current Readiness Assessment

After this MVP specification:

- Product vision readiness: 8.5/10
- MVP definition readiness: 9/10
- Build-ready readiness: depends on the technical spec
