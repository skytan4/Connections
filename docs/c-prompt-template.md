# C Prompt Template

Use this when handing a focused implementation or fix task to `C`.

```text
You are working in /Users/johntanner/Developer/Gentle Recall.

Task:
[exact change]

Purpose:
[why it matters]

Decisions already made:
- [settled product or architecture choice]
- [settled UI or interaction choice]

Start here:
- [primary file]

Read only these first:
- [file 1]
- [file 2]
- [file 3]

Likely files to change:
- [file 1]
- [file 2]

Do not touch unless required:
- [file or path]
- [file or path]

Problem area:
[paste exact code block if helpful]

Issue:
[what is wrong in that block]

Fix direction:
[preferred shape of solution]

What to do:
1. [specific step]
2. [specific step]
3. [specific step]

Constraints:
- Assume current architecture and UI guidance remain in force
- Do not re-evaluate unrelated screens or flows
- Do not do unrelated cleanup or refactors
- Keep all new user-facing content aligned with localization architecture
- Make any new interaction understandable for VoiceOver, not just visually
- Do not rely on color-only or icon-only affordances
- Keep touch, pointer, and existing accessibility behavior intact
- Keep the project building
- Only read additional files if the listed files are insufficient

Acceptance criteria:
- [success condition]
- [success condition]
- [success condition]

Stop when:
- [clear done condition]

At the end, report:
1. What you changed
2. Which files you changed
3. Whether the build succeeded
4. Any follow-up recommendation
```

## Short Guardrail Block

Use this on smaller tasks when the full template would be overkill.

```text
Assume the current architecture and UI guidance remain in force.
Do not re-evaluate unrelated screens or flows.
Touch only the files needed for this task.
Do not do unrelated cleanup or refactors.
Keep all new user-facing content aligned with localization architecture.
Make any new interaction understandable for VoiceOver, not just visually.
Do not rely on color-only or icon-only affordances.
Keep the project building.
```

## Notes

- For small fixes, always point `C` to the exact file and code block if you can.
- For medium tasks, name the likely files and the starting file so exploration stays narrow.
- For larger feature work, give the first files to open and the decisions that are already settled.
- The highest-value sections for reducing overhead are:
  - `Decisions already made`
  - `Start here`
  - `Do not touch unless required`
  - `Stop when`
