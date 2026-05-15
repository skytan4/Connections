# {{APP_NAME}} Build Stages

Updated: {{DATE}}

## Purpose

Define the order the app should be built in to minimize recoding.

## Core Build Principle

Build the bones first, then the first complete path, then variations, then polish.

## Architecture Rules To Prevent Rework

- No hard-coded strings in screens
- No hard-coded colors or tint logic in screens
- Build shared engines before feature variants
- Build persistence before feature-heavy UI
- Build one complete vertical slice before scaling breadth

Project-specific rules:

- 
- 

## Recommended Stage Order

### Stage 0: Foundation Decisions

- Lock MVP scope
- Lock privacy stance
- Lock accessibility/localization posture

### Stage 1: App Spine

- App state
- Navigation shell
- Theme tokens
- Localization scaffolding
- Core models

### Stage 2: Persistence

- Local stores
- Reset/delete path
- Version/migration plan

### Stage 3: Shared Engine

- Shared flow engine
- Shared state model
- Shared hooks into persistence

### Stage 4: First Vertical Slice

- One complete feature path end to end

### Stage 5: Onboarding Around Real Flow

- Build onboarding against real behavior

### Stage 6: Remaining MVP Breadth

- Add remaining core features using the shared framework

### Stage 7: Progress, Settings, Hardening

- Progress UI
- Settings/privacy
- Accessibility and localization hardening
- iPad refinement

## Stage Exit Criteria

Define what must be true before moving on:

- 
- 
- 

## What Not To Do

- Build many one-off feature flows first
- Delay persistence until late
- Build progress on mock assumptions
- Treat onboarding as separate from real app behavior
