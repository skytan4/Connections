# GitHub Copilot Instructions — Layers (Connections)

This is a SwiftUI iOS app (iOS 26.4+) that guides users through meaningful conversation prompts. Use these instructions when reviewing pull requests or suggesting code.

## Architecture

```
Models/       Pure Swift data types — no SwiftUI imports allowed here
Views/        SwiftUI views — declarative, no business logic
Components/   Reusable SwiftUI subviews
Services/     @Observable classes that own state and business logic
Data/         Static content banks (prompts, share experiences)
```

The single source of truth for session state is `SessionManager`. Views read from it via `@Environment(SessionManager.self)`. Never let views mutate session state directly — they call methods on `SessionManager`.

## Code review checklist

When reviewing a PR, check for:

- [ ] **No business logic in views** — conditionals and state mutations belong in `SessionManager` or a service
- [ ] **No SwiftUI imports in `Models/`** — models must stay framework-agnostic
- [ ] **No force unwraps** — use `guard`, `if let`, or provide a safe default
- [ ] **`@Observable` used correctly** — classes in `Services/` use `@Observable`; views use `@State` for local-only state
- [ ] **New prompts placed in `Data/`** — not hardcoded inside views
- [ ] **Access control** — properties default to `private`; only expose what's needed
- [ ] **No debug `print` statements** in production paths
- [ ] **Codable conformance preserved** on `Prompt`, `PromptResponse`, `FavoritesStore` — these are persisted

## Swift / SwiftUI conventions

- Prefer `struct` over `class` for models
- Enums that represent user-facing options should conform to `CaseIterable`, `Identifiable`, `Codable`
- Use `MARK: -` sections to organize view code: Body, Subviews, Helpers
- Session length is measured in prompt count (`SessionLength.rawValue`), not time
- Depth progression order: `.warmUp` → `.surface` → `.deeper` → `.vulnerable` → `.raw`
- Free topics: `.communication`, `.emotions`, `.appreciation`, `.conflict` — everything else is paid

## What to flag in PRs

**Block merge if:**
- Force unwrap on optional session state that could be nil
- Models import SwiftUI
- Persistence keys change without a migration path

**Request changes if:**
- View contains logic that belongs in a service
- New prompt data is hardcoded in a view instead of `PromptBank`/`ShareExperienceBank`
- Public API added to a type that should remain internal

**Comment (non-blocking) if:**
- Naming doesn't match existing conventions
- A simpler SwiftUI approach exists
- Missing `MARK` organization on a file over ~80 lines
