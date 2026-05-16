import SwiftUI

struct MoreOptionsSheet: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // Context picker at the top
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

                // All transformation sections
                ForEach(TransformationSection.all, id: \.title) { section in
                    Section(section.title) {
                        ForEach(section.options) { option in
                            if option == .customPrompt {
                                customPromptRow
                            } else {
                                transformRow(option: option)
                            }
                        }
                    }
                }
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

    private func transformRow(_ option: TransformationOption) -> some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                viewModel.transform(option: option)
            }
        } label: {
            HStack {
                Text(option.icon)
                    .font(.title3)
                    .frame(width: 32)
                Text(option.displayName)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var customPromptRow: some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                viewModel.showCustomPrompt = true
            }
        } label: {
            HStack {
                Text("💡")
                    .font(.title3)
                    .frame(width: 32)
                Text("Custom Prompt…")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
                Text("Describe what you want to do with your text:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                TextField("e.g. Make it sound more confident", text: $viewModel.customPromptText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .focused($isFocused)
                    .padding(.horizontal)

                Text("Suggestions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                viewModel.customPromptText = suggestion
                            }
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }

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
}
