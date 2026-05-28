# {{APP_NAME}} Technical Specification

Updated: {{DATE}}

## Purpose

Translate the product brief and MVP spec into an implementation-oriented plan.

## Build Goal

- 

## Platform And Architectural Assumptions

- SwiftUI app
- Accessibility-first
- Localization-ready
- iPhone-first, iPad-expandable

Project-specific assumptions:

- 
- 

## Suggested App Modules

- `Models`
- `Services`
- `Views`
- `Components`
- `Theme`
- `Localization`
- `Data`

## Reuse From Prior Apps

List patterns worth reusing:

- Root environment/state wiring
- Theme token structure
- Settings persistence pattern
- Enum-driven navigation
- Reusable cards/buttons

Project-specific reuse notes:

- 
- 

## SwiftUI Risk Notes

Important framework lessons to preserve:

- Prefer enum-driven routing for multi-destination flows
- Avoid starting session-style flows in the same synchronous handler that triggers navigation
- Start destination-owned flow state after the destination mounts

Project-specific risks:

- 
- 

## Core Domain Model

Recommended enums:

- 
- 
- 

Recommended core entities:

- 
- 
- 

## Persistence Model

Define the minimum persisted entities:

- User/profile/preferences
- History/session data
- Progress summaries
- Feature-specific state

Project entities:

- 
- 
- 

## Service Layer

List the services the app needs:

- 
- 
- 

## Shared Engines To Build Before Variants

- 
- 
- 

## Screen Architecture

Root sections:

- 
- 
- 

Major screens:

- 
- 
- 

## Reusable Components

- 
- 
- 

## Theme System Rules

- No hard-coded colors in screens
- No hard-coded tint logic in screens
- Use semantic tokens only

Project tokens to define:

- 
- 
- 

## Localization Rules

- No hard-coded user-facing strings in views
- Use localization resources
- Support longer strings
- Add translator context where needed
- Route count-bearing phrases through named string helpers instead of inline interpolation in views
- If pluralization may matter, make sure the quantity participates in the localized resource
- Do not create fake plural-ready helpers that accept a count but ignore it
- If a UI splits a number and noun apart, confirm that shape still localizes correctly across languages
- Accessibility labels, hints, and summaries must follow the same localization rules as visible text

## Accessibility Requirements

- 
- 
- 

## Responsive And iPad Rules

- 
- 
- 

## Privacy And Data Rules

- 
- 
- 

## Pre-Coding Decisions Still Needed

- 
- 
- 
