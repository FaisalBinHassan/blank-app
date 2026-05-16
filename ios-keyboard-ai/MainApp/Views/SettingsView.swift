import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SharedSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showClaudeKey = false
    @State private var showOpenAIKey = false

    var body: some View {
        NavigationView {
            Form {
                providerSection
                apiKeySection
                modelSection
                defaultContextSection
                hapticsSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .bold()
                }
            }
        }
    }

    // MARK: - Sections

    private var providerSection: some View {
        Section("AI Provider") {
            Picker("Provider", selection: $settings.selectedProvider) {
                ForEach(AIProvider.allCases) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
        }
    }

    private var apiKeySection: some View {
        Section {
            switch settings.selectedProvider {
            case .claude:
                apiKeyRow(
                    title: "Anthropic API Key",
                    value: $settings.claudeAPIKey,
                    isVisible: $showClaudeKey,
                    placeholder: "sk-ant-..."
                )
                Link("Get an API key →", destination: URL(string: "https://console.anthropic.com/")!)
                    .font(.footnote)
            case .openai:
                apiKeyRow(
                    title: "OpenAI API Key",
                    value: $settings.openAIAPIKey,
                    isVisible: $showOpenAIKey,
                    placeholder: "sk-..."
                )
                Link("Get an API key →", destination: URL(string: "https://platform.openai.com/api-keys")!)
                    .font(.footnote)
            }
        } header: {
            Text("API Key")
        } footer: {
            Text("Keys are stored in the shared App Group keychain — only accessible by this app and the keyboard extension.")
                .font(.caption)
        }
    }

    private func apiKeyRow(title: String, value: Binding<String>, isVisible: Binding<Bool>, placeholder: String) -> some View {
        HStack {
            if isVisible.wrappedValue {
                TextField(placeholder, text: value)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } else {
                SecureField(placeholder, text: value)
            }
            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var modelSection: some View {
        Section("Model") {
            switch settings.selectedProvider {
            case .claude:
                Picker("Claude Model", selection: $settings.claudeModel) {
                    ForEach(AIProvider.claude.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            case .openai:
                Picker("OpenAI Model", selection: $settings.openAIModel) {
                    ForEach(AIProvider.openai.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            }
        }
    }

    private var defaultContextSection: some View {
        Section("Default Context") {
            Picker("Context", selection: $settings.selectedContext) {
                ForEach(MessageContext.allCases) { ctx in
                    Label(ctx.displayName, systemImage: ctx.icon).tag(ctx)
                }
            }
        }
    }

    private var hapticsSection: some View {
        Section("Feedback") {
            Toggle("Haptic Feedback", isOn: $settings.hapticEnabled)
        }
    }
}
