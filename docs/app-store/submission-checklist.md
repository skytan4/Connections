# App Store Submission Checklist

Purpose: make Deeper Conversations ready for App Store submission with a polished product page, localized screenshots, correct monetization setup, and clear review notes.

Sources to re-check before final upload:
- Apple screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- Apple product page guidance: https://developer.apple.com/app-store/product-page/
- Apple platform version metadata reference: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Apple app icon guidance: https://developer.apple.com/design/human-interface-guidelines/app-icons

## Current Repo Facts

| Area | Current state | Action |
|---|---|---|
| Bundle ID | `com.tanner.Connections` | Confirm this exact app exists in App Store Connect. |
| Version/build | `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1` | Bump build for every TestFlight upload. |
| Device family | `TARGETED_DEVICE_FAMILY = "1,2"` | App supports iPhone and iPad, so iPad App Store screenshots are required unless we intentionally switch to iPhone-only. |
| IAP product ID | `connections.full_access` | Create matching non-consumable in App Store Connect and confirm price/localizations. |
| Local StoreKit price | `9.99` | Confirm final launch price in App Store Connect. |
| Existing screenshots | `fastlane/screenshots/*.png`, 1284 x 2778, English only | Useful raw captures, but not a full localized App Store set. |
| Fastlane screenshot config | `iPhone 16 Pro Max`, `en-US` only | Expand or add a separate submission screenshot workflow. |

## Release-Critical Product Checks

Do these before uploading the final release candidate.

- Confirm the app icon asset in `Connections/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png` is final, square, and has no baked rounded corners.
- Confirm release builds do not expose beta unlock behavior.
- Confirm the debug premium override is not visible in release builds.
- Confirm `connections.full_access` exists in App Store Connect as a non-consumable product.
- Confirm purchase, restore, cancellation, failure, and no-network states in Sandbox/TestFlight.
- Confirm the paywall price line shows the real localized StoreKit price.
- Confirm Intimacy prompts are accessible without an age gate (gate removed).
- Confirm app age rating answers account for mature intimacy content in prompts.
- Confirm App Privacy answers match the app's actual data behavior.
- Confirm privacy policy routing for every locale in Settings.
- Confirm support URL is live and includes real contact information.
- Confirm review notes explain there is no account login and how to reach premium gates.

## Required App Store Assets

| Asset | Required? | Recommended action |
|---|---:|---|
| App icon | Yes | Upload 1024 x 1024 PNG from the app icon asset. |
| iPhone screenshots | Yes | Produce a 6.9-inch portrait set. Apple accepts 1260 x 2736, 1290 x 2796, or 1320 x 2868. |
| iPad screenshots | Yes if iPad supported | Because this app currently targets iPad, produce a 13-inch iPad portrait set: 2064 x 2752 or 2048 x 2732. |
| App previews | Optional | Defer unless screenshots underperform; a calm 15-20 second preview could help later. |
| IAP display name | Yes for promoted IAP | Localize the Full Access purchase name. Limit: 35 characters. |
| IAP description | Yes for promoted IAP | Localize the short purchase benefit. Limit: 55 characters per Apple product page guidance. |

## Screenshot Strategy

Make screenshots feel like a premium editorial story, not raw simulator captures.

Recommended 6-image narrative:

| # | Screen | Message |
|---:|---|---|
| 1 | Home | Go beyond small talk. |
| 2 | Mode selection | Choose couples, friends, family, or solo reflection. |
| 3 | Intensity/depth | Pick the tone: light, honest, or unfiltered. |
| 4 | Live prompt | Ask a question that opens something real. |
| 5 | Follow-up / guided flow | Keep going when the moment matters. |
| 6 | Paywall or library value | 2,001 prompts. One purchase. No subscription. |

Visual rules:
- Use localized headline overlays, not English screenshots for every market.
- Keep overlay copy short enough for German, Finnish, Russian, and Portuguese.
- Prefer one headline plus one optional short subline per screenshot.
- Avoid showing private or sensitive user data.
- Do not over-emphasize Intimacy in screenshots; include it as part of premium value, not the primary brand.
- Use the final app icon and warm brand palette consistently.
- Test each screenshot at App Store search-result size, not only full-screen.

Suggested output structure:

```text
docs/app-store/assets/
  en-US/
    iphone-6.9/
      01-go-beyond-small-talk.png
      ...
    ipad-13/
      01-go-beyond-small-talk.png
      ...
  es/
  fr/
  ...
```

## Localized Metadata Work

Use `docs/app-store/localized-metadata-matrix.md` as the copy source of truth.

Fields to prepare per locale:
- App name: likely keep `Deeper Conversations` as the brand unless ASO research says otherwise.
- Subtitle: 30 characters max.
- Promotional text: 170 characters max; not indexed, so use benefit copy.
- Description: 4000 characters max; plain text only.
- Keywords: 100 bytes max; market-specific research required, do not merely translate the English keyword list.
- Screenshot headlines: 6 localized captions.
- IAP display name and description.

## Best-In-Class QA Before Upload

Run this after all localized assets are ready.

- Product-page squint test: first 3 screenshots explain the app without reading the description.
- Search-result test: icon, app name, subtitle, and first screenshots look distinct among relationship, journaling, therapy, mindfulness, and dating apps.
- Localization fit test: all screenshot headlines fit without awkward line breaks.
- StoreKit test: price and purchase state display correctly in each localization.
- Small-phone paywall test: no clipping on iPhone SE.
- iPad test: screenshot set and app UI do not look like stretched iPhone UI.
- Dark/tinted icon test: icon remains recognizable.
- VoiceOver smoke test for purchase button, restore button, and paywall dismiss.
- Final build: archive Release build, upload to TestFlight, install from TestFlight, run the purchase path.

## App Review Notes Draft

Use this as the starting point in App Store Connect:

```text
Deeper Conversations does not require an account or login.

The app offers conversation prompts for couples, friends, families, and solo reflection. Some premium prompts include adult relationship and intimacy content.

Premium access is a one-time non-consumable purchase using product ID connections.full_access. To test premium gates, open the app, choose a premium feature such as Unfiltered, Intimacy, a 20-question session, Fall in Love, Share an Experience, or Life Story, and the paywall will appear.

No real user data is required to test the app.
```

## Recommended Sequence From Here

1. Finalize the real App Store Connect app record and `connections.full_access` IAP.
2. Run a Sandbox/TestFlight purchase pass.
3. Decide whether to keep iPad support. If yes, produce iPad screenshots. If no, change target device family before submission.
4. Generate raw localized screenshots or build marketing screenshot templates.
5. Fill and QA the localized metadata matrix.
6. Export final screenshot assets for every supported locale.
7. Upload metadata, screenshots, privacy, age rating, and IAP info.
8. Submit IAP with the app version.
9. Submit for review with clear notes.
