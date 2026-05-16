# KeyboardAI — iOS Custom Keyboard Extension

An AI-powered iOS keyboard that lets you transform, rewrite, summarize, and
rephrase your text inline — powered by Claude or OpenAI — while you type.

## Features

| Feature | Description |
|---|---|
| **Rewrite / Paraphrase / Summarize** | One-tap AI transformations in the quick bar |
| **Make Cooler / Formal / Casual** | Tone adjustments |
| **Email / Chat / Tweet reply** | Context-aware rewrites |
| **Add Emojis / Suggest Emojis** | Emoji strip with tap-to-insert |
| **Bullet Points / Shorten / Expand** | Format transformations |
| **Custom Prompt** | Describe exactly what you want in plain English |
| **Inline Prompt Detection** | Type `translate to Spanish: Hello` and tap Rewrite |
| **Dictation** | Use the globe key 🌐 to switch to the system keyboard dictation |
| **Claude & OpenAI** | Bring your own API key for either provider |
| **Context modes** | General / Email / Chat / Social / Professional |

---

## Project Structure

```
ios-keyboard-ai/
├── Shared/                        # Compiled into BOTH targets
│   ├── Constants.swift            # App Group ID and key names
│   ├── SharedSettings.swift       # Settings model + AI provider enums
│   ├── TransformationOption.swift # All AI actions + system prompts
│   └── AIService.swift            # Claude & OpenAI API calls
│
├── KeyboardExtension/             # Keyboard extension target
│   ├── KeyboardViewController.swift   # UIInputViewController entry point
│   ├── KeyboardViewModel.swift        # All keyboard logic & AI dispatch
│   ├── Info.plist
│   └── Views/
│       ├── KeyboardView.swift         # Root SwiftUI view
│       ├── AIActionBar.swift          # AI strip + chips + emoji bar
│       ├── QWERTYKeyboard.swift       # QWERTY + numbers keyboard layouts
│       └── MoreOptionsSheet.swift     # Full options sheet + custom prompt
│
└── MainApp/                       # Container app target (required by Apple)
    ├── KeyboardAIApp.swift
    ├── Info.plist
    └── Views/
        ├── ContentView.swift      # Onboarding + status
        └── SettingsView.swift     # API key + model + preferences
```

---

## Xcode Setup (step-by-step)

### 1. Create the Xcode project

1. Open Xcode → **File › New › Project**
2. Choose **iOS › App**
3. Product Name: `KeyboardAI`
4. Bundle ID: `com.yourdomain.keyboardai`
5. Interface: SwiftUI, Language: Swift
6. Save it anywhere on your Mac

### 2. Add the Keyboard Extension target

1. **File › New › Target**
2. Choose **iOS › Custom Keyboard Extension**
3. Product Name: `KeyboardExtension`
4. Finish

### 3. Add an App Group

Both targets need to share data (API keys, settings).

1. Select the **KeyboardAI** target › Signing & Capabilities › **+ App Group**
2. Add: `group.com.yourdomain.keyboardai` (must match `AppConstants.appGroupID`)
3. Repeat for the **KeyboardExtension** target

### 4. Add source files

Copy the folders from this repo into your Xcode project:

- Drag `Shared/` into the project — **add to both targets** when prompted
- Drag `KeyboardExtension/` files into the extension target only
- Drag `MainApp/` files into the main app target only

Replace the auto-generated `KeyboardViewController.swift` that Xcode created.

### 5. Update `AppConstants.swift`

```swift
static let appGroupID = "group.com.yourdomain.keyboardai"
```

Change `yourdomain` to match your actual bundle ID prefix.

### 6. Extension Info.plist

Xcode generates its own — merge the keys from `KeyboardExtension/Info.plist`
into it, specifically:
- `RequestsOpenAccess = YES` (required for network calls / AI features)
- `NSPrincipalClass = KeyboardExtension.KeyboardViewController`

### 7. Build & run on a real device

> **Note:** Custom keyboard extensions do **not** run in the Simulator.
> You must build to a physical iPhone or iPad.

1. Select your iPhone as the run target
2. Build & run the **KeyboardAI** (main app) scheme
3. Open the iOS **Settings** app on your device:
   - Settings → General → Keyboard → Keyboards → Add New Keyboard
   - Select **KeyboardAI**
   - Tap it in the list → enable **Allow Full Access** (required for AI)

---

## How to Use

### Basic flow

1. Open any app where you want to type (Messages, Mail, Notes, etc.)
2. Tap a text field — your default keyboard appears
3. Tap the 🌐 globe key to switch to **KeyboardAI**
4. Type or dictate your message (switch back to system keyboard for dictation,
   then switch back to KeyboardAI)
5. Tap an action chip in the **AI bar** at the top

### Dictation tip

Switch to the system keyboard → tap the 🎤 microphone → dictate your text →
switch back to KeyboardAI → tap a transform button.

### Inline Prompt Detection

KeyboardAI detects when your entire text **is** the prompt:

```
make this sound more professional
translate to French: Good morning, how are you?
summarize
rewrite this to be funnier
```

Just type the instruction and tap any transform button — the AI will interpret
the whole text as a prompt.

### Custom Prompt

Tap **💡 Prompt** in the action bar or **⚙️ More → Custom Prompt** and type
any instruction you want. Examples:

- "Make it rhyme"
- "Add a P.S."
- "Translate to Japanese"
- "Make it sound like Yoda"

---

## API Keys

Keys are stored in the shared `UserDefaults` suite for the App Group.

### Claude (Anthropic)
Get a key at <https://console.anthropic.com/>
Default model: `claude-sonnet-4-6`

### OpenAI
Get a key at <https://platform.openai.com/api-keys>
Default model: `gpt-4o`

---

## Architecture Notes

### Why `UIInputViewController` + SwiftUI?

The keyboard extension must subclass `UIInputViewController` (UIKit). The SwiftUI
views are embedded via `UIHostingController`. The `KeyboardViewModel` is an
`@MainActor ObservableObject` that bridges the UIKit proxy with SwiftUI state.

### Text replacement strategy

`UITextDocumentProxy` only exposes `documentContextBeforeInput` (text before
the cursor). The replacement strategy:
1. Read the before-cursor text
2. Delete it character by character using `deleteBackward()`
3. Insert the AI-transformed result

This works well for typical message-length text. Very long documents may
truncate context; for those, the user can select the specific text to transform.

### Inline Prompt Detection

`AIService.resolvePrompt()` checks two patterns before falling back to the
selected option's system prompt:
1. `instruction: content` colon split (e.g. `translate to Spanish: hello`)
2. Text that starts with known action verbs (e.g. `make this shorter`)

### Full Access requirement

`RequestsOpenAccess = YES` in the extension's Info.plist lets the extension
make network requests. Without it, `URLSession` calls are silently blocked by iOS.
The user must also toggle **Allow Full Access** in Settings.

---

## Customisation

### Add a new transformation

1. Add a case to `TransformationOption` in `Shared/TransformationOption.swift`
2. Fill in `displayName`, `icon`, and `systemPrompt(context:)`
3. Add it to a `TransformationSection` in `TransformationSection.all`
4. Optionally set `isInQuickBar = true` to pin it to the top strip

### Change models

Update the defaults in `SharedSettings` or let the user pick in `SettingsView`.
The `AIProvider.availableModels` array drives the picker.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| AI buttons do nothing | Check Allow Full Access is enabled in Settings |
| "No API key" error | Open the KeyboardAI app → gear → add your key |
| Keyboard doesn't appear | Settings → General → Keyboards → Add New Keyboard |
| Build fails on Simulator | Deploy to a real device — keyboard extensions require one |
| Text not being replaced | Ensure cursor is at the end of the text |
