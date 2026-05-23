# Code Review

Review the code changes on the current branch against main (or a specified base branch).

## What to check

**Correctness**
- Logic errors, off-by-one issues, edge cases not handled
- SwiftUI state management — is `@Observable`, `@State`, `@Environment` used correctly?
- Session state mutations happening on the right actor

**Swift / SwiftUI idioms**
- Prefer value types (structs/enums) over classes unless reference semantics are needed
- No force unwraps (`!`) without justification
- Avoid imperative UIKit patterns when a declarative SwiftUI approach exists

**Architecture**
- Views should not contain business logic — push it to `SessionManager` or a service
- Models in `Models/` should be pure data (no SwiftUI imports)
- Data files (`PromptBank`, `ShareExperienceBank`) should be static — no side effects

**Performance**
- Avoid recomputing expensive values inside `body` — use `let` bindings or computed properties on the model
- Watch for unnecessary view re-renders caused by broad `@Observable` observation

**Security / Privacy**
- No hardcoded secrets or API keys
- Sensitive prompt responses should not be logged to console in release builds

## How to run

```
/review
/review main        # diff against main instead of develop
```

Diff the current branch, summarize what changed, then provide actionable feedback grouped by severity: **Critical**, **Suggested**, **Nit**.
