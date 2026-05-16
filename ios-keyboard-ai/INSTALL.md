# How to get KeyboardAI running on your iPhone

No Mac required. Free Apple ID is enough.

---

## The flow

```
GitHub repo  →  GitHub Actions (cloud Mac)  →  builds IPA
      ↓
Download IPA  →  AltStore on your iPhone  →  Done ✅
```

---

## Step 1 — Set your bundle ID prefix (one-time, 2 min)

Your app needs a unique ID. Use any reverse-domain you like.

1. Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
2. Click **New repository variable**
3. Name: `BUNDLE_ID_PREFIX`
4. Value: something like `com.faisal` or `com.yourname`  
   *(no spaces, all lowercase, no "keyboardai" — that's appended automatically)*
5. Save

---

## Step 2 — Trigger a build (2 min)

1. Go to your repo on GitHub → **Actions** tab
2. Click **Build KeyboardAI IPA** in the left sidebar
3. Click **Run workflow** → **Run workflow**
4. Wait ~5–8 minutes for it to finish (green checkmark ✅)
5. Click into the completed run → scroll to **Artifacts** → download **KeyboardAI-unsigned-xxxx.zip**
6. Unzip it — you'll have `KeyboardAI-unsigned.ipa`

> **Every time you push a change** to the repo, a new IPA is built automatically.

---

## Step 3 — Install AltStore on your iPhone (10 min, one-time)

AltStore signs and installs the IPA using your free Apple ID.
It also auto-refreshes the app every 7 days so it never expires.

### If you have a Windows PC:
1. Go to **altstore.io** → download **AltServer for Windows**
2. Install it and run it — it sits in the system tray
3. Plug your iPhone into the PC via USB
4. In AltServer tray icon → **Install AltStore** → select your iPhone
5. Enter your Apple ID when prompted (just used for signing, nothing is uploaded)
6. AltStore appears on your iPhone home screen

### If you have a Mac:
Same thing — download AltServer for Mac from altstore.io.

### No PC at all?
Use **Sideloadly** online signing at sideloadly.io — upload the IPA and they
sign it with your Apple ID via their web service (less ideal for long-term use).

---

## Step 4 — Install the KeyboardAI IPA (2 min)

### Via AltStore on your iPhone:
1. AirDrop the `.ipa` file to your iPhone, or put it in iCloud Drive / Files
2. Long-press the `.ipa` → **Share** → **AltStore**
3. AltStore signs and installs it

### Via AltServer on your PC (alternative):
1. Open AltServer on your PC, click the tray icon → **Sideload .ipa**
2. Select `KeyboardAI-unsigned.ipa` and your iPhone
3. Done

---

## Step 5 — Enable the keyboard (2 min, one-time)

On your iPhone:

1. **Settings** → **General** → **Keyboard** → **Keyboards** → **Add New Keyboard**
2. Scroll down → tap **KeyboardAI**
3. Tap **KeyboardAI** in the keyboard list → toggle **Allow Full Access ON**
   *(required for the AI features to make network requests)*

---

## Step 6 — Add your API key (1 min)

1. Open the **KeyboardAI** app on your iPhone
2. Tap the ⚙️ gear icon → paste your Claude or OpenAI API key
3. Choose your preferred model

---

## Step 7 — Use it

1. Open Messages, Mail, WhatsApp — any app with a text field
2. Tap the **🌐 globe key** on your current keyboard to switch to KeyboardAI
3. Type or dictate (switch to the system keyboard for dictation, then switch back)
4. Tap any chip in the AI bar to transform your text

---

## Keeping it alive (7-day refresh)

With a free Apple ID, Apple requires apps to be re-signed every 7 days.
AltStore handles this automatically **as long as your iPhone is on the same
Wi-Fi network as the computer running AltServer**. It refreshes silently in the background.

If AltServer isn't running for 7 days, you'll get a "app is no longer available"
error — just open AltStore on your phone and tap **Refresh All**.

### Want to skip the 7-day thing?
Get an [Apple Developer account](https://developer.apple.com/programs/) ($99/year).
Update the GitHub Actions workflow to sign with your paid certificate — the app
then stays on your phone for 1 full year with zero maintenance.

---

## Updating the app

1. Make changes to the code (or ask Claude to)
2. Push to GitHub — the Action builds a new IPA automatically
3. Download the new IPA from GitHub Actions → Artifacts
4. Install via AltStore (it overwrites the old version, your settings are preserved)

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Build fails in Actions | Check the Actions log; most likely a bundle ID conflict — change `BUNDLE_ID_PREFIX` |
| "App is no longer available" | Open AltStore → Refresh All (AltServer must be running) |
| AI chips do nothing | Make sure Allow Full Access is ON in Settings → Keyboard → KeyboardAI |
| "No API key" error | Open KeyboardAI app → Settings → add your key |
| Keyboard doesn't appear | Settings → General → Keyboards → Add New Keyboard → KeyboardAI |
