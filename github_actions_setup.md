# GitHub Actions Setup Guide for Default Tamer

There are two ways to build and release Default Tamer, depending on whether you have a paid Apple Developer account.

## Choose Your Path

### Path A: Unsigned Build (No Paid Account Required)
Use the **`unsigned-build`** branch. This branch is pre-configured to build a DMG without code signing or notarization.
- **Secrets Needed**: None (except `GITHUB_TOKEN` which is automatic).
- **Pros**: Easy setup, works for free.
- **Cons**: Users will see a security warning on macOS and must Right-click -> Open.

### Path B: Professional Signed Release (Paid Account Required)
Use the **`trunk`** branch. This follows the original full release flow with Apple certificates.
- **Secrets Needed**: All secrets listed in section 2 below.
- **Pros**: Professional, trusted by macOS Gatekeeper, smooth installation.
- **Cons**: Requires $99/year Apple Developer Program.

---

## 2. Prepare Your Apple Developer Credentials (Path B Only)

### A. Export Your Signing Certificate
1. Open **Keychain Access** on your Mac.
2. Find your **Developer ID Application** certificate.
3. Right-click and select **Export "Developer ID Application: ..."**.
4. Save it as a `.p12` file and set a password.
5. Convert this file to Base64 to save it in GitHub:
   ```bash
   base64 -i YourCertificate.p12 | pbcopy
   ```
   *Keep this value ready for `BUILD_CERTIFICATE_BASE64`.*

### B. Create an App-Specific Password
1. Go to [appleid.apple.com](https://appleid.apple.com/) and sign in.
2. Navigate to **App-Specific Passwords** and generate one (e.g., named "GitHub Actions").
   *Keep this value ready for `APPLE_ID_PASSWORD`.*

## 2. Configure GitHub Secrets

Go to your repository on GitHub: **Settings > Secrets and variables > Actions > New repository secret**.

| Secret Name | Description | Example |
| :--- | :--- | :--- |
| `SCRIPTS_DEPLOY_TOKEN` | A PAT with `repo` scope to pull the `private` scripts submodule. | `ghp_...` |
| `BUILD_CERTIFICATE_BASE64` | The Base64-encoded string of your `.p12` certificate. | *(Long string from step 1A)* |
| `P12_PASSWORD` | The password you set when exporting the `.p12` file. | `your_p12_password` |
| `KEYCHAIN_PASSWORD` | A random password for the temporary CI keychain. | `any_random_string` |
| `DEVELOPER_ID_NAME` | The Common Name of your certificate. | `Developer ID Application: Name (TEAMID)` |
| `TEAM_ID` | Your Apple Team ID. | `ABC123XYZ` |
| `APPLE_ID_USER` | Your Apple ID email address. | `user@example.com` |
| `APPLE_ID_TEAM` | Your Apple Team ID (usually same as `TEAM_ID`). | `ABC123XYZ` |
| `APPLE_ID_PASSWORD` | The app-specific password from step 1B. | `xxxx-xxxx-xxxx-xxxx` |
| `SPARKLE_PRIVATE_KEY` | Base64-encoded EdDSA private key for updates. | *(See step 3 below)* |

## 3. Generate Sparkle EdDSA Key (Optional)

If you haven't generated a Sparkle signing key yet, you can do so using the `generate_keys` tool (included in Sparkle):

1. Run the tool to generate `sparkle_keys.txt` containing your public and private keys.
2. Encode the **Private Key** only to Base64:
   ```bash
   echo "YOUR_PRIVATE_KEY" | base64 | pbcopy
   ```
   *Save this as `SPARKLE_PRIVATE_KEY`.*

## 4. How to Trigger a Release

The workflow is configured to run whenever a new tag starting with `v` is pushed.

1. Update the version in `VERSION.txt` (e.g., `0.0.8`).
2. Commit and push your changes.
3. Create and push a tag:
   ```bash
   git tag v0.0.8
   git push origin v0.0.8
   ```

The **Release** action will then:
- Build and sign the app.
- Create a `.dmg` using your scripts.
- Notarize the DMG with Apple.
- Create a GitHub Release with the DMG attached.
- Update the website data if applicable.

> [!IMPORTANT]
> Ensure the `private` submodule is accessible by the `SCRIPTS_DEPLOY_TOKEN`. If the scripts repo belongs to you, a Classic PAT with `repo` scope is usually sufficient.
