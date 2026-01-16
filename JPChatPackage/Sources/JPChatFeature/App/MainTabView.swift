import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var audioManager = AudioManager.shared

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(0)

            StreamsView()
                .tabItem {
                    Label("Streams", systemImage: "radio.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(Color.sfSilver)
        .preferredColorScheme(.dark)
        .overlay(alignment: .bottom) {
            if audioManager.currentChannel != nil {
                MiniPlayer()
                    .padding(.bottom, 49) // Tab bar height
            }
        }
    }
}

struct MiniPlayer: View {
    @State private var audioManager = AudioManager.shared

    var body: some View {
        if let channel = audioManager.currentChannel {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(channel.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(channel.vibe)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    audioManager.togglePlayPause()
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(Color.sfWhite)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .background(Color.sfDarkGray.opacity(0.8))
        }
    }
}

#Preview {
    MainTabView()
}
