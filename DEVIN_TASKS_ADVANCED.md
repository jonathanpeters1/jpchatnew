# JPChat Advanced Features - Devin Task Breakdown (Phase 2)

## Overview
These tasks extend the core JPChat app with advanced features. Complete Phase 1 (core app) before starting these tasks.

---

## PHASE 9: Live Location & ETA Sharing
**Estimated Devin Sessions: 2-3**

### Task 9.1: Location Service Foundation
**Prompt for Devin:**
```
In the JPChat iOS project, implement location services foundation:

1. Create JPChatPackage/Sources/JPChatFeature/Services/LocationService.swift:
   - CLLocationManager wrapper as singleton
   - Request "Always" or "When In Use" authorization
   - Continuous location updates with battery optimization
   - Significant location change monitoring
   - Properties:
     @Published var currentLocation: CLLocation?
     @Published var authorizationStatus: CLAuthorizationStatus
     @Published var isMoving: Bool (detect if user is driving)

2. Create JPChatPackage/Sources/JPChatFeature/Models/UserLocation.swift:
   - struct UserLocation: Codable
   - Properties: userId, latitude, longitude, speed, heading, timestamp, isSharing

3. Update Info.plist with:
   - NSLocationWhenInUseUsageDescription
   - NSLocationAlwaysAndWhenInUseUsageDescription
   - UIBackgroundModes: location

4. Add location toggle in Settings to enable/disable sharing

Test: App should request location permission and log current coordinates.
```

### Task 9.2: ETA Calculation & Sharing
**Prompt for Devin:**
```
In the JPChat iOS project, implement ETA calculation and sharing:

1. Create JPChatPackage/Sources/JPChatFeature/Services/ETAService.swift:
   - Calculate ETA using MKDirections API
   - Method: calculateETA(to destination: CLLocationCoordinate2D) async -> TimeInterval?
   - Method: getFormattedETA() -> String (e.g., "12 minutes away")
   - Auto-recalculate when location changes significantly
   - Cache routes to reduce API calls

2. Create JPChatPackage/Sources/JPChatFeature/Models/ETAUpdate.swift:
   - struct ETAUpdate: Codable
   - Properties: userId, userName, etaMinutes, destinationName, lastUpdated

3. Update WebSocketService to broadcast ETA updates:
   - New message type: .etaUpdate
   - Send updates every 2 minutes or when ETA changes by >2 minutes

4. Create JPChatPackage/Sources/JPChatFeature/Views/ETABannerView.swift:
   - Shows incoming user ETAs in chat
   - "JP is 12 minutes away" with live countdown
   - Tap to open in Apple Maps

5. Add "Share My ETA" button in chat that:
   - Prompts for destination (search or pick from map)
   - Starts sharing until arrival or manual stop

Test: Set a destination, see ETA update in chat as you move.
```

### Task 9.3: Meetup Coordination
**Prompt for Devin:**
```
In the JPChat iOS project, implement meetup coordination:

1. Create JPChatPackage/Sources/JPChatFeature/Models/Meetup.swift:
   - struct Meetup: Codable, Identifiable
   - Properties: id, name, location, coordinate, createdBy, participants, createdAt

2. Create JPChatPackage/Sources/JPChatFeature/Views/MeetupMapView.swift:
   - Full-screen map showing:
     - Meetup destination pin
     - All participants as moving dots with names
     - Each person's ETA label
   - Uses MapKit with custom annotations
   - Real-time updates via WebSocket

3. Create JPChatPackage/Sources/JPChatFeature/Views/CreateMeetupSheet.swift:
   - Search for location (MKLocalSearch)
   - Or drop pin on map
   - Name the meetup
   - Auto-share to current chat

4. Update ChatContainerView:
   - Add meetup button in toolbar
   - Show active meetup banner when one exists
   - Tap banner to open MeetupMapView

5. Add CarPlay support:
   - Show meetup destination in CarPlay maps
   - Voice: "Start navigation to meetup"

Test: Create meetup, see all participants on map with live ETAs.
```

---

## PHASE 10: Voice Reactions & Voice Notes
**Estimated Devin Sessions: 2**

### Task 10.1: Voice Reaction Detection
**Prompt for Devin:**
```
In the JPChat iOS project, implement voice reactions:

1. Create JPChatPackage/Sources/JPChatFeature/Services/VoiceReactionDetector.swift:
   - Keyword detection from SpeechRecognitionService transcription
   - Reaction mappings:
     "laugh" / "lol" / "haha" -> 😂
     "fire" / "lit" -> 🔥
     "love" / "heart" -> ❤️
     "wow" / "whoa" -> 😮
     "sad" / "crying" -> 😢
     "thumbs up" / "yes" / "agreed" -> 👍
     "thumbs down" / "no" / "disagree" -> 👎
     "clap" / "applause" -> 👏
   - Returns detected reaction or nil
   - Configurable: user can add custom mappings

2. Create JPChatPackage/Sources/JPChatFeature/Models/Reaction.swift:
   - struct Reaction: Codable
   - Properties: emoji, messageId, senderId, timestamp

3. Update ChatMessage model:
   - Add reactions: [Reaction] property

4. Update MessageBubbleView:
   - Show reaction pills below message
   - Animate reaction when added (scale bounce)
   - Long-press to see who reacted

5. Wire VoiceReactionDetector to ChatViewModel:
   - When reaction detected, send to last message in chat
   - Play haptic feedback
   - Show brief toast: "Sent 🔥"

Test: Say "fire" and see reaction appear on last message.
```

### Task 10.2: Voice Notes with Transcription
**Prompt for Devin:**
```
In the JPChat iOS project, implement voice notes:

1. Create JPChatPackage/Sources/JPChatFeature/Services/VoiceNoteRecorder.swift:
   - Uses AVAudioRecorder
   - Records to m4a format (AAC codec)
   - Max duration: 60 seconds
   - Properties:
     @Published var isRecording: Bool
     @Published var recordingDuration: TimeInterval
   - Methods: startRecording(), stopRecording() -> URL?
   - Handles audio session for recording

2. Create JPChatPackage/Sources/JPChatFeature/Models/VoiceNote.swift:
   - struct VoiceNote: Codable
   - Properties: id, audioURL, duration, transcription, senderId, timestamp

3. Create JPChatPackage/Sources/JPChatFeature/Views/VoiceNotePlayerView.swift:
   - Waveform visualization (simplified bars)
   - Play/pause button
   - Scrubber for seeking
   - Shows transcription text below (expandable)
   - Duration label

4. Update ChatInputView:
   - Hold microphone button for >0.5s to start voice note
   - Release to send
   - Swipe left while holding to cancel
   - Show recording indicator with duration

5. Update ChatMessage model:
   - Add optional voiceNote: VoiceNote? property

6. Auto-transcribe voice notes:
   - Use SpeechRecognitionService on the recorded audio
   - Attach transcription to VoiceNote before sending

Test: Record voice note, see waveform player with transcription in chat.
```

### Task 10.3: Voice Tone Analysis (Advanced)
**Prompt for Devin:**
```
In the JPChat iOS project, implement voice tone analysis:

1. Create JPChatPackage/Sources/JPChatFeature/Services/ToneAnalyzer.swift:
   - Analyze audio features using AVAudioEngine
   - Detect:
     - Pitch (high = excited, low = calm)
     - Volume (loud = energetic, soft = quiet)
     - Speed (fast = excited, slow = relaxed)
   - Return suggested mood: excited, calm, happy, serious, questioning
   - This is a simplified heuristic, not full ML

2. Create JPChatPackage/Sources/JPChatFeature/Models/MessageMood.swift:
   - enum MessageMood: String, Codable
   - Cases: excited, calm, happy, serious, questioning, neutral

3. Update VoiceNote model:
   - Add detectedMood: MessageMood? property

4. Create mood indicator UI:
   - Small colored dot on voice note bubble
   - Tooltip shows mood when tapped
   - Colors: excited=orange, calm=blue, happy=yellow, etc.

5. Auto-suggest reactions based on tone:
   - Excited tone -> suggest 🔥 or 🎉
   - Happy tone -> suggest 😊
   - Show suggestion chip that user can tap to send

Note: Keep tone analysis simple - use audio amplitude and speech rate.
Full emotion detection would require CoreML model.
```

---

## PHASE 11: Driving Context Awareness
**Estimated Devin Sessions: 2**

### Task 11.1: Motion & Activity Detection
**Prompt for Devin:**
```
In the JPChat iOS project, implement driving detection:

1. Create JPChatPackage/Sources/JPChatFeature/Services/MotionActivityService.swift:
   - Uses CMMotionActivityManager
   - Detect activity types: stationary, walking, running, automotive
   - Properties:
     @Published var currentActivity: CMMotionActivity?
     @Published var isDriving: Bool
     @Published var isStationary: Bool
   - Start/stop monitoring methods
   - Battery-efficient background monitoring

2. Create JPChatPackage/Sources/JPChatFeature/Services/DrivingContextManager.swift:
   - Combines MotionActivityService + LocationService
   - Detect driving states:
     - Starting to drive (was stationary, now automotive)
     - Stopped driving (was automotive, now stationary)
     - Highway driving (speed > 55 mph)
     - Traffic (automotive but low speed)
   - Properties:
     @Published var drivingState: DrivingState
   - enum DrivingState: stationary, city, highway, traffic, parked

3. Update Info.plist:
   - NSMotionUsageDescription

4. Add driving mode toggle in Settings:
   - Auto-enable features when driving detected
   - Manual override option

Test: App should detect when you start/stop driving.
```

### Task 11.2: Smart Audio Ducking
**Prompt for Devin:**
```
In the JPChat iOS project, implement smart audio ducking:

1. Update AudioManager.swift:
   - Add ducking support for navigation audio
   - Method: duckAudio(duration: TimeInterval)
   - Method: restoreAudio()
   - Smoothly lower volume to 20% then restore
   - Use AVAudioSession.interruptionNotification

2. Create JPChatPackage/Sources/JPChatFeature/Services/NavigationAudioDetector.swift:
   - Detect when navigation apps are speaking
   - Listen for AVAudioSession route changes
   - Monitor for "spoken audio" category activation
   - Notify AudioManager to duck

3. Implement speed-based volume:
   - Create VolumeProfile enum: city, highway, stationary
   - Adjust base volume based on DrivingContextManager.drivingState
   - City: 70%, Highway: 100%, Stationary: 50%
   - User can customize in Settings

4. Add settings:
   - Toggle: "Auto-duck for navigation"
   - Toggle: "Speed-based volume"
   - Sliders for each volume profile

Test: Play music, start Apple Maps navigation, volume should lower during voice guidance.
```

### Task 11.3: Smart Driving Notifications
**Prompt for Devin:**
```
In the JPChat iOS project, implement smart driving notifications:

1. Create JPChatPackage/Sources/JPChatFeature/Services/DrivingNotificationManager.swift:
   - When driving detected, switch to "driving mode":
     - Only speak high-priority messages
     - Batch low-priority: "You have 5 new messages"
     - Emergency keywords always read: "emergency", "urgent", "help", "accident"
   - Priority detection (simple keyword-based):
     - High: contains emergency words, from favorite contacts
     - Medium: direct mentions, replies to your messages
     - Low: everything else

2. Create JPChatPackage/Sources/JPChatFeature/Models/NotificationPriority.swift:
   - enum NotificationPriority: high, medium, low
   - Method to analyze message and return priority

3. Update CarPlayChatController:
   - Use DrivingNotificationManager for message filtering
   - Show badge count for unread low-priority
   - Immediate alerts for high-priority only

4. Add "Running Late" auto-detection:
   - If hard braking detected (accelerometer) + in traffic
   - Prompt: "Looks like traffic. Send 'Running late' to JP Chat?"
   - User confirms with "Yes" voice command
   - Uses CoreMotion for acceleration data

5. Add settings:
   - Toggle: "Smart notifications while driving"
   - Configure emergency contacts
   - Custom high-priority keywords

Test: While driving, low-priority messages batch; high-priority read immediately.
```

---

## PHASE 12: "Hey JP" Wake Word
**Estimated Devin Sessions: 2-3**

### Task 12.1: Wake Word Detection Setup
**Prompt for Devin:**
```
In the JPChat iOS project, implement wake word detection foundation:

1. Create JPChatPackage/Sources/JPChatFeature/Services/WakeWordDetector.swift:
   - Uses Speech framework with continuous listening
   - Listens for "Hey JP" or "Hey J P" variations
   - Low-power background listening mode
   - Properties:
     @Published var isListening: Bool
     @Published var isActivated: Bool (wake word detected)
   - Methods:
     startListening()
     stopListening()
     resetActivation()

2. Audio session configuration:
   - Use AVAudioSession category that allows background listening
   - Mix with other audio (don't interrupt music)
   - Handle audio interruptions gracefully

3. Wake word matching:
   - Fuzzy match for "Hey JP", "Hey J.P.", "Hey Jay Pee"
   - Ignore false positives (check confidence score)
   - Cooldown period after activation (5 seconds)

4. Add wake word toggle in Settings:
   - Enable/disable "Hey JP"
   - Sensitivity slider (strict/normal/sensitive)
   - Test button to verify detection

Note: This uses on-device Speech framework, not a custom ML model.
For production, consider using a dedicated wake word SDK like Picovoice Porcupine.
```

### Task 12.2: Voice Command System
**Prompt for Devin:**
```
In the JPChat iOS project, implement voice command processing:

1. Create JPChatPackage/Sources/JPChatFeature/Services/VoiceCommandRouter.swift:
   - Processes speech after wake word activation
   - Command registry with patterns and handlers
   - Commands to support:

   PLAYBACK:
   - "play" / "resume" -> AudioManager.play()
   - "pause" / "stop" -> AudioManager.pause()
   - "skip" / "next" -> AudioManager.skip()
   - "play [genre]" -> switch to genre stream
   - "favorite this" -> favorite current track
   - "what's playing" -> speak current track info

   CHAT:
   - "read messages" -> read last 3 messages
   - "read last message" -> read most recent
   - "send message [text]" -> send to current chat
   - "switch to JP chat" -> change chat mode
   - "switch to group chat" -> change chat mode

   NAVIGATION:
   - "share my location" -> start location sharing
   - "stop sharing" -> stop location sharing
   - "what's my ETA" -> speak current ETA

   SYSTEM:
   - "yes" / "confirm" -> confirm pending action
   - "no" / "cancel" -> cancel pending action
   - "never mind" -> deactivate without action

2. Create JPChatPackage/Sources/JPChatFeature/Models/VoiceCommand.swift:
   - struct VoiceCommand
   - Properties: pattern (regex), action, requiresConfirmation

3. Implement confirmation flow:
   - Some commands need "yes/no" confirmation
   - Timeout after 10 seconds -> cancel
   - Speak confirmation prompt

4. Add audio feedback:
   - Chime sound when wake word detected
   - Different sound for command success/failure
   - Use system sounds or custom audio files
```

### Task 12.3: CarPlay Wake Word Integration
**Prompt for Devin:**
```
In the JPChat iOS project, integrate wake word with CarPlay:

1. Update CarPlaySceneDelegate:
   - Start WakeWordDetector when CarPlay connects
   - Stop when CarPlay disconnects (optional based on settings)
   - Handle wake word activation in CarPlay context

2. Create JPChatPackage/Sources/JPChatFeature/CarPlay/CarPlayVoiceController.swift:
   - Manages voice interaction in CarPlay
   - Shows listening indicator in CarPlay UI
   - Displays recognized command text
   - Shows confirmation dialogs via CPAlertTemplate

3. Visual feedback in CarPlay:
   - When "Hey JP" detected, show brief overlay
   - Animated microphone icon while listening
   - Command text appears as recognized

4. Update Now Playing template:
   - Add voice command hint: "Say 'Hey JP' for voice control"
   - Show last command executed

5. Handle edge cases:
   - Wake word during phone call -> ignore
   - Wake word during Siri -> ignore
   - Music playing -> duck volume, listen, restore

6. Add settings:
   - "Hey JP in CarPlay only" option
   - "Hey JP always on" option
   - Disable when not driving option

Test: While in CarPlay, say "Hey JP, skip" and track should skip.
```

---

## PHASE 13: Car-to-Car & Convoy Mode
**Estimated Devin Sessions: 3**

### Task 13.1: Nearby User Discovery
**Prompt for Devin:**
```
In the JPChat iOS project, implement nearby user discovery:

1. Create JPChatPackage/Sources/JPChatFeature/Services/NearbyUsersService.swift:
   - Uses Multipeer Connectivity framework for local discovery
   - Fallback: server-based proximity using location + geohashing
   - Properties:
     @Published var nearbyUsers: [NearbyUser]
   - Range: within 500 meters
   - Update frequency: every 30 seconds

2. Create JPChatPackage/Sources/JPChatFeature/Models/NearbyUser.swift:
   - struct NearbyUser: Identifiable
   - Properties: userId, displayName, distance, direction, isInConvoy, currentStream

3. Server-side proximity (via WebSocket):
   - Send location updates to server
   - Server calculates nearby users with same geohash
   - Returns list of nearby app users
   - Privacy: only shows users who opted in

4. Create JPChatPackage/Sources/JPChatFeature/Views/NearbyUsersView.swift:
   - Radar-style visualization showing nearby users
   - Distance and direction indicators
   - Tap user to send convoy invite
   - Shows what they're listening to

5. Add settings:
   - Toggle: "Discoverable to nearby users"
   - Toggle: "Show what I'm listening to"

6. Update Info.plist:
   - NSLocalNetworkUsageDescription
   - NSBonjourServices for multipeer

Test: Two devices nearby should discover each other.
```

### Task 13.2: Convoy Mode Foundation
**Prompt for Devin:**
```
In the JPChat iOS project, implement convoy mode:

1. Create JPChatPackage/Sources/JPChatFeature/Models/Convoy.swift:
   - struct Convoy: Codable, Identifiable
   - Properties:
     id, name, hostUserId,
     participants: [ConvoyParticipant],
     sharedStreamId, chatEnabled,
     createdAt, isActive

2. Create JPChatPackage/Sources/JPChatFeature/Models/ConvoyParticipant.swift:
   - struct ConvoyParticipant: Codable
   - Properties: userId, displayName, location, isHost, joinedAt

3. Create JPChatPackage/Sources/JPChatFeature/Services/ConvoyManager.swift:
   - Manages convoy state
   - Methods:
     createConvoy(name: String) -> Convoy
     inviteToConvoy(userId: String)
     joinConvoy(convoyId: String)
     leaveConvoy()
     dissolveConvoy() // host only
   - Properties:
     @Published var activeConvoy: Convoy?
     @Published var pendingInvites: [ConvoyInvite]
   - WebSocket events for convoy updates

4. Create JPChatPackage/Sources/JPChatFeature/Views/ConvoyInviteSheet.swift:
   - Shows when invite received
   - Convoy name, host name, participant count
   - Accept / Decline buttons
   - Auto-dismiss after 30 seconds

5. Create JPChatPackage/Sources/JPChatFeature/Views/ActiveConvoyBanner.swift:
   - Persistent banner when in convoy
   - Shows participant count, convoy name
   - Tap to expand convoy details
   - Leave button

Test: Create convoy, invite nearby user, they can accept and join.
```

### Task 13.3: Synced Streaming & Convoy Chat
**Prompt for Devin:**
```
In the JPChat iOS project, implement synced streaming for convoy:

1. Create JPChatPackage/Sources/JPChatFeature/Services/SyncedPlaybackService.swift:
   - Synchronizes audio playback across convoy members
   - Host controls what plays
   - NTP-style time sync for accurate playback
   - Methods:
     syncToHost(timestamp: TimeInterval)
     broadcastPlaybackState()
   - Handle network latency (buffer adjustment)

2. Update AudioManager:
   - Add convoy mode flag
   - When in convoy, follow host's stream selection
   - Sync play/pause/skip with host
   - Local volume still independent

3. Create convoy chat channel:
   - Automatic private chat for convoy members
   - Messages only visible to convoy participants
   - Chat dissolves when convoy ends
   - Voice messages work in convoy chat

4. Create JPChatPackage/Sources/JPChatFeature/Views/ConvoyDashboardView.swift:
   - Full screen convoy management
   - Map showing all convoy cars
   - Shared stream controls (host only)
   - Convoy chat inline
   - Participant list with kick option (host)

5. CarPlay convoy integration:
   - Show convoy status in CarPlay
   - "You're in a convoy with 3 others"
   - Voice: "Hey JP, leave convoy"

6. Handle convoy edge cases:
   - Member goes out of range -> stays in convoy (uses server)
   - Host leaves -> promote next member or dissolve
   - Network issues -> local playback continues, resync when reconnected

Test: Two cars in convoy should hear same stream in sync.
```

---

## PHASE 14: Social Listening Features
**Estimated Devin Sessions: 2**

### Task 14.1: Listener Count & Presence
**Prompt for Devin:**
```
In the JPChat iOS project, implement social listening presence:

1. Create JPChatPackage/Sources/JPChatFeature/Services/ListenerPresenceService.swift:
   - Track which stream user is listening to
   - Send presence updates via WebSocket
   - Properties:
     @Published var currentStreamListeners: Int
     @Published var listenersByStream: [String: Int]
   - Update every 30 seconds

2. Update backend WebSocket to:
   - Track active listeners per stream
   - Broadcast listener counts
   - Handle user disconnect (remove from count)

3. Create JPChatPackage/Sources/JPChatFeature/Views/ListenerCountBadge.swift:
   - Shows "🎧 47 listening" badge
   - Animated when count changes
   - Tap to see listener breakdown

4. Update NowPlayingBar:
   - Show listener count for current stream
   - Pulse animation when someone joins

5. Update stream browser:
   - Show listener count on each stream card
   - Sort option: "Most Popular"
   - "Hot" badge for streams with 50+ listeners

6. Privacy considerations:
   - Users can opt-out of being counted
   - No individual names shown, just count

Test: Play a stream, see listener count, have another device join and see count update.
```

### Task 14.2: Live Reactions on Stream
**Prompt for Devin:**
```
In the JPChat iOS project, implement live stream reactions:

1. Create JPChatPackage/Sources/JPChatFeature/Models/StreamReaction.swift:
   - struct StreamReaction: Codable
   - Properties: emoji, userId, streamId, timestamp

2. Create JPChatPackage/Sources/JPChatFeature/Services/StreamReactionService.swift:
   - Send reactions via WebSocket
   - Receive reactions from other listeners
   - Rate limit: max 1 reaction per 2 seconds per user
   - Properties:
     @Published var recentReactions: [StreamReaction]

3. Create JPChatPackage/Sources/JPChatFeature/Views/FloatingReactionsView.swift:
   - Twitch/TikTok-style floating emoji
   - Emoji float up and fade out
   - Random horizontal positions
   - Stagger animations for multiple reactions
   - Use SwiftUI animations

4. Create JPChatPackage/Sources/JPChatFeature/Views/ReactionBar.swift:
   - Quick reaction buttons: 🔥 ❤️ 🎵 👏 🙌
   - Tap to send reaction
   - Shows your recent reaction briefly highlighted
   - Haptic feedback on send

5. Update FullPlayerView:
   - Add FloatingReactionsView overlay
   - Add ReactionBar at bottom
   - Show reaction surge indicator ("🔥 x23 in last minute")

6. CarPlay integration:
   - Voice: "Hey JP, send fire" sends 🔥 to stream
   - Show reaction count in CarPlay player

Test: Send reaction, see it float up, see reactions from other listeners.
```

### Task 14.3: Listener Activity Feed
**Prompt for Devin:**
```
In the JPChat iOS project, implement listener activity feed:

1. Create JPChatPackage/Sources/JPChatFeature/Models/ListenerActivity.swift:
   - struct ListenerActivity: Codable, Identifiable
   - Types: joined, left, reacted, favorited, shared
   - Properties: type, userId, userName, streamId, timestamp, details

2. Create JPChatPackage/Sources/JPChatFeature/Services/ActivityFeedService.swift:
   - Receives activity updates via WebSocket
   - Stores recent 100 activities
   - Filters by stream or global
   - Properties:
     @Published var activities: [ListenerActivity]

3. Create JPChatPackage/Sources/JPChatFeature/Views/ActivityFeedView.swift:
   - Scrollable list of recent activity
   - "John joined House stream"
   - "Sarah sent 🔥"
   - "Mike favorited this track"
   - Timestamp for each
   - Pull to refresh

4. Create JPChatPackage/Sources/JPChatFeature/Views/ActivityTickerView.swift:
   - Horizontal scrolling ticker
   - Shows latest activity one at a time
   - Auto-advances every 3 seconds
   - Compact for embedding in player

5. Add "Friends" filter:
   - Only show activity from people you follow
   - Follow/unfollow from activity feed
   - Mutual follows shown as "friend"

6. Privacy settings:
   - Toggle: "Show my activity to others"
   - Toggle: "Show activity feed"

Test: Activity feed shows when users join, react, and favorite.
```

---

## PHASE 15: AI Chat Assistant
**Estimated Devin Sessions: 2**

### Task 15.1: Chat Summarization
**Prompt for Devin:**
```
In the JPChat iOS project, implement AI chat summarization:

1. Create JPChatPackage/Sources/JPChatFeature/Services/ChatAIService.swift:
   - Integrates with OpenAI API (or Claude API)
   - Method: summarizeMessages(_ messages: [ChatMessage]) async -> String
   - Method: getSmartReply(context: [ChatMessage]) async -> [String]
   - Handle API errors gracefully
   - Cache summaries to reduce API calls

2. Create JPChatPackage/Sources/JPChatFeature/Models/ChatSummary.swift:
   - struct ChatSummary: Codable
   - Properties: chatId, summary, keyPoints, timestamp, messageRange

3. Create JPChatPackage/Sources/JPChatFeature/Views/ChatSummarySheet.swift:
   - "What did I miss?" button in chat
   - Shows AI-generated summary
   - Key points as bullet list
   - "Since you were last active" timeframe
   - Tap any point to jump to that message

4. Summarization triggers:
   - Manual: tap "Summarize" button
   - Auto: offer summary when >20 unread messages
   - Voice: "Hey JP, what did I miss?"

5. Add API key configuration:
   - Store in Keychain
   - Settings screen to enter key
   - Or use backend proxy to hide key

6. Privacy note:
   - Show disclaimer that messages sent to AI
   - Option to disable AI features

Test: Accumulate 20+ messages, request summary, get coherent summary.
```

### Task 15.2: Smart Replies
**Prompt for Devin:**
```
In the JPChat iOS project, implement smart reply suggestions:

1. Update ChatAIService:
   - getSmartReply returns 3 contextual suggestions
   - Based on last 5 messages of conversation
   - Quick, casual responses appropriate for chat

2. Create JPChatPackage/Sources/JPChatFeature/Views/SmartReplyBar.swift:
   - Horizontal row of 3 suggestion chips
   - Shows above keyboard when active
   - Tap chip to send immediately
   - Swipe to dismiss
   - Regenerate button for new suggestions

3. Smart reply triggers:
   - Show after receiving a message (with delay)
   - Show when user focuses input field
   - Don't show if user is already typing

4. Context awareness:
   - Different tone for JP Chat vs Group Chat
   - Detect questions and suggest answers
   - Detect greetings and suggest greetings
   - Use recent conversation context

5. Quick actions in suggestions:
   - "[Share Location]" -> shares location
   - "[Send Voice Note]" -> opens voice recorder
   - "[React 🔥]" -> sends reaction

6. Caching and offline:
   - Cache recent suggestions
   - Fallback to generic replies if offline

Test: Receive question message, see relevant answer suggestions appear.
```

### Task 15.3: AI Voice Assistant Integration
**Prompt for Devin:**
```
In the JPChat iOS project, integrate AI with voice commands:

1. Update VoiceCommandRouter:
   - Add AI query commands:
     "Hey JP, summarize chat" -> triggers summarization
     "Hey JP, what should I reply?" -> speaks smart reply options
     "Hey JP, [any question]" -> routes to ChatAIService

2. Create JPChatPackage/Sources/JPChatFeature/Services/VoiceAIAssistant.swift:
   - Handles open-ended voice queries
   - Method: processQuery(_ query: String) async -> String
   - Speaks response using AVSpeechSynthesizer
   - Context-aware (knows current stream, chat, etc.)

3. Example interactions:
   - "Hey JP, who's in the group chat?" -> lists active members
   - "Hey JP, what's trending?" -> describes popular streams
   - "Hey JP, any important messages?" -> summarizes high-priority
   - "Hey JP, tell me about this DJ" -> info about current stream

4. Voice response:
   - Use natural TTS voice (AVSpeechSynthesizer)
   - Keep responses brief for driving
   - Option to see full response on screen

5. CarPlay integration:
   - AI responses shown as CPAlertTemplate
   - Speak response, then auto-dismiss
   - "Would you like me to read more?"

6. Rate limiting:
   - Max 10 AI queries per hour
   - Show usage in settings
   - Premium tier for unlimited

Test: Ask "Hey JP, summarize the chat" and hear spoken summary.
```

---

## PHASE 16: Apple Watch Companion
**Estimated Devin Sessions: 2**

### Task 16.1: Watch App Foundation
**Prompt for Devin:**
```
In the JPChat Xcode project, add Apple Watch app:

1. Add new target: "JPChat Watch App" (watchOS 10+)
   - Use SwiftUI for Watch
   - Enable App Groups (shared with iOS app)

2. Create Watch/ContentView.swift:
   - Tab-based interface:
     - Now Playing tab
     - Chat tab
     - Settings tab
   - Use NavigationStack

3. Create Watch/NowPlayingWatchView.swift:
   - Current stream name and artwork (small)
   - Play/Pause button (large, centered)
   - Skip button
   - Volume control via Digital Crown
   - Uses WatchConnectivity to control iOS app

4. Create Watch/Services/WatchConnectivityService.swift:
   - WCSession setup
   - Send commands to iOS: play, pause, skip, setVolume
   - Receive state updates: currentStream, isPlaying, unreadCount
   - Handle background updates

5. Create iOS/Services/WatchSyncService.swift:
   - Counterpart on iOS side
   - Receives commands from Watch
   - Sends state updates to Watch
   - Sync on app launch and state changes

6. Test basic connectivity:
   - Pause on Watch -> iOS app pauses
   - Change stream on iOS -> Watch updates

Note: Audio plays from iPhone, Watch is remote control only.
```

### Task 16.2: Watch Chat & Notifications
**Prompt for Devin:**
```
In the JPChat Watch app, implement chat features:

1. Create Watch/ChatWatchView.swift:
   - List of recent messages (last 10)
   - Sender name and message preview
   - Timestamp
   - Tap message to see full text

2. Create Watch/QuickReplyView.swift:
   - Preset replies: "👍", "On my way", "OK", "Call me"
   - Dictation button for voice input
   - Scribble input option
   - Send via WatchConnectivity

3. Create Watch/MessageDetailView.swift:
   - Full message text
   - Reply button
   - React button (emoji picker)

4. Notifications on Watch:
   - Configure notification categories
   - Show message preview
   - Quick reply from notification
   - Haptic for new messages

5. Complications:
   - Create JPChatComplications.swift
   - Circular: unread message count
   - Rectangular: now playing + unread count
   - Corner: just unread count badge
   - Update via WatchConnectivity

6. Update iOS app:
   - Send notification data to Watch
   - Handle replies from Watch
   - Update complications when state changes

Test: Receive message on Watch, reply with preset, see in iOS chat.
```

---

## PHASE 17: Shortcuts & Automations
**Estimated Devin Sessions: 2**

### Task 17.1: Siri Shortcuts Integration
**Prompt for Devin:**
```
In the JPChat iOS project, implement Siri Shortcuts:

1. Create JPChatPackage/Sources/JPChatFeature/Intents/PlayStreamIntent.swift:
   - AppIntent for playing a specific stream
   - Parameters: streamName (genre)
   - "Play House on JPChat"

2. Create JPChatPackage/Sources/JPChatFeature/Intents/SendMessageIntent.swift:
   - AppIntent for sending a message
   - Parameters: message, chatType (JP/Group)
   - "Send 'On my way' to JP Chat"

3. Create JPChatPackage/Sources/JPChatFeature/Intents/ShareLocationIntent.swift:
   - AppIntent to start/stop location sharing
   - "Start sharing my location on JPChat"

4. Create JPChatPackage/Sources/JPChatFeature/Intents/GetStatusIntent.swift:
   - AppIntent to get current status
   - Returns: current stream, unread count
   - "What's playing on JPChat?"

5. Create App Shortcuts provider:
   - AppShortcutsProvider with suggested shortcuts
   - Phrases for each intent
   - Show in Shortcuts app

6. Donate intents:
   - Donate when user performs actions
   - Improves Siri suggestions

7. Add Siri tip banners:
   - Show "Add to Siri" prompts contextually
   - After playing stream: "Add 'Play House' to Siri?"

Test: "Hey Siri, play House on JPChat" starts House stream.
```

### Task 17.2: Automation Triggers
**Prompt for Devin:**
```
In the JPChat iOS project, implement automation support:

1. Create JPChatPackage/Sources/JPChatFeature/Intents/CarPlayConnectedIntent.swift:
   - Donates when CarPlay connects
   - Can trigger Shortcuts automation
   - "When CarPlay connects..."

2. Create JPChatPackage/Sources/JPChatFeature/Intents/ArrivedIntent.swift:
   - Donates when user arrives at destination
   - Uses geofencing from LocationService
   - "When I arrive at Work..."

3. Create JPChatPackage/Sources/JPChatFeature/Intents/ConvoyIntent.swift:
   - Intent to create/join convoy
   - "Create a convoy called 'Road Trip'"

4. Create automation presets in app:
   - JPChatPackage/Sources/JPChatFeature/Views/AutomationPresetsView.swift:
   - Suggested automations:
     - "When CarPlay connects, play my last stream"
     - "When I arrive home, send 'Home safe' to JP Chat"
     - "Every weekday at 8am, start Techno stream"
   - One-tap setup via Shortcuts app

5. Widget with automation status:
   - Show active automations
   - Quick toggle to disable

6. Background execution:
   - Ensure intents can run in background
   - Handle audio session properly

Test: Set up "CarPlay connects" automation, connect CarPlay, stream auto-plays.
```

---

## PHASE 18: Themes & Visual Polish
**Estimated Devin Sessions: 2**

### Task 18.1: Dynamic Themes
**Prompt for Devin:**
```
In the JPChat iOS project, implement dynamic theming:

1. Create JPChatPackage/Sources/JPChatFeature/Theme/ThemeManager.swift:
   - Singleton managing app theme
   - Properties:
     @Published var currentTheme: AppTheme
     @Published var useSystemAppearance: Bool
   - Auto-switch based on time of day (optional)

2. Create JPChatPackage/Sources/JPChatFeature/Theme/AppTheme.swift:
   - struct AppTheme
   - Properties:
     name, primaryColor, secondaryColor,
     backgroundColor, surfaceColor,
     textColor, accentColor,
     gradientColors: [Color]
   - Predefined themes:
     - Default (purple/blue)
     - Midnight (dark purple/black)
     - Sunset (orange/pink)
     - Ocean (blue/teal)
     - Forest (green/brown)
     - Neon (pink/cyan)

3. Create JPChatPackage/Sources/JPChatFeature/Theme/ThemedComponents.swift:
   - ThemedButton, ThemedCard, ThemedText
   - Automatically use ThemeManager colors
   - Support for gradients

4. Create JPChatPackage/Sources/JPChatFeature/Views/ThemePickerView.swift:
   - Visual theme selector
   - Preview each theme
   - Custom theme creator (pick your colors)

5. Apply theme throughout app:
   - Update all views to use themed components
   - Chat bubbles, buttons, backgrounds
   - Navigation bars, tab bars

6. Add settings:
   - Theme picker
   - "Match music energy" toggle (future feature)
   - Schedule: light during day, dark at night

Test: Change theme, see entire app update colors.
```

### Task 18.2: Audio Visualizer
**Prompt for Devin:**
```
In the JPChat iOS project, implement audio visualizer:

1. Create JPChatPackage/Sources/JPChatFeature/Visualizer/AudioAnalyzer.swift:
   - Uses AVAudioEngine to tap audio
   - FFT analysis for frequency bands
   - Properties:
     @Published var frequencyBands: [Float] (e.g., 32 bands)
     @Published var amplitude: Float
   - Update at 30fps

2. Create JPChatPackage/Sources/JPChatFeature/Visualizer/BarVisualizerView.swift:
   - Classic equalizer bars
   - Bars react to frequency bands
   - Smooth animations
   - Configurable bar count, colors, spacing

3. Create JPChatPackage/Sources/JPChatFeature/Visualizer/WaveVisualizerView.swift:
   - Smooth waveform visualization
   - Sine wave that reacts to audio
   - Gradient coloring

4. Create JPChatPackage/Sources/JPChatFeature/Visualizer/CircleVisualizerView.swift:
   - Circular visualization around artwork
   - Pulses with beat
   - Radiating rings

5. Update FullPlayerView:
   - Visualizer behind/around album art
   - Setting to choose visualizer style
   - Toggle visualizer on/off

6. Performance optimization:
   - Use Metal/Core Animation for smooth rendering
   - Reduce update rate when app backgrounded
   - Battery-conscious mode

Test: Play stream, see visualizer react to music in real-time.
```

### Task 18.3: Achievements & Gamification
**Prompt for Devin:**
```
In the JPChat iOS project, implement achievements:

1. Create JPChatPackage/Sources/JPChatFeature/Models/Achievement.swift:
   - struct Achievement: Codable, Identifiable
   - Properties: id, name, description, icon, unlockedAt, progress, target
   - Categories: listening, social, exploration

2. Create JPChatPackage/Sources/JPChatFeature/Services/AchievementService.swift:
   - Tracks progress toward achievements
   - Stores in UserDefaults/CloudKit
   - Properties:
     @Published var unlockedAchievements: [Achievement]
     @Published var inProgressAchievements: [Achievement]

   Achievements:
   LISTENING:
   - "First Listen" - play your first stream
   - "Night Owl" - listen past midnight
   - "Early Bird" - listen before 6am
   - "Marathon" - 10 hours total listening
   - "Genre Explorer" - listen to all 16 genres
   - "Dedicated Fan" - 100 hours total

   SOCIAL:
   - "Conversation Starter" - send first message
   - "Social Butterfly" - 100 messages sent
   - "Reactor" - send 50 reactions
   - "Voice Actor" - send 10 voice notes
   - "Road Trip" - join a convoy

   FEATURES:
   - "Bookmark Collector" - 10 favorites
   - "Voice Commander" - use 10 voice commands
   - "Automator" - set up a Shortcut

3. Create JPChatPackage/Sources/JPChatFeature/Views/AchievementsView.swift:
   - Grid of achievement badges
   - Locked achievements show silhouette
   - Progress bars for in-progress
   - Tap for details

4. Achievement unlock notification:
   - In-app toast when achievement unlocked
   - Confetti animation
   - Share to social media option

5. Profile badge display:
   - Show top 3 achievements on profile
   - Total achievement count

Test: Complete listening achievement, see unlock animation.
```

---

## Summary: Advanced Features Task Order

**Location & Social (Phase 9-10):**
1. Task 9.1 - Location Service
2. Task 9.2 - ETA Sharing
3. Task 9.3 - Meetup Coordination
4. Task 10.1 - Voice Reactions
5. Task 10.2 - Voice Notes
6. Task 10.3 - Tone Analysis

**Driving Intelligence (Phase 11-12):**
7. Task 11.1 - Motion Detection
8. Task 11.2 - Audio Ducking
9. Task 11.3 - Smart Notifications
10. Task 12.1 - Wake Word Detection
11. Task 12.2 - Voice Commands
12. Task 12.3 - CarPlay Voice

**Social Features (Phase 13-14):**
13. Task 13.1 - Nearby Discovery
14. Task 13.2 - Convoy Mode
15. Task 13.3 - Synced Streaming
16. Task 14.1 - Listener Presence
17. Task 14.2 - Stream Reactions
18. Task 14.3 - Activity Feed

**AI & Intelligence (Phase 15):**
19. Task 15.1 - Chat Summarization
20. Task 15.2 - Smart Replies
21. Task 15.3 - Voice AI Assistant

**Platform Extensions (Phase 16-17):**
22. Task 16.1 - Watch App
23. Task 16.2 - Watch Chat
24. Task 17.1 - Siri Shortcuts
25. Task 17.2 - Automations

**Polish & Delight (Phase 18):**
26. Task 18.1 - Dynamic Themes
27. Task 18.2 - Audio Visualizer
28. Task 18.3 - Achievements

---

## Priority Recommendations

**Must-Have (Ship with v1.5):**
- Voice Reactions (10.1)
- Wake Word "Hey JP" (12.1-12.3)
- Siri Shortcuts (17.1)
- Dynamic Themes (18.1)

**High-Value (v2.0):**
- ETA Sharing (9.2)
- Convoy Mode (13.1-13.3)
- AI Summarization (15.1)
- Apple Watch (16.1-16.2)

**Differentiators (v2.5):**
- Smart Driving Notifications (11.3)
- Live Stream Reactions (14.2)
- Audio Visualizer (18.2)
- Achievements (18.3)

---

## Notes for Devin Sessions

- Each task is designed to be completable in 1-2 Devin sessions
- Test thoroughly before moving to next task
- Some tasks have dependencies (noted in descriptions)
- Backend changes may be needed for social features
- Always handle errors and edge cases gracefully
