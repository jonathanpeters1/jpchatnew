import Foundation
import Combine

@MainActor
class WebSocketService: ObservableObject {
    static let shared = WebSocketService()
    
    @Published var isConnected = false
    @Published var lastMessage: WebSocketMessage?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private let baseURL = "wss://api.soundfactory.app/ws"
    
    private init() {
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
    }
    
    func connect() {
        guard let url = URL(string: baseURL) else {
            print("WebSocketService: Invalid URL")
            return
        }
        
        disconnect()
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    func send(message: String) {
        guard isConnected else {
            print("WebSocketService: Not connected")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocketService: Send error: \(error)")
            }
        }
    }
    
    func send(data: Data) {
        guard isConnected else {
            print("WebSocketService: Not connected")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.data(data)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocketService: Send error: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let message):
                    self?.handleMessage(message)
                    self?.receiveMessage()
                case .failure(let error):
                    print("WebSocketService: Receive error: \(error)")
                    self?.isConnected = false
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if let data = text.data(using: .utf8),
               let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                lastMessage = wsMessage
            }
        case .data(let data):
            if let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                lastMessage = wsMessage
            }
        @unknown default:
            break
        }
    }
}

struct WebSocketMessage: Codable, Identifiable {
    let id: String
    let type: MessageType
    let payload: String
    let timestamp: Date
    
    enum MessageType: String, Codable {
        case chat
        case audio
        case notification
        case system
    }
}
