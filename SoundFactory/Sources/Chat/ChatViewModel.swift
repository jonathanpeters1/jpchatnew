import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isRecording = false
    @Published var isLoading = false
    
    private let apiService = APIService.shared
    private let speechService = SpeechService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSpeechService()
        loadInitialMessages()
    }
    
    private func setupSpeechService() {
        speechService.$transcribedText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self, !text.isEmpty else { return }
                self.sendMessage(text)
            }
            .store(in: &cancellables)
        
        speechService.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRecording)
    }
    
    private func loadInitialMessages() {
        let welcomeMessage = Message(
            id: UUID(),
            content: "Welcome to SoundFactory! How can I help you today?",
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(_ content: String) {
        let userMessage = Message(
            id: UUID(),
            content: content,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        Task {
            await fetchResponse(for: content)
        }
    }
    
    private func fetchResponse(for content: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiService.sendChatMessage(content)
            let botMessage = Message(
                id: UUID(),
                content: response,
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(botMessage)
        } catch {
            let errorMessage = Message(
                id: UUID(),
                content: "Sorry, I couldn't process your message. Please try again.",
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
    }
    
    func startVoiceInput() {
        if isRecording {
            speechService.stopRecording()
        } else {
            speechService.startRecording()
        }
    }
}
