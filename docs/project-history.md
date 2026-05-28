# Deeper Conversations Project History

This document records the practical decisions, workflows, files, and lessons that helped build and submit Deeper Conversations. Keep it current so future app work can reuse what worked instead of reconstructing it from memory.

## Product Shape

Deeper Conversations is a guided conversation prompt app for couples, friends, families, and solo reflection. The core experience is:

- choose a mode
- choose a tone or intensity
- choose topics and session length
- move through prompts with optional follow-up questions
- favorite meaningful prompts
- finish with a session summary

Premium is a one-time non-consumable purchase, not a subscription. The Premium unlock language must stay clear:

- 924 additional prompts, for 2,001 total conversation prompts
- Share Experiences
- Life History prompts
- Unfiltered question sets for Couples, Family, and Friends
- Premium topics including Intimacy and Fall in Love
- Added categories and new conversation packs as they become available
- One-time purchase, lifetime access, no subscription

## Key Repo Files

Product and planning:

- `README.md` - current app overview and project structure
- `docs/app-store/submission-checklist.md` - launch checklist and review notes
- `docs/app-store/localized-metadata-matrix.md` - localized App Store metadata source
- `docs/localization/agent-translation-workflow.md` - translation workflow
- `docs/localization/post-translation-audit-guide.md` - translation QA workflow
- `Paywall Language.md` - source of truth for Premium paywall copy and translations

App code:

- `Connections/ConnectionsApp.swift` - app entry point
- `Connections/Views/PremiumPaywallView.swift` - Premium paywall UI
- `Connections/Paywall.xcstrings` - localized paywall strings
- `Connections/Views/SessionSetupView.swift` - session setup screen
- `Connections/Views/SessionPlayView.swift` - active prompt session
- `Connections/Services/SessionManager.swift` - session state and favorites
- `Connections/Services/SessionSummaryEngine.swift` - session summary generation

Automation:

- `ConnectionsUITests/ConnectionsUITestsLaunchTests.swift` - App Store screenshot UI tests
- `fastlane/Fastfile` - TestFlight, signing, screenshot, and screenshot upload lanes
- `fastlane/Snapfile` - screenshot devices and locales
- `fastlane/screenshots/` - generated localized screenshot assets
- `CLAUDE.md` - machine/setup notes and Fastlane signing details

## Localization Workflow

The app uses `.xcstrings` files for localized UI text. For paywall copy, `Paywall Language.md` is the human handoff file and `Connections/Paywall.xcstrings` is the implementation file.

Supported paywall locales from the App Store review push:

- `en`
- `es`
- `fr`
- `de`
- `pt-BR`
- `nl`
- `ja`
- `it`
- `sv`
- `da`
- `nb`
- `fi`
- `zh-Hans`
- `ru`
- `pl`

Important localization habits:

- Preserve product concepts exactly, especially `Share Experiences`.
- Keep Premium as a one-time purchase with lifetime access.
- Do not add subscription renewal language.
- Do not add privacy/no-data-collection claims to the paywall.
- Use translated feature names consistently between paywall copy, app UI, and screenshots.
- After editing `.xcstrings`, inspect the actual paywall UI for clipping on small devices.

## Premium Paywall Review Lesson

Apple rejected an earlier build because the Premium/IAP flow did not clearly explain what users receive when they pay. The paywall needs to make clear that Premium unlocks the full product, not only the feature the user came from.

The paywall should show the full Premium value proposition and the one-time purchase language. Life Story and other premium gates should route to the same paywall so Apple sees one consistent explanation.

The In-App Purchase also needs an internal App Review screenshot in App Store Connect. This is separate from public App Store marketing screenshots. Use the English paywall screenshot, for example:

`fastlane/screenshots/en-US/iPhone 17 Pro Max-06-paywall.png`

## Post-Launch SwiftUI Compatibility Lessons

The iPhone and iPad paywall worked, but the App Store build crashed when opening the paywall as an iPhone/iPad app on an Apple Silicon Mac. The crash stack pointed into SwiftUI sheet presentation and `EnvironmentValues`.

Lesson:

- Do not assume iPhone/iPad modal environment inheritance behaves identically on Apple Silicon Mac compatibility.
- If a presented view depends on `@Environment(SomeObservable.self)`, explicitly pass the required environment stores into the sheet/popover/full-screen cover.
- For paywalls and StoreKit flows, test on iPhone, iPad, and the Xcode "My Mac" destination when Mac availability is enabled.

The setup screens also had scroll friction because `SelectionCard` used `DragGesture(minimumDistance: 0)` for press feedback. That gesture could steal vertical scroll drags when the user started scrolling from the middle of a card.

Lesson:

- Do not use a zero-distance drag gesture on tappable cards inside a `ScrollView` only for press animation.
- Use a custom `ButtonStyle` and `configuration.isPressed` for press visuals so tap selects and drag scrolls.
- Shared UI components need interaction QA because one small gesture decision can affect many screens.

## App Store Screenshots

The current screenshot automation captures 10 screenshots per locale per device:

1. `01-home`
2. `02-modes`
3. `03-session-setup`
4. `04-prompt`
5. `05-session-summary`
6. `06-paywall`
7. `07-share-experiences`
8. `08-life-history`
9. `09-premium-unfiltered`
10. `10-mortality-question`

These screens were chosen because they tell both the free and Premium product story:

- Home and modes explain the product quickly.
- Session setup shows topics, follow-up questions, and session length.
- Prompt and summary show the actual conversation flow.
- Paywall explains the one-time Premium unlock.
- Share Experiences, Life History, premium unfiltered, and Mortality screens show paid value.

The session summary and modes screens are not Premium-only. They can appear before the paywall in the public screenshot order because they represent the app's general value.

Current Fastlane screenshot config:

- devices: `iPhone 17 Pro Max`, `iPad Air 13-inch (M4)`
- locales: `en-US`, `es-ES`, `de-DE`, `fr-FR`, `pt-BR`, `nl-NL`, `ja`, `it`, `sv`, `da`, `no`, `fi`, `zh-Hans`, `ru`, `pl`
- expected output count: 15 locales x 2 devices x 10 screenshots = 300 PNGs

App Store Connect accepts different locale folder names than Xcode localization names. For Fastlane Deliver, use the App Store Connect-compatible folder names above. Examples:

- Danish: `da`, not `da-DK`
- Finnish: `fi`, not `fi-FI`
- Italian: `it`, not `it-IT`
- Japanese: `ja`, not `ja-JP`
- Norwegian Bokmal: `no`, not `nb-NO`
- Polish: `pl`, not `pl-PL`
- Russian: `ru`, not `ru-RU`
- Swedish: `sv`, not `sv-SE`

Future screenshot optimization:

- For broad visual or copy changes, keep using the full screenshot automation as the reliable fallback.
- For small changes, generate only the affected screenshots from the real simulator UI, then write them into the existing `fastlane/screenshots/<locale>/` folders with the same filenames.
- For a paywall-only change, capture only `06-paywall` for every required locale and device: 15 locales x 2 devices = 30 PNGs, instead of regenerating the full 300-image set.
- Capture all needed screens for one locale before moving to the next locale. iOS localization generally refreshes cleanly at app launch, so the runner should relaunch the app when changing locales, but it should avoid unnecessary app reinstall/rebuild work.
- Use Fastlane for upload after the local screenshot folders are correct. The upload lane expects a complete folder set because `sync_screenshots: true` reconciles App Store Connect against the local directory.

## Fastlane Commands

Run from the repo root:

```sh
cd /Users/johntanner/Developer/Connections
```

Generate localized screenshots:

```sh
/opt/homebrew/opt/ruby/bin/bundle exec fastlane screenshots
```

Upload screenshot assets only:

```sh
export APPLE_ID=tanner3068@hotmail.com
/opt/homebrew/opt/ruby/bin/bundle exec fastlane upload_screenshots
```

The upload lane uses `sync_screenshots: true`, which reconciles App Store Connect against the local `fastlane/screenshots` folder and preserves filename order. This fixed earlier partial/out-of-order upload issues.

If Fastlane says `Could not locate Gemfile`, the terminal is in the wrong folder. `cd /Users/johntanner/Developer/Connections` and run again.

If App Store Connect shows temporary `500` processing messages during upload, verify the final Fastlane result and then inspect ASC. A successful run should say:

```text
Screenshots are synced successfully!
fastlane.tools finished successfully
```

The Fastlane precheck warning during screenshot upload is not a blocker when the lane finishes successfully and `submit_for_review` is false.

## App Store Connect Review Flow

For this release, the final review blockers were:

- public localized screenshots needed to be present and ordered correctly
- IAP App Review screenshot needed to be attached to the IAP product
- Paid Apps Agreement needed to be active
- tax and banking setup needed to be completed

Important distinction:

- Public App Store screenshots live on the app version product page.
- The IAP App Review screenshot lives inside the In-App Purchase metadata and is used internally by Apple Review.
- The optional 1024 x 1024 IAP image is not required for review. It appears in offer code redemptions and only appears on the product page if App Store Promotion is enabled for the IAP.

Paid Apps Agreement status:

- `New` means the agreement is available but not active yet.
- The Account Holder must complete legal entity, tax, and banking information.
- The app can be resubmitted when the Paid Apps Agreement is active.

## Build and Signing Notes

The main app identity:

- Bundle ID: `com.tanner.Connections`
- Team ID: `56X72VGLKJ`
- Apple ID used for App Store Connect: `tanner3068@hotmail.com`
- IAP product ID: `connections.full_access`

Fastlane lanes:

- `beta` - build and upload a new TestFlight build
- `sync_signing` - sync signing certificates and profiles
- `setup_signing` - create or upload signing certificates and profiles
- `screenshots` - capture App Store screenshots
- `upload_screenshots` - upload localized screenshots only

When Xcode command-line tools point only at Command Line Tools, `xcodebuild` can fail with:

```text
xcode-select: error: tool 'xcodebuild' requires Xcode
```

Fix by selecting the full Xcode developer directory in Xcode settings or via `xcode-select`.

## Claude Code and Local Tooling Notes

On a new Mac, the useful setup path was:

- install Xcode and Command Line Tools
- install Homebrew
- install Node with Homebrew
- install Claude Code with npm
- install `gh` with Homebrew for pull requests
- install Ruby/Bundler dependencies for Fastlane

Useful checks:

```sh
xcodebuild -version
brew --version
node --version
npm --version
claude --version
gh auth status
```

If `brew`, `npm`, or `claude` is `command not found`, confirm the shell environment first. For Apple Silicon Homebrew:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## GitHub Workflow

The paywall and screenshot work was prepared through branches and pull requests. The known PR from this push:

- PR #41: `https://github.com/skytan4/Connections/pull/41`

Useful GitHub CLI commands:

```sh
gh auth login
gh pr view 41 --repo skytan4/Connections --json mergeStateStatus,mergeable,state,url
```

Before committing future changes, always inspect:

```sh
git status --short
git diff --stat
```

Do not overwrite unrelated local changes. This repo often has work-in-progress files during release tasks.

## Design Principles We Used

The app should feel calm, intimate, and serious enough for meaningful conversation without becoming clinical.

Good patterns:

- show the real app experience quickly
- keep paywall copy specific and concrete
- treat Premium as a full-product unlock
- keep App Store screenshots truthful and easy to understand
- avoid over-indexing on Intimacy in marketing, even though it is a Premium feature
- use screenshots to show flow, not just isolated features
- test long translated strings on real UI surfaces

For future apps, start with:

- a one-page product brief
- the core user journey
- monetization shape
- App Store review risks
- localization plan
- screenshot narrative
- clear source-of-truth files for copy

## Collaboration Playbook

What worked well:

- keep a human-readable copy handoff file before editing localization files
- automate screenshots as soon as App Store review needs more than one language
- generate and upload from Fastlane rather than hand-managing hundreds of assets
- use filenames to control screenshot order
- verify the result in App Store Connect after upload
- record Apple review issues as product requirements, not just compliance chores

For future apps together:

- build the actual usable product first, not a marketing shell
- keep UI and copy scoped to the user's real workflow
- add automation when repetition or review risk appears
- keep App Store review assets in the repo
- write down any rejection reason and the exact fix
- update this project history after major review, localization, automation, or monetization changes
