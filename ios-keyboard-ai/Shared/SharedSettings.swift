import Foundation

final class SharedSettings: ObservableObject {
    static let shared = SharedSettings()

    private var defaults: UserDefaults {
        UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
    }

    @Published var selectedProvider: AIProvider {
        didSet { defaults.set(selectedProvider.rawValue, forKey: AppConstants.UserDefaultsKey.selectedProvider) }
    }
    @Published var claudeAPIKey: String {
        didSet { defaults.set(claudeAPIKey, forKey: AppConstants.UserDefaultsKey.claudeAPIKey) }
    }
    @Published var openAIAPIKey: String {
        didSet { defaults.set(openAIAPIKey, forKey: AppConstants.UserDefaultsKey.openAIAPIKey) }
    }
    @Published var claudeModel: String {
        didSet { defaults.set(claudeModel, forKey: AppConstants.UserDefaultsKey.claudeModel) }
    }
    @Published var openAIModel: String {
        didSet { defaults.set(openAIModel, forKey: AppConstants.UserDefaultsKey.openAIModel) }
    }
    @Published var selectedContext: MessageContext {
        didSet { defaults.set(selectedContext.rawValue, forKey: AppConstants.UserDefaultsKey.selectedContext) }
    }
    @Published var hapticEnabled: Bool {
        didSet { defaults.set(hapticEnabled, forKey: AppConstants.UserDefaultsKey.hapticEnabled) }
    }

    private init() {
        let d = UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        selectedProvider = AIProvider(rawValue: d.string(forKey: AppConstants.UserDefaultsKey.selectedProvider) ?? "") ?? .claude
        claudeAPIKey = d.string(forKey: AppConstants.UserDefaultsKey.claudeAPIKey) ?? ""
        openAIAPIKey = d.string(forKey: AppConstants.UserDefaultsKey.openAIAPIKey) ?? ""
        claudeModel = d.string(forKey: AppConstants.UserDefaultsKey.claudeModel) ?? "claude-sonnet-4-6"
        openAIModel = d.string(forKey: AppConstants.UserDefaultsKey.openAIModel) ?? "gpt-4o"
        selectedContext = MessageContext(rawValue: d.string(forKey: AppConstants.UserDefaultsKey.selectedContext) ?? "") ?? .general
        hapticEnabled = d.bool(forKey: AppConstants.UserDefaultsKey.hapticEnabled)
    }

    var activeAPIKey: String {
        switch selectedProvider {
        case .claude: return claudeAPIKey
        case .openai: return openAIAPIKey
        }
    }

    var isConfigured: Bool { !activeAPIKey.isEmpty }
}

enum AIProvider: String, CaseIterable, Identifiable {
    case claude, openai

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .claude: return "Claude (Anthropic)"
        case .openai: return "OpenAI"
        }
    }
    var defaultModel: String {
        switch self {
        case .claude: return "claude-sonnet-4-6"
        case .openai: return "gpt-4o"
        }
    }
    var availableModels: [String] {
        switch self {
        case .claude: return ["claude-opus-4-7", "claude-sonnet-4-6", "claude-haiku-4-5-20251001"]
        case .openai: return ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo"]
        }
    }
}

enum MessageContext: String, CaseIterable, Identifiable {
    case general, email, chat, social, professional

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .general: return "General"
        case .email: return "Email"
        case .chat: return "Chat / iMessage"
        case .social: return "Social Media"
        case .professional: return "Professional"
        }
    }
    var icon: String {
        switch self {
        case .general: return "text.bubble"
        case .email: return "envelope"
        case .chat: return "message"
        case .social: return "person.2"
        case .professional: return "briefcase"
        }
    }
    var styleNote: String {
        switch self {
        case .general: return ""
        case .email: return " Format it as a well-structured email."
        case .chat: return " Keep it casual and conversational, suitable for chat."
        case .social: return " Make it engaging for social media."
        case .professional: return " Use a formal, professional tone."
        }
    }
}
