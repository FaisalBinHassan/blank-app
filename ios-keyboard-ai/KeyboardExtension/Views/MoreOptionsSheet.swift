import SwiftUI

struct MoreOptionsSheet: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                contextSection
                transformationSections
            }
            .navigationTitle("AI Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var contextSection: some View {
        Section("Context") {
            Picker("Style", selection: Binding(
                get: { viewModel.selectedContext },
                set: { viewModel.selectedContext = $0 }
            )) {
                ForEach(MessageContext.allCases) { ctx in
                    Label(ctx.displayName, systemImage: ctx.icon).tag(ctx)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var transformationSections: some View {
        ForEach(TransformationSection.all, id: \.title) { section in
            Section(section.title) {
                ForEach(section.options) { option in
                    sheetRow(option)
                }
            }
        }
    }

    @ViewBuilder
    private func sheetRow(_ option: TransformationOption) -> some View {
        if option == .customPrompt {
            customPromptRow
        } else {
            transformRow(option)
        }
    }

    private func transformRow(_ option: TransformationOption) -> some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                viewModel.transform(option: option)
            }
        } label: {
            rowLabel(icon: option.icon, title: option.displayName)
        }
    }

    private var customPromptRow: some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                viewModel.showCustomPrompt = true
            }
        } label: {
            rowLabel(icon: "💡", title: "Custom Prompt…")
        }
    }

    private func rowLabel(icon: String, title: String) -> some View {
        HStack {
            Text(icon)
                .font(.title3)
                .frame(width: 32)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Custom Prompt Sheet

struct CustomPromptSheet: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private let suggestions = [
        "Translate to Spanish",
        "Make it sound like Shakespeare",
        "Add a call to action",
        "Make it more persuasive",
        "Explain like I'm 5",
        "Convert to first person",
        "Add humor",
    ]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                inputSection
                suggestionsSection
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Custom Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.customPromptText = ""
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            viewModel.applyCustomPrompt()
                        }
                    }
                    .disabled(viewModel.customPromptText.isEmpty)
                    .bold()
                }
            }
        }
        .onAppear { isFocused = true }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe what you want to do with your text:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            TextField("e.g. Make it sound more confident", text: $viewModel.customPromptText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .focused($isFocused)
                .padding(.horizontal)
        }
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Suggestions")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(suggestions, id: \.self) { suggestion in
                        suggestionButton(suggestion)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func suggestionButton(_ title: String) -> some View {
        Button(title) {
            viewModel.customPromptText = title
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}
