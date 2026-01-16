import SwiftUI

public struct ChatView: View {
    @State private var chatService = JPChatService.shared
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatService.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if chatService.isLoading {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatService.messages.count) { _, _ in
                        if let lastMessage = chatService.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    TextField("Message JP...", text: $messageText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.sfDarkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .focused($isInputFocused)
                        .onSubmit {
                            sendMessage()
                        }

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(messageText.isEmpty ? Color.gray : Color.sfSilver)
                    }
                    .disabled(messageText.isEmpty || chatService.isLoading)
                }
                .padding()
                .background(Color.sfBlack)
            }
            .navigationTitle("JP")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.sfBlack)
            .toolbarBackground(Color.sfBlack, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messageText = ""
        isInputFocused = false

        Task {
            await chatService.sendMessage(text)
        }
    }
}

struct MessageBubble: View {
    let message: JPMessage

    var body: some View {
        HStack {
            if !message.isFromJP { Spacer(minLength: 60) }

            VStack(alignment: message.isFromJP ? .leading : .trailing, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromJP ? Color.sfDarkGray : Color.sfSilver)
                    .foregroundStyle(Color.sfWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if message.isFromJP { Spacer(minLength: 60) }
        }
    }
}

struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.sfSilver)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.sfDarkGray)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { animating = true }
    }
}

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}
