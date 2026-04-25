# Connections

## TestFlight Pipeline

Builds are triggered automatically on push to `main` via GitHub Actions. You can also trigger manually: GitHub → Actions → TestFlight → Run workflow.

### Credentials & Accounts

| Item | Value |
|---|---|
| Apple Developer Team ID | 56X72VGLKJ |
| Bundle ID | com.tanner.Connections |
| Apple ID | tanner3068@hotmail.com |
| App Store Connect Key ID | B6542GXZ8W |
| Certificates repo | github.com/tanner3068/connections-certificates |

### If you need to set up signing on a new Mac

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Add your SSH key to GitHub** (if not already done)
   ```bash
   ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519_personal
   gh ssh-key add ~/.ssh/id_ed25519_personal.pub --title "My Mac"
   ```
   You'll also need read access to `github.com/tanner3068/connections-certificates` — ask Skyler to add you as a collaborator.

3. **Export the App Store Connect API key** — get the `.p8` file and set these in your terminal:
   ```bash
   export APP_STORE_CONNECT_KEY_ID=B6542GXZ8W
   export APP_STORE_CONNECT_ISSUER_ID=69a6de87-04cf-47e3-e053-5b8c7c11a4d1
   export APP_STORE_CONNECT_KEY_CONTENT=$(base64 -b 0 -i /path/to/AuthKey_B6542GXZ8W.p8)
   export APPLE_ID=tanner3068@hotmail.com
   export MATCH_PASSWORD=<password saved in Apple Passwords as "match cert password">
   ```

4. **Sync certificates to your machine**
   ```bash
   bundle exec fastlane sync_signing
   ```

### Fastlane Lanes

| Lane | Command | Purpose |
|---|---|---|
| `beta` | `bundle exec fastlane beta` | Build and upload to TestFlight |
| `sync_signing` | `bundle exec fastlane sync_signing` | Install certs/profiles on this machine |
| `setup_signing` | `bundle exec fastlane setup_signing` | Regenerate certs (run once, rarely needed) |
| `screenshots` | `bundle exec fastlane screenshots` | Capture App Store screenshots |

### Screenshots

Screenshots use the iPhone 16 Pro Max on iOS 18.0 simulator. Make sure it's installed in Xcode → Settings → Platforms before running `fastlane screenshots`.
