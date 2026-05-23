# Layers (Connections)

A guided prompt iOS app for meaningful conversation — built for couples, friends, families, and solo reflection.

## What it does

Layers guides users through a progressively deeper set of conversation prompts. You pick a mode, intensity, topic, and session length, then work through prompts together. The app tracks emotional connection in real-time, surfaces follow-up questions, and generates a session summary at the end.

## Features

- **Modes** — Couples, Friends, Family, Solo Reflection
- **Intensity levels** — Light, Honest, Unfiltered
- **Topics** — Communication, Emotions, Appreciation, Conflict, Growth, Values, Past, Intimacy, Daily Life, Identity, Sex (free/paid split)
- **Depth progression** — Prompts escalate from Warm Up → Surface → Deeper → Vulnerable → Raw
- **Feeling check-ins** — Periodic emotional pulse checks during a session
- **Session summary** — Recap of depth reached, responses logged, and connection score
- **Share Experience mode** — Separate prompt bank for collaborative sharing exercises
- **Favorites** — Save prompts for later

## Tech

- Swift / SwiftUI
- iOS 26.4+
- `@Observable` for state management (no third-party dependencies)

## Project structure

```
Connections/
  ConnectionsApp.swift        App entry point
  Assets.xcassets/

  Models/
    Models.swift              Core enums & structs (Mode, Intensity, Topic, Prompt, etc.)
    IntensityTone.swift       Tone model for intensity levels
    ConnectionTracker.swift   Feeling check-in logic and connection scoring

  Views/
    ContentView.swift         Root navigation container
    HomeView.swift            Landing screen
    ModeSelectionView.swift   Mode picker
    IntensitySelectionView.swift  Intensity picker
    SessionSetupView.swift    Topic + length configuration
    SessionPlayView.swift     Active session (prompts, follow-ups, check-ins)
    FeelingCheckInView.swift  Mid-session emotional check-in
    ConnectionHeartView.swift Connection score visualization
    ShareExperience.swift     Share experience entry point
    ShareExperiencePlayView.swift  Share experience session

  Components/
    SelectionCard.swift       Reusable selection card UI

  Services/
    SessionManager.swift      Session state machine + favorites persistence
    SessionSummaryEngine.swift  Post-session summary generation

  Data/
    PromptBank.swift          All conversation prompts
    ShareExperienceBank.swift  Share experience prompts
```

## Setup

1. Clone the repo
2. Open `Connections.xcodeproj` in Xcode 16+
3. Select your team under Signing & Capabilities
4. Run on simulator or device (iOS 26.4+)

No package dependencies — just build and run.

## Contributing

See `.claude/commands/` for slash commands that automate code review, PR creation, and code generation workflows.
