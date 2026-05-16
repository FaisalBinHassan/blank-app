import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: SharedSettings
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            List {
                statusSection
                setupSection
                aboutSection
            }
            .navigationTitle("KeyboardAI")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settings)
            }
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        Section("Status") {
            HStack {
                Image(systemName: settings.isConfigured ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(settings.isConfigured ? .green : .orange)
                VStack(alignment: .leading) {
                    Text(settings.isConfigured ? "API Key Configured" : "API Key Missing")
                        .font(.headline)
                    Text(settings.selectedProvider.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if !settings.isConfigured {
                Button("Configure API Key →") {
                    showSettings = true
                }
                .foregroundColor(.blue)
            }
        }
    }

    private var setupSection: some View {
        Section("Setup") {
            ForEach(Step.allCases) { step in
                HStack(alignment: .top, spacing: 12) {
                    Text(step.number)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Color.blue)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title)
                            .font(.subheadline)
                            .bold()
                        Text(step.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            Label("Supports Claude & OpenAI", systemImage: "brain")
            Label("Inline prompt detection", systemImage: "text.magnifyingglass")
            Label("Rewrite, Paraphrase, Summarize, and more", systemImage: "wand.and.stars")
            Label("Emoji suggestions", systemImage: "face.smiling")
            Label("Full dictation support via globe key", systemImage: "mic")
        }
        .foregroundColor(.secondary)
        .font(.subheadline)
    }
}

// MARK: - Setup steps model

private enum Step: CaseIterable, Identifiable {
    case addAPIKey, enableKeyboard, allowFullAccess, goType

    var id: Self { self }
    var number: String {
        switch self {
        case .addAPIKey: return "1"
        case .enableKeyboard: return "2"
        case .allowFullAccess: return "3"
        case .goType: return "4"
        }
    }
    var title: String {
        switch self {
        case .addAPIKey: return "Add your API key"
        case .enableKeyboard: return "Enable the keyboard"
        case .allowFullAccess: return "Allow Full Access"
        case .goType: return "Start typing!"
        }
    }
    var description: String {
        switch self {
        case .addAPIKey:
            return "Tap the gear icon → Settings and paste your Claude or OpenAI API key."
        case .enableKeyboard:
            return "Go to Settings → General → Keyboard → Keyboards → Add New Keyboard → KeyboardAI."
        case .allowFullAccess:
            return "Tap KeyboardAI in the keyboards list, then enable Allow Full Access (required for AI features)."
        case .goType:
            return "Switch to KeyboardAI via the 🌐 globe key in any app. Tap the AI bar to transform your text."
        }
    }
}
