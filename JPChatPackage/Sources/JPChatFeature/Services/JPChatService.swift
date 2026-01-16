import Foundation
import Observation

public struct JPMessage: Identifiable, Codable, Sendable {
    public let id: UUID
    public let content: String
    public let isFromJP: Bool
    public let timestamp: Date

    public init(content: String, isFromJP: Bool) {
        self.id = UUID()
        self.content = content
        self.isFromJP = isFromJP
        self.timestamp = Date()
    }
}

@Observable
@MainActor
public final class JPChatService {
    public static let shared = JPChatService()

    public private(set) var messages: [JPMessage] = []
    public private(set) var isLoading = false

    private let baseURL = "https://soundfactory-unified-119762395778.us-central1.run.app"

    private init() {}

    public func sendMessage(_ text: String) async {
        messages.append(JPMessage(content: text, isFromJP: false))
        isLoading = true

        defer { isLoading = false }

        do {
            let response = try await callJPAPI(message: text)
            messages.append(JPMessage(content: response, isFromJP: true))
        } catch {
            messages.append(JPMessage(content: "Connection lost. The music continues...", isFromJP: true))
        }
    }

    private func callJPAPI(message: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/chat/message") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "message": message,
            "user_id": UUID().uuidString,
            "conversation_id": UUID().uuidString
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let response = json["response"] as? String {
            return response
        }

        return "I hear you. The music speaks."
    }
}
