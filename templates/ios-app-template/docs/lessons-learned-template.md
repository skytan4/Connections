# Template Lessons Learned

Updated: 2026-04-27

## Purpose

This file is where we capture things we wish we had known before starting an app.

When a lesson repeats across projects, update the template itself.

## Current Starter Lessons

### SwiftUI Navigation

- Prefer enum-driven routing for multi-destination flows
- Do not start session-style state in the same synchronous handler that triggers navigation on iOS 18
- Let the destination own the start of the active flow when possible

### Product Definition

- Tighten MVP definition before content scale
- Define build stages before coding breadth
- Decide privacy stance early
- Decide localization/accessibility posture before UI implementation

### Design System

- Use semantic color and tint tokens only
- Keep typography, spacing, and component rules centralized
- Assume future readability and larger-screen needs from the start

### Architecture

- Build shared engines before feature variants
- Build one vertical slice before scaling breadth
- Do not retrofit persistence late

### Localization And Accessibility Copy

- Centralize count-bearing phrases in string helpers instead of building them inline in views
- If a phrase may need plural rules later, the count must be part of the localized resource
- Do not assume punctuation, separators, or conjunctions are universal across languages
- Accessibility copy must be localized with the same discipline as visible UI copy
- If a UI layout separates numbers from nouns, verify that structure still works for localization before it spreads

## New Lessons To Add

Template:

- Date:
- App:
- Lesson:
- What it should change in the template:
