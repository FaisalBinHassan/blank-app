import Foundation

enum AppConstants {
    // IMPORTANT: Change this to match your App Group ID in Xcode
    // Must match in both MainApp and KeyboardExtension targets
    static let appGroupID = "group.com.yourdomain.keyboardai"

    static let keychainServiceName = "com.yourdomain.keyboardai"

    enum UserDefaultsKey {
        static let selectedProvider = "selectedProvider"
        static let claudeAPIKey = "claudeAPIKey"
        static let openAIAPIKey = "openAIAPIKey"
        static let claudeModel = "claudeModel"
        static let openAIModel = "openAIModel"
        static let selectedContext = "selectedContext"
        static let hapticEnabled = "hapticEnabled"
        static let autoCapitalize = "autoCapitalize"
    }
}
