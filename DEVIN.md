# JP Chat - Devin Development Guide

## Project Overview

**JP Chat** is a voice-first CarPlay-integrated chat and music streaming iOS app. Users chat with JP (Sound Factory DJ) and stream from 16 curated house music channels.

## Quick Start

```bash
# Clone
git clone https://github.com/jonathanpeters1/jpchatnew.git
cd jpchatnew

# Open in Xcode
open JPChat.xcworkspace

# Build
xcodebuild -workspace JPChat.xcworkspace -scheme JPChat \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

## Project Structure

```
JPChat/
├── JPChat.xcworkspace           # OPEN THIS
├── JPChat.xcodeproj             # App shell
├── JPChat/                      # App target (minimal)
│   ├── JPChatApp.swift          # @main entry
│   └── Info.plist
├── JPChatPackage/               # ALL CODE GOES HERE
│   ├── Package.swift            # iOS 17+
│   └── Sources/JPChatFeature/
│       └── ContentView.swift    # Starting point
├── Config/
│   ├── JPChat.entitlements
│   └── *.xcconfig
└── DEVIN.md
```

## Your Tasks

### Phase 1 - Foundation

#### 1.1 Create Folder Structure
In `JPChatPackage/Sources/JPChatFeature/`, create:
```
├── App/           # MainTabView, SettingsView
├── Audio/         # AudioManager, player views
├── CarPlay/       # CarPlay delegates & controllers
├── Chat/          # Chat views
├── Models/        # Data models
├── Services/      # API & WebSocket
├── Extensions/    # Colors, utilities
└── Views/         # Reusable components
```

#### 1.2 Create Data Models
Create `Models/DJChannel.swift`:
```swift
import Foundation

public enum DJChannel: String, CaseIterable, Codable, Sendable, Identifiable {
    case deep, house, techno, melodic, funky, jackin
    case tech, afro, soulful, indie, classics, producer
    case vocal, minimal, breaks, chill

    public var id: String { rawValue }

    public var displayName: String {
        rawValue.capitalized
    }

    public var vibe: String {
        switch self {
        case .deep: return "The foundation"
        case .house: return "The heartbeat"
        case .techno: return "The pulse"
        case .melodic: return "The feeling"
        case .funky: return "The groove"
        case .jackin: return "The bounce"
        case .tech: return "The edge"
        case .afro: return "The spirit"
        case .soulful: return "The heart"
        case .indie: return "The underground"
        case .classics: return "The legacy"
        case .producer: return "The craft"
        case .vocal: return "The voice"
        case .minimal: return "The space"
        case .breaks: return "The rhythm"
        case .chill: return "The calm"
        }
    }

    public var streamURL: URL {
        // Placeholder - replace with real Cloudflare URLs
        URL(string: "https://example.com/stream/\(rawValue)")!
    }
}
```

#### 1.3 Create Brand Colors
Create `Extensions/BrandColors.swift`:
```swift
import SwiftUI

public extension Color {
    static let sfBlack = Color.black
    static let sfWhite = Color.white
    static let sfSilver = Color(red: 192/255, green: 192/255, blue: 192/255)
    static let sfDarkGray = Color(white: 0.15)
}
```

#### 1.4 Create JP Chat Service
Create `Services/JPChatService.swift`:
```swift
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

        // TODO: Implement actual API call
        // For now, simulate JP's response
        try? await Task.sleep(for: .seconds(1))

        let response = "I hear you. The music speaks."
        messages.append(JPMessage(content: response, isFromJP: true))
    }
}
```

#### 1.5 Create Audio Manager
Create `Audio/AudioManager.swift`:
```swift
import AVFoundation
import Observation
import MediaPlayer

@Observable
@MainActor
public final class AudioManager {
    public static let shared = AudioManager()

    public private(set) var currentChannel: DJChannel?
    public private(set) var isPlaying = false

    private var player: AVPlayer?

    private init() {
        setupAudioSession()
    }

    public func play(channel: DJChannel) {
        currentChannel = channel
        let item = AVPlayerItem(url: channel.streamURL)

        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    public func pause() {
        player?.pause()
        isPlaying = false
    }

    public func togglePlayPause() {
        isPlaying ? pause() : player?.play()
        isPlaying.toggle()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private func updateNowPlaying() {
        guard let channel = currentChannel else { return }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: channel.displayName,
            MPMediaItemPropertyArtist: channel.vibe,
            MPNowPlayingInfoPropertyIsLiveStream: true
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
```

### Phase 2 - CarPlay Integration

#### 2.1 Update Info.plist
Add to `JPChat/Info.plist`:
```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>CPTemplateApplicationSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>CarPlay</string>
                <key>UISceneDelegateClassName</key>
                <string>JPChatFeature.CarPlaySceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

#### 2.2 Create CarPlay Scene Delegate
Create `CarPlay/CarPlaySceneDelegate.swift`:
```swift
import CarPlay

public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController

        let nowPlayingTab = CPTabBarTemplate.init(templates: [
            CPNowPlayingTemplate.shared
        ])

        interfaceController.setRootTemplate(nowPlayingTab, animated: true)
    }

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
    }
}
```

### Phase 3 - Main UI

#### 3.1 Create Main Tab View
Create `App/MainTabView.swift`:
```swift
import SwiftUI

public struct MainTabView: View {
    public init() {}

    public var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }

            StreamsView()
                .tabItem {
                    Label("Streams", systemImage: "radio")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(.dark)
    }
}
```

#### 3.2 Create Chat View
Create `Chat/ChatView.swift`:
```swift
import SwiftUI

public struct ChatView: View {
    @State private var chatService = JPChatService.shared
    @State private var messageText = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatService.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Message JP...", text: $messageText)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task {
                            await chatService.sendMessage(messageText)
                            messageText = ""
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("JP")
            .background(Color.sfBlack)
        }
    }
}

struct MessageBubble: View {
    let message: JPMessage

    var body: some View {
        HStack {
            if !message.isFromJP { Spacer() }

            Text(message.content)
                .padding()
                .background(message.isFromJP ? Color.sfDarkGray : Color.sfSilver)
                .foregroundStyle(Color.sfWhite)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if message.isFromJP { Spacer() }
        }
    }
}
```

#### 3.3 Create Streams View
Create `Audio/StreamsView.swift`:
```swift
import SwiftUI

public struct StreamsView: View {
    @State private var audioManager = AudioManager.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            List(DJChannel.allCases) { channel in
                Button {
                    audioManager.play(channel: channel)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(channel.displayName)
                                .font(.headline)
                            Text(channel.vibe)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if audioManager.currentChannel == channel {
                            Image(systemName: audioManager.isPlaying ? "speaker.wave.3" : "pause")
                                .foregroundStyle(Color.sfSilver)
                        }
                    }
                }
            }
            .navigationTitle("Channels")
        }
    }
}
```

#### 3.4 Create Settings View
Create `App/SettingsView.swift`:
```swift
import SwiftUI

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Audio") {
                    Text("Quality: High")
                }

                Section("About") {
                    Text("JP Chat v1.0")
                    Text("Sound Factory")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

#### 3.5 Update ContentView
Update `ContentView.swift`:
```swift
import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        MainTabView()
    }
}
```

### Phase 4 - Voice Features

#### 4.1 Create Speech Recognizer
Create `Services/SpeechRecognizer.swift` with voice input using Speech framework.

#### 4.2 Create Floating Words
Create `Views/FloatingWordsView.swift` - words float up as you speak.

## Code Patterns

### @Observable (MV Pattern)
```swift
@Observable
@MainActor
public final class SomeService {
    public private(set) var state = State()
}

struct SomeView: View {
    @State private var service = SomeService()
}
```

### Async in Views
```swift
.task {
    await loadData()  // Auto-cancels
}
```

## Configuration

### Entitlements
Edit `Config/JPChat.entitlements`:
- Add `com.apple.developer.carplay-audio`
- Add App Groups if needed

### Signing
1. Add Development Team in Xcode
2. Enable CarPlay capability
3. Enable Background Modes: Audio

## Build Commands

```bash
# Build
xcodebuild -workspace JPChat.xcworkspace -scheme JPChat build

# Test
xcodebuild -workspace JPChat.xcworkspace -scheme JPChat test
```

## Backend API

- **Endpoint:** `https://soundfactory-unified-119762395778.us-central1.run.app/api/chat/message`
- **Method:** POST
- **Body:** `{ "message": "...", "user_id": "...", "conversation_id": "..." }`

## Important Rules

1. **All code in JPChatPackage** - never edit the app project
2. **iOS 17+** - use @Observable
3. **@MainActor** - all UI code
4. **No ViewModels** - use services directly
5. **Swift 6** - strict concurrency
