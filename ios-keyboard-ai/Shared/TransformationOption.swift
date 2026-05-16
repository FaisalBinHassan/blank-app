import Foundation

enum TransformationOption: String, CaseIterable, Identifiable {
    // Quick bar (always visible)
    case rewrite
    case paraphrase
    case fixGrammar
    case summarize

    // Tone
    case makeCooler
    case makeFormal
    case makeCasual
    case makeShorter
    case makeExpanded

    // Context
    case replyToEmail
    case replyToMessage
    case tweetFormat
    case bulletPoints

    // Emoji
    case addEmojis
    case suggestEmojis

    // Prompt-driven
    case customPrompt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rewrite:       return "Rewrite"
        case .paraphrase:    return "Paraphrase"
        case .fixGrammar:    return "Fix Grammar"
        case .summarize:     return "Summarize"
        case .makeCooler:    return "Make Cooler 😎"
        case .makeFormal:    return "Make Formal 👔"
        case .makeCasual:    return "Make Casual 👋"
        case .makeShorter:   return "Shorten ✂️"
        case .makeExpanded:  return "Expand 📖"
        case .replyToEmail:  return "Reply to Email 📧"
        case .replyToMessage:return "Reply to Message 💬"
        case .tweetFormat:   return "Tweet Format 𝕏"
        case .bulletPoints:  return "Bullet Points •"
        case .addEmojis:     return "Add Emojis 😊"
        case .suggestEmojis: return "Suggest Emojis 🎯"
        case .customPrompt:  return "Custom Prompt 🎤"
        }
    }

    var icon: String {
        switch self {
        case .rewrite:       return "✍️"
        case .paraphrase:    return "🔄"
        case .fixGrammar:    return "✅"
        case .summarize:     return "📝"
        case .makeCooler:    return "😎"
        case .makeFormal:    return "👔"
        case .makeCasual:    return "👋"
        case .makeShorter:   return "✂️"
        case .makeExpanded:  return "📖"
        case .replyToEmail:  return "📧"
        case .replyToMessage:return "💬"
        case .tweetFormat:   return "𝕏"
        case .bulletPoints:  return "•"
        case .addEmojis:     return "😊"
        case .suggestEmojis: return "🎯"
        case .customPrompt:  return "💡"
        }
    }

    var isInQuickBar: Bool {
        switch self {
        case .rewrite, .paraphrase, .fixGrammar, .summarize: return true
        default: return false
        }
    }

    func systemPrompt(context: MessageContext) -> String {
        let base: String
        switch self {
        case .rewrite:
            base = "Rewrite the following text to improve its clarity, flow, and readability. Preserve the original meaning. Return only the rewritten text, no explanations."
        case .paraphrase:
            base = "Paraphrase the following text using different words and sentence structures while preserving the exact meaning. Return only the paraphrased text."
        case .fixGrammar:
            base = "Correct all grammar, spelling, punctuation, and style errors in the following text. Return only the corrected text."
        case .summarize:
            base = "Summarize the following text concisely, preserving all key points. Return only the summary."
        case .makeCooler:
            base = "Rewrite the following text to sound cooler, more trendy, energetic, and fun. Keep the core message. Return only the transformed text."
        case .makeFormal:
            base = "Transform the following text to be more formal and professional. Return only the transformed text."
        case .makeCasual:
            base = "Rewrite the following text to be more casual, friendly, and relaxed. Return only the transformed text."
        case .makeShorter:
            base = "Make the following text significantly shorter and more concise while preserving the key message. Return only the shortened text."
        case .makeExpanded:
            base = "Expand the following text with more detail, examples, or context while keeping it natural and on-topic. Return only the expanded text."
        case .replyToEmail:
            base = "Write a professional and appropriate email reply to the following email. Be concise and helpful. Return only the reply body text."
        case .replyToMessage:
            base = "Write a natural and friendly reply to the following message. Match the tone and style. Return only the reply text."
        case .tweetFormat:
            base = "Reformat the following text to be an engaging tweet under 280 characters. Use hashtags if appropriate. Return only the tweet text."
        case .bulletPoints:
            base = "Convert the following text into a clear, well-organized bullet point list. Return only the bullet points."
        case .addEmojis:
            base = "Add relevant and expressive emojis throughout the following text to make it more vivid and engaging. Return only the text with emojis."
        case .suggestEmojis:
            base = "Analyze the following text and return a list of the 10 most relevant emojis for it, separated by spaces. Return only the emojis, nothing else."
        case .customPrompt:
            return "" // Filled in by the caller
        }
        return base + context.styleNote
    }
}

// Sections for the "More" sheet
struct TransformationSection {
    let title: String
    let options: [TransformationOption]

    static let all: [TransformationSection] = [
        TransformationSection(title: "Rewrite", options: [.rewrite, .paraphrase, .fixGrammar, .summarize]),
        TransformationSection(title: "Tone", options: [.makeCooler, .makeFormal, .makeCasual, .makeShorter, .makeExpanded]),
        TransformationSection(title: "Context", options: [.replyToEmail, .replyToMessage, .tweetFormat, .bulletPoints]),
        TransformationSection(title: "Emojis", options: [.addEmojis, .suggestEmojis]),
        TransformationSection(title: "Prompt", options: [.customPrompt]),
    ]
}
