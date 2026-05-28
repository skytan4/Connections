# Create Pull Request

Create a pull request for the current branch.

## Steps

1. Run `git status` and `git log develop..HEAD` (or `main..HEAD`) to understand what's on this branch
2. Summarize all commits — not just the latest one
3. Push the branch if it isn't already tracking a remote (`git push -u origin <branch>`)
4. Create the PR with `gh pr create` using the template below

## PR template

```
## What changed
- <bullet summary of each logical change>

## Why
<one or two sentences on motivation — feature request, bug fix, refactor, etc.>

## How to test
- [ ] <step 1>
- [ ] <step 2>
- [ ] Build succeeds with no warnings
- [ ] Tested on simulator (iPhone + iPad if relevant)

## Notes
<anything reviewers should know — decisions made, tradeoffs, follow-up work>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Usage

```
/pr
/pr "short title override"
```

If the branch has no commits beyond the base, say so and do not create a PR.
Base branch defaults to `develop`. If `develop` doesn't exist, fall back to `main`.
