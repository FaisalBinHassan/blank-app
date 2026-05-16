@preconcurrency import UIKit
import SwiftUI

@MainActor
final class KeyboardViewModel: ObservableObject {
    // Injected by the view controller
    var inputViewController: UIInputViewController?

    // State
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var lastResult: String?
    @Published var showMoreOptions = false
    @Published var showCustomPrompt = false
    @Published var customPromptText = ""
    @Published var showEmojiSuggestions = false
    @Published var emojiSuggestions: [String] = []
    @Published var keyboardMode: KeyboardMode = .letters
    @Published var isUppercase = false
    @Published var isCapsLock = false
    @Published var currentText: String = ""

    private var settings: SharedSettings { SharedSettings.shared }

    private var proxy: UITextDocumentProxy? {
        inputViewController?.textDocumentProxy
    }

    var selectedContext: MessageContext {
        get { settings.selectedContext }
        set { settings.selectedContext = newValue }
    }

    // MARK: - Text manipulation

    func insertText(_ text: String) {
        proxy?.insertText(text)
        if isUppercase && !isCapsLock {
            isUppercase = false
        }
        refreshCurrentText()
    }

    func deleteBackward() {
        proxy?.deleteBackward()
        refreshCurrentText()
    }

    func insertSpace() { insertText(" ") }

    func insertNewline() { insertText("\n") }

    func switchToNextKeyboard() {
        inputViewController?.advanceToNextInputMode()
    }

    func dismissKeyboard() {
        inputViewController?.dismissKeyboard()
    }

    func refreshCurrentText() {
        currentText = proxy?.documentContextBeforeInput ?? ""
    }

    // Grabs all the text visible to the proxy (before + after cursor)
    var fullText: String {
        let before = proxy?.documentContextBeforeInput ?? ""
        let after = proxy?.documentContextAfterInput ?? ""
        return (before + after).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Shift handling

    func tapShift() {
        if isCapsLock {
            isCapsLock = false
            isUppercase = false
        } else if isUppercase {
            isCapsLock = true
        } else {
            isUppercase = true
        }
    }

    // MARK: - AI Transformations

    func transform(option: TransformationOption) {
        guard !isProcessing else { return }
        let text = fullText
        guard !text.isEmpty else {
            errorMessage = "Nothing to transform — type or dictate some text first."
            return
        }

        Task {
            await runTransform(text: text, option: option)
        }
    }

    func applyCustomPrompt() {
        guard !customPromptText.isEmpty else { return }
        let text = fullText
        guard !text.isEmpty else {
            errorMessage = "Nothing to transform."
            return
        }
        showCustomPrompt = false
        Task {
            await runTransform(text: text, option: .customPrompt, custom: customPromptText)
        }
    }

    private func runTransform(text: String, option: TransformationOption, custom: String = "") async {
        isProcessing = true
        errorMessage = nil

        do {
            let result = try await AIService.shared.transform(
                text: text,
                option: option,
                context: settings.selectedContext,
                customPrompt: custom
            )

            // Special case: emoji suggestions → show picker, don't replace text
            if option == .suggestEmojis {
                let emojis = result.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                emojiSuggestions = emojis
                showEmojiSuggestions = true
                isProcessing = false
                return
            }

            // Replace all text before the cursor with the AI result
            replaceText(original: text, replacement: result)
            lastResult = result

        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func replaceText(original: String, replacement: String) {
        guard let proxy else { return }

        // Move to end of document, then delete all before-cursor content
        // This handles cases where cursor is in the middle
        let beforeCount = (proxy.documentContextBeforeInput ?? "").count
        for _ in 0..<beforeCount {
            proxy.deleteBackward()
        }
        proxy.insertText(replacement)
    }

    // MARK: - Undo

    func undoLastTransform() {
        // iOS text proxies don't expose undo directly; we rely on the host app's undo
        // Trigger system undo via shake gesture proxy workaround is not available,
        // so we show a hint to the user.
        errorMessage = "Shake your device to undo."
    }
}

enum KeyboardMode {
    case letters, numbers, symbols
}
