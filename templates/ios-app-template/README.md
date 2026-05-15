# iOS App Template

Updated: 2026-04-27

## Purpose

This template is a repeatable starting point for new Apple-platform apps.

It is designed to reduce avoidable rework by forcing the team to define:

- Product direction
- MVP boundaries
- Technical architecture
- Build order
- Reusable lessons learned

Use this before implementation begins.

## What This Template Includes

- `docs/product-brief-template.md`
- `docs/mvp-spec-template.md`
- `docs/technical-spec-template.md`
- `docs/build-stages-template.md`
- `docs/external-validation-template.md`
- `docs/lessons-learned-template.md`

## Recommended Workflow

1. Copy this template into a new app folder.
2. Rename the placeholder app name throughout.
3. Fill in the product brief first.
4. Tighten the MVP spec before coding.
5. Define the technical spec before building feature breadth.
6. Use the build stages doc to sequence the work.
7. Add new discoveries to the lessons-learned file so the template improves over time.

## Non-Negotiable Starter Rules

- No hard-coded user-facing strings in screens
- No hard-coded colors or tinting in screens
- Accessibility from the start
- Localization-ready from the start
- iPhone-first, iPad-expandable layout assumptions
- Privacy stance decided early
- Shared engines before feature variations

## Important SwiftUI Lesson To Preserve

For session-style flows on iOS 18 and later:

- Do not mutate shared session state into an active session and trigger navigation in the same synchronous button handler
- Prefer enum-driven routing
- Start the session in the destination view after it mounts

This prevents SwiftUI navigation/state races that can blank or reset the destination flow.

## Template Evolution

Whenever a project teaches us:

- "we should have known this up front"
- "this caused avoidable refactoring"
- "this should be a default rule next time"

add it to `docs/lessons-learned-template.md` and update the relevant template file.
