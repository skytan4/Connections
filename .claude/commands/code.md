# Write Code

Generate new Swift/SwiftUI code for the Layers (Connections) app.

## Project conventions to follow

**State management**
- Use `@Observable` for service/manager classes (`SessionManager`, etc.)
- Views receive managers via `@Environment` — do not instantiate them inside views
- Use `private(set)` for state that only the owning type should mutate

**SwiftUI views**
- Keep `body` declarative and thin — extract sub-views or computed properties for anything complex
- Use `MARK: -` sections to organize: `// MARK: - Body`, `// MARK: - Subviews`, `// MARK: - Helpers`
- Prefer `GeometryReader` only when truly needed for layout math

**Models**
- Pure value types in `Models/` — no SwiftUI or Foundation side effects
- Enums should conform to `CaseIterable`, `Identifiable`, and `Codable` where it makes sense
- `Prompt` and related types must remain `Codable` for persistence

**Data files**
- `PromptBank` and `ShareExperienceBank` are static structs — add prompts as static `let` arrays
- Prompts have: `text`, `mode`, `intensity`, `depthLevel`, `topic`, optional `followUps`

**File placement**
- New views → `Views/`
- New reusable UI components → `Components/`
- New data models or enums → `Models/`
- New business logic → `Services/`
- New static prompt/content data → `Data/`

**Style**
- No comments explaining what the code does — only comment the non-obvious why
- No force unwraps
- Access control: default to `private`; only expose what callers actually need

## Usage

```
/code <description of what to build>
```

Example: `/code a settings sheet that lets the user toggle follow-up questions and reset session history`
