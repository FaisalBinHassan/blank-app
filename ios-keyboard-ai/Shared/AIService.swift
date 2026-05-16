import Foundation

actor AIService {
    static let shared = AIService()
    private init() {}

    // Entry point — detects inline prompts and dispatches to the right provider
    func transform(
        text: String,
        option: TransformationOption,
        context: MessageContext = .general,
        customPrompt: String = ""
    ) async throws -> String {

        let settings = SharedSettings.shared
        guard settings.isConfigured else {
            throw AIError.noAPIKey("No API key configured. Open the KeyboardAI app and add your API key in Settings.")
        }

        let (systemPrompt, userContent) = resolvePrompt(
            text: text,
            option: option,
            context: context,
            customPrompt: customPrompt
        )

        switch settings.selectedProvider {
        case .claude:
            return try await callClaude(system: systemPrompt, user: userContent, settings: settings)
        case .openai:
            return try await callOpenAI(system: systemPrompt, user: userContent, settings: settings)
        }
    }

    // MARK: - Inline Prompt Detection

    // Detects patterns like "make this sound professional" or "translate to spanish: hello world"
    private func resolvePrompt(
        text: String,
        option: TransformationOption,
        context: MessageContext,
        customPrompt: String
    ) -> (system: String, user: String) {

        // Pattern 1: "instruction: content" — colon split with short instruction
        let colonPattern = #"^(.{3,60}):\s+(.+)$"#
        if let match = text.range(of: colonPattern, options: [.regularExpression, .anchored]) {
            let parts = text.components(separatedBy: ": ")
            if parts.count >= 2 {
                let instruction = parts[0].trimmingCharacters(in: .whitespaces)
                let content = parts.dropFirst().joined(separator: ": ").trimmingCharacters(in: .whitespaces)
                if instruction.count < 80 && content.count > 3 {
                    return (
                        system: "You are a writing assistant. The user's instruction: \"\(instruction)\". Apply it and return only the result, no explanations.",
                        user: content
                    )
                }
            }
            _ = match // suppress warning
        }

        // Pattern 2: text starts with action verbs (whole text is the prompt)
        let actionPrefixes = [
            "make it", "make this", "rewrite", "change this", "transform",
            "summarize", "paraphrase", "fix", "improve", "shorten",
            "expand", "translate", "write a reply", "respond to"
        ]
        let lowered = text.lowercased().trimmingCharacters(in: .whitespaces)
        for prefix in actionPrefixes where lowered.hasPrefix(prefix) && text.count < 200 {
            return (
                system: "You are a writing assistant. Follow the user's instruction and return only the result, no preamble.",
                user: text
            )
        }

        // Pattern 3: custom prompt mode
        if option == .customPrompt && !customPrompt.isEmpty {
            return (
                system: "You are a writing assistant. \(customPrompt)\(context.styleNote) Return only the result, no explanations.",
                user: text
            )
        }

        // Default: use the option's built-in prompt
        return (
            system: option.systemPrompt(context: context),
            user: text
        )
    }

    // MARK: - Claude

    private func callClaude(system: String, user: String, settings: SharedSettings) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(settings.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let body: [String: Any] = [
            "model": settings.claudeModel,
            "max_tokens": 1024,
            "system": system,
            "messages": [["role": "user", "content": user]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        try checkHTTP(response: response, data: data, provider: "Claude")

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = (json["content"] as? [[String: Any]])?.first,
            let text = content["text"] as? String
        else { throw AIError.parseError("Unexpected Claude response format") }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - OpenAI

    private func callOpenAI(system: String, user: String, settings: SharedSettings) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(settings.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let body: [String: Any] = [
            "model": settings.openAIModel,
            "max_tokens": 1024,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        try checkHTTP(response: response, data: data, provider: "OpenAI")

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = (json["choices"] as? [[String: Any]])?.first,
            let message = choices["message"] as? [String: Any],
            let text = message["content"] as? String
        else { throw AIError.parseError("Unexpected OpenAI response format") }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Helpers

    private func checkHTTP(response: URLResponse, data: Data, provider: String) throws {
        guard let http = response as? HTTPURLResponse else {
            throw AIError.networkError("No HTTP response")
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            if http.statusCode == 401 { throw AIError.noAPIKey("\(provider): Invalid API key (401)") }
            if http.statusCode == 429 { throw AIError.apiError("\(provider): Rate limit exceeded. Try again in a moment.") }
            throw AIError.apiError("\(provider) error \(http.statusCode): \(body.prefix(200))")
        }
    }
}

enum AIError: LocalizedError {
    case noAPIKey(String)
    case networkError(String)
    case apiError(String)
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey(let m), .networkError(let m), .apiError(let m), .parseError(let m): return m
        }
    }
}
