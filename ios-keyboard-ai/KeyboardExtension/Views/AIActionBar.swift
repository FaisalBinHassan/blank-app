import SwiftUI

struct AIActionBar: View {
    @ObservedObject var viewModel: KeyboardViewModel

    private let quickOptions: [TransformationOption] = TransformationOption.allCases.filter { $0.isInQuickBar }

    var body: some View {
        HStack(spacing: 0) {
            if viewModel.isProcessing {
                processingView
            } else if let err = viewModel.errorMessage {
                errorView(err)
            } else {
                quickActionsRow
            }
        }
        .frame(height: 44)
        .background(Color(.systemBackground).opacity(0.95))
    }

    // MARK: - States

    private var processingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Thinking…")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Button("Cancel") {
                viewModel.isProcessing = false
            }
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.trailing, 12)
        }
        .padding(.leading, 12)
    }

    private func errorView(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
                .lineLimit(1)
            Spacer()
            Button("✕") {
                viewModel.errorMessage = nil
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.trailing, 12)
        }
        .padding(.leading, 12)
    }

    private var quickActionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                // Quick options
                ForEach(quickOptions) { option in
                    ActionChip(label: "\(option.icon) \(option.displayName)") {
                        viewModel.transform(option: option)
                    }
                }

                Divider()
                    .frame(height: 22)
                    .padding(.horizontal, 2)

                // More button
                ActionChip(label: "⚙️ More", highlighted: true) {
                    viewModel.showMoreOptions = true
                }

                // Custom prompt button
                ActionChip(label: "💡 Prompt") {
                    viewModel.showCustomPrompt = true
                }

                // Context selector
                contextMenu
            }
            .padding(.horizontal, 10)
        }
    }

    private var contextMenu: some View {
        Menu {
            ForEach(MessageContext.allCases) { ctx in
                Button {
                    viewModel.selectedContext = ctx
                } label: {
                    Label(ctx.displayName, systemImage: ctx.icon)
                }
            }
        } label: {
            ActionChip(
                label: "📍 \(viewModel.selectedContext.displayName)",
                highlighted: viewModel.selectedContext != .general
            ) {}
        }
    }
}

// MARK: - ActionChip

struct ActionChip: View {
    let label: String
    var highlighted: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(highlighted ? .white : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(highlighted ? Color.blue : Color(.secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Emoji suggestion strip

struct EmojiSuggestionBar: View {
    let emojis: [String]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Text("Tap to insert:")
                .font(.caption2)
                .foregroundColor(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(emoji) { onSelect(emoji) }
                            .font(.title2)
                    }
                }
            }
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color(.systemBackground).opacity(0.95))
    }
}
