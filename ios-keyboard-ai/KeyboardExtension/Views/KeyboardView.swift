import SwiftUI

// Top-level SwiftUI root passed into the UIHostingController
struct KeyboardRootView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let needsGlobe: Bool

    var body: some View {
        KeyboardView(viewModel: viewModel, needsGlobe: needsGlobe)
            .sheet(isPresented: $viewModel.showMoreOptions) {
                MoreOptionsSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showCustomPrompt) {
                CustomPromptSheet(viewModel: viewModel)
            }
    }
}

// MARK: - Main keyboard container

struct KeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let needsGlobe: Bool

    var body: some View {
        VStack(spacing: 0) {
            // AI action bar / error / loading strip
            if viewModel.showEmojiSuggestions {
                EmojiSuggestionBar(
                    emojis: viewModel.emojiSuggestions,
                    onSelect: { emoji in
                        viewModel.insertText(emoji)
                    },
                    onDismiss: {
                        viewModel.showEmojiSuggestions = false
                        viewModel.emojiSuggestions = []
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                AIActionBar(viewModel: viewModel)
                    .transition(.opacity)
            }

            Divider()

            // Keyboard body
            Group {
                switch viewModel.keyboardMode {
                case .letters:
                    QWERTYKeyboard(viewModel: viewModel, needsGlobe: needsGlobe)
                case .numbers, .symbols:
                    NumbersKeyboard(viewModel: viewModel, needsGlobe: needsGlobe)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: viewModel.keyboardMode)
        }
        .background(Color(.systemGroupedBackground))
    }
}
