# CarPlay Chat & Music App - Devin Task Breakdown

## Overview
This document breaks the iOS CarPlay-integrated chat and music streaming application into discrete, manageable tasks for Devin. Each phase is designed to stay within context limits while producing working, testable code.

---

## PHASE 1: Project Foundation & CarPlay Shell
**Estimated Devin Sessions: 2-3**

### Task 1.1: Xcode Project Setup
**Status: COMPLETE** - Project already scaffolded with workspace + SPM architecture.

Current structure:
```
JPChat/
├── JPChat.xcworkspace
├── JPChat.xcodeproj
├── JPChat/ (App target)
├── JPChatPackage/ (All code here)
│   └── Sources/JPChatFeature/
│       ├── App/
│       ├── Audio/
│       ├── CarPlay/
│       ├── Chat/
│       ├── Models/
│       ├── Services/
│       └── Extensions/
└── Config/
```

### Task 1.2: CarPlay Scene Configuration
**Prompt for Devin:**
```
In the JPChat iOS project, enhance CarPlay scene support:

1. Update JPChat/Info.plist with:
   - CPSupportedInterfaceStyles: light, dark
   - CPTemplateApplicationScene configuration
   - UIApplicationSceneManifest with CarPlay scene
   - UIBackgroundModes: audio, voip

2. The CarPlaySceneDelegate.swift already exists at:
   JPChatPackage/Sources/JPChatFeature/CarPlay/CarPlaySceneDelegate.swift

   Verify it:
   - Implements CPTemplateApplicationSceneDelegate
   - Sets up CPTabBarTemplate with tabs for Now Playing and Channels
   - Stores reference to interfaceController

3. Create CarPlayManager.swift singleton that:
   - Holds CarPlay connection state
   - Provides methods to update templates
   - Posts notifications on connect/disconnect

Build and test in CarPlay simulator.
```

### Task 1.3: CarPlay Audio Integration Base
**Prompt for Devin:**
```
In the JPChat iOS project, the audio foundation exists at:
JPChatPackage/Sources/JPChatFeature/Audio/AudioManager.swift

Verify and enhance:
1. AVAudioSession configured for playback + voice chat category
2. MPNowPlayingInfoCenter integration working
3. MPRemoteCommandCenter handlers for play/pause

Update CarPlaySceneDelegate to:
- Initialize AudioManager on connect
- Wire CPNowPlayingTemplate to AudioManager state

Test: CarPlay simulator should show Now Playing with real stream data.
```

---

## PHASE 2: Audio Streaming System
**Estimated Devin Sessions: 2-3**

### Task 2.1: Stream Data Model & Configuration
**Status: COMPLETE** - DJChannel.swift exists with 16 channels.

Location: `JPChatPackage/Sources/JPChatFeature/Models/DJChannel.swift`

**Prompt for Devin:**
```
In the JPChat iOS project, enhance the streaming data layer:

1. DJChannel.swift already has 16 genres. Update streamURL property with real Cloudflare URLs when available.

2. Create JPChatPackage/Sources/JPChatFeature/Services/FavoritesManager.swift:
   - UserDefaults-backed storage for favorite channel IDs
   - Methods: addFavorite(id), removeFavorite(id), isFavorite(id), getFavorites()
   - Use @AppStorage for SwiftUI integration
```

### Task 2.2: Audio Playback Implementation
**Status: PARTIAL** - AudioManager.swift exists with basic playback.

**Prompt for Devin:**
```
In the JPChat iOS project, enhance AudioManager.swift:

Location: JPChatPackage/Sources/JPChatFeature/Audio/AudioManager.swift

Add:
1. Stream error handling with retry logic
2. Handle interruptions (calls, Siri, etc.)
3. Handle route changes (headphones, CarPlay, Bluetooth)
4. Add streaming state: .loading, .playing, .paused, .error

Test: App should play audio that continues in background and shows in Control Center.
```

### Task 2.3: CarPlay Stream Browser
**Prompt for Devin:**
```
In the JPChat iOS project, enhance CarPlay stream browsing:

1. Update CarPlaySceneDelegate.swift to show all 16 channels as CPListItems
2. Group channels by vibe/mood in CPListSections
3. Show currently playing indicator on active channel
4. Handle item selection to switch streams

Test in CarPlay simulator: Browse channels, select one, verify playback starts.
```

---

## PHASE 3: Core Chat System
**Estimated Devin Sessions: 3-4**

### Task 3.1: Chat Data Models
**Status: PARTIAL** - JPMessage exists, need enhancements.

**Prompt for Devin:**
```
In the JPChat iOS project, enhance chat data models:

1. Update JPChatPackage/Sources/JPChatFeature/Services/JPChatService.swift:
   - Add TextEffect enum: bold, italic, color options
   - Add ChatType enum: jpChat, groupChat
   - Update JPMessage to include textEffects array

2. Create JPChatPackage/Sources/JPChatFeature/Models/User.swift:
   - struct User: Codable, Identifiable
   - Properties: id, displayName, avatarURL

3. Create JPChatPackage/Sources/JPChatFeature/Models/Conversation.swift:
   - struct Conversation: Codable, Identifiable
   - Properties: id, type (ChatType), participants, messages, lastUpdated
```

### Task 3.2: WebSocket Service
**Prompt for Devin:**
```
In the JPChat iOS project, implement WebSocket communication:

1. Create JPChatPackage/Sources/JPChatFeature/Services/WebSocketService.swift:
   - Uses URLSessionWebSocketTask (native, no dependencies)
   - Connection management: connect(), disconnect(), reconnect()
   - Message sending: send(_ message: JPMessage)
   - Combine publisher for incoming messages
   - Heartbeat/ping-pong handling
   - Auto-reconnect on disconnect

2. Update JPChatService.swift to use WebSocketService instead of REST calls for real-time messages.

The backend endpoint is: wss://soundfactory-unified-119762395778.us-central1.run.app/ws
```

### Task 3.3: Chat View Enhancements
**Status: PARTIAL** - ChatView.swift exists with basic UI.

**Prompt for Devin:**
```
In the JPChat iOS project, enhance chat UI:

Location: JPChatPackage/Sources/JPChatFeature/Chat/ChatView.swift

Add:
1. Mode toggle at top (JP Chat / Group Chat segment control)
2. Text effects picker button in input bar
3. Support for bold, italic, colored text rendering in bubbles
4. Unread message indicator
5. Pull-to-refresh for history

The view already has:
- Message bubbles with sender styling
- Typing indicator
- Auto-scroll
- Send button
```

### Task 3.4: Chat Persistence
**Prompt for Devin:**
```
In the JPChat iOS project, add chat persistence:

1. Create JPChatPackage/Sources/JPChatFeature/Services/ChatStorageService.swift:
   - Save messages to UserDefaults or file storage
   - Separate storage for JP chat vs Group chat
   - Load history on app launch
   - Limit stored messages (last 100 per chat)

2. Update JPChatService to:
   - Load persisted messages on init
   - Save new messages automatically
   - Sync with server history when online
```

---

## PHASE 4: Voice & Speech Integration
**Estimated Devin Sessions: 2-3**

### Task 4.1: Speech Recognition Service
**Prompt for Devin:**
```
In the JPChat iOS project, implement speech recognition:

1. Create JPChatPackage/Sources/JPChatFeature/Services/SpeechRecognitionService.swift:
   - Uses Speech framework (SFSpeechRecognizer)
   - Request authorization on first use
   - Continuous recognition mode
   - @Published var transcription: String
   - @Published var isListening: Bool

   Methods:
   - startListening()
   - stopListening()
   - Handle audio session conflicts with music playback

2. Add to Info.plist (via Devin or manual):
   - NSMicrophoneUsageDescription: "JP Chat uses your microphone for voice messages"
   - NSSpeechRecognitionUsageDescription: "JP Chat uses speech recognition for hands-free messaging"
```

### Task 4.2: Voice Command Processing
**Prompt for Devin:**
```
In the JPChat iOS project, implement voice commands:

1. Create JPChatPackage/Sources/JPChatFeature/Services/VoiceCommandProcessor.swift:
   - Listens to SpeechRecognitionService transcription
   - Detects trigger words: "JP", "group"
   - Filters trigger words from final message

   Commands to detect:
   - "JP" or "Hey JP" -> switch to JP Chat mode
   - "group" or "group chat" -> switch to Group Chat mode
   - "skip" -> skip to next channel
   - "pause" / "play" -> control playback
   - "play [channel name]" -> switch to specific channel

2. Update ChatView:
   - Long-press microphone button starts listening
   - Release stops and sends transcribed text
   - Visual waveform feedback during recording
```

### Task 4.3: CarPlay Voice Integration
**Prompt for Devin:**
```
In the JPChat iOS project, add voice to CarPlay:

1. Create JPChatPackage/Sources/JPChatFeature/CarPlay/CarPlayChatController.swift:
   - Manages voice input for CarPlay
   - CPVoiceControlTemplate integration
   - Shows last 5 messages per chat type

2. Update CarPlaySceneDelegate:
   - Add "Chat" tab with recent messages
   - "Send Message" button activates voice
   - Show incoming messages as brief alerts

Test in CarPlay simulator with voice input.
```

---

## PHASE 5: Floating Words Animation
**Estimated Devin Sessions: 1-2**

### Task 5.1: Floating Words View
**Prompt for Devin:**
```
In the JPChat iOS project, create floating words animation:

1. Create JPChatPackage/Sources/JPChatFeature/Views/FloatingWordsView.swift:
   - Words float up from bottom as user speaks
   - Each word appears individually with slight delay
   - Words fade out as they reach top
   - Use GeometryReader for positioning
   - Animate with .spring() for organic feel

2. Create JPChatPackage/Sources/JPChatFeature/Views/FloatingWord.swift:
   - Single word view with:
     - Random horizontal offset
     - Vertical animation (bottom to top)
     - Scale animation (small to normal to small)
     - Opacity animation (fade in, fade out)
     - Random rotation for playfulness

3. Integrate with SpeechRecognitionService:
   - As words are recognized, add to floating view
   - Remove words after they complete animation
```

### Task 5.2: Voice Input Overlay
**Prompt for Devin:**
```
In the JPChat iOS project, create voice input overlay:

1. Create JPChatPackage/Sources/JPChatFeature/Views/VoiceInputOverlay.swift:
   - Full-screen overlay when voice is active
   - Dark semi-transparent background
   - FloatingWordsView in center
   - Waveform visualization at bottom
   - "Listening..." indicator
   - Cancel button

2. Update ChatView:
   - Show VoiceInputOverlay when microphone is held
   - Dismiss on release
   - Send accumulated words as message
```

---

## PHASE 6: Main App UI & Polish
**Estimated Devin Sessions: 2**

### Task 6.1: Now Playing Bar
**Status: PARTIAL** - MiniPlayer exists in MainTabView.

**Prompt for Devin:**
```
In the JPChat iOS project, enhance the mini player:

Location: JPChatPackage/Sources/JPChatFeature/App/MainTabView.swift

Current MiniPlayer shows channel name and play/pause. Add:
1. Channel artwork/icon
2. Skip button
3. Tap to expand to full player sheet
4. Swipe up gesture to expand
5. Animation when track changes
```

### Task 6.2: Full Player View
**Prompt for Devin:**
```
In the JPChat iOS project, create full player:

1. Create JPChatPackage/Sources/JPChatFeature/Audio/FullPlayerView.swift:
   - Presented as sheet from mini player
   - Large channel artwork/visualization
   - Channel name and vibe description
   - Play/pause, previous, next buttons
   - Favorite toggle button
   - Channel picker (horizontal scroll of other channels)
   - "Now Streaming" live indicator
   - Close button to dismiss
```

### Task 6.3: Settings Enhancement
**Status: PARTIAL** - Basic SettingsView exists.

**Prompt for Devin:**
```
In the JPChat iOS project, enhance settings:

Location: JPChatPackage/Sources/JPChatFeature/App/SettingsView.swift

Add sections:
1. Voice Settings:
   - Voice activation toggle
   - Trigger word customization
   - Microphone sensitivity slider

2. Chat Settings:
   - Default chat mode (JP/Group)
   - Message notifications toggle
   - Clear chat history button

3. Playback Settings:
   - Auto-play on launch toggle
   - Default channel picker
   - Stream quality (when available)
```

---

## PHASE 7: Backend Integration
**Estimated Devin Sessions: 2**

### Task 7.1: API Service Enhancement
**Prompt for Devin:**
```
In the JPChat iOS project, enhance API integration:

The backend is at: https://soundfactory-unified-119762395778.us-central1.run.app

1. Update JPChatService.swift with full API:
   - POST /api/chat/message - send message
   - GET /api/chat/history - fetch history
   - POST /api/chat/typing - typing indicator

2. Create JPChatPackage/Sources/JPChatFeature/Services/AuthService.swift:
   - Anonymous auth (device-based user ID)
   - Store user ID in Keychain
   - Include in all API requests

3. Add offline support:
   - Queue messages when offline
   - Send queued messages on reconnect
   - Show offline indicator in UI
```

### Task 7.2: Stream URL Configuration
**Prompt for Devin:**
```
In the JPChat iOS project, configure real stream URLs:

1. Update DJChannel.swift streamURL property:
   - Use Cloudflare Stream HLS URLs
   - Format: https://customer-[id].cloudflarestream.com/[video-id]/manifest/video.m3u8

2. Create JPChatPackage/Sources/JPChatFeature/Services/StreamConfigService.swift:
   - Fetch stream URLs from backend (allows updates without app release)
   - Cache URLs locally
   - Fallback to hardcoded URLs if fetch fails

3. Add stream health check:
   - Verify stream is live before playing
   - Show "Offline" for unavailable channels
```

---

## PHASE 8: Testing & Polish
**Estimated Devin Sessions: 1-2**

### Task 8.1: SwiftUI Previews
**Prompt for Devin:**
```
In the JPChat iOS project, add comprehensive previews:

1. Create JPChatPackage/Sources/JPChatFeature/Preview Content/MockServices.swift:
   - MockAudioManager with sample state
   - MockJPChatService with sample messages
   - MockSpeechRecognitionService

2. Add #Preview blocks to all views:
   - ChatView with mock messages
   - StreamsView with mock channels
   - SettingsView
   - FloatingWordsView with sample words
   - FullPlayerView with mock playing state

3. Create preview for different states:
   - Empty chat
   - Loading state
   - Error state
   - Playing vs paused
```

### Task 8.2: Final Integration Testing
**Prompt for Devin:**
```
In the JPChat iOS project, verify integration:

1. Test flow: Launch -> Play channel -> Open chat -> Send message -> Voice input

2. Test CarPlay: Connect -> Browse channels -> Play -> Voice message

3. Verify:
   - Background audio continues
   - Now Playing shows in Control Center
   - Remote commands work
   - Chat persists between launches

4. Fix any warnings in build output

5. Verify all views work in both light and dark mode (app uses dark)
```

---

## Quick Reference: File Locations

| Feature | Path |
|---------|------|
| App Entry | `JPChat/JPChatApp.swift` |
| All Features | `JPChatPackage/Sources/JPChatFeature/` |
| Models | `Models/DJChannel.swift` |
| Chat Service | `Services/JPChatService.swift` |
| Audio Manager | `Audio/AudioManager.swift` |
| Chat UI | `Chat/ChatView.swift` |
| Streams UI | `Audio/StreamsView.swift` |
| CarPlay | `CarPlay/CarPlaySceneDelegate.swift` |
| Main Navigation | `App/MainTabView.swift` |
| Settings | `App/SettingsView.swift` |
| Colors | `Extensions/BrandColors.swift` |

---

## Backend API Reference

**Base URL:** `https://soundfactory-unified-119762395778.us-central1.run.app`

| Endpoint | Method | Body |
|----------|--------|------|
| `/api/chat/message` | POST | `{ "message": "...", "user_id": "...", "conversation_id": "..." }` |
| `/api/chat/history` | GET | Query: `?user_id=...&limit=50` |
| `/ws` | WebSocket | Real-time messages |

---

## Code Patterns to Follow

```swift
// Service pattern
@Observable
@MainActor
public final class SomeService {
    public static let shared = SomeService()
    public private(set) var state: State = .idle
    private init() {}
}

// View pattern
public struct SomeView: View {
    @State private var service = SomeService.shared
    public init() {}
    public var body: some View { ... }
}

// Async work in views
.task {
    await service.loadData()
}
```

---

## Priority Order for Devin

1. **Voice Input** (Phase 4) - Core differentiator
2. **Floating Words** (Phase 5) - Visual polish
3. **CarPlay Voice** (Phase 4.3) - Hands-free use case
4. **WebSocket** (Phase 3.2) - Real-time chat
5. **Full Player** (Phase 6.2) - Better UX
6. **Settings** (Phase 6.3) - User customization
